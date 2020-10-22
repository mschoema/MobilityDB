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
#include "lwgeom_utils.h"

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

/*****************************************************************************/
