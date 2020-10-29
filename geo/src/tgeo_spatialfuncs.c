/*****************************************************************************
 *
 * tgeo_spatialfuncs.c
 *    Geospatial functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "tgeo_spatialfuncs.h"

#include <assert.h>
#include <float.h>
#include <utils/builtins.h>
#include <utils/timestamp.h>

#include "tempcache.h"
#include "temporal_util.h"
#include "temporaltypes.h"
#include "timeops.h"
#include "lwgeom_utils.h"
#include "tpoint_spatialfuncs.h"
#include "tgeo_transform.h"
#include "rtransform.h"

/*****************************************************************************
 * Parameter tests
 *****************************************************************************/

static bool
tgeo_rigid_body_gs(const GSERIALIZED *gs)
{
  return (
    (gserialized_get_type(gs) == POLYGONTYPE && !FLAGS_GET_Z(gs->flags)) ||
    (gserialized_get_type(gs) == POLYHEDRALSURFACETYPE && FLAGS_GET_Z(gs->flags))
  );
}

bool
tgeo_rigid_body_instant(const TInstant *inst)
{
  bool isgeo = tgeo_base_type(inst->basetypid);
  if (!isgeo)
    return false;
  GSERIALIZED *gs = (GSERIALIZED *) DatumGetPointer(tinstant_value(inst));
  return tgeo_rigid_body_gs(gs);
}

bool
tgeo_3d_inst(const TInstant *inst)
{
  if (tgeo_base_type(inst->basetypid))
  {
    GSERIALIZED *gs = (GSERIALIZED *) DatumGetPointer(tinstant_value(inst));
    return FLAGS_GET_Z(gs->flags);
  }
  else if (tgeo_rtransform_base_type(inst->basetypid))
    return inst->basetypid == type_oid(T_RTRANSFORM3D);
  return NULL;
}

void
ensure_geo_type(const GSERIALIZED *gs)
{
  if (!tgeo_rigid_body_gs(gs))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Only 2D polygons or 3D polyhedral surfaces accepted")));
}

static void
ensure_same_rings_lwpoly(const LWPOLY *poly1, const LWPOLY *poly2)
{
  if (poly1->nrings != poly2->nrings)
    ereport(ERROR, (errcode(ERRCODE_RESTRICT_VIOLATION),
      errmsg("All polygons must contain the same number of rings")));
  for (int i = 0; i < (int) poly1->nrings; ++i)
  {
    if (poly1->rings[i]->npoints != poly2->rings[i]->npoints)
      ereport(ERROR, (errcode(ERRCODE_RESTRICT_VIOLATION),
        errmsg("Corresponding rings in each polygon must contain the same number of points")));
  }
}

static void
ensure_same_geoms_lwpsurface(const LWPSURFACE *psurface1, const LWPSURFACE *psurface2)
{
  if (psurface1->ngeoms != psurface2->ngeoms)
    ereport(ERROR, (errcode(ERRCODE_RESTRICT_VIOLATION),
      errmsg("All polyhedral surfaces must contain the same number of faces")));
  for (int i = 0; i < (int) psurface1->ngeoms; ++i)
    ensure_same_rings_lwpoly(psurface1->geoms[i], psurface2->geoms[i]);
}

void
ensure_similar_geo(const TInstant *inst1, const TInstant *inst2)
{
  if (tgeo_rigid_body_instant(inst1))
  {
    GSERIALIZED *gs1 = (GSERIALIZED *) DatumGetPointer(tinstant_value(inst1));
    GSERIALIZED *gs2 = (GSERIALIZED *) DatumGetPointer(tinstant_value(inst2));
    bool is3d = tgeo_3d_inst(inst1);
    if (!is3d)
    {
      LWPOLY *poly1 = (LWPOLY *) lwgeom_from_gserialized(gs1);
      LWPOLY *poly2 = (LWPOLY *) lwgeom_from_gserialized(gs2);
      ensure_same_rings_lwpoly(poly1, poly2);
      lwpoly_free(poly1);
      lwpoly_free(poly2);
    }
    else
    {
      LWPSURFACE *psurface1 = (LWPSURFACE *) lwgeom_from_gserialized(gs1);
      LWPSURFACE *psurface2 = (LWPSURFACE *) lwgeom_from_gserialized(gs2);
      ensure_same_geoms_lwpsurface(psurface1, psurface2);
      lwpsurface_free(psurface1);
      lwpsurface_free(psurface2);
    }
  }
  return;
}

void
ensure_rigid_body(const Datum geom1_datum, const Datum geom2_datum)
{
  GSERIALIZED *gs1 = (GSERIALIZED *) DatumGetPointer(geom1_datum);
  GSERIALIZED *gs2 = (GSERIALIZED *) DatumGetPointer(geom2_datum);
  LWGEOM *geom1 = lwgeom_from_gserialized(gs1);
  LWGEOM *geom2 = lwgeom_from_gserialized(gs2);
  bool rigid = lwgeom_rigid(geom1, geom2);
  lwgeom_free(geom1);
  lwgeom_free(geom2);
  if (!rigid)
    ereport(ERROR, (errcode(ERRCODE_RESTRICT_VIOLATION),
      errmsg("All geometries must be congruent")));
  return;
}

/*****************************************************************************
 * Trajectory Functions
 *****************************************************************************/

static TInstant *
tgeoinst_trajectory_centre(TInstant *inst)
{
  Datum value = tinstant_value(inst);
  GSERIALIZED *gs = (GSERIALIZED *) DatumGetPointer(value);
  LWGEOM *geom = lwgeom_from_gserialized(gs);
  LWGEOM *centroid;
  if (gserialized_get_type(gs) == POLYGONTYPE)
    centroid = lwgeom_centroid(geom);
  else if (gserialized_get_type(gs) == POLYHEDRALSURFACETYPE)
    centroid = (LWGEOM *)lwpsurface_centroid((LWPSURFACE *)geom);
  lwgeom_free(geom);
  GSERIALIZED *centroid_gs = geo_serialize(centroid);
  lwgeom_free(centroid);
  Datum centroid_datum = PointerGetDatum(centroid_gs);
  TInstant *result = tinstant_make(centroid_datum, inst->t, type_oid(T_GEOMETRY));
  pfree(centroid_gs);
  return result;
}

static TInstantSet *
tgeoi_trajectory_centre(TInstantSet *ti)
{
  TInstant **instants = palloc(sizeof(TInstant *) * ti->count);
  instants[0] = tgeoinst_trajectory_centre(tinstantset_inst_n(ti, 0));
  for (int i = 1; i < ti->count; i++)
    instants[i] = tgeoinst_rtransform_apply_point(
      tinstantset_inst_n(ti, i), instants[0], NULL);
  return tinstantset_make_free(instants, ti->count, MERGE_NO);
}

static TSequence *
tgeoseq_trajectory_centre(TSequence *seq)
{
  TInstant **instants = palloc(sizeof(TInstant *) * seq->count);
  instants[0] = tgeoinst_trajectory_centre(tsequence_inst_n(seq, 0));
  for (int i = 1; i < seq->count; i++)
    instants[i] = tgeoinst_rtransform_apply_point(
      tsequence_inst_n(seq, i), instants[0], NULL);
  return tsequence_make_free(instants, seq->count, seq->period.lower_inc,
      seq->period.upper_inc, MOBDB_FLAGS_GET_LINEAR(seq->flags), NORMALIZE);
}

static TSequenceSet *
tgeos_trajectory_centre(TSequenceSet *ts)
{
  TSequence **sequences = palloc(sizeof(TSequence *) * ts->count);
  for (int i = 0; i < ts->count; i++)
    sequences[i] = tgeoseq_trajectory_centre(tsequenceset_seq_n(ts, i));
  return tsequenceset_make_free(sequences, ts->count, NORMALIZE);
}

static Temporal *
tgeo_trajectory_centre_internal(Temporal *temp)
{
  Temporal *result;
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT)
    result = (Temporal *)tgeoinst_trajectory_centre((TInstant *)temp);
  else if (temp->subtype == INSTANTSET)
    result = (Temporal *)tgeoi_trajectory_centre((TInstantSet *)temp);
  else if (temp->subtype == SEQUENCE)
    result = (Temporal *)tgeoseq_trajectory_centre((TSequence *)temp);
  else /* temp->subtype == SEQUENCESET */
    result = (Temporal *)tgeos_trajectory_centre((TSequenceSet *)temp);
  return result;
}

PG_FUNCTION_INFO_V1(tgeo_trajectory_centre);

PGDLLEXPORT Datum
tgeo_trajectory_centre(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL(0);
  Temporal *result = tgeo_trajectory_centre_internal(temp);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_POINTER(result);
}

static TInstant *
tgeoinst_trajectory(TInstant *inst, TInstant *tpoint)
{
  if (inst->t != tpoint->t)
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("The temporal point is not part of the temporal geometry")));

  /* Test point inside */
  GSERIALIZED *geom1 = (GSERIALIZED *) DatumGetPointer(tinstant_value(inst));
  GSERIALIZED *geom2 = (GSERIALIZED *) DatumGetPointer(tinstant_value(tpoint));
  LWGEOM *lwgeom1 = lwgeom_from_gserialized(geom1);
  LWGEOM *lwgeom2 = lwgeom_from_gserialized(geom2);

  if (lwgeom1->type == POLYGONTYPE && 0.0 != lwgeom_mindistance2d_tolerance(lwgeom1,lwgeom2,0.0))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("The temporal point is not part of the temporal geometry")));
  else if (lwgeom1->type == POLYHEDRALSURFACETYPE)
  {
    LWGEOM *points[2];
    points[0] = lwgeom2;
    points[1] = (LWGEOM *)lwpsurface_centroid((LWPSURFACE *)lwgeom1);
    LWGEOM *lwline = (LWGEOM *)lwline_from_lwgeom_array(lwgeom2->srid, 2, points);
    if (0.0 == lwgeom_mindistance3d_tolerance(lwgeom1,lwline,0.0) &&
      0.0 != lwgeom_mindistance3d_tolerance(lwgeom1,lwgeom2,0.0))
      ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
        errmsg("The temporal point is not part of the temporal geometry")));
    pfree(points[1]);
  }
  return tinstant_copy(tpoint);
}

static TInstantSet *
tgeoi_trajectory(TInstantSet *ti, TInstant *tpoint)
{
  int loc;
  if (!tinstantset_find_timestamp(ti, tpoint->t, &loc))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("The temporal point is not part of the temporal geometry")));

  /* Compute the position of the point at the start timestamp of the temporal geometry */
  TInstant *start_tpoint = tpoint;
  TInstant *centroid = tgeoinst_trajectory_centre(tinstantset_inst_n(ti, 0));
  if (loc != 0)
  {
    TInstant *rt_inst = tinstantset_inst_n(ti, loc);
    start_tpoint = tgeoinst_rtransform_revert_point(rt_inst, tpoint, centroid);
  }

  TInstant **instants = palloc(sizeof(TInstant *) * ti->count);
  instants[0] = tgeoinst_trajectory(tinstantset_inst_n(ti, 0), start_tpoint);
  for (int i = 1; i < ti->count; i++)
    instants[i] = tgeoinst_rtransform_apply_point(
      tinstantset_inst_n(ti, i), start_tpoint, centroid);
  pfree(centroid);
  return tinstantset_make_free(instants, ti->count, MERGE_NO);
}

static TSequence *
tgeoseq_trajectory(TSequence *seq, TInstant *tpoint, int32 n)
{
  /* Bounding box test */
  if (!contains_period_timestamp_internal(&seq->period, tpoint->t))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("The temporal point is not part of the temporal geometry")));

  /* Instantaneous sequence */
  if (seq->count == 1)
  {
    TInstant *inst = tgeoinst_trajectory(tsequence_inst_n(seq, 0), tpoint);
    TSequence *result = tinstant_to_tsequence(inst, MOBDB_FLAGS_GET_LINEAR(seq->flags));
    pfree(inst);
    return result;
  }

  TInstant *start_tpoint = tpoint;
  TInstant *centroid = tgeoinst_trajectory_centre(tsequence_inst_n(seq, 0));

  /* General case */
  if (tsequence_inst_n(seq, 0)->t != tpoint->t)
  {
    int loc = tsequence_find_timestamp(seq, tpoint->t);
    TInstant *inst1 = tsequence_inst_n(seq, loc);
    TInstant *inst2 = tsequence_inst_n(seq, loc + 1);
    if (loc == 0)
      inst1 = tgeoinst_rtransform_zero(inst1->t, inst2->basetypid);
    Datum rt = tsequence_value_at_timestamp1(inst1, inst2, MOBDB_FLAGS_GET_LINEAR(seq->flags), tpoint->t);
    TInstant *rt_inst = tinstant_make(rt, tpoint->t, inst1->basetypid);
    start_tpoint = tgeoinst_rtransform_revert_point(rt_inst, tpoint, centroid);
    pfree(rt_inst);
    pfree(DatumGetPointer(rt));
    if (loc == 0)
      pfree(inst1);
  }

  TInstant **instants = palloc(sizeof(TInstant *) * (seq->count + (seq->count - 1)*n));
  instants[0] = tgeoinst_trajectory(tsequence_inst_n(seq, 0), start_tpoint);
  for (int i = 1; i < seq->count; i++)
  {
    for (int j = 1; j < n + 1; ++j)
    {
      TInstant *inst1 = tsequence_inst_n(seq, i - 1);
      TInstant *inst2 = tsequence_inst_n(seq, i);
      if (i == 1)
        inst1 = tgeoinst_rtransform_zero(inst1->t, inst2->basetypid);
      double duration = (inst2->t - inst1->t);
      double ratio = (double) j / (double) (n + 1);
      assert(ratio > 0 && ratio < 1);
      TimestampTz tj = inst1->t + (long) (duration * ratio);
      Datum rt = tsequence_value_at_timestamp1(inst1, inst2, MOBDB_FLAGS_GET_LINEAR(seq->flags), tj);
      Datum new_point = rtransform_apply_point_datum(rt, tinstant_value(start_tpoint), tinstant_value(centroid), inst1->basetypid);
      instants[(i - 1)*(n + 1) + j] = tinstant_make(new_point, tj, start_tpoint->basetypid);
      pfree(DatumGetPointer(new_point));
      pfree(DatumGetPointer(rt));
      if (i == 1)
        pfree(inst1);
    }
    instants[i*(n + 1)] = tgeoinst_rtransform_apply_point(
      tsequence_inst_n(seq, i), start_tpoint, centroid);
  }
  pfree(centroid);
  return tsequence_make_free(instants, seq->count + (seq->count - 1)*n, seq->period.lower_inc, seq->period.upper_inc, MOBDB_FLAGS_GET_LINEAR(seq->flags), NORMALIZE);
}

static TSequenceSet *
tgeos_trajectory(TSequenceSet *ts, TInstant *tpoint, int32 n)
{
  /* Singleton sequence set */
  if (ts->count == 1)
  {
    TSequence *seq = tgeoseq_trajectory(tsequenceset_seq_n(ts, 0), tpoint, n);
    TSequenceSet *result = tsequence_to_tsequenceset(seq);
    pfree(seq);
    return result;
  }

  /* General case */
  int loc;
  if (!tsequenceset_find_timestamp(ts, tpoint->t, &loc))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("The temporal point is not part of the temporal geometry")));

  TSequence *loc_seq = tsequenceset_seq_n(ts, loc);
  TSequence *loc_point_seq = tgeoseq_trajectory(loc_seq, tpoint, n);
  TSequence **sequences = palloc(sizeof(TSequence *) * ts->count);
  for (int i = 0; i < ts->count; i++)
  {
    if (i == loc)
      sequences[i] = loc_point_seq;
    else
    {
      TSequence *seq = tsequenceset_seq_n(ts, i);
      TInstant *centroid = tgeoinst_trajectory_centre(tsequence_inst_n(seq, 0));
      TInstant *rt_inst = tgeoinst_geometry_to_rtransform(tsequence_inst_n(loc_seq, 0), tsequence_inst_n(seq, 0));
      TInstant *tpoint_i = tgeoinst_rtransform_revert_point(rt_inst, tsequence_inst_n(loc_point_seq, 0), centroid);
      sequences[i] = tgeoseq_trajectory(seq, tpoint_i, n);
      pfree(tpoint_i);
      pfree(rt_inst);
      pfree(centroid);
    }
  }
  return tsequenceset_make_free(sequences, ts->count, NORMALIZE_NO);
}

static Temporal *
tgeo_trajectory_internal(Temporal *temp, TInstant *tpoint, int32 n)
{
  Temporal *result;
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT)
    result = (Temporal *)tgeoinst_trajectory((TInstant *)temp, tpoint);
  else if (temp->subtype == INSTANTSET)
    result = (Temporal *)tgeoi_trajectory((TInstantSet *)temp, tpoint);
  else if (temp->subtype == SEQUENCE)
    result = (Temporal *)tgeoseq_trajectory((TSequence *)temp, tpoint, n);
  else /* temp->subtype == SEQUENCESET */
    result = (Temporal *)tgeos_trajectory((TSequenceSet *)temp, tpoint, n);
  return result;
}

PG_FUNCTION_INFO_V1(tgeo_trajectory);

PGDLLEXPORT Datum
tgeo_trajectory(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL(0);
  Temporal *tpoint = PG_GETARG_TEMPORAL(1);
  /* Validity tests */
  if (tpoint->subtype != INSTANT)
    ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
      errmsg("The second argument must be of instant subtype")));
  int32 n = PG_GETARG_INT32(2);
  assert(n >= 0);
  ensure_same_spatial_dimensionality(temp->flags, tpoint->flags);
  ensure_same_srid_tpoint(temp, tpoint);
  Temporal *result = tgeo_trajectory_internal(temp, (TInstant *)tpoint, n);
  PG_FREE_IF_COPY(temp, 0);
  PG_FREE_IF_COPY(tpoint, 1);
  if (!result)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

/*****************************************************************************/
