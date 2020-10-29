/*****************************************************************************
 *
 * tgeo_transform.c
 *    Transformation (encoder/decoder) functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "tgeo_transform.h"

#include <libpq/pqformat.h>
#include <executor/spi.h>
#include <liblwgeom.h>
#include <math.h>
#include <float.h>

#include "temporaltypes.h"
#include "tempcache.h"
#include "tgeo.h"
#include "temporal_util.h"
#include "tgeo_parser.h"
#include "tgeo_spatialfuncs.h"

/*****************************************************************************
 * Encoding functions
 *****************************************************************************/

TInstant *
tgeoinst_geometry_to_rtransform(const TInstant *inst, const TInstant *ref_inst)
{
  Datum geom = tinstant_value(inst);
  Datum ref_geom = tinstant_value(ref_inst);
  Oid basetypid = tgeo_3d_inst(inst) ? type_oid(T_RTRANSFORM3D) : type_oid(T_RTRANSFORM2D);
  Datum result_datum = rtransform_compute_datum(ref_geom, geom, basetypid);
  TInstant *result = tinstant_make(result_datum, inst->t, basetypid);
  pfree((void *) result_datum);
  return result;
}

/*
Computes the transformations for all instants with respect to the first instant
Raises an error if the geometries are not colinear enough
Creates a new array of instants, does not free old array
 */
TInstant **
tgeo_instarr_to_rtransform(TInstant **instants, int count)
{
  TInstant **newInstants = palloc(sizeof(TInstant *) * count);;
  newInstants[0] = (TInstant *) temporal_copy((Temporal *) instants[0]);
  TInstant *prev_rtransform_inst = NULL;
  for (int i = 1; i < count; ++i)
  {
    if (tgeo_base_type(instants[i]->basetypid))
    {
      newInstants[i] = tgeoinst_geometry_to_rtransform(instants[i], instants[0]);
      prev_rtransform_inst = newInstants[0];
    }
    else if (tgeo_rtransform_base_type(instants[i]->basetypid))
      newInstants[i] = prev_rtransform_inst == NULL ?
        (TInstant *) temporal_copy((Temporal *) instants[i]) :
        tgeoinst_rtransform_combine(instants[i], prev_rtransform_inst);
  }
  return newInstants;
}

/*****************************************************************************
 * Decoding functions
 *****************************************************************************/

TInstant *
tgeoinst_rtransform_to_geometry(const TInstant *inst, const TInstant *ref_inst)
{
  Datum rt = tinstant_value(inst);
  Datum geom = tinstant_value(ref_inst);
  Datum result_datum = rtransform_apply_datum(rt, geom, inst->basetypid);
  TInstant *result = tinstant_make(result_datum, inst->t, ref_inst->basetypid);
  pfree((void *) result_datum);
  return result;
}

 /*****************************************************************************
 * Other transformation functions
 *****************************************************************************/

TInstant *
tgeoinst_rtransform_zero(TimestampTz t, Oid basetypid)
{
  Datum result_datum = rtransform_zero_datum(basetypid);
  TInstant *result = tinstant_make(result_datum, t, basetypid);
  pfree((void *) result_datum);
  return result;
}

TInstant *
tgeoinst_rtransform_combine(const TInstant *inst, const TInstant *ref_inst)
{
  Datum rt1 = tinstant_value(inst);
  Datum rt2 = tinstant_value(ref_inst);
  Datum result_datum = rtransform_combine_datum(rt2, rt1, inst->basetypid);
  TInstant *result = tinstant_make(result_datum, inst->t, inst->basetypid);
  pfree((void *) result_datum);
  return result;
}

TInstant *
tgeoinst_rtransform_apply_point(const TInstant *inst, const TInstant *point_inst, const TInstant *centroid_inst)
{
  Datum rt = tinstant_value(inst);
  Datum point = tinstant_value(point_inst);
  Datum centroid = PointerGetDatum(NULL);
  if (centroid_inst)
    centroid = tinstant_value(centroid_inst);
  Datum result_datum = rtransform_apply_point_datum(rt, point, centroid, inst->basetypid);
  TInstant *result = tinstant_make(result_datum, inst->t, point_inst->basetypid);
  pfree((void *) result_datum);
  return result;
}

TInstant *
tgeoinst_rtransform_revert_point(const TInstant *inst, const TInstant *point_inst, const TInstant *centroid_inst)
{
  Datum rt = tinstant_value(inst);
  Datum point = tinstant_value(point_inst);
  Datum centroid = tinstant_value(centroid_inst);
  Datum new_centroid = rtransform_apply_point_datum(rt, centroid, PointerGetDatum(NULL), inst->basetypid);
  Datum rt_inverse = rtransform_invert_datum(rt, inst->basetypid);
  Datum old_point = rtransform_apply_point_datum(rt_inverse, point, new_centroid, inst->basetypid);
  TInstant *result = tinstant_make(old_point, centroid_inst->t, point_inst->basetypid);
  pfree((void *) new_centroid);
  pfree((void *) rt_inverse);
  pfree((void *) old_point);
  return result;
}

/*****************************************************************************/
