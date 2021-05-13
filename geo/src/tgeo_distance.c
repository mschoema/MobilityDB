/***********************************************************************
 *
 * tgeo_distance.c
 *    Distance functions for temporal geometries.
 *
 * Portions Copyright (c) 2020, Esteban Zimanyi, Arthur Lesuisse,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2020, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "tgeo_distance.h"

#include <liblwgeom.h>
#include <utils/builtins.h>

#include "postgis.h"
#include "lifting.h"
#include "temporal.h"
#include "temporaltypes.h"
#include "tpoint_spatialfuncs.h"
#include "tgeo_spatialfuncs.h"

/*****************************************************************************
 * Temporal distance
 *****************************************************************************/

/**
 * Returns the temporal distance between the temporal sequence geometry and
 * the geometry point/polygon
 *
 * @param[in] seq Temporal point
 * @param[in] geo Point/Polygon
 * @param[in] func Distance function
 */
static TSequence *
distance_tgeoseq_geo(const TSequence *seq, Datum geo)
{
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("function distance_tgeoseq_geo not implemented")));
  return NULL;
}

/**
 * Returns the temporal distance between the temporal sequence set geometry and
 * the geometry point/polygon
 *
 * @param[in] ts Temporal point
 * @param[in] geo Point/Polygon
 * @param[in] func Distance function
 */
static TSequenceSet *
distance_tgeoseqset_geo(const TSequenceSet *ts, Datum geo)
{
  TSequence **sequences = palloc(sizeof(TSequence *) * ts->count);
  for (int i = 0; i < ts->count; i++)
  {
    const TSequence *seq = tsequenceset_seq_n(ts, i);
    sequences[i] = distance_tgeoseq_geo(seq, geo);
  }
  return tsequenceset_make_free(sequences, ts->count, NORMALIZE);
}

/*****************************************************************************/

/**
 * Returns the temporal distance between the temporal point and the
 * geometry/geography point (distpatch function)
 */
Temporal *
distance_tgeo_geo_internal(const Temporal *temp, Datum geo)
{
  LiftedFunctionInfo lfinfo;
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT || temp->subtype == INSTANTSET)
  {
    lfinfo.func = (varfunc) get_distance_fn(temp->flags);
    lfinfo.numparam = 2;
    lfinfo.restypid = FLOAT8OID;
    lfinfo.reslinear = MOBDB_FLAGS_GET_LINEAR(temp->flags);
    lfinfo.invert = INVERT_NO;
    lfinfo.discont = CONTINUOUS;
    lfinfo.tpfunc = NULL;
  }
  Temporal *result;
  if (temp->subtype == INSTANT)
    result = (Temporal *)tfunc_tinstant_base((TInstant *)temp, geo,
      temp->basetypid, (Datum) NULL, lfinfo);
  else if (temp->subtype == INSTANTSET)
    result = (Temporal *)tfunc_tinstantset_base((TInstantSet *)temp, geo,
      temp->basetypid, (Datum) NULL, lfinfo);
  else if (temp->subtype == SEQUENCE)
    result = (Temporal *)distance_tgeoseq_geo((TSequence *)temp, geo);
  else /* temp->subtype == SEQUENCESET */
    result = (Temporal *)distance_tgeoseqset_geo((TSequenceSet *)temp, geo);
  return result;
}

PG_FUNCTION_INFO_V1(distance_geo_tgeo);
/**
 * Returns the temporal distance between the geometry point/polygon
 * and the temporal geometry
 */
PGDLLEXPORT Datum
distance_geo_tgeo(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL(1);
  // ensure_point_type(gs);
  ensure_same_srid_tpoint_gs(temp, gs);
  ensure_same_dimensionality_tpoint_gs(temp, gs);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *result = distance_tgeo_geo_internal(temp, PointerGetDatum(gs));
  PG_FREE_IF_COPY(gs, 0);
  PG_FREE_IF_COPY(temp, 1);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(distance_tgeo_geo);
/**
 * Returns the temporal distance between the temporal geometry and the
 * geometry point/polygon
 */
PGDLLEXPORT Datum
distance_tgeo_geo(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(1);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL(0);
  // ensure_point_type(gs);
  ensure_same_srid_tpoint_gs(temp, gs);
  ensure_same_dimensionality_tpoint_gs(temp, gs);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *result = distance_tgeo_geo_internal(temp, PointerGetDatum(gs));
  PG_FREE_IF_COPY(temp, 0);
  PG_FREE_IF_COPY(gs, 1);
  PG_RETURN_POINTER(result);
}

/*****************************************************************************/

/**
 * Returns the temporal distance between the temporal geometry and the temporal point
 */
Temporal *
distance_tgeo_tpoint_internal(const Temporal *temp1, const Temporal *temp2)
{
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("function distance_tgeo_tpoint_internal not implemented")));
  return NULL;
}

PG_FUNCTION_INFO_V1(distance_tpoint_tgeo);
/**
 * Returns the temporal distance between the temporal point and the temporal geometry
 */
PGDLLEXPORT Datum
distance_tpoint_tgeo(PG_FUNCTION_ARGS)
{
  Temporal *temp1 = PG_GETARG_TEMPORAL(0);
  Temporal *temp2 = PG_GETARG_TEMPORAL(1);
  ensure_same_srid_tpoint(temp1, temp2);
  ensure_same_dimensionality(temp1->flags, temp2->flags);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *result = distance_tgeo_tpoint_internal(temp2, temp1);
  PG_FREE_IF_COPY(temp1, 0);
  PG_FREE_IF_COPY(temp2, 1);
  if (result == NULL)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(distance_tgeo_tpoint);
/**
 * Returns the temporal distance between the temporal geometry and the temporal point
 */
PGDLLEXPORT Datum
distance_tgeo_tpoint(PG_FUNCTION_ARGS)
{
  Temporal *temp1 = PG_GETARG_TEMPORAL(0);
  Temporal *temp2 = PG_GETARG_TEMPORAL(1);
  ensure_same_srid_tpoint(temp1, temp2);
  ensure_same_dimensionality(temp1->flags, temp2->flags);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *result = distance_tgeo_tpoint_internal(temp1, temp2);
  PG_FREE_IF_COPY(temp1, 0);
  PG_FREE_IF_COPY(temp2, 1);
  if (result == NULL)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

/*****************************************************************************/

/**
 * Returns the temporal distance between the two temporal geometries
 */
Temporal *
distance_tgeo_tgeo_internal(const Temporal *temp1, const Temporal *temp2)
{
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("function distance_tgeo_tgeo_internal not implemented")));
  return NULL;
}

PG_FUNCTION_INFO_V1(distance_tgeo_tgeo);
/**
 * Returns the temporal distance between the two temporal geometries
 */
PGDLLEXPORT Datum
distance_tgeo_tgeo(PG_FUNCTION_ARGS)
{
  Temporal *temp1 = PG_GETARG_TEMPORAL(0);
  Temporal *temp2 = PG_GETARG_TEMPORAL(1);
  ensure_same_srid_tpoint(temp1, temp2);
  ensure_same_dimensionality(temp1->flags, temp2->flags);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *result = distance_tgeo_tgeo_internal(temp1, temp2);
  PG_FREE_IF_COPY(temp1, 0);
  PG_FREE_IF_COPY(temp2, 1);
  if (result == NULL)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

/*****************************************************************************
 * Nearest approach distance
 *****************************************************************************/

/**
 * Returns the nearest approach distance between the temporal geometry and the
 * static geometry (internal function)
 */
static Datum
NAD_tgeo_geo_internal(FunctionCallInfo fcinfo, Temporal *temp,
  GSERIALIZED *gs)
{
  ensure_same_srid_tpoint_gs(temp, gs);
  ensure_same_dimensionality_tpoint_gs(temp, gs);
  if (MOBDB_FLAGS_GET_Z(temp->flags))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Cannot compute the NAD of a 3D geometry")));
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Datum trav_area = tgeo_traversed_area_internal(temp);
  Datum result = geom_distance2d(trav_area, PointerGetDatum(gs));
  pfree(DatumGetPointer(trav_area));
  return result;
}

PG_FUNCTION_INFO_V1(NAD_geo_tgeo);
/**
 * Returns the nearest approach distance between the static geometry and
 * the temporal geometry
 */
PGDLLEXPORT Datum
NAD_geo_tgeo(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL(1);
  Datum result = NAD_tgeo_geo_internal(fcinfo, temp, gs);
  PG_FREE_IF_COPY(gs, 0);
  PG_FREE_IF_COPY(temp, 1);
  PG_RETURN_DATUM(result);
}

PG_FUNCTION_INFO_V1(NAD_tgeo_geo);
/**
 * Returns the nearest approach distance between the temporal geometry
 * and the static geometry
 */
PGDLLEXPORT Datum
NAD_tgeo_geo(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(1);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL(0);
  Datum result = NAD_tgeo_geo_internal(fcinfo, temp, gs);
  PG_FREE_IF_COPY(temp, 0);
  PG_FREE_IF_COPY(gs, 1);
  PG_RETURN_DATUM(result);
}

/*****************************************************************************/
