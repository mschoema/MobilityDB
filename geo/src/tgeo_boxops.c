/*****************************************************************************
 *
 * tgeo_boxops.c
 *    Bounding box operators for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "tgeo_boxops.h"

#include <assert.h>

#include "temporaltypes.h"
#include "lwgeom_utils.h"
#include "tpoint_boxops.h"
#include "tgeo_transform.h"

/*****************************************************************************
 * Functions computing the bounding box at the creation of a temporal point
 *****************************************************************************/

/* Transform a geometry to a stbox
 * Assumes that we take the rotation invariant stbox,
 * meaning we can rotate the geometry without going out of the stbox
 */
static bool
rotating_geo_to_stbox_internal(STBOX *box, GSERIALIZED *gs)
{
  LWGEOM *geom = lwgeom_from_gserialized(gs);
  LWPOINT *centroid;
  double d;
  bool is3d = FLAGS_GET_Z(gs->flags);
  if (!is3d)
  {
    centroid = lwpoly_centroid((LWPOLY *) geom);
    d = lwpoly_max_vertex_distance((LWPOLY *) geom, centroid);
  }
  else
  {
    centroid = lwpsurface_centroid((LWPSURFACE *) geom);
    d = lwpsurface_max_vertex_distance((LWPSURFACE *) geom, centroid);
  }
  lwgeom_free(geom);

  double cx = lwpoint_get_x(centroid);
  double cy = lwpoint_get_y(centroid);
  box->xmin = cx - d;
  box->xmax = cx + d;
  box->ymin = cy - d;
  box->ymax = cy + d;
  if (is3d)
  {
    double cz = lwpoint_get_z(centroid);
    box->zmin = cz - d;
    box->zmax = cz + d;
  }
  lwpoint_free(centroid);
  box->srid = gserialized_get_srid(gs);
  MOBDB_FLAGS_SET_X(box->flags, true);
  MOBDB_FLAGS_SET_Z(box->flags, is3d);
  MOBDB_FLAGS_SET_T(box->flags, false);
  MOBDB_FLAGS_SET_GEODETIC(box->flags, FLAGS_GET_GEODETIC(gs->flags));
  return true;
}

static void
tgeoinst_make_stbox(STBOX *box, TInstant *inst, bool rotating)
{
  Datum value = tinstant_value(inst);
  GSERIALIZED *gs = (GSERIALIZED *)PointerGetDatum(value);
  if (rotating)
    assert(rotating_geo_to_stbox_internal(box, gs));
  else
    assert(geo_to_stbox_internal(box, gs));
  box->tmin = box->tmax = inst->t;
  MOBDB_FLAGS_SET_T(box->flags, true);
  return;
}

/**
 * Set the spatiotemporal box from the array of temporal instant point values
 *
 * @param[out] box Spatiotemporal box
 * @param[in] instants Temporal instant values
 * @param[in] count Number of elements in the array
 * @note Temporal instant values do not have a precomputed bounding box
 */
void
tgeoinstarr_to_stbox(STBOX *box, TInstant **instants, int count, bool rotating)
{
  tgeoinst_make_stbox(box, instants[0], rotating);
  for (int i = 1; i < count; i++)
  {
    STBOX box1;
    memset(&box1, 0, sizeof(STBOX));
    TInstant *geom_inst = tgeoinst_rtransform_to_geometry(instants[i], instants[0]);
    tgeoinst_make_stbox(&box1, geom_inst, rotating);
    pfree(geom_inst);
    stbox_expand(box, &box1);
  }
}

/*****************************************************************************/
