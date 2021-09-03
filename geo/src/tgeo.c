/*****************************************************************************
 *
 * tgeo.c
 *    Basic functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "tgeo.h"

#include <utils/builtins.h>
#include <utils/timestamp.h>
#include <math.h>
#include <float.h>

#include "temporaltypes.h"
#include "tempcache.h"
#include "temporal_util.h"
#include "timeops.h"
#include "tgeo_parser.h"
#include "tpoint_spatialfuncs.h"
#include "tgeo_spatialfuncs.h"
#include "tgeo_transform.h"
#include "rtransform.h"
#include "quaternion.h"

/*****************************************************************************
 * Input function
 *****************************************************************************/

PG_FUNCTION_INFO_V1(tgeo_in);

PGDLLEXPORT Datum
tgeo_in(PG_FUNCTION_ARGS)
{
  char *input = PG_GETARG_CSTRING(0);
  Oid temptypid = PG_GETARG_OID(1);
  Oid basetypid = temporal_basetypid(temptypid);
  Temporal *result = tgeo_parse(&input, basetypid);
  PG_RETURN_POINTER(result);
}

/*****************************************************************************
 * Constructor function
 *****************************************************************************/

/* Construct a temporal instant geometry from two arguments */

PG_FUNCTION_INFO_V1(tgeoinst_constructor);

PGDLLEXPORT Datum
tgeoinst_constructor(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  ensure_geo_type(gs);
  ensure_non_empty(gs);
  ensure_has_not_M_gs(gs);
  Pose *p = PG_GETARG_POSE(1);
  /* Check that dimension of pose and geom correspond */
  TimestampTz t = PG_GETARG_TIMESTAMPTZ(2);
  Oid basetypid = get_fn_expr_argtype(fcinfo->flinfo, 0);
  Temporal *result = (Temporal *)tgeoinst_make(PointerGetDatum(gs),
    PoseGetDatum(p), t, basetypid);
  PG_FREE_IF_COPY(gs, 0);
  PG_RETURN_POINTER(result);
}

/**
 * Construct a temporal instant value from the arguments
 *
 * The memory structure of a temporal instant value is as follows
 * @code
 * ----------------------------------
 * ( TInstant )_X | ( Value )_X |
 * ----------------------------------
 * @endcode
 * where the `_X` are unused bytes added for double padding.
 *
 * @param value Base value
 * @param t Timestamp
 * @param basetypid Oid of the base type
 */
TInstant *
tgeoinst_make(Datum geom, Datum value, TimestampTz t, Oid basetypid)
{
  size_t value_offset = double_pad(sizeof(TInstant));
  size_t size = value_offset;
  /* Create the temporal value */
  TInstant *result;
  size_t value_size;
  void *value_from;
  /* Copy value */
  bool typbyval = base_type_byvalue(basetypid);
  if (typbyval)
  {
    /* For base types passed by value */
    value_size = double_pad(sizeof(Datum));
    value_from = &value;
  }
  else
  {
    /* For base types passed by reference */
    value_from = DatumGetPointer(value);
    int16 typlen = base_type_length(basetypid);
    value_size = (typlen != -1) ? double_pad((unsigned int) typlen) :
      double_pad(VARSIZE(value_from));
  }
  size += value_size;
  result = palloc0(size);
  void *value_to = ((char *) result) + value_offset;
  memcpy(value_to, value_from, value_size);
  /* Initialize fixed-size values */
  result->subtype = INSTANT;
  result->basetypid = basetypid;
  result->t = t;
  SET_VARSIZE(result, size);
  MOBDB_FLAGS_SET_BYVAL(result->flags, typbyval);
  bool continuous = base_type_continuous(basetypid);
  MOBDB_FLAGS_SET_CONTINUOUS(result->flags, continuous);
  MOBDB_FLAGS_SET_LINEAR(result->flags, continuous);
  MOBDB_FLAGS_SET_X(result->flags, true);
  MOBDB_FLAGS_SET_T(result->flags, true);
  if (tgeo_base_type(basetypid))
  {
    GSERIALIZED *gs = (GSERIALIZED *) PG_DETOAST_DATUM(value);
    MOBDB_FLAGS_SET_Z(result->flags, FLAGS_GET_Z(gs->flags));
    MOBDB_FLAGS_SET_GEODETIC(result->flags, FLAGS_GET_GEODETIC(gs->flags));
    POSTGIS_FREE_IF_COPY_P(gs, DatumGetPointer(value));
  }
  return result;
}

/*****************************************************************************
 * Rotation at timestamp functions
 *****************************************************************************/

static bool
tgeoinst_rtransform_at_timestamp(const TInstant *inst, TimestampTz t, Oid basetypid, Datum *result)
{
  if (t != inst->t)
    return false;
  *result = rtransform_zero_datum(basetypid);
  return true;
}

static bool
tgeoi_rtransform_at_timestamp(const TInstantSet *ti, TimestampTz t, Oid basetypid, Datum *result)
{
  int loc;
  if (! tinstantset_find_timestamp(ti, t, &loc))
    return false;

  if (loc == 0)
    *result = rtransform_zero_datum(basetypid);
  else
    *result = tinstant_value_copy(tinstantset_inst_n(ti, loc));
  return true;
}

static bool
tgeoseq_rtransform_at_timestamp(const TSequence *seq, TimestampTz t, Oid basetypid, Datum *result)
{
  /* Bounding box test */
  if (!contains_period_timestamp_internal(&seq->period, t))
    return false;

  /* Instantaneous sequence */
  if (seq->count == 1)
  {
    *result = rtransform_zero_datum(basetypid);
    return true;
  }

  /* General case */
  int n = tsequence_find_timestamp(seq, t);
  TInstant *inst1 = tsequence_inst_n(seq, n);
  TInstant *inst2 = tsequence_inst_n(seq, n + 1);
  if (n == 0)
    inst1 = tgeoinst_rtransform_zero(inst1->t, inst2->basetypid);
  *result = tsequence_value_at_timestamp1(inst1, inst2, MOBDB_FLAGS_GET_LINEAR(seq->flags), t);
  return true;
}

static bool
tgeos_rtransform_at_timestamp(const TSequenceSet *ts, TimestampTz t, Oid basetypid, Datum *result)
{
  /* Singleton sequence set */
  if (ts->count == 1)
    return tgeoseq_rtransform_at_timestamp(tsequenceset_seq_n(ts, 0), t, basetypid, result);

  /* General case */
  int loc;
  if (!tsequenceset_find_timestamp(ts, t, &loc))
    return false;
  return tgeoseq_rtransform_at_timestamp(tsequenceset_seq_n(ts, loc), t, basetypid, result);
}

static bool
tgeo_rtransform_at_timestamp(const Temporal *temp, TimestampTz t, Datum *value)
{
  bool result;
  Oid basetypid = MOBDB_FLAGS_GET_Z(temp->flags) ?
    type_oid(T_RTRANSFORM3D) : type_oid(T_RTRANSFORM2D);
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT)
    result = tgeoinst_rtransform_at_timestamp((TInstant *)temp, t, basetypid, value);
  else if (temp->subtype == INSTANTSET)
    result = tgeoi_rtransform_at_timestamp((TInstantSet *)temp, t, basetypid, value);
  else if (temp->subtype == SEQUENCE)
    result = tgeoseq_rtransform_at_timestamp((TSequence *)temp, t, basetypid, value);
  else /* temp->subtype == SEQUENCESET */
    result = tgeos_rtransform_at_timestamp((TSequenceSet *)temp, t, basetypid, value);
  return result;
}

PG_FUNCTION_INFO_V1(tgeo_angle_at_timestamp);

PGDLLEXPORT Datum
tgeo_angle_at_timestamp(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL(0);
  if (MOBDB_FLAGS_GET_Z(temp->flags))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Cannot compute the rotation angle of a 3D geometry")));
  TimestampTz t = PG_GETARG_TIMESTAMPTZ(1);
  double initial_rotation = PG_GETARG_FLOAT8(2);
  if (initial_rotation <= -M_PI || initial_rotation > M_PI)
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("The initial rotation angle must be in ]-pi, pi]")));
  Datum rt_datum;
  bool found = tgeo_rtransform_at_timestamp(temp, t, &rt_datum);
  PG_FREE_IF_COPY(temp, 0);
  if (!found)
    PG_RETURN_NULL();
  RTransform2D *rt = DatumGetRTransform2D(rt_datum);
  double rotation = rt->theta;
  double result = initial_rotation + rotation;
  if (result <= -M_PI)
    result += 2*M_PI;
  else if (result > M_PI)
    result -= 2*M_PI;
  pfree(rt);
  PG_RETURN_FLOAT8(result);
}

PG_FUNCTION_INFO_V1(tgeo_quaternion_at_timestamp);

PGDLLEXPORT Datum
tgeo_quaternion_at_timestamp(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL(0);
  if (!MOBDB_FLAGS_GET_Z(temp->flags))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Cannot compute the rotation quaternion of a 2D geometry")));
  TimestampTz t = PG_GETARG_TIMESTAMPTZ(1);
  double W = PG_GETARG_FLOAT8(2);
  double X = PG_GETARG_FLOAT8(3);
  double Y = PG_GETARG_FLOAT8(4);
  double Z = PG_GETARG_FLOAT8(5);
  Quaternion initial_quat = (Quaternion) {W, X, Y, Z};
  if (fabs(quaternion_norm(initial_quat) - 1) > EPSILON)
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("The initial rotation quaternion must be of unit norm")));
  Datum rt_datum;
  bool found = tgeo_rtransform_at_timestamp(temp, t, &rt_datum);
  PG_FREE_IF_COPY(temp, 0);
  if (!found)
    PG_RETURN_NULL();
  RTransform3D *rt = DatumGetRTransform3D(rt_datum);
  Quaternion quat = rt->quat;
  Quaternion result_quat = quaternion_multiply(initial_quat, quat);
  pfree(rt);

  Datum *vals = (Datum*) palloc(sizeof(Datum) * 4);
  ArrayType* result;
  vals[0] = Float8GetDatum(result_quat.W);
  vals[1] = Float8GetDatum(result_quat.X);
  vals[2] = Float8GetDatum(result_quat.Y);
  vals[3] = Float8GetDatum(result_quat.Z);
  result = construct_array(vals, 4, FLOAT8OID, sizeof(double), true, 'd');
  PG_RETURN_ARRAYTYPE_P(result);
}

/*****************************************************************************/
