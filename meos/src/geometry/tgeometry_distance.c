/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 * Copyright (c) 2016-2023, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2023, PostGIS contributors
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
 * @brief Distance functions for rigid temporal geometries.
 */

#include "geometry/tgeometry_distance.h"

/* C */
#include <assert.h>
#include <c.h>
#include <float.h>
#include <math.h>
/* PostgreSQL */
#include <postgres.h>
#include <stdio.h>
#include <utils/elog.h>
#include <utils/palloc.h>
#include <utils/timestamp.h>
#include <utils/float.h>
/* PostGIS */
#include <lwgeodetic_tree.h>
#include <liblwgeom.h>
#include <measures.h>
#include <measures3d.h>
/* MEOS */
#include "general/temporal.h"
#include "meos.h"
#include "meos_internal.h"
#include "general/temporaltypes.h"
#include "general/type_util.h"
#include "general/meos_catalog.h"
#include "point/pgis_call.h"
#include "point/tpoint_spatialfuncs.h"
#include "geometry/tgeometry_temporaltypes.h"
#include "geometry/tgeometry_spatialfuncs.h"
#include "geometry/tgeometry_vclip.h"
#include "pose/tpose_static.h"

/*****************************************************************************
 * cfp array utility functions
 *****************************************************************************/

static cfp_elem
cfp_make(LWGEOM *geom_1, LWGEOM *geom_2, Pose *pose_1, Pose *pose_2, uint32_t cf_1, uint32_t cf_2, TimestampTz t, bool store)
{
  cfp_elem cfp;
  cfp.geom_1 = geom_1;
  cfp.geom_2 = geom_2;
  cfp.pose_1 = pose_1;
  cfp.pose_2 = pose_2;
  cfp.cf_1 = cf_1;
  cfp.cf_2 = cf_2;
  cfp.t = t;
  cfp.store = store;
  cfp.free_pose_1 = MEOS_CFP_FREE_NO;
  cfp.free_pose_2 = MEOS_CFP_FREE_NO;
  return cfp;
}

static cfp_elem
cfp_make_zero(LWGEOM *geom_1, LWGEOM *geom_2, Pose *pose_1, Pose *pose_2, TimestampTz t, bool store)
{
  return cfp_make(geom_1, geom_2, pose_1, pose_2, 0, 0, t, store);
}

static void
init_cfp_array(cfp_array *cfpa, size_t n)
{
  cfpa->arr = palloc0(sizeof(cfp_elem) * n);
  cfpa->count = 0;
  cfpa->size = n;
}

static void
free_cfp_array(cfp_array *cfpa)
{
  for (uint32_t i = 0; i < cfpa->count; ++i)
  {
    if (cfpa->arr[i].free_pose_1)
      pfree(cfpa->arr[i].pose_1);
    if (cfpa->arr[i].free_pose_2)
      pfree(cfpa->arr[i].pose_2);
  }
  pfree(cfpa->arr);
}

static void
append_cfp_elem(cfp_array *cfpa, cfp_elem cfp)
{
  if (cfpa->count == cfpa->size)
  {
    cfpa->size *= 2;
    cfp_elem *new_arr = repalloc(cfpa->arr, sizeof(cfp_elem) * cfpa->size);
    if (new_arr == NULL)
      elog(ERROR, "Not enough memory");
    else
      cfpa->arr = new_arr;
  }
  cfpa->arr[cfpa->count++] = cfp;
}

static tdist_elem
tdist_make(double dist, TimestampTz t)
{
  tdist_elem td;
  td.dist = dist;
  td.t = t;
  return td;
}

static void
init_tdist_array(tdist_array *tda, size_t n)
{
  tda->arr = palloc0(sizeof(tdist_elem) * n);
  tda->count = 0;
  tda->size = n;
}

static void
free_tdist_array(tdist_array *tda)
{
  pfree(tda->arr);
}

static void
append_tdist_elem(tdist_array *tda, tdist_elem td)
{
  if (tda->count == tda->size)
  {
    tda->size *= 2;
    tdist_elem *new_arr = repalloc(tda->arr, sizeof(tdist_elem) * tda->size);
    if (new_arr == NULL)
      elog(ERROR, "Not enough memory");
    else
      tda->arr = new_arr;
  }
  tda->arr[tda->count++] = td;
}

/*****************************************************************************
 * V-clip
 *****************************************************************************/

static inline uint32_t
uint_mod_add(uint32_t i, uint32_t j, uint32_t n)
{
  return (i + j) % n;
}

// Handle negative values correctly
// Requirement: j < n
static inline uint32_t
uint_mod_sub(uint32_t i, uint32_t j, uint32_t n)
{
  return (i + n - j) % n;
}

static void
apply_pose_point4d(POINT4D *p, Pose *pose)
{
  double c = cos(pose->data[2]);
  double s = sin(pose->data[2]);
  double x = p->x, y = p->y;
  p->x = x * c - y * s + pose->data[0];
  p->y = x * s + y * c + pose->data[1];
  return;
}

/* Computes the relative position of point
 * on segment v(vs, ve).
 * s < 0      -> p before point vs
 * s = 0      -> p = vs
 * 0 < s < 1  -> p = vs * (1 - s)  + ve * s
 * s = 1      -> p = ve
 * 1 < s      -> p after point ve
 */
static inline double
compute_s(POINT4D p, POINT4D vs, POINT4D ve)
{
  return ((p.x - vs.x) * (ve.x - vs.x) + (p.y - vs.y) * (ve.y - vs.y))
                / (pow(ve.x - vs.x, 2) + pow(ve.y - vs.y, 2));
}

/* Computes the signed length of the cross product
 * of the vectors (vs, p) and (vs, ve).
 *
 * The sign of this value determines the relative
 * position between p and the line l going
 * though segment (vs, ve) (oriented towards ve).
 * angle > 0: p is on the right of l
 * angle = 0: P is on l
 * angle < 0: P is on the left of l
 */
static inline double
compute_angle(POINT4D p, POINT4D vs, POINT4D ve)
{
  return (p.x - vs.x) * (ve.y - vs.y) - (p.y - vs.y) * (ve.x - vs.x);
}

/* Computes the distance between point p and segment v(vs, ve)
 *
 * Note: this assumes that the projection of p
 * on the line l going through (vs, ve) is
 * between vs and ve. (0 <= compute_s(p, vs, ve) <= 1)
 */
static inline double
compute_dist2(POINT4D p, POINT4D vs, POINT4D ve)
{
  double s = compute_s(p, vs, ve);
  return pow(p.x - vs.x - (ve.x - vs.x) * s, 2) + pow(p.y - vs.y - (ve.y - vs.y) * s, 2);
}

/*
 * Tests if a polygon is defined in
 * counter-clockwise order (ccw)
 * Returns True if it is the case
 * Note: Polygon must be convex
 */
static bool
poly_is_ccw(const LWPOLY *poly)
{
  POINT4D v1, v2, v3;
  getPoint4d_p(poly->rings[0], 0, &v1);
  getPoint4d_p(poly->rings[0], 1, &v2);
  getPoint4d_p(poly->rings[0], 2, &v3);
  return compute_angle(v1, v2, v3) < 0;
}

/*****************************************************************************
 * Temporal distance
 *****************************************************************************/

TInstant *
dist2d_tgeometryinst_geo(const TInstant *inst, const GSERIALIZED *gs)
{
  Datum ref_geom = tgeometryinst_geom(inst);
  GSERIALIZED *ref_gs = DatumGetGserializedP(ref_geom);
  double dist = gserialized_distance(ref_gs, gs);
  return tinstant_make(Float8GetDatum(dist), T_FLOAT8, inst->t);
}

static void
pose_interpolate_2d(Pose *pose1, Pose *pose2, double ratio, double *x, double *y, double *theta)
{
  assert(0 <= ratio && ratio <= 1);
  *x = pose1->data[0] * (1 - ratio) + pose2->data[0] * ratio;
  *y = pose1->data[1] * (1 - ratio) + pose2->data[1] * ratio;
  double theta_delta = pose2->data[2] - pose1->data[2];
  /* If fabs(theta_delta) == M_PI: Always turn counter-clockwise */
  if (fabs(theta_delta) < MEOS_EPSILON)
    *theta = pose1->data[2];
  else if (theta_delta > 0 && fabs(theta_delta) <= M_PI)
    *theta = pose1->data[2] + theta_delta*ratio;
  else if (theta_delta > 0 && fabs(theta_delta) > M_PI)
    *theta = pose2->data[2] + (2*M_PI - theta_delta)*(1 - ratio);
  else if (theta_delta < 0 && fabs(theta_delta) < M_PI)
    *theta = pose1->data[2] + theta_delta*ratio;
  else /* (theta_delta < 0 && fabs(theta_delta) >= M_PI) */
    *theta = pose1->data[2] + (2*M_PI + theta_delta)*ratio;
  if (*theta > M_PI)
    *theta = *theta - 2*M_PI;
}

static void
pose_diff_2d(Pose *pose1, Pose *pose2, double *x, double *y, double *theta)
{
  *x = pose2->data[0] - pose1->data[0];
  *y = pose2->data[1] - pose1->data[1];
  double theta_delta = pose2->data[2] - pose1->data[2];
  /* If fabs(theta_delta) == M_PI: Always turn counter-clockwise */
  if (fabs(theta_delta) < MEOS_EPSILON)
    *theta = theta_delta;
  else if (theta_delta > 0 && fabs(theta_delta) <= M_PI)
    *theta = theta_delta;
  else if (theta_delta > 0 && fabs(theta_delta) > M_PI)
    *theta = 2*M_PI - theta_delta;
  else if (theta_delta < 0 && fabs(theta_delta) < M_PI)
    *theta = theta_delta;
  else /* (theta_delta < 0 && fabs(theta_delta) >= M_PI) */
    *theta = 2*M_PI + theta_delta;
}

static double
f_tpoint_poly(POINT4D p, POINT4D q, POINT4D r,
  Pose *poly_pose_s, Pose *poly_pose_e, double ratio,
  bool solution_kind)
{
  double dx, dy, dtheta;
  double co, si, qx, qy, rx, ry;
  pose_interpolate_2d(poly_pose_s, poly_pose_e, ratio, &dx, &dy, &dtheta);
  co = cos(dtheta);
  si = sin(dtheta);
  qx = q.x * co - q.y * si + dx;
  qy = q.x * si + q.y * co + dy;
  rx = r.x * co - r.y * si + dx;
  ry = r.x * si + r.y * co + dy;
  if (solution_kind) /* MEOS_SOLVE_0 */
    return (p.x - qx) * (rx - qx) + (p.y - qy) * (ry - qy);
  else /* MEOS_SOLVE_1 */
    return (p.x - rx) * (rx - qx) + (p.y - ry) * (ry - qy);
}

static double
solve_s_tpoly_point(LWPOLY *poly, LWPOINT *point, Pose *poly_pose_s, Pose *poly_pose_e,
  uint32_t poly_v, double prev_result, bool solution_kind)
{
  uint32_t n = poly->rings[0]->npoints - 1;
  POINT4D p, q, r;
  lwpoint_getPoint4d_p(point, &p);
  getPoint4d_p(poly->rings[0], poly_v, &q);
  getPoint4d_p(poly->rings[0], uint_mod_add(poly_v, 1, n), &r);

/*  if (solution_kind)
    printf("s(t) = 0; p = (%lf, %lf), q = (%lf, %lf), r = (%lf, %lf), \npose_1 = (%lf, %lf, %lf), pose_2 = (%lf, %lf, %lf)\n",
      p.x, p.y, q.x, q.y, r.x, r.y,
      poly_pose_s->data[0], poly_pose_s->data[1], poly_pose_s->data[2],
      poly_pose_e->data[0], poly_pose_e->data[1], poly_pose_e->data[2]);
  else
    printf("s(t) = 1; p = (%lf, %lf), q = (%lf, %lf), r = (%lf, %lf), \npose_1 = (%lf, %lf, %lf), pose_2 = (%lf, %lf, %lf)\n",
      p.x, p.y, q.x, q.y, r.x, r.y,
      poly_pose_s->data[0], poly_pose_s->data[1], poly_pose_s->data[2],
      poly_pose_e->data[0], poly_pose_e->data[1], poly_pose_e->data[2]);
  fflush(stdout);*/

  if (fabs(poly_pose_s->data[2] - poly_pose_e->data[2]) < MEOS_EPSILON)
  {
    apply_pose_point4d(&q, poly_pose_s);
    apply_pose_point4d(&r, poly_pose_s);
    double result;
    double discr = ((poly_pose_e->data[0] - poly_pose_s->data[0]) * (r.x - q.x)
      + (poly_pose_e->data[1] - poly_pose_s->data[1]) * (r.y - q.y));
    if (solution_kind) /* MEOS_SOLVE_0 */
      result = ((p.x - q.x) * (r.x - q.x) + (p.y - q.y) * (r.y - q.y)) / discr;
    else /* MEOS_SOLVE_1 */
      result = ((p.x - r.x) * (r.x - q.x) + (p.y - r.y) * (r.y - q.y)) / discr;
    if (result > prev_result + MEOS_EPSILON && result < 1 - MEOS_EPSILON)
      return result;
    return 2;
  }

  double tl, tr, t0 = 0; /* Make compiler quiet */
  double vl, vr, v0;
  double ts = prev_result, te = 1;
  vl = f_tpoint_poly(p, q, r, poly_pose_s, poly_pose_e,
    ts, solution_kind);
  v0 = f_tpoint_poly(p, q, r, poly_pose_s, poly_pose_e,
    (ts + te) / 2, solution_kind);
  vr = f_tpoint_poly(p, q, r, poly_pose_s, poly_pose_e,
    te, solution_kind);
  if (fabs(vl) > MEOS_EPSILON && vl * v0 < 0)
  {
    tl = ts;
    tr = (ts + te) / 2;
    vr = v0;
  }
  else if (v0 * vr < 0)
  {
    tl = (ts + te) / 2;
    tr = te;
    vl = v0;
  }
  else
    return 2;


  uint8_t i = 0;
  while(fabs(tr - tl) >= MEOS_EPSILON && i < 100)
  {
    ++i;
    t0 = (tl * vr - tr * vl) / (vr - vl);
    v0 = f_tpoint_poly(p, q, r, poly_pose_s, poly_pose_e,
      t0, solution_kind);
    if (fabs(v0) < MEOS_EPSILON)
      break;
    if (vl * v0 <= 0)
      tr = t0, vr = v0;
    else
      tl = t0, vl = v0;
  }
  return t0;
}

static double
solve_angle_0_tpoly_point(LWPOLY *poly, LWPOINT *point, Pose *poly_pose_s, Pose *poly_pose_e, uint32_t poly_v, double r_prev)
{
  return 2;
}

static void
compute_dist_tpoly_point(cfp_elem *cfp, tdist_array *tda)
{
  double dist;
  POINT4D p, q, r;
  LWPOLY *poly = (LWPOLY *)cfp->geom_1;
  LWPOINT *point = (LWPOINT *)cfp->geom_2;
  uint32_t n = poly->rings[0]->npoints - 1;
  uint32_t v = cfp->cf_1 / 2;
  lwpoint_getPoint4d_p(point, &p);
  getPoint4d_p(poly->rings[0], v, &q);
  apply_pose_point4d(&q, cfp->pose_1);
  if (cfp->cf_1 % 2 == 0)
    dist = sqrt(pow(p.x - q.x, 2) + pow(p.y - q.y, 2));
  else /* cfp->cf_1 % 2 == 1 */
  {
    getPoint4d_p(poly->rings[0], uint_mod_add(v, 1, n), &r);
    apply_pose_point4d(&r, cfp->pose_1);
    double s = ((p.x - q.x) * (r.x - q.x)
      + (p.y - q.y) * (r.y - q.y)) / (pow(r.x - q.x, 2) + pow(r.y - q.y, 2));
    if (s <= 0 || s >= 1)
    {
      /*printf("Problem, s should be between 0 and 1: s = %lf\n", s);
      fflush(stdout);*/
      return;
    }
    double x = q.x  + (r.x - q.x) * s;
    double y = q.y  + (r.y - q.y) * s;
    dist = sqrt(pow(p.x - x, 2) + pow(p.y - y, 2));
  }
  tdist_elem td = tdist_make(dist, cfp->t);
  append_tdist_elem(tda, td);
}

static double
f_turnpoints_v_v_tpoint_poly(POINT4D p, POINT4D q,
  Pose *poly_pose_s, Pose *poly_pose_e, double ratio)
{
  double tx, ty, ttheta;
  double dx, dy, dtheta;
  double co, si, qx, qy, qx_, qy_;
  pose_interpolate_2d(poly_pose_s, poly_pose_e, ratio, &tx, &ty, &ttheta);
  pose_diff_2d(poly_pose_s, poly_pose_e, &dx, &dy, &dtheta);
  co = cos(ttheta);
  si = sin(ttheta);
  qx = q.x * co - q.y * si + tx;
  qy = q.x * si + q.y * co + ty;
  qx_ = - q.x * si * dtheta - q.y * co * dtheta + dx;
  qy_ = q.x * co * dtheta - q.y * si * dtheta + dy;
  return 2 * ((p.x - qx) * qx_ + (p.y - qy) * qy_);
}

static double
f_turnpoints_v_e_tpoint_poly(POINT4D p, POINT4D q, POINT4D r,
  Pose *poly_pose_s, Pose *poly_pose_e, double ratio)
{
  double tx, ty, ttheta;
  double dx, dy, dtheta;
  double co, si;
  double s, s_;
  double qx, qy, qx_, qy_;
  double rx, ry, rx_, ry_;
  double x, y, x_, y_;
  double l2 = pow(q.x - r.x, 2) + pow(q.y - r.y, 2);
  pose_interpolate_2d(poly_pose_s, poly_pose_e, ratio, &tx, &ty, &ttheta);
  pose_diff_2d(poly_pose_s, poly_pose_e, &dx, &dy, &dtheta);
  co = cos(ttheta);
  si = sin(ttheta);
  qx = q.x * co - q.y * si + tx;
  qy = q.x * si + q.y * co + ty;
  qx_ = - q.x * si * dtheta - q.y * co * dtheta + dx;
  qy_ = q.x * co * dtheta - q.y * si * dtheta + dy;
  rx = r.x * co - r.y * si + tx;
  ry = r.x * si + r.y * co + ty;
  rx_ = - r.x * si * dtheta - r.y * co * dtheta + dx;
  ry_ = r.x * co * dtheta - r.y * si * dtheta + dy;
  s = ((p.x - qx) * (rx - qx) + (p.y - qy) * (ry - qy)) / l2;
  s_ = (- qx_ * (rx - qx) + (p.x - qx) * (rx_ - qx_) - qy_ * (ry - qy) + (p.y - qy) * (ry_ - qy_)) / l2;
  x = qx + (rx - qx) * s;
  y = qy + (ry - qy) * s;
  x_ = (qx_ + (rx_ - qx_) * s) + (rx - qx) * s_;
  y_ = (qy_ + (ry_ - qy_) * s) + (ry - qy) * s_;
  return 2 * ((p.x - x) * x_ + (p.y - y) * y_);
}

static void
compute_turnpoints_tpoly_point(cfp_elem *cfp_s, cfp_elem *cfp_e, tdist_array *tda)
{
  if (fabs(cfp_s->pose_1->data[0] - cfp_e->pose_1->data[0]) < MEOS_EPSILON &&
      fabs(cfp_s->pose_1->data[1] - cfp_e->pose_1->data[1]) < MEOS_EPSILON &&
      fabs(cfp_s->pose_1->data[2] - cfp_e->pose_1->data[2]) < MEOS_EPSILON)
      return;

  double dist;
  POINT4D p, q, r;
  LWPOLY *poly = (LWPOLY *)cfp_s->geom_1;
  LWPOINT *point = (LWPOINT *)cfp_s->geom_2;
  uint32_t v = cfp_s->cf_1 / 2;
  uint32_t n = poly->rings[0]->npoints - 1;
  lwpoint_getPoint4d_p(point, &p);
  getPoint4d_p(poly->rings[0], v, &q);
  getPoint4d_p(poly->rings[0], uint_mod_add(v, 1, n), &r);

  if (fabs(cfp_s->pose_1->data[2] - cfp_e->pose_1->data[2]) < MEOS_EPSILON)
  {
    double ratio;
    apply_pose_point4d(&q, cfp_s->pose_1);
    apply_pose_point4d(&r, cfp_s->pose_1);
    double dx = cfp_s->pose_1->data[0] - cfp_e->pose_1->data[0];
    double dy = cfp_s->pose_1->data[1] - cfp_e->pose_1->data[1];
    if (cfp_s->cf_1 % 2 == 0)
    {
      ratio = (dx * (q.x - p.x) + dy * (q.y - p.y)) / (dx * dx + dy * dy);
      if (0 < ratio && ratio < 1)
      {
        Pose *pose_at_ratio = pose_interpolate(cfp_s->pose_1, cfp_e->pose_1, ratio);
        getPoint4d_p(poly->rings[0], v, &q);
        apply_pose_point4d(&q, pose_at_ratio);
        dist = sqrt(pow(p.x - q.x, 2) + pow(p.y - q.y, 2));
        tdist_elem td = tdist_make(dist, cfp_s->t + (cfp_e->t - cfp_s->t) * ratio);
        append_tdist_elem(tda, td);
        pfree(pose_at_ratio);
      }
    }
    else /* cfp_s->cf_1 % 2 == 1 */
    {
      /* TODO: Maybe remove, since we never have turnpoints here */
      double det = dx * (r.y - q.y) - dy * (r.x - q.x);
      /* TODO: Check if we have to return ratio = 0 and ratio = 1, or nothing*/
      if (fabs(det) < MEOS_EPSILON)
        return;
      ratio = ((q.x - p.x) * (r.y - q.y) + (q.y - p.y) * (r.x - q.x)) / det;
      if (0 < ratio && ratio < 1)
      {
        Pose *pose_at_ratio = pose_interpolate(cfp_s->pose_1, cfp_e->pose_1, ratio);
        getPoint4d_p(poly->rings[0], v, &q);
        apply_pose_point4d(&q, pose_at_ratio);
        getPoint4d_p(poly->rings[0], uint_mod_add(v, 1, n), &r);
        apply_pose_point4d(&r, pose_at_ratio);
        double s = ((p.x - q.x) * (r.x - q.x)
          + (p.y - q.y) * (r.y - q.y)) / (pow(r.x - q.x, 2) + pow(r.y - q.y, 2));
        if (s <= 0 || s >= 1)
        {
          /*printf("Problem, s should be between 0 and 1: s = %lf\n", s);
          fflush(stdout);*/
          return;
        }
        double x = q.x  + (r.x - q.x) * s;
        double y = q.y  + (r.y - q.y) * s;
        dist = sqrt(pow(p.x - x, 2) + pow(p.y - y, 2));
        tdist_elem td = tdist_make(dist, cfp_s->t + (cfp_e->t - cfp_s->t) * ratio);
        append_tdist_elem(tda, td);
        pfree(pose_at_ratio);
      }
    }
    return;
  }

  for (double i = 0; i < 4; ++i)
  {
    double tl = i / 4, tr = (i + 1) / 4, t0 = -1;
    double vl, vr, v0;
    if (cfp_s->cf_1 % 2 == 0)
    {
      vl = f_turnpoints_v_v_tpoint_poly(p, q, cfp_s->pose_1, cfp_e->pose_1, tl);
      vr = f_turnpoints_v_v_tpoint_poly(p, q, cfp_s->pose_1, cfp_e->pose_1, tr);
    }
    else /* cfp_s->cf_1 % 2 == 1 */
    {
      vl = f_turnpoints_v_e_tpoint_poly(p, q, r, cfp_s->pose_1, cfp_e->pose_1, tl);
      vr = f_turnpoints_v_e_tpoint_poly(p, q, r, cfp_s->pose_1, cfp_e->pose_1, tr);
    }
    if (fabs(vr) < MEOS_EPSILON && i != 3)
      t0 = tr;
    else if (fabs(vl) > MEOS_EPSILON && fabs(vr) > MEOS_EPSILON && vl * vr < 0)
    {
      uint8_t j = 0;
      while(fabs(tr - tl) >= MEOS_EPSILON && j < 100)
      {
        ++j;
        t0 = (tl * vr - tr * vl) / (vr - vl);
        if (cfp_s->cf_1 % 2 == 0)
          v0 = f_turnpoints_v_v_tpoint_poly(p, q, cfp_s->pose_1, cfp_e->pose_1, t0);
        else /* cfp_s->cf_1 % 2 == 1 */
          v0 = f_turnpoints_v_e_tpoint_poly(p, q, r, cfp_s->pose_1, cfp_e->pose_1, t0);
        if (fabs(v0) < MEOS_EPSILON)
          break;
        if (vl * v0 <= 0)
          tr = t0, vr = v0;
        else
          tl = t0, vl = v0;
      }
    }
    if (t0 != -1)
    {
      double dx, dy, theta;
      pose_interpolate_2d(cfp_s->pose_1, cfp_e->pose_1, t0, &dx, &dy, &theta);
      double co = cos(theta);
      double si = sin(theta);
      double qx = q.x * co - q.y * si + dx;
      double qy = q.x * si + q.y * co + dy;
      if (cfp_s->cf_1 % 2 == 0)
      {
        dist = sqrt(pow(p.x - qx, 2) + pow(p.y - qy, 2));
      }
      else /* cfp_s->cf_1 % 2 == 1 */
      {
        double rx = r.x * co - r.y * si + dx;
        double ry = r.x * si + r.y * co + dy;
        double s = ((p.x - qx) * (rx - qx) + (p.y - qy) * (ry - qy)) / (pow(rx - qx, 2) + pow(ry - qy, 2));
        if (s <= 0 || s >= 1)
        {
          /*printf("Problem, s should be between 0 and 1: s = %lf\n", s);
          fflush(stdout);*/
          return;
        }
        double x = qx  + (rx - qx) * s;
        double y = qy  + (ry - qy) * s;
        dist = sqrt(pow(p.x - x, 2) + pow(p.y - y, 2));
      }
      tdist_elem td = tdist_make(dist, cfp_s->t + (cfp_e->t - cfp_s->t) * t0);
      append_tdist_elem(tda, td);
    }
  }
  return;
}

/*
 * Find the next change in closest feature
 */
static int
vertex_vertex_tpoly_point(LWPOLY *poly, Pose *pose_start, Pose *pose_end,
  LWPOINT *point, uint32_t *poly_feature, int *direction, double *ratio)
{
  uint32_t n = poly->rings[0]->npoints - 1;
  uint32_t i = *poly_feature / 2;
  /* Detect next change in closest feature */
  double ratio_1 = 2, ratio_2 = 2;
  if (*direction == MEOS_RIGHT || *direction == MEOS_ANY)
    ratio_1 = solve_s_tpoly_point(poly, point, pose_start, pose_end,
      i, *ratio, MEOS_SOLVE_0);
  if (*direction == MEOS_LEFT || *direction == MEOS_ANY)
    ratio_2 = solve_s_tpoly_point(poly, point, pose_start, pose_end,
      uint_mod_sub(i, 1, n), *ratio, MEOS_SOLVE_1);

  /* No change in closest feature */
  if (ratio_1 == 2 && ratio_2 == 2)
    return MEOS_DISJOINT;
  /* Intersection through vertex */
  else if (fabs(ratio_1 - ratio_2) < MEOS_EPSILON)
    return MEOS_INTERSECT;
  /* Go to next closest feature */
  else if (ratio_1 < ratio_2)
  {
    *direction = MEOS_RIGHT;
    *poly_feature = uint_mod_add(*poly_feature, 1, 2*n);
    *ratio = ratio_1;
    return MEOS_CONTINUE;
  }
  /* Go to previous closest feature */
  else if (ratio_2 < ratio_1)
  {
    *direction = MEOS_LEFT;
    *poly_feature = uint_mod_sub(*poly_feature, 1, 2*n);
    *ratio = ratio_2;
    return MEOS_CONTINUE;
  }
  /* Cannot happen */
  assert(false);
  return MEOS_DISJOINT;
}

/*
 * Find the next change in closest feature
 */
static int
edge_vertex_tpoly_point(LWPOLY *poly, Pose *pose_start, Pose *pose_end,
  LWPOINT *point, uint32_t *poly_feature, int *direction, double *ratio)
{
  uint32_t n = poly->rings[0]->npoints - 1;
  uint32_t i = *poly_feature / 2;
  /* Detect next change in closest feature */
  double ratio_1 = 2, ratio_2 = 2;
  if (*direction == MEOS_RIGHT || *direction == MEOS_ANY)
    ratio_1 = solve_s_tpoly_point(poly, point, pose_start, pose_end,
      i, *ratio, MEOS_SOLVE_1);
  if (*direction == MEOS_LEFT || *direction == MEOS_ANY)
    ratio_2 = solve_s_tpoly_point(poly, point, pose_start, pose_end,
      i, *ratio, MEOS_SOLVE_0);
  /* Detect intersection with the edge */
  double ratio_inter = solve_angle_0_tpoly_point(poly, point, pose_start, pose_end,
    i, *ratio);

  /* Intersection through edge */
  if (ratio_inter < ratio_1 && ratio_inter < ratio_2)
    return MEOS_INTERSECT;
  /* No change in closest feature */
  else if (ratio_1 == 2 && ratio_2 == 2)
    return MEOS_DISJOINT;
  /* Go to next closest feature */
  else if (ratio_1 < ratio_2)
  {
    *direction = MEOS_RIGHT;
    *poly_feature = uint_mod_add(*poly_feature, 1, 2*n);
    *ratio = ratio_1;
    return MEOS_CONTINUE;
  }
  /* Go to previous closest feature */
  else if (ratio_2 < ratio_1)
  {
    *direction = MEOS_LEFT;
    *poly_feature = uint_mod_sub(*poly_feature, 1, 2*n);
    *ratio = ratio_2;
    return MEOS_CONTINUE;
  }
  /* Cannot happen */
  assert(false);
  return MEOS_DISJOINT;
}

TSequence *
dist2d_tgeometryseq_point(const TSequence *seq, const GSERIALIZED *gs)
{
  /* TODO: Add check and code for stepwise seq */
  TSequence *result;
  Datum ref_geom = tgeometry_seq_geom(seq);
  GSERIALIZED *ref_gs = DatumGetGserializedP(ref_geom);

  /* TODO: check that polygon is convex */
  LWPOLY *poly = lwgeom_as_lwpoly(lwgeom_from_gserialized(ref_gs));
  LWPOINT *point = lwgeom_as_lwpoint(lwgeom_from_gserialized(gs));

  const TInstant *inst1, *inst2;
  Pose *pose1, *pose2;

  inst1 = TSEQUENCE_INST_N(seq, 0);
  pose1 = DatumGetPoseP(tinstant_value(inst1));

  /* Compute the initial closest features */
  cfp_array cfpa;
  init_cfp_array(&cfpa, seq->count);
  cfp_elem cfp = cfp_make_zero((LWGEOM *)poly, (LWGEOM *)point,
    pose1, NULL, inst1->t, MEOS_CFP_STORE);
  v_clip_tpoly_point(poly, point, pose1, &cfp.cf_1, NULL);
  append_cfp_elem(&cfpa, cfp);
  for (int i = 0; i < seq->count - 1; ++i)
  {
    /* TODO: optimise using simple checks, such as:
     * 1) cfp(0) == cfp(0.5) == cfp(1) -> no change in cf
     */
    inst1 = TSEQUENCE_INST_N(seq, i);
    inst2 = TSEQUENCE_INST_N(seq, i + 1);
    pose1 = DatumGetPoseP(tinstant_value(inst1));
    pose2 = DatumGetPoseP(tinstant_value(inst2));
    double ratio = 0.0;
    int loop = 0, state, direction = MEOS_ANY;
    /* Compute the evolution of closest features for this segment */
    do
    {
      if (cfp.cf_1 % 2 == 0) /* poly_feature is a vertex */
        state = vertex_vertex_tpoly_point(poly, pose1, pose2, point,
          &cfp.cf_1, &direction, &ratio);
      else /* poly_feature is an edge */
        state = edge_vertex_tpoly_point(poly, pose1, pose2, point,
          &cfp.cf_1, &direction, &ratio);

      if (state == MEOS_CONTINUE)
      {
        cfp.t = inst1->t + (inst2->t - inst1->t) * ratio;
        cfp.pose_1 = pose_interpolate(pose1, pose2, ratio);
        cfp.free_pose_1 = MEOS_CFP_FREE;
        cfp.store = MEOS_CFP_STORE_NO;
        append_cfp_elem(&cfpa, cfp);
      }

      if (loop++ == MEOS_MAX_ITERS) break;

    } while (state == MEOS_CONTINUE);

    if (loop > MEOS_MAX_ITERS)
      elog(ERROR, "Temporal distance: Cycle detected, current feature: %d", cfp.cf_1);

    cfp.pose_1 = pose2;
    cfp.free_pose_1 = MEOS_CFP_FREE_NO;
    cfp.t = inst2->t;
    cfp.store = MEOS_CFP_STORE;
    cfp_elem next_cfp = cfp;
    v_clip_tpoly_point(poly, point, pose2, &next_cfp.cf_1, NULL);
    append_cfp_elem(&cfpa, next_cfp);
    if (next_cfp.cf_1 != cfp.cf_1)
    {
      printf("Problem, cfp changed from %d to %d at end of temporal segment\n", cfp.cf_1, next_cfp.cf_1);
      fflush(stdout);
    }
    cfp = next_cfp;
  }

  /* Compute the linear approximation of the distance
   * given the array of closest features */
  tdist_array tda;
  init_tdist_array(&tda, cfpa.count);
  for (uint32_t i = 0; i < cfpa.count - 1; ++i)
  {
    if (cfpa.arr[i].store)
      compute_dist_tpoly_point(&cfpa.arr[i], &tda);
    compute_turnpoints_tpoly_point(&cfpa.arr[i], &cfpa.arr[i+1], &tda);
  }
  compute_dist_tpoly_point(&cfpa.arr[cfpa.count-1], &tda);

  /* Create the result tfloat */
  TInstant **instants = palloc(sizeof(TInstant *) * tda.count);
  for (uint32_t i = 0; i < tda.count; ++i)
    instants[i] = tinstant_make(Float8GetDatum(tda.arr[i].dist), T_TFLOAT, tda.arr[i].t);
  result = tsequence_make_free(instants, tda.count, seq->period.lower_inc,
    seq->period.upper_inc, MEOS_FLAGS_LINEAR_INTERP(seq->flags), NORMALIZE);

  lwpoly_free(poly);
  lwpoint_free(point);
  free_cfp_array(&cfpa);
  free_tdist_array(&tda);
  return result;
}

static double
f_tpoly_poly(POINT4D p, POINT4D q, POINT4D r,
  Pose *poly_pose_s, Pose *poly_pose_e, double ratio,
  bool solution_kind)
{
  double dx, dy, dtheta;
  double co, si, qx, qy, rx, ry;
  pose_interpolate_2d(poly_pose_s, poly_pose_e, ratio, &dx, &dy, &dtheta);
  co = cos(dtheta);
  si = sin(dtheta);
  qx = q.x * co - q.y * si + dx;
  qy = q.x * si + q.y * co + dy;
  rx = r.x * co - r.y * si + dx;
  ry = r.x * si + r.y * co + dy;
  if (solution_kind) /* MEOS_SOLVE_0 */
    return (p.x - qx) * (rx - qx) + (p.y - qy) * (ry - qy);
  else /* MEOS_SOLVE_1 */
    return (p.x - rx) * (rx - qx) + (p.y - ry) * (ry - qy);
}

static double
solve_s_tpoly_poly(LWPOLY *poly1, Pose *poly_pose_s, Pose *poly_pose_e, LWPOLY *poly2,
  uint32_t poly1_v, uint32_t poly2_v, double prev_result, bool solution_kind)
{
  uint32_t n1 = poly1->rings[0]->npoints - 1;
  POINT4D p, q, r;
  getPoint4d_p(poly2->rings[0], poly2_v, &p);
  getPoint4d_p(poly1->rings[0], poly1_v, &q);
  getPoint4d_p(poly1->rings[0], uint_mod_add(poly1_v, 1, n1), &r);

  if (fabs(poly_pose_s->data[2] - poly_pose_e->data[2]) < MEOS_EPSILON)
  {
    apply_pose_point4d(&q, poly_pose_s);
    apply_pose_point4d(&r, poly_pose_s);
    double result;
    double discr = (poly_pose_e->data[0] - poly_pose_s->data[0]) * (r.x - q.x)
                 + (poly_pose_e->data[1] - poly_pose_s->data[1]) * (r.y - q.y);
    if (fabs(discr) < MEOS_EPSILON)
      return 2;
    if (solution_kind) /* MEOS_SOLVE_0 */
      result = ((p.x - q.x) * (r.x - q.x) + (p.y - q.y) * (r.y - q.y)) / discr;
    else /* MEOS_SOLVE_1 */
      result = ((p.x - r.x) * (r.x - q.x) + (p.y - r.y) * (r.y - q.y)) / discr;
    if (result > prev_result + MEOS_EPSILON && result < 1 - MEOS_EPSILON)
      return result;
    return 2;
  }

  double tl, tr, t0 = 0; /* Make compiler quiet */
  double vl, vr, v0;
  double ts = prev_result, te = 1;
  vl = f_tpoly_poly(p, q, r, poly_pose_s, poly_pose_e,
    ts, solution_kind);
  v0 = f_tpoly_poly(p, q, r, poly_pose_s, poly_pose_e,
    (ts + te) / 2, solution_kind);
  vr = f_tpoly_poly(p, q, r, poly_pose_s, poly_pose_e,
    te, solution_kind);
  if (fabs(vl) > MEOS_EPSILON && vl * v0 < 0)
  {
    tl = ts;
    tr = (ts + te) / 2;
    vr = v0;
  }
  else if (v0 * vr < 0)
  {
    tl = (ts + te) / 2;
    tr = te;
    vl = v0;
  }
  else
    return 2;


  uint8_t i = 0;
  while(fabs(tr - tl) >= MEOS_EPSILON && i < 100)
  {
    ++i;
    t0 = (tl * vr - tr * vl) / (vr - vl);
    v0 = f_tpoly_poly(p, q, r, poly_pose_s, poly_pose_e,
      t0, solution_kind);
    if (fabs(v0) < MEOS_EPSILON)
      break;
    if (vl * v0 <= 0)
      tr = t0, vr = v0;
    else
      tl = t0, vl = v0;
  }
  return t0;
}

static double
f_poly_tpoly(POINT4D p, POINT4D q, POINT4D r,
  Pose *poly_pose_s, Pose *poly_pose_e, double ratio,
  bool solution_kind)
{
  double dx, dy, dtheta;
  double co, si, px, py;
  pose_interpolate_2d(poly_pose_s, poly_pose_e, ratio, &dx, &dy, &dtheta);
  co = cos(dtheta);
  si = sin(dtheta);
  px = p.x * co - p.y * si + dx;
  py = p.x * si + p.y * co + dy;
  if (solution_kind) /* MEOS_SOLVE_0 */
    return (px - q.x) * (r.x - q.x) + (py - q.y) * (r.y - q.y);
  else /* MEOS_SOLVE_1 */
    return (px - r.x) * (r.x - q.x) + (py - r.y) * (r.y - q.y);
}

static double
solve_s_poly_tpoly(LWPOLY *poly1, LWPOLY *poly2, Pose *poly_pose_s, Pose *poly_pose_e,
  uint32_t poly1_v, uint32_t poly2_v, double prev_result, bool solution_kind)
{
  uint32_t n1 = poly1->rings[0]->npoints - 1;
  POINT4D p, q, r;
  getPoint4d_p(poly2->rings[0], poly2_v, &p);
  getPoint4d_p(poly1->rings[0], poly1_v, &q);
  getPoint4d_p(poly1->rings[0], uint_mod_add(poly1_v, 1, n1), &r);

  if (fabs(poly_pose_s->data[2] - poly_pose_e->data[2]) < MEOS_EPSILON)
  {
    apply_pose_point4d(&p, poly_pose_s);
    double result;
    double discr = - (poly_pose_e->data[0] - poly_pose_s->data[0]) * (r.x - q.x)
                   - (poly_pose_e->data[1] - poly_pose_s->data[1]) * (r.y - q.y);
    if (fabs(discr) < MEOS_EPSILON)
      return 2;
    if (solution_kind) /* MEOS_SOLVE_0 */
      result = ((p.x - q.x) * (r.x - q.x) + (p.y - q.y) * (r.y - q.y)) / discr;
    else /* MEOS_SOLVE_1 */
      result = ((p.x - r.x) * (r.x - q.x) + (p.y - r.y) * (r.y - q.y)) / discr;
    if (result > prev_result + MEOS_EPSILON && result < 1 - MEOS_EPSILON)
      return result;
    return 2;
  }

  double tl, tr, t0 = 0; /* Make compiler quiet */
  double vl, vr, v0;
  double ts = prev_result, te = 1;
  vl = f_poly_tpoly(p, q, r, poly_pose_s, poly_pose_e,
    ts, solution_kind);
  v0 = f_poly_tpoly(p, q, r, poly_pose_s, poly_pose_e,
    (ts + te) / 2, solution_kind);
  vr = f_poly_tpoly(p, q, r, poly_pose_s, poly_pose_e,
    te, solution_kind);
  if (fabs(vl) > MEOS_EPSILON && vl * v0 < 0)
  {
    tl = ts;
    tr = (ts + te) / 2;
    vr = v0;
  }
  else if (v0 * vr < 0)
  {
    tl = (ts + te) / 2;
    tr = te;
    vl = v0;
  }
  else
    return 2;


  uint8_t i = 0;
  while(fabs(tr - tl) >= MEOS_EPSILON && i < 100)
  {
    ++i;
    t0 = (tl * vr - tr * vl) / (vr - vl);
    v0 = f_poly_tpoly(p, q, r, poly_pose_s, poly_pose_e,
      t0, solution_kind);
    if (fabs(v0) < MEOS_EPSILON)
      break;
    if (vl * v0 <= 0)
      tr = t0, vr = v0;
    else
      tl = t0, vl = v0;
  }
  return t0;
}

/*
 * Find the next change in closest feature
 */
static int
vertex_vertex_tpoly_poly(LWPOLY *poly1, Pose *pose_start, Pose *pose_end,
  LWPOLY *poly2, uint32_t *poly1_feature, uint32_t *poly2_feature,
  int *dir1, int *dir2, double *ratio)
{
  uint32_t n1 = poly1->rings[0]->npoints - 1;
  uint32_t i1 = *poly1_feature / 2;
  uint32_t n2 = poly2->rings[0]->npoints - 1;
  uint32_t i2 = *poly2_feature / 2;
  double ratio_1 = 2, ratio_2 = 2, ratio_3 = 2, ratio_4 = 2;
  /* Detect if vertex of poly2 exits vertex of poly1 -> change poly1_feature */
  if (*dir1 == MEOS_RIGHT || *dir1 == MEOS_ANY)
    ratio_1 = solve_s_tpoly_poly(poly1, pose_start, pose_end, poly2,
      i1, i2, *ratio, MEOS_SOLVE_0);
  if (*dir1 == MEOS_LEFT || *dir1 == MEOS_ANY)
    ratio_2 = solve_s_tpoly_poly(poly1, pose_start, pose_end, poly2,
      uint_mod_sub(i1, 1, n1), i2, *ratio, MEOS_SOLVE_1);
  /* Detect if vertex of poly1 exits vertex of poly2 -> change poly2_feature */
  if (*dir2 == MEOS_RIGHT || *dir2 == MEOS_ANY)
    ratio_3 = solve_s_poly_tpoly(poly2, poly1, pose_start, pose_end,
      i2, i1, *ratio, MEOS_SOLVE_0);
  if (*dir2 == MEOS_LEFT || *dir2 == MEOS_ANY)
    ratio_4 = solve_s_poly_tpoly(poly2, poly1, pose_start, pose_end,
      uint_mod_sub(i2, 1, n2), i1, *ratio, MEOS_SOLVE_1);

  // printf("%lf, %lf, %lf, %f\n", ratio_1, ratio_2, ratio_3, ratio_4);
  // fflush(stdout);

  /* No change in closest feature */
  if (ratio_1 == 2 && ratio_2 == 2 && ratio_3 == 2 && ratio_4 == 2)
    return MEOS_DISJOINT;
  /* Intersection through vertex */
  else if (((ratio_1 != 2 || ratio_2 != 2) && fabs(ratio_1 - ratio_2) < MEOS_EPSILON)
        || ((ratio_3 != 2 || ratio_4 != 2) && fabs(ratio_3 - ratio_4) < MEOS_EPSILON))
    return MEOS_INTERSECT;
  /* Go to next closest feature */
  else if (ratio_1 <= ratio_2 && ratio_1 <= ratio_3 && ratio_1 <= ratio_4)
  {
    *dir1 = MEOS_RIGHT;
    *poly1_feature = uint_mod_add(*poly1_feature, 1, 2*n1);
    *ratio = ratio_1;
    return MEOS_CONTINUE;
  }
  /* Go to previous closest feature */
  else if (ratio_2 <= ratio_3 && ratio_2 <= ratio_4)
  {
    *dir1 = MEOS_LEFT;
    *poly1_feature = uint_mod_sub(*poly1_feature, 1, 2*n1);
    *ratio = ratio_2;
    return MEOS_CONTINUE;
  }
  else if (ratio_3 <= ratio_4)
  {
    *dir2 = MEOS_RIGHT;
    *poly2_feature = uint_mod_add(*poly2_feature, 1, 2*n2);
    *ratio = ratio_3;
    return MEOS_CONTINUE;
  }
  /* Go to previous closest feature */
  else
  {
    *dir2 = MEOS_LEFT;
    *poly2_feature = uint_mod_sub(*poly2_feature, 1, 2*n2);
    *ratio = ratio_4;
    return MEOS_CONTINUE;
  }
}

static double
f_parallel_edges_tpoly_poly(LWPOLY *poly1, Pose *poly_pose_s, Pose *poly_pose_e,
  LWPOLY *poly2, uint32_t poly1_v, uint32_t poly2_v, double ratio)
{
  uint32_t n1 = poly1->rings[0]->npoints - 1;
  uint32_t n2 = poly2->rings[0]->npoints - 1;
  POINT4D ps, pe, qs, qe;
  getPoint4d_p(poly1->rings[0], poly1_v, &qs);
  getPoint4d_p(poly1->rings[0], uint_mod_add(poly1_v, 1, n1), &qe);
  getPoint4d_p(poly2->rings[0], poly2_v, &ps);
  getPoint4d_p(poly2->rings[0], uint_mod_add(poly2_v, 1, n2), &pe);
  double dx, dy, dtheta;
  double co, si, qsx, qsy, qex, qey;
  pose_interpolate_2d(poly_pose_s, poly_pose_e, ratio, &dx, &dy, &dtheta);
  co = cos(dtheta);
  si = sin(dtheta);
  qsx = qs.x * co - qs.y * si + dx;
  qsy = qs.x * si + qs.y * co + dy;
  qex = qe.x * co - qe.y * si + dx;
  qey = qe.x * si + qe.y * co + dy;
  return (pe.x - ps.x) * (qey - qsy) - (pe.y - ps.y) * (qex - qsx);
}

static double
solve_parallel_edges_tpoly_poly(LWPOLY *poly1, Pose *poly_pose_s, Pose *poly_pose_e,
  LWPOLY *poly2, uint32_t poly1_v, uint32_t poly2_v, double prev_result)
{
  /* No rotation during movement
   * Edges do not rotate, so no need to solve this */
  if (fabs(poly_pose_s->data[2] - poly_pose_e->data[2]) < MEOS_EPSILON)
    return 2;

  double tl, tr, t0 = 0; /* Make compiler quiet */
  double vl, vr, v0;
  double ts = prev_result, te = 1;
  vl = f_parallel_edges_tpoly_poly(poly1, poly_pose_s, poly_pose_e, poly2,
    poly1_v, poly2_v, ts);
  v0 = f_parallel_edges_tpoly_poly(poly1, poly_pose_s, poly_pose_e, poly2,
    poly1_v, poly2_v, (ts + te) / 2);
  vr = f_parallel_edges_tpoly_poly(poly1, poly_pose_s, poly_pose_e, poly2,
    poly1_v, poly2_v, te);
  // printf("%lf, %lf, %lf\n", vl, v0, vr);
  // fflush(stdout);
  if (fabs(vl) > MEOS_EPSILON && vl * v0 < 0)
  {
    tl = ts;
    tr = (ts + te) / 2;
    vr = v0;
  }
  else if (v0 * vr < 0)
  {
    tl = (ts + te) / 2;
    tr = te;
    vl = v0;
  }
  else
    return 2;


  uint8_t i = 0;
  while(fabs(tr - tl) >= MEOS_EPSILON && i < 100)
  {
    ++i;
    t0 = (tl * vr - tr * vl) / (vr - vl);
    v0 = f_parallel_edges_tpoly_poly(poly1, poly_pose_s, poly_pose_e, poly2,
      poly1_v, poly2_v, t0);
    if (fabs(v0) < MEOS_EPSILON)
      break;
    if (vl * v0 <= 0)
      tr = t0, vr = v0;
    else
      tl = t0, vl = v0;
  }
  if (fabs(t0 - prev_result) < MEOS_EPSILON)
    return 2;
  return t0;
}

static double
solve_angle_0_poly_tpoly(LWPOLY *poly1, LWPOLY *poly2, Pose *poly_pose_s, Pose *poly_pose_e,
  uint32_t poly1_v, uint32_t poly2_v, double ratio)
{
  return 2;
}

/*
 * Find the next change in closest feature
 */
static int
vertex_edge_tpoly_poly(LWPOLY *poly1, Pose *pose_start, Pose *pose_end,
  LWPOLY *poly2, uint32_t *poly1_feature, uint32_t *poly2_feature,
  int *dir1, int *dir2, double *ratio)
{
  uint32_t n1 = poly1->rings[0]->npoints - 1;
  uint32_t i1 = *poly1_feature / 2;
  uint32_t n2 = poly2->rings[0]->npoints - 1;
  uint32_t i2 = *poly2_feature / 2;
  double ratio_1 = 2, ratio_2 = 2, ratio_3 = 2, ratio_4 = 2, ratio_inter;
  /* Detect if vertex of poly1 exits edge of poly2 -> change poly2_feature */
  if (*dir2 == MEOS_RIGHT || *dir2 == MEOS_ANY)
    ratio_1 = solve_s_poly_tpoly(poly2, poly1, pose_start, pose_end,
      i2, i1, *ratio, MEOS_SOLVE_1);
  if (*dir2 == MEOS_LEFT || *dir2 == MEOS_ANY)
    ratio_2 = solve_s_poly_tpoly(poly2, poly1, pose_start, pose_end,
      i2, i1, *ratio, MEOS_SOLVE_0);
  /* Detect parallel edges -> 2 changes in closest features at once */
  ratio_3 = solve_parallel_edges_tpoly_poly(poly1, pose_start, pose_end, poly2,
    i1, i2, *ratio);
  ratio_4 = solve_parallel_edges_tpoly_poly(poly1, pose_start, pose_end, poly2,
    uint_mod_sub(i1, 1, n1), i2, *ratio);
  /* Detect intersection with the edge */
  ratio_inter = solve_angle_0_poly_tpoly(poly2, poly1, pose_start, pose_end,
    i2, i1, *ratio);

  // printf("%lf, %lf, %lf, %f\n", ratio_1, ratio_2, ratio_3, ratio_4);
  // fflush(stdout);

  /* Intersection through edge */
  if (ratio_inter < ratio_1 && ratio_inter < ratio_2)
    return MEOS_INTERSECT;
  /* No change in closest feature */
  else if (ratio_1 == 2 && ratio_2 == 2 && ratio_3 == 2 && ratio_4 == 2)
    return MEOS_DISJOINT;
  /* Go to next closest feature of poly2 */
  else if (ratio_1 <= ratio_2 && ratio_1 <= ratio_3 && ratio_1 <= ratio_4)
  {
    *dir2 = MEOS_RIGHT;
    *poly2_feature = uint_mod_add(*poly2_feature, 1, 2*n2);
    *ratio = ratio_1;
    return MEOS_CONTINUE;
  }
  /* Go to previous closest feature of poly2 */
  else if (ratio_2 <= ratio_3 && ratio_2 <= ratio_4)
  {
    *dir2 = MEOS_LEFT;
    *poly2_feature = uint_mod_sub(*poly2_feature, 1, 2*n2);
    *ratio = ratio_2;
    return MEOS_CONTINUE;
  }
  /* Next edge of poly1 is parallel with edge of poly2 */
  else if (ratio_3 <= ratio_4)
  {
    /* Determine how to update closest feature */
    uint32_t n1 = poly1->rings[0]->npoints - 1;
    uint32_t n2 = poly2->rings[0]->npoints - 1;
    POINT4D ps, pe, qs, qe;
    getPoint4d_p(poly1->rings[0], i1, &qs);
    getPoint4d_p(poly1->rings[0], uint_mod_add(i1, 1, n1), &qe);
    getPoint4d_p(poly2->rings[0], i2, &ps);
    getPoint4d_p(poly2->rings[0], uint_mod_add(i2, 1, n2), &pe);
    Pose *pose = pose_interpolate(pose_start, pose_end, ratio_3);
    apply_pose_point4d(&qs, pose);
    apply_pose_point4d(&qe, pose);
    pfree(pose);
    /* TODO: check if we assume that ccw1 == ccw2 here or not */
    double s1 = compute_s(qe, ps, pe);
    double s2 = compute_s(ps, qs, qe);
    // printf("C: %lf, %lf\n", s1, s2);
    // fflush(stdout);
    if (0 < s1 && s1 < 1)
    {
      /* Next features:
       * - next vertex of poly1
       * - current edge of poly2*/
      // *dir1 = MEOS_RIGHT;
      *poly1_feature = uint_mod_add(*poly1_feature, 2, 2*n1);
    }
    else if (0 < s2 && s2 < 1)
    {
      /* Next features:
       * - next edge of poly1
       * - previous vertex of poly2*/
      // *dir1 = MEOS_RIGHT;
      *poly1_feature = uint_mod_add(*poly1_feature, 1, 2*n1);
      // *dir2 = MEOS_LEFT;
      *poly2_feature = uint_mod_sub(*poly2_feature, 1, 2*n2);
    }
    else
    {
      /* Endpoints of the edges are aligned
       * Next features:
       * - next vertex of poly1
       * - previous vertex of poly2*/
      // *dir1 = MEOS_RIGHT;
      *poly1_feature = uint_mod_add(*poly1_feature, 2, 2*n1);
      // *dir2 = MEOS_LEFT;
      *poly2_feature = uint_mod_sub(*poly2_feature, 1, 2*n2);
    }
    *ratio = ratio_3;
    return MEOS_CONTINUE;
  }
  /* Next edge of poly1 is parallel with edge of poly2 */
  else
  {
    /* Determine how to update closest feature */
    uint32_t n1 = poly1->rings[0]->npoints - 1;
    uint32_t n2 = poly2->rings[0]->npoints - 1;
    POINT4D ps, pe, qs, qe;
    getPoint4d_p(poly1->rings[0], uint_mod_sub(i1, 1, n1), &qs);
    getPoint4d_p(poly1->rings[0], i1, &qe);
    getPoint4d_p(poly2->rings[0], i2, &ps);
    getPoint4d_p(poly2->rings[0], uint_mod_add(i2, 1, n2), &pe);
    Pose *pose = pose_interpolate(pose_start, pose_end, ratio_4);
    apply_pose_point4d(&qs, pose);
    apply_pose_point4d(&qe, pose);
    pfree(pose);
    /* TODO: check if we assume that ccw1 == ccw2 here or not */
    double s1 = compute_s(qs, ps, pe);
    double s2 = compute_s(pe, qs, qe);
    // printf("D: %lf, %lf\n", s1, s2);
    // fflush(stdout);
    if (0 < s1 && s1 < 1)
    {
      /* Next features:
       * - previous vertex of poly1
       * - current edge of poly2*/
      // *dir1 = MEOS_LEFT;
      *poly1_feature = uint_mod_sub(*poly1_feature, 2, 2*n1);
    }
    else if (0 < s2 && s2 < 1)
    {
      /* Next features:
       * - previous edge of poly1
       * - next vertex of poly2*/
      // *dir1 = MEOS_LEFT;
      *poly1_feature = uint_mod_sub(*poly1_feature, 1, 2*n1);
      // *dir2 = MEOS_RIGHT;
      *poly2_feature = uint_mod_add(*poly2_feature, 1, 2*n2);
    }
    else
    {
      /* Endpoints of the edges are aligned
       * Next features:
       * - previous vertex of poly1
       * - next vertex of poly2*/
      // *dir1 = MEOS_LEFT;
      *poly1_feature = uint_mod_sub(*poly1_feature, 2, 2*n1);
      // *dir2 = MEOS_RIGHT;
      *poly2_feature = uint_mod_add(*poly2_feature, 1, 2*n2);
    }
    *ratio = ratio_4;
    return MEOS_CONTINUE;
  }
  /* Cannot happen */
  assert(false);
  return MEOS_DISJOINT;
}

/*
 * Find the next change in closest feature
 */
static int
edge_vertex_tpoly_poly(LWPOLY *poly1, Pose *pose_start, Pose *pose_end,
  LWPOLY *poly2, uint32_t *poly1_feature, uint32_t *poly2_feature,
  int *dir1, int *dir2, double *ratio)
{
  uint32_t n1 = poly1->rings[0]->npoints - 1;
  uint32_t i1 = *poly1_feature / 2;
  uint32_t n2 = poly2->rings[0]->npoints - 1;
  uint32_t i2 = *poly2_feature / 2;
  double ratio_1 = 2, ratio_2 = 2, ratio_3 = 2, ratio_4 = 2, ratio_inter;
  /* Detect if vertex of poly2 exits edge of poly1 -> change poly1_feature */
  if (*dir1 == MEOS_RIGHT || *dir1 == MEOS_ANY)
    ratio_1 = solve_s_tpoly_poly(poly1, pose_start, pose_end, poly2,
      i1, i2, *ratio, MEOS_SOLVE_1);
  if (*dir1 == MEOS_LEFT || *dir1 == MEOS_ANY)
    ratio_2 = solve_s_tpoly_poly(poly1, pose_start, pose_end, poly2,
      i1, i2, *ratio, MEOS_SOLVE_0);
  /* Detect parallel edges -> 2 changes in closest features at once */
  ratio_3 = solve_parallel_edges_tpoly_poly(poly1, pose_start, pose_end, poly2,
    i1, i2, *ratio);
  ratio_4 = solve_parallel_edges_tpoly_poly(poly1, pose_start, pose_end, poly2,
    i1, uint_mod_sub(i2, 1, n2), *ratio);
  /* Detect intersection with the edge */
  ratio_inter = solve_angle_0_poly_tpoly(poly2, poly1, pose_start, pose_end,
    i2, i1, *ratio);

  // printf("%lf, %lf, %lf, %f\n", ratio_1, ratio_2, ratio_3, ratio_4);
  // fflush(stdout);

  /* Intersection through edge */
  if (ratio_inter < ratio_1 && ratio_inter < ratio_2)
    return MEOS_INTERSECT;
  /* No change in closest feature */
  else if (ratio_1 == 2 && ratio_2 == 2 && ratio_3 == 2 && ratio_4 == 2)
    return MEOS_DISJOINT;
  /* Go to next closest feature of poly1 */
  else if (ratio_1 <= ratio_2 && ratio_1 <= ratio_3 && ratio_1 <= ratio_4)
  {
    *dir1 = MEOS_RIGHT;
    *poly1_feature = uint_mod_add(*poly1_feature, 1, 2*n1);
    *ratio = ratio_1;
    return MEOS_CONTINUE;
  }
  /* Go to previous closest feature of poly1 */
  else if (ratio_2 <= ratio_3 && ratio_2 <= ratio_4)
  {
    *dir1 = MEOS_LEFT;
    *poly1_feature = uint_mod_sub(*poly1_feature, 1, 2*n1);
    *ratio = ratio_2;
    return MEOS_CONTINUE;
  }
  /* Next edge of poly2 is parallel with edge of poly1 */
  else if (ratio_3 <= ratio_4)
  {
    /* Determine how to update closest feature */
    uint32_t n1 = poly1->rings[0]->npoints - 1;
    uint32_t n2 = poly2->rings[0]->npoints - 1;
    POINT4D ps, pe, qs, qe;
    getPoint4d_p(poly1->rings[0], i1, &qs);
    getPoint4d_p(poly1->rings[0], uint_mod_add(i1, 1, n1), &qe);
    getPoint4d_p(poly2->rings[0], i2, &ps);
    getPoint4d_p(poly2->rings[0], uint_mod_add(i2, 1, n2), &pe);
    Pose *pose = pose_interpolate(pose_start, pose_end, ratio_3);
    apply_pose_point4d(&qs, pose);
    apply_pose_point4d(&qe, pose);
    pfree(pose);
    /* TODO: check if we assume that ccw1 == ccw2 here or not */
    double s1 = compute_s(pe, qs, qe);
    double s2 = compute_s(qs, ps, pe);
    // printf("A: %lf, %lf\n", s1, s2);
    // fflush(stdout);
    if (0 < s1 && s1 < 1)
    {
      /* Next features:
       * - next vertex of poly2
       * - current edge of poly1 */
      // *dir2 = MEOS_RIGHT;
      *poly2_feature = uint_mod_add(*poly2_feature, 2, 2*n2);
    }
    else if (0 < s2 && s2 < 1)
    {
      /* Next features:
       * - next edge of poly2
       * - previous vertex of poly1 */
      // *dir2 = MEOS_RIGHT;
      *poly2_feature = uint_mod_add(*poly2_feature, 1, 2*n2);
      // *dir1 = MEOS_LEFT;
      *poly1_feature = uint_mod_sub(*poly1_feature, 1, 2*n1);
    }
    else
    {
      /* Endpoints of the edges are aligned
       * Next features:
       * - next vertex of poly2
       * - previous vertex of poly1 */
      // *dir2 = MEOS_RIGHT;
      *poly2_feature = uint_mod_add(*poly2_feature, 2, 2*n2);
      // *dir1 = MEOS_LEFT;
      *poly1_feature = uint_mod_sub(*poly1_feature, 1, 2*n1);
    }
    *ratio = ratio_3;
    return MEOS_CONTINUE;
  }
  /* Next edge of poly2 is parallel with edge of poly1 */
  else
  {
    /* Determine how to update closest feature */
    uint32_t n1 = poly1->rings[0]->npoints - 1;
    uint32_t n2 = poly2->rings[0]->npoints - 1;
    POINT4D ps, pe, qs, qe;
    getPoint4d_p(poly1->rings[0], i1, &qs);
    getPoint4d_p(poly1->rings[0], uint_mod_add(i1, 1, n1), &qe);
    getPoint4d_p(poly2->rings[0], uint_mod_sub(i2, 1, n2), &ps);
    getPoint4d_p(poly2->rings[0], i2, &pe);
    Pose *pose = pose_interpolate(pose_start, pose_end, ratio_4);
    apply_pose_point4d(&qs, pose);
    apply_pose_point4d(&qe, pose);
    pfree(pose);
    /* TODO: check if we assume that ccw1 == ccw2 here or not */
    double s1 = compute_s(ps, qs, qe);
    double s2 = compute_s(qe, ps, pe);
    // printf("B: %lf, %lf\n", s1, s2);
    // fflush(stdout);
    if (0 < s1 && s1 < 1)
    {
      /* Next features:
       * - previous vertex of poly2
       * - current edge of poly1 */
      // *dir2 = MEOS_LEFT;
      *poly2_feature = uint_mod_sub(*poly2_feature, 2, 2*n2);
    }
    else if (0 < s2 && s2 < 1)
    {
      /* Next features:
       * - previous edge of poly2
       * - next vertex of poly1 */
      // *dir2 = MEOS_LEFT;
      *poly2_feature = uint_mod_sub(*poly2_feature, 1, 2*n2);
      // *dir1 = MEOS_RIGHT;
      *poly1_feature = uint_mod_add(*poly1_feature, 1, 2*n1);
    }
    else
    {
      /* Endpoints of the edges are aligned
       * Next features:
       * - previous vertex of poly2
       * - next vertex of poly1 */
      // *dir2 = MEOS_LEFT;
      *poly2_feature = uint_mod_sub(*poly2_feature, 2, 2*n2);
      // *dir1 = MEOS_RIGHT;
      *poly1_feature = uint_mod_add(*poly1_feature, 1, 2*n1);
    }
    *ratio = ratio_4;
    return MEOS_CONTINUE;
  }
  /* Cannot happen */
  assert(false);
  return MEOS_DISJOINT;
}

static void
compute_dist_tpoly_poly(cfp_elem *cfp, tdist_array *tda)
{
  double dist;
  POINT4D ps, pe, qs, qe;
  LWPOLY *poly1 = (LWPOLY *)cfp->geom_1;
  LWPOLY *poly2 = (LWPOLY *)cfp->geom_2;
  uint32_t n1 = poly1->rings[0]->npoints - 1;
  uint32_t n2 = poly2->rings[0]->npoints - 1;
  uint32_t v1 = cfp->cf_1 / 2;
  uint32_t v2 = cfp->cf_2 / 2;
  getPoint4d_p(poly2->rings[0], v2, &ps);
  getPoint4d_p(poly1->rings[0], v1, &qs);
  apply_pose_point4d(&qs, cfp->pose_1);
  if (cfp->cf_1 % 2 == 0 && cfp->cf_2 % 2 == 0)
    dist = sqrt(pow(ps.x - qs.x, 2) + pow(ps.y - qs.y, 2));
  else if (cfp->cf_2 % 2 == 0) /* cfp->cf_1 % 2 == 1 */
  {
    getPoint4d_p(poly1->rings[0], uint_mod_add(v1, 1, n1), &qe);
    apply_pose_point4d(&qe, cfp->pose_1);
    double s = ((ps.x - qs.x) * (qe.x - qs.x)
      + (ps.y - qs.y) * (qe.y - qs.y)) / (pow(qe.x - qs.x, 2) + pow(qe.y - qs.y, 2));
    if (s <= 0 || s >= 1)
    {
      printf("Problem 1, s should be between 0 and 1: s = %lf\n", s);
      fflush(stdout);
      return;
    }
    double x = qs.x  + (qe.x - qs.x) * s;
    double y = qs.y  + (qe.y - qs.y) * s;
    dist = sqrt(pow(ps.x - x, 2) + pow(ps.y - y, 2));
  }
  else /* cfp->cf_1 % 2 == 0 && cfp->cf_2 % 2 == 1 */
  {
    getPoint4d_p(poly2->rings[0], uint_mod_add(v2, 1, n2), &pe);
    double s = ((qs.x - ps.x) * (pe.x - ps.x)
      + (qs.y - ps.y) * (pe.y - ps.y)) / (pow(pe.x - ps.x, 2) + pow(pe.y - ps.y, 2));
    if (s <= 0 || s >= 1)
    {
      printf("Problem 2, s should be between 0 and 1: s = %lf\n", s);
      fflush(stdout);
      return;
    }
    double x = ps.x  + (pe.x - ps.x) * s;
    double y = ps.y  + (pe.y - ps.y) * s;
    dist = sqrt(pow(qs.x - x, 2) + pow(qs.y - y, 2));
  }
  tdist_elem td = tdist_make(dist, cfp->t);
  append_tdist_elem(tda, td);
}

TSequence *
dist2d_tgeometryseq_poly(const TSequence *seq, const GSERIALIZED *gs)
{
  /* TODO: Add check and code for stepwise seq */
  TSequence *result;
  Datum ref_geom = tgeometry_seq_geom(seq);
  GSERIALIZED *ref_gs = DatumGetGserializedP(ref_geom);

  /* TODO: check that both polygons are convex */
  LWPOLY *poly1 = lwgeom_as_lwpoly(lwgeom_from_gserialized(ref_gs));
  LWPOLY *poly2 = lwgeom_as_lwpoly(lwgeom_from_gserialized(gs));

  const TInstant *inst1, *inst2;
  Pose *pose1, *pose2;

  inst1 = TSEQUENCE_INST_N(seq, 0);
  pose1 = DatumGetPoseP(tinstant_value(inst1));

  /* Compute the initial closest features */
  cfp_array cfpa;
  init_cfp_array(&cfpa, seq->count);
  cfp_elem cfp = cfp_make_zero((LWGEOM *)poly1, (LWGEOM *)poly2,
    pose1, NULL, inst1->t, MEOS_CFP_STORE);
  v_clip_tpoly_tpoly(poly1, poly2, pose1, NULL, &cfp.cf_1, &cfp.cf_2, NULL);
  append_cfp_elem(&cfpa, cfp);
  for (int i = 0; i < seq->count - 1; ++i)
  {
    // printf("Segment %d\n", i);
    // fflush(stdout);
    /* TODO: optimise using simple checks, such as:
     * 1) cfp(0) == cfp(0.5) == cfp(1) -> no change in cf
     */
    inst1 = TSEQUENCE_INST_N(seq, i);
    inst2 = TSEQUENCE_INST_N(seq, i + 1);
    pose1 = DatumGetPoseP(tinstant_value(inst1));
    pose2 = DatumGetPoseP(tinstant_value(inst2));
    double ratio = 0.0;
    int loop = 0, state, dir1 = MEOS_ANY, dir2 = MEOS_ANY;
    /* Compute the evolution of closest features for this segment */
    do
    {
      // printf("Features before %d, %d\n", cfp.cf_1, cfp.cf_2);
      // printf("Dirs before = (%d, %d)\n", dir1, dir2);
      // fflush(stdout);

      if (cfp.cf_1 % 2 == 0 && cfp.cf_2 % 2 == 0) /* vertex <-> vertex */
        state = vertex_vertex_tpoly_poly(poly1, pose1, pose2, poly2,
          &cfp.cf_1, &cfp.cf_2, &dir1, &dir2, &ratio);
      else if (cfp.cf_1 % 2 == 0) /* vertex <-> edge */
        state = vertex_edge_tpoly_poly(poly1, pose1, pose2, poly2,
          &cfp.cf_1, &cfp.cf_2, &dir1, &dir2, &ratio);
      else if (cfp.cf_2 % 2 == 0) /* edge <-> vertex */
        state = edge_vertex_tpoly_poly(poly1, pose1, pose2, poly2,
          &cfp.cf_1, &cfp.cf_2, &dir1, &dir2, &ratio);
      else /* edge <-> edge */
        // state = edge_edge_tpoly_poly(poly1, pose1, pose2, poly2,
        //   &cfp.cf_1, &cfp.cf_2, &dir1, &dir2, &ratio);
        elog(ERROR, "Can't happen");

      // printf("Features after %d, %d\n", cfp.cf_1, cfp.cf_2);
      // printf("Dirs after = (%d, %d)\n", dir1, dir2);
      // fflush(stdout);

      if (state == MEOS_CONTINUE)
      {
        cfp.t = inst1->t + (inst2->t - inst1->t) * ratio;
        cfp.pose_1 = pose_interpolate(pose1, pose2, ratio);
        cfp.free_pose_1 = MEOS_CFP_FREE;
        cfp.store = MEOS_CFP_STORE_NO;
        append_cfp_elem(&cfpa, cfp);
      }

      // cfp_elem test_cfp = cfp;
      // v_clip_tpoly_tpoly(poly1, poly2, cfp.pose_1, NULL, &test_cfp.cf_1, &test_cfp.cf_2, NULL);
      // if (test_cfp.cf_1 != cfp.cf_1 || test_cfp.cf_2 != cfp.cf_2)
      // {
      //   printf("Problem, test cfp changed from (%d, %d) to (%d, %d) during temporal segment\n",
      //     cfp.cf_1, cfp.cf_2, test_cfp.cf_1, test_cfp.cf_2);
      //   fflush(stdout);
      // }

      if (loop++ == MEOS_MAX_ITERS) break;

    } while (state == MEOS_CONTINUE);

    if (loop > MEOS_MAX_ITERS)
      elog(ERROR, "Temporal distance: Cycle detected, current features: (%d, %d)", cfp.cf_1, cfp.cf_2);

    cfp.pose_1 = pose2;
    cfp.free_pose_1 = MEOS_CFP_FREE_NO;
    cfp.t = inst2->t;
    cfp.store = MEOS_CFP_STORE;
    cfp_elem next_cfp = cfp;
    v_clip_tpoly_tpoly(poly1, poly2, pose2, NULL, &next_cfp.cf_1, &next_cfp.cf_2, NULL);
    append_cfp_elem(&cfpa, next_cfp);
    if (next_cfp.cf_1 != cfp.cf_1 || next_cfp.cf_2 != cfp.cf_2)
    {
      printf("Problem, cfp changed from (%d, %d) to (%d, %d) at end of temporal segment\n",
        cfp.cf_1, cfp.cf_2, next_cfp.cf_1, next_cfp.cf_2);
      fflush(stdout);
    }
    cfp = next_cfp;
  }

  /* Compute the linear approximation of the distance
   * given the array of closest features */
  tdist_array tda;
  init_tdist_array(&tda, cfpa.count);
  for (uint32_t i = 0; i < cfpa.count - 1; ++i)
  {
    if (cfpa.arr[i].store)
      compute_dist_tpoly_poly(&cfpa.arr[i], &tda);
    // compute_turnpoints_tpoly_point(&cfpa.arr[i], &cfpa.arr[i+1], &tda);
  }
  compute_dist_tpoly_poly(&cfpa.arr[cfpa.count-1], &tda);

  /* Create the result tfloat */
  TInstant **instants = palloc(sizeof(TInstant *) * tda.count);
  for (uint32_t i = 0; i < tda.count; ++i)
    instants[i] = tinstant_make(Float8GetDatum(tda.arr[i].dist), T_TFLOAT, tda.arr[i].t);
  result = tsequence_make_free(instants, tda.count, seq->period.lower_inc,
    seq->period.upper_inc, MEOS_FLAGS_LINEAR_INTERP(seq->flags), NORMALIZE);

  lwpoly_free(poly1);
  lwpoly_free(poly2);
  free_cfp_array(&cfpa);
  free_tdist_array(&tda);
  return result;
}

TSequence *
dist2d_tgeometryseq_geo(const TSequence *seq, const GSERIALIZED *gs)
{
  uint32_t gs_type = gserialized_get_type(gs);
  TSequence *result = NULL;
  switch (gs_type)
  {
    case POINTTYPE:
      result = dist2d_tgeometryseq_point(seq, gs);
      break;
    case POLYGONTYPE:
      result = dist2d_tgeometryseq_poly(seq, gs);
      break;
    default:
      ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
        errmsg("Unsupported geometry type: %s", lwtype_name(gs_type))));
      break;
  }
  return result;
}

TSequenceSet *
dist2d_tgeometryseqset_geo(const TSequenceSet *ss, const GSERIALIZED *gs)
{
  TSequence **sequences = palloc(sizeof(TSequence *) * ss->count);
  for (int i = 0; i < ss->count; i++)
  {
    const TSequence *seq = TSEQUENCESET_SEQ_N(ss, i);
    sequences[i] = dist2d_tgeometryseq_geo(seq, gs);
  }
  return tsequenceset_make_free(sequences, ss->count, NORMALIZE);
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the temporal distance between a
 * ridig temporal geometry and a geometry/geography point
 * @sqlop @p <->
 */
Temporal *
distance_tgeometry_geo(const Temporal *temp, const GSERIALIZED *gs)
{
  if (gserialized_is_empty(gs))
    return NULL;
  ensure_same_srid(tgeometry_srid(temp), gserialized_get_srid(gs));
  ensure_same_dimensionality_tpoint_gs(temp, gs);
  if (MEOS_FLAGS_GET_Z(temp->flags))
    elog(ERROR, "Distance computation in 3D is not supported yet");

  Temporal *result;
  assert(temptype_subtype(temp->subtype));
  if (temp->subtype == TINSTANT)
    result = (Temporal *)dist2d_tgeometryinst_geo((const TInstant *) temp, gs);
  else if (temp->subtype == TSEQUENCE)
    result = (Temporal *)dist2d_tgeometryseq_geo((const TSequence *) temp, gs);
  else /* temp->subtype == TSEQUENCESET */
    result = (Temporal *)dist2d_tgeometryseqset_geo((const TSequenceSet *) temp, gs);
  return result;
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the temporal distance between two
 * rigid temporal geometries.
 * @sqlop @p <->
 */
Temporal *
distance_tgeometry_tpoint(const Temporal *temp1, const Temporal *temp2)
{
  /* TODO */
  elog(ERROR, "Function %s not implemented yet.", __FUNCTION__);
  return NULL;
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the temporal distance between two
 * rigid temporal geometries.
 * @sqlop @p <->
 */
Temporal *
distance_tgeometry_tgeometry(const Temporal *temp1, const Temporal *temp2)
{
  /* TODO */
  elog(ERROR, "Function %s not implemented yet.", __FUNCTION__);
  return NULL;
}

/*****************************************************************************
 * Nearest approach instant (NAI)
 *****************************************************************************/

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the nearest approach instant between a
 * rigid temporal geometry and a geometry.
 * @sqlfunc nearestApproachInstant()
 */
TInstant *
nai_tgeometry_geo(const Temporal *temp, const GSERIALIZED *gs)
{
  if (gserialized_is_empty(gs))
    return NULL;
  ensure_same_srid(tgeometry_srid(temp), gserialized_get_srid(gs));
  ensure_same_dimensionality_tpoint_gs(temp, gs);

  TInstant *result = NULL;
  assert(temptype_subtype(temp->subtype));
  if (temp->subtype == TINSTANT)
    result = tinstant_copy((TInstant *) temp);
  else
  {
    Temporal *dist = distance_tgeometry_geo(temp, gs);
    if (dist != NULL)
    {
      const TInstant *min = temporal_min_instant(dist);
      /* The closest point may be at an exclusive bound. */
      Datum value;
      temporal_value_at_timestamp(temp, min->t, false, &value);
      result = tgeometryinst_make(tgeometry_geom(temp),
        value, temp->temptype, min->t);
      pfree(dist); pfree(DatumGetPointer(value));
    }
  }
  return result;
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the nearest approach instant between the
 * rigid temporal geometries.
 * @sqlfunc nearestApproachInstant()
 */
TInstant *
nai_tgeometry_tpoint(const Temporal *temp1, const Temporal *temp2)
{
  ensure_same_srid(tgeometry_srid(temp1), tgeometry_srid(temp2));
  ensure_same_dimensionality(temp1->flags, temp2->flags);
  TInstant *result = NULL;
  Temporal *dist = distance_tgeometry_tpoint(temp1, temp2);
  if (dist != NULL)
  {
    const TInstant *min = temporal_min_instant(dist);
    /* The closest point may be at an exclusive bound. */
    Datum value;
    temporal_value_at_timestamp(temp1, min->t, false, &value);
      result = tgeometryinst_make(tgeometry_geom(temp1),
        value, temp1->temptype, min->t);
    pfree(dist); pfree(DatumGetPointer(value));
  }
  return result;
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the nearest approach instant between the
 * rigid temporal geometries.
 * @sqlfunc nearestApproachInstant()
 */
TInstant *
nai_tgeometry_tgeometry(const Temporal *temp1, const Temporal *temp2)
{
  ensure_same_srid(tgeometry_srid(temp1), tgeometry_srid(temp2));
  ensure_same_dimensionality(temp1->flags, temp2->flags);
  TInstant *result = NULL;
  Temporal *dist = distance_tgeometry_tgeometry(temp1, temp2);
  if (dist != NULL)
  {
    const TInstant *min = temporal_min_instant(dist);
    /* The closest point may be at an exclusive bound. */
    Datum value;
    temporal_value_at_timestamp(temp1, min->t, false, &value);
      result = tgeometryinst_make(tgeometry_geom(temp1),
        value, temp1->temptype, min->t);
    pfree(dist); pfree(DatumGetPointer(value));
  }
  return result;
}

/*****************************************************************************
 * Nearest approach distance (NAD)
 *****************************************************************************/

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the nearest approach distance between a
 * rigid temporal geometry and a geometry
 * @sqlop @p |=|
 */
double
nad_tgeometry_geo(const Temporal *temp, const GSERIALIZED *gs)
{
  if (gserialized_is_empty(gs))
    return -1;
  ensure_same_srid(tgeometry_srid(temp), gserialized_get_srid(gs));
  ensure_same_dimensionality_tpoint_gs(temp, gs);
  Temporal *dist = distance_tgeometry_geo(temp, gs);
  double result = DatumGetFloat8(temporal_min_value(dist));
  pfree(dist);
  return result;
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the nearest approach distance between a
 * rigid temporal geometry and a spatio-temporal box
 * @sqlop @p |=|
 */
double
nad_tgeometry_stbox(const Temporal *temp, const STBox *box)
{
  ensure_has_X_stbox(box);
  ensure_same_geodetic(temp->flags, box->flags);
  ensure_same_spatial_dimensionality_temp_box(temp->flags, box->flags);
  ensure_same_srid(tgeometry_srid(temp), stbox_srid(box));
  /* Project the temporal point to the timespan of the box */
  bool hast = MEOS_FLAGS_GET_T(box->flags);
  Span p, inter;
  if (hast)
  {
    temporal_set_period(temp, &p);
    if (! inter_span_span(&p, &box->period, &inter))
      return -1;
  }
  /* Convert the stbox to a geometry */
  const GSERIALIZED *geo = stbox_to_geo(box);
  Temporal *temp1 = hast ?
    temporal_restrict_period(temp, &inter, REST_AT) :
    (Temporal *) temp;
  /* Compute the result */
  Temporal *dist = distance_tgeometry_geo(temp, geo);
  double result = DatumGetFloat8(temporal_min_value(dist));
  pfree(DatumGetPointer(geo));
  if (hast)
    pfree(temp1);
  return result;
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the nearest approach distance between the
 * rigid temporal geometries
 * @sqlop @p |=|
 */
double
nad_tgeometry_tpoint(const Temporal *temp1, const Temporal *temp2)
{
  ensure_same_srid(tgeometry_srid(temp1), tpoint_srid(temp2));
  ensure_same_dimensionality(temp1->flags, temp2->flags);
  Temporal *dist = distance_tgeometry_tpoint(temp1, temp2);
  if (dist == NULL)
    return -1;

  double result = DatumGetFloat8(temporal_min_value(dist));
  pfree(dist);
  return result;
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the nearest approach distance between the
 * rigid temporal geometries
 * @sqlop @p |=|
 */
double
nad_tgeometry_tgeometry(const Temporal *temp1, const Temporal *temp2)
{
  ensure_same_srid(tgeometry_srid(temp1), tgeometry_srid(temp2));
  ensure_same_dimensionality(temp1->flags, temp2->flags);
  Temporal *dist = distance_tgeometry_tgeometry(temp1, temp2);
  if (dist == NULL)
    return -1;

  double result = DatumGetFloat8(temporal_min_value(dist));
  pfree(dist);
  return result;
}

/*****************************************************************************
 * ShortestLine
 *****************************************************************************/

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the line connecting the nearest approach point between a
 * rigid temporal geometry and a geometry.
 * @sqlfunc shortestLine()
 */
bool
shortestline_tgeometry_geo(const Temporal *temp, const GSERIALIZED *gs,
  GSERIALIZED **result)
{
  if (gserialized_is_empty(gs))
    return false;
  ensure_same_srid(tgeometry_srid(temp), gserialized_get_srid(gs));
  ensure_same_dimensionality_tpoint_gs(temp, gs);
  Temporal *dist = distance_tgeometry_geo(temp, gs);
  const TInstant *inst = temporal_min_instant(dist);
  /* Timestamp t may be at an exclusive bound */
  Datum value;
  tgeometry_value_at_timestamp(temp, inst->t, false, &value);
  LWGEOM *line = (LWGEOM *) lwline_make(value, PointerGetDatum(gs));
  *result = geo_serialize(line);
  lwgeom_free(line);
  return true;
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the line connecting the nearest approach point between the
 * rigid temporal geometries
 * @sqlfunc shortestLine()
 */
bool
shortestline_tgeometry_tpoint(const Temporal *temp1, const Temporal *temp2,
  GSERIALIZED **result)
{
  ensure_same_srid(tgeometry_srid(temp1), tpoint_srid(temp2));
  ensure_same_dimensionality(temp1->flags, temp2->flags);
  Temporal *dist = distance_tgeometry_tpoint(temp1, temp2);
  if (dist == NULL)
    return false;
  const TInstant *inst = temporal_min_instant(dist);
  /* Timestamp t may be at an exclusive bound */
  Datum value1, value2;
  tgeometry_value_at_timestamp(temp1, inst->t, false, &value1);
  temporal_value_at_timestamp(temp2, inst->t, false, &value2);
  LWGEOM *line = (LWGEOM *) lwline_make(value1, value2);
  *result = geo_serialize(line);
  lwgeom_free(line);
  return true;
}

/**
 * @ingroup libmeos_temporal_dist
 * @brief Return the line connecting the nearest approach point between the
 * rigid temporal geometries
 * @sqlfunc shortestLine()
 */
bool
shortestline_tgeometry_tgeometry(const Temporal *temp1, const Temporal *temp2,
  GSERIALIZED **result)
{
  ensure_same_srid(tgeometry_srid(temp1), tgeometry_srid(temp2));
  ensure_same_dimensionality(temp1->flags, temp2->flags);
  Temporal *dist = distance_tgeometry_tgeometry(temp1, temp2);
  if (dist == NULL)
    return false;
  const TInstant *inst = temporal_min_instant(dist);
  /* Timestamp t may be at an exclusive bound */
  Datum value1, value2;
  tgeometry_value_at_timestamp(temp1, inst->t, false, &value1);
  tgeometry_value_at_timestamp(temp2, inst->t, false, &value2);
  LWGEOM *line = (LWGEOM *) lwline_make(value1, value2);
  *result = geo_serialize(line);
  lwgeom_free(line);
  return true;
}

/*****************************************************************************/
