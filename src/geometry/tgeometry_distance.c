/***********************************************************************
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
 * @file tgeometry_distance.c
 * Distance functions for rigid temporal geometries.
 */

#include "geometry/tgeometry_distance.h"

#include <assert.h>
#include <float.h>
#include <math.h>
#include <utils/builtins.h>
#include <utils/timestamp.h>
#if POSTGRESQL_VERSION_NUMBER >= 120000
#include <utils/float.h>
#endif

#if POSTGIS_VERSION_NUMBER >= 30000
#include <lwgeodetic_tree.h>
#include <liblwgeom.h>
#include <measures.h>
#include <measures3d.h>
#endif

#include "general/temporaltypes.h"
#include "general/temporal_util.h"
#include "general/tempcache.h"

#include "point/tpoint_spatialfuncs.h"

#include "geometry/tgeometry_inst.h"
#include "geometry/tgeometry_spatialfuncs.h"

#include "pose/pose.h"

/*****************************************************************************
 * cfp array utility functions
 *****************************************************************************/

static cfp_elem
cfp_make(LWGEOM *geom_1, LWGEOM *geom_2, pose *pose_1, pose *pose_2, uint32_t cf_1, uint32_t cf_2, TimestampTz t, bool store)
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
  cfp.free_pose_1 = MOBDB_CFP_FREE_NO;
  cfp.free_pose_2 = MOBDB_CFP_FREE_NO;
  return cfp;
}

static cfp_elem
cfp_make_zero(LWGEOM *geom_1, LWGEOM *geom_2, pose *pose_1, pose *pose_2, TimestampTz t, bool store)
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
      ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
        errmsg("Not enough memory")));
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
      ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
        errmsg("Not enough memory")));
    else
      tda->arr = new_arr;
  }
  tda->arr[tda->count++] = td;
}

/*****************************************************************************
 * V-clip
 *****************************************************************************/

static inline uint32_t
uint_mod(uint8_t i, uint32_t n)
{
  return (i % n + n) % n;
}

static void
apply_pose_point4d(POINT4D *p, pose *pose)
{
  double c = cos(pose->data[2]);
  double s = sin(pose->data[2]);
  double x = p->x, y = p->y;
  p->x = x * c - y * s + pose->data[0];
  p->y = x * s + y * c + pose->data[1];
  return;
}

static inline double
compute_s(POINT4D p, POINT4D q, POINT4D r)
{
  return ((p.x - q.x) * (r.x - q.x) + (p.y - q.y) * (r.y - q.y)) / (pow(r.x - q.x, 2) + pow(r.y - q.y, 2));
}

static inline double
compute_angle(POINT4D p, POINT4D q, POINT4D r)
{
  return (p.x - q.x) * (r.y - q.y) - (p.y - q.y) * (r.x - q.x);
}

static inline double
compute_dist2(POINT4D p, POINT4D q, POINT4D r)
{
  double s = compute_s(p, q, r);
  return pow(p.x - q.x - (r.x - q.x) * s, 2) + pow(p.y - q.y - (r.y - q.y) * s, 2);
}

static cfp_elem
v_clip_tpoly_point_internal(cfp_elem prev_cfp)
{
  /* TODO: maybe check if poly, point and pose pointers are the same. */
  cfp_elem cfp = prev_cfp;
  LWPOLY *poly = (LWPOLY *)cfp.geom_1;
  LWPOINT *point = (LWPOINT *)cfp.geom_2;
  pose *poly_pose = cfp.pose_1;
  uint32_t n = poly->rings[0]->npoints - 1;
  POINT4D p, r, r_prev, r_next;
  lwpoint_getPoint4d_p(point, &p);
  int i = 0;
  while (true)
  {
    i += 1;
    uint32_t v = cfp.cf_1 / 2;
    getPoint4d_p(poly->rings[0], v, &r);
    apply_pose_point4d(&r, poly_pose);
    getPoint4d_p(poly->rings[0], uint_mod(v + 1, n), &r_next);
    apply_pose_point4d(&r_next, poly_pose);
    double s_r_rnext = compute_s(p, r, r_next);
    if (cfp.cf_1 % 2 == 0)
    {
      getPoint4d_p(poly->rings[0], uint_mod(v - 1, n), &r_prev);
      apply_pose_point4d(&r_prev, poly_pose);
      double s_rprev_r = compute_s(p, r_prev, r);
      if (s_rprev_r < 1)
        cfp.cf_1 = uint_mod(cfp.cf_1 - 1, 2 * n);
      else if (s_r_rnext > 0)
        cfp.cf_1 = cfp.cf_1 + 1;
      else if (fabs(s_rprev_r - 1) < MOBDB_EPSILON && fabs(s_r_rnext) < MOBDB_EPSILON)
      {
        ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
          errmsg("Intersection detected.")));
        break;
      }
      else
        break;
    }
    else /* cfp.cf_1 % 2 == 1 */
    {
      if (s_r_rnext <= 0)
        cfp.cf_1 = cfp.cf_1 - 1;
      else if (s_r_rnext >= 1)
        cfp.cf_1 = uint_mod(cfp.cf_1 + 1, 2 * n);
      else if (compute_angle(p, r, r_next) <= MOBDB_EPSILON)
      {
        double dmax = -1;
        for (uint32_t i = 0; i < n - 1; ++i)
        {
          v = uint_mod(v + 1, n);
          getPoint4d_p(poly->rings[0], v, &r);
          apply_pose_point4d(&r, poly_pose);
          getPoint4d_p(poly->rings[0], uint_mod(v + 1, n), &r_next);
          apply_pose_point4d(&r_next, poly_pose);
          double d = compute_dist2(p, r, r_next);
          if (compute_angle(p, r, r_next) > MOBDB_EPSILON)
          {
            if (d > dmax)
            {
              dmax = d;
              cfp.cf_1 = uint_mod(cfp.cf_1 + 2 * i, 2 * n);
            }
          }
        }
        if (dmax == -1)
        {
          ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
            errmsg("Intersection detected.")));
          break;
        }
      }
      else
        break;
    }
  }
  printf("V-clip iterations: %d\n", i);
  fflush(stdout);
  return cfp;
}

PG_FUNCTION_INFO_V1(v_clip_tpoly_point);
/**
 * Returns the temporal distance between the geometry/geography point/polygon
 * and the rigid temporal geometry
 */
PGDLLEXPORT Datum
v_clip_tpoly_point(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs_poly = PG_GETARG_GSERIALIZED_P(0);
  GSERIALIZED *gs_point = PG_GETARG_GSERIALIZED_P(1);
  pose *p = PG_GETARG_POSE(2);
  if (gserialized_is_empty(gs_poly) || gserialized_is_empty(gs_point))
    PG_RETURN_NULL();
  LWPOLY *poly = lwgeom_as_lwpoly(lwgeom_from_gserialized(gs_poly));
  LWPOINT *point = lwgeom_as_lwpoint(lwgeom_from_gserialized(gs_point));
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  cfp_elem cfp = v_clip_tpoly_point_internal(
    cfp_make_zero((LWGEOM *)poly, (LWGEOM *)point, p, NULL, 0, MOBDB_CFP_STORE_NO));
  lwpoly_free(poly);
  lwpoint_free(point);
  PG_FREE_IF_COPY(gs_poly, 0);
  PG_FREE_IF_COPY(gs_point, 1);
  PG_RETURN_UINT32(cfp.cf_1);
}

/*****************************************************************************
 * Temporal distance
 *****************************************************************************/

TInstant *
dist2d_tgeometryinst_geo(const TInstant *inst, GSERIALIZED *gs)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return NULL;
}

TInstantSet *
dist2d_tgeometryinstset_geo(const TInstantSet *ti, GSERIALIZED *gs)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return NULL;
}

static void
pose_interpolate_2d(pose *p1, pose *p2, double ratio, double *x, double *y, double *theta)
{
  *x = p1->data[0] * (1 - ratio) + p2->data[0] * ratio;
  *y = p1->data[1] * (1 - ratio) + p2->data[1] * ratio;
  double theta_delta = p2->data[2] - p1->data[2];
  /* If fabs(theta_delta) == M_PI: Always turn counter-clockwise */
  if (fabs(theta_delta) < MOBDB_EPSILON)
      *theta = p1->data[2];
  else if (theta_delta > 0 && fabs(theta_delta) <= M_PI)
      *theta = p1->data[2] + theta_delta*ratio;
  else if (theta_delta > 0 && fabs(theta_delta) > M_PI)
      *theta = p2->data[2] + (2*M_PI - theta_delta)*(1 - ratio);
  else if (theta_delta < 0 && fabs(theta_delta) < M_PI)
      *theta = p1->data[2] + theta_delta*ratio;
  else /* (theta_delta < 0 && fabs(theta_delta) >= M_PI) */
      *theta = p1->data[2] + (2*M_PI + theta_delta)*ratio;
  if (*theta > M_PI)
      *theta = *theta - 2*M_PI;
}

static double
f_tpoint_poly(POINT4D p, POINT4D q, POINT4D r,
  pose *poly_pose_s, pose *poly_pose_e, double ratio,
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
  if (solution_kind) /* MOBDB_SOLVE_0 */
    return (p.x - qx) * (rx - qx) + (p.y - qy) * (ry - qy);
  else /* MOBDB_SOLVE_1 */
    return (p.x - rx) * (rx - qx) + (p.y - ry) * (ry - qy);
}

static double
solve_s_tpoly_point(LWPOLY *poly, LWPOINT *point, pose *poly_pose_s, pose *poly_pose_e,
  uint32_t poly_v, double prev_result, bool solution_kind)
{
  uint32_t n = poly->rings[0]->npoints - 1;
  POINT4D p, q, r;
  lwpoint_getPoint4d_p(point, &p);
  getPoint4d_p(poly->rings[0], poly_v, &q);
  getPoint4d_p(poly->rings[0], uint_mod(poly_v + 1, n), &r);

  if (fabs(poly_pose_s->data[2] - poly_pose_e->data[2]) < MOBDB_EPSILON)
  {
    apply_pose_point4d(&q, poly_pose_s);
    apply_pose_point4d(&r, poly_pose_s);
    double result;
    double discr = ((poly_pose_e->data[0] - poly_pose_s->data[0]) * (r.x - q.x)
      + (poly_pose_e->data[1] - poly_pose_s->data[1]) * (r.y - q.y));
    if (solution_kind) /* MOBDB_SOLVE_0 */
      result = ((p.x - q.x) * (r.x - q.x) + (p.y - q.y) * (r.y - q.y)) / discr;
    else /* MOBDB_SOLVE_1 */
      result = ((p.x - r.x) * (r.x - q.x) + (p.y - r.y) * (r.y - q.y)) / discr;
    if (result > prev_result + MOBDB_EPSILON && result < 1 - MOBDB_EPSILON)
      return result;
    return 2;
  }

  double tl, tr, t0;
  double vl, vr, v0;
  double ts = prev_result, te = 1;
  vl = f_tpoint_poly(p, q, r, poly_pose_s, poly_pose_e,
    ts, solution_kind);
  v0 = f_tpoint_poly(p, q, r, poly_pose_s, poly_pose_e,
    (ts + te) / 2, solution_kind);
  vr = f_tpoint_poly(p, q, r, poly_pose_s, poly_pose_e,
    te, solution_kind);
  if (fabs(vl) > MOBDB_EPSILON && vl * v0 < 0)
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
  while(fabs(tr - tl) >= MOBDB_EPSILON)
  {
    t0 = tr - vr * (tr - tl) / (vr - vl);
    v0 = f_tpoint_poly(p, q, r, poly_pose_s, poly_pose_e,
      t0, solution_kind);
    if (fabs(v0) < MOBDB_EPSILON)
      break;
    if (vl * v0 <= 0)
      tr = t0, vr = v0;
    else
      tl = t0, vl = v0;
    i++;
  }
  return t0;
}

static double
solve_angle_0_tpoly_point(LWPOLY *poly, LWPOINT *point, pose *poly_pose_s, pose *poly_pose_e, uint32_t poly_v, double r_prev)
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
    getPoint4d_p(poly->rings[0], uint_mod(v + 1, n), &r);
    apply_pose_point4d(&r, cfp->pose_1);
    double s = ((p.x - q.x) * (r.x - q.x)
      + (p.y - q.y) * (r.y - q.y)) / (pow(r.x - q.x, 2) + pow(r.y - q.y, 2));
    if (s <= 0 || s >= 1)
    {
      printf("Problem: s = %lf\n", s);
      fflush(stdout);
    }
    double x = q.x  + (r.x - q.x) * s;
    double y = q.y  + (r.y - q.y) * s;
    dist = sqrt(pow(p.x - x, 2) + pow(p.y - y, 2));
  }
  tdist_elem td = tdist_make(dist, cfp->t);
  append_tdist_elem(tda, td);
}

static void
compute_turnpoints_tpoly_point(cfp_elem *cfp_s, cfp_elem *cfp_e, tdist_array *tda)
{
  if (fabs(cfp_s->pose_1->data[0] - cfp_e->pose_1->data[0]) < MOBDB_EPSILON &&
      fabs(cfp_s->pose_1->data[1] - cfp_e->pose_1->data[1]) < MOBDB_EPSILON &&
      fabs(cfp_s->pose_1->data[2] - cfp_e->pose_1->data[2]) < MOBDB_EPSILON)
      return;

  if (fabs(cfp_s->pose_1->data[2] - cfp_e->pose_1->data[2]) < MOBDB_EPSILON)
  {
    double ratio, dist;
    POINT4D p, q, r;
    LWPOLY *poly = (LWPOLY *)cfp_s->geom_1;
    LWPOINT *point = (LWPOINT *)cfp_s->geom_2;
    uint32_t n = poly->rings[0]->npoints - 1;
    uint32_t v = cfp_s->cf_1 / 2;
    lwpoint_getPoint4d_p(point, &p);
    getPoint4d_p(poly->rings[0], v, &q);
    apply_pose_point4d(&q, cfp_s->pose_1);
    double dx = cfp_s->pose_1->data[0] - cfp_e->pose_1->data[0];
    double dy = cfp_s->pose_1->data[1] - cfp_e->pose_1->data[1];
    if (cfp_s->cf_1 % 2 == 0)
    {
      ratio = (dx * (q.x - p.x) + dy * (q.y - p.y)) / (dx * dx + dy * dy);
      if (0 < ratio && ratio < 1)
      {
        pose *pose_at_ratio = pose_interpolate(cfp_s->pose_1, cfp_e->pose_1, ratio);
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
      getPoint4d_p(poly->rings[0], uint_mod(v + 1, n), &r);
      apply_pose_point4d(&r, cfp_s->pose_1);
      double det = dx * (r.y - q.y) - dy * (r.x - q.x);
      /* TODO: Check if we have to return ratio = 0 and ratio = 1, or nothing*/
      if (fabs(det) < MOBDB_EPSILON)
        return;
      ratio = ((q.x - p.x) * (r.y - q.y) + (q.y - p.y) * (r.x - q.x)) / det;
      if (0 < ratio && ratio < 1)
      {
        pose *pose_at_ratio = pose_interpolate(cfp_s->pose_1, cfp_e->pose_1, ratio);
        getPoint4d_p(poly->rings[0], v, &q);
        apply_pose_point4d(&q, pose_at_ratio);
        getPoint4d_p(poly->rings[0], uint_mod(v + 1, n), &r);
        apply_pose_point4d(&r, pose_at_ratio);
        double s = ((p.x - q.x) * (r.x - q.x)
          + (p.y - q.y) * (r.y - q.y)) / (pow(r.x - q.x, 2) + pow(r.y - q.y, 2));
        if (s <= 0 || s >= 1)
        {
          printf("Problem: s = %lf\n", s);
          fflush(stdout);
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
  /* TODO: Handle rotating case */
  return;
}

TSequence *
dist2d_tgeometryseq_point(const TSequence *seq, GSERIALIZED *gs)
{
  /* TODO: Add check and code for stepwise seq */
  TSequence *result;
  Datum ref_geom = tgeometryseq_geom(seq);
  GSERIALIZED *ref_gs = (GSERIALIZED *) DatumGetPointer(ref_geom);

  /* TODO: check that polygon is convex */
  LWPOLY *poly = lwgeom_as_lwpoly(lwgeom_from_gserialized(ref_gs));
  LWPOINT *point = lwgeom_as_lwpoint(lwgeom_from_gserialized(gs));

  const TInstant *inst1, *inst2;
  pose *p1, *p2;

  inst1 = tsequence_inst_n(seq, 0);
  p1 = DatumGetPose(tinstant_value(inst1));

  cfp_array cfpa;
  init_cfp_array(&cfpa, seq->count);
  cfp_elem cfp = v_clip_tpoly_point_internal(
    cfp_make_zero((LWGEOM *)poly, (LWGEOM *)point, p1, NULL, inst1->t, MOBDB_CFP_STORE));
  append_cfp_elem(&cfpa, cfp);
  uint32_t n = poly->rings[0]->npoints - 1;
  for (int i = 0; i < seq->count - 1; ++i)
  {
    /* TODO: optimise using simple checks, such as:
     * 1) cfp(0) == cfp(0.5) == cfp(1) -> no change in cf
     */
    inst1 = tsequence_inst_n(seq, i);
    inst2 = tsequence_inst_n(seq, i + 1);
    p1 = DatumGetPose(tinstant_value(inst1));
    p2 = DatumGetPose(tinstant_value(inst2));
    double r_prev = 0;
    double r_1, r_2, r_inter;
    cfp.store = MOBDB_CFP_STORE_NO;
    while (true)
    {
      uint32_t v = cfp.cf_1 / 2;
      if (cfp.cf_1 % 2 == 0)
      {
        r_1 = solve_s_tpoly_point(poly, point, p1, p2,
          v, r_prev, MOBDB_SOLVE_0);
        r_2 = solve_s_tpoly_point(poly, point, p1, p2,
          uint_mod(v - 1, n), r_prev, MOBDB_SOLVE_1);
        printf("r_1: %lf, r_2: %lf\n", r_1, r_2);
        fflush(stdout);
      }
      else /* cfp.cf_1 % 2 == 1 */
      {
        r_1 = solve_s_tpoly_point(poly, point, p1, p2,
          v, r_prev, MOBDB_SOLVE_1);
        r_2 = solve_s_tpoly_point(poly, point, p1, p2,
          v, r_prev, MOBDB_SOLVE_0);
        printf("r_1: %lf, r_2: %lf\n", r_1, r_2);
        fflush(stdout);
        r_inter = solve_angle_0_tpoly_point(poly, point, p1, p2, v, r_prev);
      }

      if ((fabs(r_1 - r_2) < MOBDB_EPSILON && r_1 < 1 && r_2 < 1) ||
        (r_inter < r_1 && r_inter < r_2 && r_inter < 1))
      {
        ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
          errmsg("Intersection detected.")));
        break;
      }
      else if (r_1 < r_2 && r_1 < 1)
      {
        cfp.t = inst1->t + (inst2->t - inst1->t) * r_1;
        cfp.pose_1 = pose_interpolate(p1, p2, r_1);
        cfp.free_pose_1 = MOBDB_CFP_FREE;
        cfp.cf_1 = uint_mod(cfp.cf_1 + 1, 2 * n);
        append_cfp_elem(&cfpa, cfp);
        r_prev = r_1;
      }
      else if (r_2 < r_1 && r_2 < 1)
      {
        cfp.t = inst1->t + (inst2->t - inst1->t) * r_2;
        cfp.pose_1 = pose_interpolate(p1, p2, r_2);
        cfp.free_pose_1 = MOBDB_CFP_FREE;
        cfp.cf_1 = uint_mod(cfp.cf_1 - 1, 2 * n);
        append_cfp_elem(&cfpa, cfp);
        r_prev = r_2;
      }
      else
        break;
    }
    cfp.pose_1 = p2;
    cfp.free_pose_1 = MOBDB_CFP_FREE_NO;
    cfp.t = inst2->t;
    cfp.store = MOBDB_CFP_STORE;
    cfp_elem next_cfp = v_clip_tpoly_point_internal(cfp);
    append_cfp_elem(&cfpa, next_cfp);
    if (next_cfp.cf_1 != cfp.cf_1)
    {
      printf("Problem, cfp changed from %d to %d at end of temporal segment\n", cfp.cf_1, next_cfp.cf_1);
      fflush(stdout);
    }
    cfp = next_cfp;
  }

  for (uint32_t i = 0; i < cfpa.count; ++i)
    printf("Cfp %d: %d @ %s\n", i, cfpa.arr[i].cf_1, call_output(TIMESTAMPTZOID, TimestampTzGetDatum(cfpa.arr[i].t)));
  fflush(stdout);

  tdist_array tda;
  init_tdist_array(&tda, cfpa.count);
  for (uint32_t i = 0; i < cfpa.count - 1; ++i)
  {
    if (cfpa.arr[i].store)
      compute_dist_tpoly_point(&cfpa.arr[i], &tda);
    compute_turnpoints_tpoly_point(&cfpa.arr[i], &cfpa.arr[i+1], &tda);
  }
  compute_dist_tpoly_point(&cfpa.arr[cfpa.count-1], &tda);

  for (uint32_t i = 0; i < tda.count; ++i)
    printf("Dist %d: %lf @ %s\n", i, tda.arr[i].dist, call_output(TIMESTAMPTZOID, TimestampTzGetDatum(tda.arr[i].t)));
  fflush(stdout);

  TInstant **instants = palloc(sizeof(TInstant *) * tda.count);
  for (uint32_t i = 0; i < tda.count; ++i)
    instants[i] = tinstant_make(Float8GetDatum(tda.arr[i].dist), tda.arr[i].t, type_oid(T_FLOAT8));
  result = tsequence_make_free(instants, tda.count, seq->period.lower_inc,
    seq->period.upper_inc, MOBDB_FLAGS_GET_LINEAR(seq->flags), NORMALIZE);

  free_cfp_array(&cfpa);
  free_tdist_array(&tda);
  return result;
}

TSequence *
dist2d_tgeometryseq_poly(const TSequence *seq, GSERIALIZED *gs)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return NULL;
}

TSequence *
dist2d_tgeometryseq_geo(const TSequence *seq, GSERIALIZED *gs)
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
dist2d_tgeometryseqset_geo(const TSequenceSet *ts, GSERIALIZED *gs)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return NULL;
}

/**
 * Returns the temporal distance between the rigid temporal geometry and the
 * geometry/geography point/polygon (distpatch function)
 */
Temporal *
distance_tgeometry_geo_internal(const Temporal *temp, Datum geo)
{
  GSERIALIZED *gs = (GSERIALIZED *) DatumGetPointer(geo);
  ensure_same_srid(tgeometry_srid_internal(temp), gserialized_get_srid(gs));
  ensure_same_dimensionality_tpoint_gs(temp, gs);
  #if POSTGIS_VERSION_NUMBER < 30000
    if (MOBDB_FLAGS_GET_Z(temp->flags) != FLAGS_GET_Z(gs->flags))
  #else
    if (MOBDB_FLAGS_GET_Z(temp->flags) != FLAGS_GET_Z(gs->gflags))
  #endif
      ereport(ERROR, (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
        errmsg("Distance computation in 3D is not supported yet")));

  Temporal *result;
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT)
    result = (Temporal *)dist2d_tgeometryinst_geo((const TInstant *) temp, gs);
  else if (temp->subtype == INSTANTSET)
    result = (Temporal *)dist2d_tgeometryinstset_geo((const TInstantSet *) temp, gs);
  else if (temp->subtype == SEQUENCE)
    result = (Temporal *)dist2d_tgeometryseq_geo((const TSequence *) temp, gs);
  else /* temp->subtype == SEQUENCESET */
    result = (Temporal *)dist2d_tgeometryseqset_geo((const TSequenceSet *) temp, gs);
  return result;
}

PG_FUNCTION_INFO_V1(distance_geo_tgeometry);
/**
 * Returns the temporal distance between the geometry/geography point/polygon
 * and the rigid temporal geometry
 */
PGDLLEXPORT Datum
distance_geo_tgeometry(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  Temporal *temp = PG_GETARG_TEMPORAL_P(1);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *result = distance_tgeometry_geo_internal(temp, PointerGetDatum(gs));
  PG_FREE_IF_COPY(gs, 0);
  PG_FREE_IF_COPY(temp, 1);
  if (result == NULL)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(distance_tgeometry_geo);
/**
 * Returns the temporal distance between the rigid temporal geometry and the
 * geometry/geography point/polygon
 */
PGDLLEXPORT Datum
distance_tgeometry_geo(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(1);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *result = distance_tgeometry_geo_internal(temp, PointerGetDatum(gs));
  PG_FREE_IF_COPY(temp, 0);
  PG_FREE_IF_COPY(gs, 1);
  if (result == NULL)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

/**
 * Returns the temporal distance between the two rigid temporal geometries
 * (dispatch function)
 */
Temporal *
distance_tgeometry_tgeometry_internal(const Temporal *temp1, const Temporal *temp2)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return NULL;
}

PG_FUNCTION_INFO_V1(distance_tgeometry_tgeometry);
/**
 * Returns the temporal distance between the two rigid temporal geometries
 */
PGDLLEXPORT Datum
distance_tgeometry_tgeometry(PG_FUNCTION_ARGS)
{
  Temporal *temp1 = PG_GETARG_TEMPORAL_P(0);
  Temporal *temp2 = PG_GETARG_TEMPORAL_P(1);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *result = distance_tgeometry_tgeometry_internal(temp1, temp2);
  PG_FREE_IF_COPY(temp1, 0);
  PG_FREE_IF_COPY(temp2, 1);
  if (result == NULL)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

/*****************************************************************************
 * Nearest approach instant
 *****************************************************************************/

/**
 * Returns the nearest approach instant between the rigid temporal geometry and
 * the geometry (dispatch function)
 */
TInstant *
NAI_tgeometry_geo_internal(FunctionCallInfo fcinfo, const Temporal *temp,
  GSERIALIZED *gs)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return NULL;
}

PG_FUNCTION_INFO_V1(NAI_geo_tgeometry);
/**
 * Returns the nearest approach instant between the geometry and
 * the rigid temporal geometry
 */
PGDLLEXPORT Datum
NAI_geo_tgeometry(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL_P(1);
  TInstant *result = NAI_tgeometry_geo_internal(fcinfo, temp, gs);
  PG_FREE_IF_COPY(gs, 0);
  PG_FREE_IF_COPY(temp, 1);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(NAI_tgeometry_geo);
/**
 * Returns the nearest approach instant between the rigid temporal geometry
 * and the geometry
 */
PGDLLEXPORT Datum
NAI_tgeometry_geo(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(1);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  TInstant *result = NAI_tgeometry_geo_internal(fcinfo, temp, gs);
  PG_FREE_IF_COPY(temp, 0);
  PG_FREE_IF_COPY(gs, 1);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(NAI_tgeometry_tgeometry);
/**
 * Returns the nearest approach instant between the rigid temporal geometries
 */
PGDLLEXPORT Datum
NAI_tgeometry_tgeometry(PG_FUNCTION_ARGS)
{
  Temporal *temp1 = PG_GETARG_TEMPORAL_P(0);
  Temporal *temp2 = PG_GETARG_TEMPORAL_P(1);
  TInstant *result = NULL;
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *dist = distance_tgeometry_tgeometry_internal(temp1, temp2);
  if (dist != NULL)
  {
    /* TODO: return an instant with the reference geometry*/
    const TInstant *min = temporal_min_instant(dist);
    result = (TInstant *) temporal_restrict_timestamp_internal(temp1,
      min->t, REST_AT);
    pfree(dist);
    if (result == NULL)
    {
      if (temp1->subtype == SEQUENCE)
        result = tinstant_copy(tsequence_inst_at_timestamp_excl(
          (TSequence *) temp1, min->t));
      else /* temp->subtype == SEQUENCESET */
        result = tinstant_copy(tsequenceset_inst_at_timestamp_excl(
          (TSequenceSet *) temp1, min->t));
    }
  }
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
 * Returns the nearest approach distance between the rigid temporal geometry and the
 * geometry (internal function)
 */
Datum
NAD_tgeometry_geo_internal(FunctionCallInfo fcinfo, Temporal *temp,
  GSERIALIZED *gs)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return Float8GetDatum(0.0);
}

PG_FUNCTION_INFO_V1(NAD_geo_tgeometry);
/**
 * Returns the nearest approach distance between the geometry and
 * the rigid temporal geometry
 */
PGDLLEXPORT Datum
NAD_geo_tgeometry(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL_P(1);
  Datum result = NAD_tgeometry_geo_internal(fcinfo, temp, gs);
  PG_FREE_IF_COPY(gs, 0);
  PG_FREE_IF_COPY(temp, 1);
  PG_RETURN_DATUM(result);
}

PG_FUNCTION_INFO_V1(NAD_tgeometry_geo);
/**
 * Returns the nearest approach distance between the rigid temporal geometry
 * and the geometry
 */
PGDLLEXPORT Datum
NAD_tgeometry_geo(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(1);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  Datum result = NAD_tgeometry_geo_internal(fcinfo, temp, gs);
  PG_FREE_IF_COPY(temp, 0);
  PG_FREE_IF_COPY(gs, 1);
  PG_RETURN_DATUM(result);
}

/**
 * Returns the nearest approach distance between the rigid temporal geometry and the
 * spatio-temporal box (internal function)
 */
double
NAD_tgeometry_stbox_internal(const Temporal *temp, STBOX *box)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return 0.0;
}

PG_FUNCTION_INFO_V1(NAD_stbox_tgeometry);
/**
 * Returns the nearest approach distance between the spatio-temporal box and the
 * rigid temporal geometry
 */
PGDLLEXPORT Datum
NAD_stbox_tgeometry(PG_FUNCTION_ARGS)
{
  STBOX *box = PG_GETARG_STBOX_P(0);
  Temporal *temp = PG_GETARG_TEMPORAL_P(1);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  double result = NAD_tgeometry_stbox_internal(temp, box);
  PG_FREE_IF_COPY(temp, 1);
  if (result == DBL_MAX)
    PG_RETURN_NULL();
  PG_RETURN_FLOAT8(result);
}

PG_FUNCTION_INFO_V1(NAD_tgeometry_stbox);
/**
 * Returns the nearest approach distance between the rigid temporal geometry and the
 * spatio-temporal box
 */
PGDLLEXPORT Datum
NAD_tgeometry_stbox(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  STBOX *box = PG_GETARG_STBOX_P(1);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  double result = NAD_tgeometry_stbox_internal(temp, box);
  PG_FREE_IF_COPY(temp, 0);
  if (result == DBL_MAX)
    PG_RETURN_NULL();
  PG_RETURN_FLOAT8(result);
}

PG_FUNCTION_INFO_V1(NAD_tgeometry_tgeometry);
/**
 * Returns the nearest approach distance between the rigid temporal geometries
 */
PGDLLEXPORT Datum
NAD_tgeometry_tgeometry(PG_FUNCTION_ARGS)
{
  Temporal *temp1 = PG_GETARG_TEMPORAL_P(0);
  Temporal *temp2 = PG_GETARG_TEMPORAL_P(1);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *dist = distance_tgeometry_tgeometry_internal(temp1, temp2);
  if (dist == NULL)
  {
    PG_FREE_IF_COPY(temp1, 0);
    PG_FREE_IF_COPY(temp2, 1);
    PG_RETURN_NULL();
  }

  Datum result = temporal_min_value_internal(dist);
  pfree(dist);
  PG_FREE_IF_COPY(temp1, 0);
  PG_FREE_IF_COPY(temp2, 1);
  PG_RETURN_DATUM(result);
}

/*****************************************************************************
 * ShortestLine
 *****************************************************************************/

/**
 * Returns the line connecting the nearest approach point between the
 * rigid temporal geometry and the geometry (internal function)
 */
Datum
shortestline_tgeometry_geo_internal(Temporal *temp, GSERIALIZED *gs)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return PointerGetDatum(NULL);
}

PG_FUNCTION_INFO_V1(shortestline_geo_tgeometry);
/**
 * Returns the line connecting the nearest approach points between the
 * geometry and the rigid temporal geometry
 */
PGDLLEXPORT Datum
shortestline_geo_tgeometry(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL_P(1);
  Datum result = shortestline_tgeometry_geo_internal(temp, gs);
  PG_FREE_IF_COPY(gs, 0);
  PG_FREE_IF_COPY(temp, 1);
  PG_RETURN_DATUM(result);
}

PG_FUNCTION_INFO_V1(shortestline_tgeometry_geo);
/**
 * Returns the line connecting the nearest approach points between the
 * rigid temporal geometry and the geometry/geography
 */
PGDLLEXPORT Datum
shortestline_tgeometry_geo(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(1);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  Datum result = shortestline_tgeometry_geo_internal(temp, gs);
  PG_FREE_IF_COPY(temp, 0);
  PG_FREE_IF_COPY(gs, 1);
  PG_RETURN_DATUM(result);
}

/**
 * Returns the line connecting the nearest approach points between the
 * rigid temporal geometries
 */
bool
shortestline_tgeometry_tgeometry_internal(const Temporal *temp1,
  const Temporal *temp2, Datum *line)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return false;
}

PG_FUNCTION_INFO_V1(shortestline_tgeometry_tgeometry);
/**
 * Returns the line connecting the nearest approach points between the
 * rigid temporal geometries
 */
PGDLLEXPORT Datum
shortestline_tgeometry_tgeometry(PG_FUNCTION_ARGS)
{
  Temporal *temp1 = PG_GETARG_TEMPORAL_P(0);
  Temporal *temp2 = PG_GETARG_TEMPORAL_P(1);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Datum result;
  bool found = shortestline_tgeometry_tgeometry_internal(temp1, temp2, &result);
  PG_FREE_IF_COPY(temp1, 0);
  PG_FREE_IF_COPY(temp2, 1);
  if (!found)
    PG_RETURN_NULL();
  PG_RETURN_DATUM(result);
}

/*****************************************************************************
 * Temporal dwithin
 * Available for rigid temporal geometries
 *****************************************************************************/

/**
 * Returns a temporal Boolean that states whether the rigid temporal geometry and
 * the geometry are within the given distance (dispatch function)
 */
Temporal *
tdwithin_tgeometry_geo_internal(const Temporal *temp, GSERIALIZED *gs, Datum dist)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return false;
}

PG_FUNCTION_INFO_V1(tdwithin_geo_tgeometry);
/**
 * Returns a temporal Boolean that states whether the geometry and the
 * temporal point are within the given distance
 */
PGDLLEXPORT Datum
tdwithin_geo_tgeometry(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL_P(1);
  Datum dist = PG_GETARG_DATUM(2);
  Temporal *result = tdwithin_tgeometry_geo_internal(temp, gs, dist);
  PG_FREE_IF_COPY(gs, 0);
  PG_FREE_IF_COPY(temp, 1);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(tdwithin_tgeometry_geo);
/**
 * Returns a temporal Boolean that states whether the temporal point and
 * the geometry are within the given distance
 */
PGDLLEXPORT Datum
tdwithin_tgeometry_geo(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(1);
  if (gserialized_is_empty(gs))
    PG_RETURN_NULL();
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  Datum dist = PG_GETARG_DATUM(2);
  Temporal *result = tdwithin_tgeometry_geo_internal(temp, gs, dist);
  PG_FREE_IF_COPY(temp, 0);
  PG_FREE_IF_COPY(gs, 1);
  PG_RETURN_POINTER(result);
}

/*****************************************************************************/

/**
 * Returns a temporal Boolean that states whether the temporal points
 * are within the given distance (internal function)
 */
Temporal *
tdwithin_tgeometry_tgeometry_internal(const Temporal *temp1, const Temporal *temp2,
  Datum dist)
{
  /* TODO */
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("Function not implemented yet.")));
  return false;
}

PG_FUNCTION_INFO_V1(tdwithin_tgeometry_tgeometry);
/**
 * Returns a temporal Boolean that states whether the temporal points
 * are within the given distance
 */
PGDLLEXPORT Datum
tdwithin_tgeometry_tgeometry(PG_FUNCTION_ARGS)
{
  Temporal *temp1 = PG_GETARG_TEMPORAL_P(0);
  Temporal *temp2 = PG_GETARG_TEMPORAL_P(1);
  Datum dist = PG_GETARG_DATUM(2);
  /* Store fcinfo into a global variable */
  store_fcinfo(fcinfo);
  Temporal *result = tdwithin_tgeometry_tgeometry_internal(temp1, temp2, dist);
  PG_FREE_IF_COPY(temp1, 0);
  PG_FREE_IF_COPY(temp2, 1);
  if (result == NULL)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

/*****************************************************************************/
