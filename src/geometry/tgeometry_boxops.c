/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 *
 * Copyright (c) 2016-2021, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2021, PostGIS contributors
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without a written
 * agreement is hereby granted, provided that the above copyright notice and
 * this paragraph and the following two paragraphs appear in all copies.
 *
 * IN NO EVENT SHALL UNIVERSITE LIBRE DE BRUXELLES BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
 * LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF UNIVERSITE LIBRE DE BRUXELLES HAS BEEN ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * UNIVERSITE LIBRE DE BRUXELLES SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON
 * AN "AS IS" BASIS, AND UNIVERSITE LIBRE DE BRUXELLES HAS NO OBLIGATIONS TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 
 *
 *****************************************************************************/

/**
 * @file tgeometry_boxops.c
 * Bounding box operators for rigid temporal geometries.
 *
 * These operators test the bounding boxes of rigid temporal geometries,
 * which are STBOX boxes. The following operators are defined:
 *    overlaps, contains, contained, same
 * The operators consider as many dimensions as they are shared in both
 * arguments: only the space dimension, only the time dimension, or both
 * the space and the time dimensions.
 */

#include "geometry/tgeometry_boxops.h"

#include <math.h>
#include <liblwgeom.h>
#include <utils/timestamp.h>

#include "general/temporaltypes.h"
#include "general/tempcache.h"
#include "general/temporal_util.h"

#include "point/stbox.h"

#include "pose/pose.h"

#include "geometry/tgeometry_inst.h"

/*****************************************************************************
 * Transform a temporal geometry to a STBOX
 *****************************************************************************/

static void
lwgeom_affine_transform(LWGEOM *geom,
  double a, double b, double c,
  double d, double e, double f,
  double g, double h, double i,
  double xoff, double yoff, double zoff)
{
  AFFINE affine;
  affine.afac =  a;
  affine.bfac =  b;
  affine.cfac =  c;
  affine.dfac =  d;
  affine.efac =  e;
  affine.ffac =  f;
  affine.gfac =  g;
  affine.hfac =  h;
  affine.ifac =  i;
  affine.xoff =  xoff;
  affine.yoff =  yoff;
  affine.zoff =  zoff;
  lwgeom_affine(geom, &affine);
  return;
}

void
lwgeom_apply_pose(LWGEOM *geom, pose *p)
{
  if (!MOBDB_FLAGS_GET_Z(p->flags))
  {
    double a = cos(p->data[2]);
    double b = sin(p->data[2]);

    lwgeom_affine_transform(geom,
      a, -b, 0,
      b, a, 0,
      0, 0, 1,
      p->data[0], p->data[1], 0);
  }
  else
  {
    double W = p->data[3];
    double X = p->data[4];
    double Y = p->data[5];
    double Z = p->data[6];

    double a = W*W + X*X - Y*Y - Z*Z;
    double b = 2*X*Y - 2*W*Z;
    double c = 2*X*Z + 2*W*Y;
    double d = 2*X*Y + 2*W*Z;
    double e = W*W - X*X + Y*Y - Z*Z;
    double f = 2*Y*Z - 2*W*X;
    double g = 2*X*Z - 2*W*Y;
    double h = 2*Y*Z + 2*W*X;
    double i = W*W - X*X - Y*Y + Z*Z;

    lwgeom_affine_transform(geom,
      a, b, c,
      d, e, f,
      g, h, i,
      p->data[0], p->data[1], p->data[2]);
  }
  return;
}

/**
 * Set the spatiotemporal box from the geometry value
 *
 * @param[out] box Spatiotemporal box
 * @param[in] inst Temporal network point
 */
void
tgeometryinst_make_stbox(const Datum geom, const TInstant *inst,
  STBOX *box)
{
  pose *p = DatumGetPose(tinstant_value(inst));
  GSERIALIZED *gs = (GSERIALIZED *) DatumGetPointer(geom);
  LWGEOM *lwgeom = lwgeom_from_gserialized(gs);
  LWGEOM *lwgeom_copy = lwgeom_clone_deep(lwgeom);
  lwgeom_apply_pose(lwgeom_copy, p);

  GBOX gbox;
  int ret = lwgeom_calculate_gbox(lwgeom_copy, &gbox);

  lwgeom_free(lwgeom_copy);
  lwgeom_free(lwgeom);

  if (ret == LW_FAILURE)
  {
    /* Spatial dimensions are set as missing for the SP-GiST index */
    MOBDB_FLAGS_SET_X(box->flags, false);
    MOBDB_FLAGS_SET_Z(box->flags, false);
    MOBDB_FLAGS_SET_T(box->flags, false);
    return;
  }
  box->xmin = gbox.xmin;
  box->xmax = gbox.xmax;
  box->ymin = gbox.ymin;
  box->ymax = gbox.ymax;
#if POSTGIS_VERSION_NUMBER < 30000
  bool hasz = (bool) FLAGS_GET_Z(gs->flags);
  bool geodetic = (bool) FLAGS_GET_GEODETIC(gs->flags);
#else
  bool hasz = (bool) FLAGS_GET_Z(gs->gflags);
  bool geodetic = (bool) FLAGS_GET_GEODETIC(gs->gflags);
#endif
  if (hasz || geodetic)
  {
    box->zmin = gbox.zmin;
    box->zmax = gbox.zmax;
  }
  box->tmin = box->tmax = inst->t;
  box->srid = gserialized_get_srid(gs);
  MOBDB_FLAGS_SET_X(box->flags, true);
  MOBDB_FLAGS_SET_Z(box->flags, hasz);
  MOBDB_FLAGS_SET_T(box->flags, true);
  MOBDB_FLAGS_SET_GEODETIC(box->flags, geodetic);
  return;
}

/**
 * Set the spatiotemporal box from the array of rigid temporal geometry values
 *
 * @param[out] box Spatiotemporal box
 * @param[in] instants Temporal geometry values
 * @param[in] count Number of elements in the array
 */
void
tgeometryinstarr_step_to_stbox(const Datum geom, const TInstant **instants,
  int count, STBOX *box)
{
  tgeometryinst_make_stbox(geom, instants[0], box);
  for (int i = 1; i < count; i++)
  {
    STBOX box1;
    memset(&box1, 0, sizeof(STBOX));
    tgeometryinst_make_stbox(geom, instants[i], &box1);
    stbox_expand(box, &box1);
  }
}

/**
 * Set the spatiotemporal box from the pose value
 *
 * @param[out] box Spatiotemporal box
 * @param[in] inst Temporal network point
 */
static void
tgeometryinst_pose_make_stbox(const TInstant *inst, STBOX *box)
{
  pose *p = DatumGetPose(tinstant_value(inst));
  box->xmin = box->xmax = p->data[0];
  box->ymin = box->ymax = p->data[1];
  if (MOBDB_FLAGS_GET_Z(p->flags))
    box->zmin = box->zmax = p->data[2];
  box->tmin = box->tmax = inst->t;
  MOBDB_FLAGS_SET_X(box->flags, true);
  MOBDB_FLAGS_SET_Z(box->flags, MOBDB_FLAGS_GET_Z(p->flags));
  MOBDB_FLAGS_SET_T(box->flags, true);
  return;
}

static double
geom_radius(Datum geom_datum)
{
  GSERIALIZED *gs = (GSERIALIZED *) DatumGetPointer(geom_datum);
  LWGEOM *geom = lwgeom_from_gserialized(gs);
  LWPOINTITERATOR *it = lwpointiterator_create(geom);
  double r = 0;
  POINT4D p;
  while (lwpointiterator_next(it, &p))
  {
    if (FLAGS_GET_Z(geom->flags))
      r = fmax(r, sqrt(pow(p.x, 2) + pow(p.y, 2) + pow(p.z, 2)));
    else
      r = fmax(r, sqrt(pow(p.x, 2) + pow(p.y, 2)));
  }
  lwpointiterator_destroy(it);
  lwgeom_free(geom);
  return r;
}

/**
 * Set the spatiotemporal box from the array of rigid temporal geometry values
 *
 * @param[out] box Spatiotemporal box
 * @param[in] instants Temporal geometry values
 * @param[in] count Number of elements in the array
 */
void
tgeometryinstarr_linear_to_stbox(const Datum geom, const TInstant **instants,
  int count, STBOX *box)
{
  double r = geom_radius(geom);
  tgeometryinst_pose_make_stbox(instants[0], box);
  for (int i = 1; i < count; i++)
  {
    STBOX box1;
    memset(&box1, 0, sizeof(STBOX));
    tgeometryinst_pose_make_stbox(instants[i], &box1);
    stbox_expand(box, &box1);
  }
  box->xmin -= r;
  box->xmax += r;
  box->ymin -= r;
  box->ymax += r;
  box->zmin -= r;
  box->zmax += r;
  box->srid = gserialized_get_srid(
    (GSERIALIZED *) DatumGetPointer(geom));
  MOBDB_FLAGS_SET_GEODETIC(box->flags, false);
  return;
}

/*****************************************************************************/

/**
 * Set the bounding box from the array of temporal instant values
 * (dispatch function)
 *
 * @param[in] box Box
 * @param[in] instants Temporal instants
 * @param[in] count Number of elements in the array
 */
void
tgeometry_instset_make_bbox(const Datum geom, const TInstant **instants,
  int count, void *box)
{
  /* Only external types have bounding box */
  ensure_temporal_base_type(instants[0]->basetypid);
  if (instants[0]->basetypid == type_oid(T_POSE))
    tgeometryinstarr_step_to_stbox(geom, instants, count, (STBOX *) box);
  else
    elog(ERROR, "#1 unknown bounding box function for base type: %d",
      instants[0]->basetypid);
  return;
}

/**
 * Set the bounding box from the array of temporal instant values
 * (dispatch function)
 *
 * @param[in] box Box
 * @param[in] instants Temporal instants
 * @param[in] count Number of elements in the array
 * @param[in] lower_inc,upper_inc Period bounds
 */
void
tgeometry_seq_make_bbox(const Datum geom, const TInstant **instants,
  int count, bool lower_inc, bool upper_inc, bool linear, void *box)
{
  /* Only external types have bounding box */
  ensure_temporal_base_type(instants[0]->basetypid);
  if (instants[0]->basetypid == type_oid(T_POSE))
  {
    if (linear)
      tgeometryinstarr_linear_to_stbox(geom, instants, count, (STBOX *) box);
    else
      tgeometryinstarr_step_to_stbox(geom, instants, count, (STBOX *) box);
  }
  else
    elog(ERROR, "#2 unknown bounding box function for base type: %d",
      instants[0]->basetypid);
  return;
}

/*****************************************************************************/
