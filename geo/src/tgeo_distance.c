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
#include "temporal.h"
#include "tpoint_spatialfuncs.h"
#include "tgeo_spatialfuncs.h"

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
