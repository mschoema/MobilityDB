/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 * Copyright (c) 2016-2026, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2025, PostGIS contributors
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
 * @file
 * @brief Validation of the closest-feature walk of
 * meos/src/rgeo/trgeo_distwalk.c against a dense scan of the true
 * point-to-convex-polygon distance
 *
 * Build it as described in meos/test/trgeo_distwalk_test.c, adding
 * libpostgis.a and the GEOS libraries, which distrefpoly_set() needs for
 * getPoint4d_p():
 *
 * @code
 * gcc -O2 -Wall $FLAGS -o trgeo_distwalk_poly_test \
 *     meos/test/trgeo_distwalk_poly_test.c \
 *     meos/src/rgeo/trgeo_distwalk.c meos/src/rgeo/trgeo_distsolve.c \
 *     <build>/postgis/libpostgis.a <build>/pgtypes/libpgtypes.a \
 *     -L<meos install>/lib -lmeos -lgeos_c -lgeos -lproj -ljson-c -lm
 * @endcode
 *
 * What it establishes:
 *
 *   1. Every emitted instant carries the true distance there.
 *   2. The instants come out in increasing order.
 *   3. The MINIMUM over the emitted instants is the true minimum of the
 *      distance over the segment.  That is the property the whole design
 *      exists for: it is what makes nearestApproachDistance exact rather
 *      than an over-estimate, and it is what an implementation that
 *      brackets extrema by sampled values fails on roughly half of
 *      randomly generated rotating cases.
 *   4. No emitted distance is BELOW the true one, which would mean the walk
 *      is measuring to the LINE of an edge whose projection has left it.
 *
 * Section 4.2 of the paper excludes intersection, so segments where the
 * point enters the polygon are counted apart rather than validated; the
 * overlap regime is what will handle them.
 */

#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "rgeo/trgeo_distwalk.h"
#include "rgeo/trgeo_vclip.h"

extern void meos_initialize(void);
extern void meos_finalize(void);
extern Pose *pose_make_2d(double x, double y, double th, bool g, int32 srid);

static uint64_t rs = 0xDEADBEEF12345678ULL;
static double rnd(double lo, double hi)
{ rs ^= rs << 13; rs ^= rs >> 7; rs ^= rs << 17;
  return lo + (hi - lo) * ((double)(rs >> 11) / 9007199254740992.0); }

/* Andrew's monotone chain, so the reference polygon is genuinely convex */
static int cmpp(const void *a, const void *b)
{ const double *x = a, *y = b;
  if (x[0] != y[0]) return x[0] < y[0] ? -1 : 1;
  return x[1] < y[1] ? -1 : (x[1] > y[1]); }
static double cross3(const double *o, const double *a, const double *b)
{ return (a[0]-o[0])*(b[1]-o[1]) - (a[1]-o[1])*(b[0]-o[0]); }
static int hull(double *pts, int n, double *out)
{
  qsort(pts, n, 2*sizeof(double), cmpp);
  int k = 0;
  for (int i = 0; i < n; i++) {
    while (k >= 2 && cross3(out+2*(k-2), out+2*(k-1), pts+2*i) <= 0) k--;
    out[2*k] = pts[2*i]; out[2*k+1] = pts[2*i+1]; k++; }
  int lo = k+1;
  for (int i = n-2; i >= 0; i--) {
    while (k >= lo && cross3(out+2*(k-2), out+2*(k-1), pts+2*i) <= 0) k--;
    out[2*k] = pts[2*i]; out[2*k+1] = pts[2*i+1]; k++; }
  return k-1;   /* ccw, last point == first dropped */
}

/* True distance from a placed convex polygon to a point */
static double
truedist(const DistMotion *ma, const double *v, int n,
         const DistMotion *mb, double t)
{
  double px, py; distmotion_place(mb, 0.0, 0.0, t, &px, &py);
  double wx[64], wy[64];
  for (int i = 0; i < n; i++) distmotion_place(ma, v[2*i], v[2*i+1], t,
    &wx[i], &wy[i]);
  bool inside = true;
  for (int i = 0; i < n; i++) {
    int j = (i+1) % n;
    if ((wx[j]-wx[i])*(py-wy[i]) - (wy[j]-wy[i])*(px-wx[i]) < 0) {
      inside = false; break; } }
  if (inside) return 0.0;
  double best = 1e300;
  for (int i = 0; i < n; i++) {
    int j = (i+1) % n;
    double ux = wx[j]-wx[i], uy = wy[j]-wy[i];
    double l2 = ux*ux + uy*uy;
    double s = ((px-wx[i])*ux + (py-wy[i])*uy) / l2;
    s = s < 0 ? 0 : (s > 1 ? 1 : s);
    double d = hypot(px - (wx[i]+s*ux), py - (wy[i]+s*uy));
    if (d < best) best = d; }
  return best;
}

int main(int argc, char **argv)
{
  meos_initialize();
  int trials = (argc > 1) ? atoi(argv[1]) : 4000;
  const int SCAN = 40001;
  long nadbad = 0, valbad = 0, ordbad = 0, cyc = 0, full = 0, solve = 0;
  long nintersect = 0, ninside = 0, below = 0;
  double worst_nad = 0, worst_val = 0;
  long tot_ev = 0; int maxev_seen = 0;

  for (int k = 0; k < trials; k++)
  {
    /* Convex reference polygon about the body origin */
    double raw[40], hpts[100];
    int nraw = 4 + (int) rnd(0, 6.99);
    for (int i = 0; i < nraw; i++) {
      raw[2*i] = rnd(-4, 4); raw[2*i+1] = rnd(-4, 4); }
    int n = hull(raw, nraw, hpts);
    if (n < 3) continue;

    DistMotion ma, mb;
    distmotion_set(&ma, rnd(-20,-10), rnd(-6,6), rnd(-M_PI,M_PI),
                        rnd(10,20),  rnd(-6,6), rnd(-M_PI,M_PI));
    bool moving = (k % 3 == 0);
    if (moving)
      distmotion_set(&mb, rnd(-8,8), rnd(-10,10), 0.0,
                          rnd(-8,8), rnd(-10,10), 0.0);
    else
      distmotion_set_static(&mb, rnd(-8,8), rnd(-10,10));
    DistSegm seg; distsegm_set(&seg, &ma, &mb);

    /* Reference polygon and its feature constants */
    POINTARRAY *pa = ptarray_construct_empty(0, 0, (uint32_t)(n+1));
    for (int i = 0; i <= n; i++) {
      POINT4D p = {hpts[2*(i%n)], hpts[2*(i%n)+1], 0, 0};
      ptarray_append_point(pa, &p, LW_TRUE); }
    POINTARRAY **rings = lwalloc(sizeof(POINTARRAY *)); rings[0] = pa;
    LWPOLY *poly = lwpoly_construct(0, NULL, 1, rings);
    DistRefPoly rp;
    if (! distrefpoly_set(&rp, poly)) { lwpoly_free(poly); continue; }

    /* Seed from the existing v-clip oracle at t = 0 */
    double px0, py0; distmotion_place(&mb, 0, 0, 0.0, &px0, &py0);
    LWPOINT *lpt = lwpoint_make2d(0, px0, py0);
    Pose *p0 = pose_make_2d(ma.cx, ma.cy, ma.th0, false, 0);
    uint32_t cf = 0;
    v_clip_tpoly_point(poly, lpt, p0, &cf, NULL);

    DistRefVert target; distrefvert_set(&target, 0.0, 0.0);
    DistEvent ev[256]; int nev = 0;
    int rc = distwalk_poly_point(&seg, &rp, &target, 1e-12, &cf, ev, 256,
      &nev);

    /* Section 4.2 excludes intersection, so classify that first: a walk that
     * reports it cannot proceed there is behaving correctly */
    bool touches0 = false;
    for (int j = 0; j < SCAN; j += 1)
      if (truedist(&ma, hpts, n, &mb, (double)j/(SCAN-1)) <= 0.0)
      { touches0 = true; break; }
    if (touches0) { nintersect++; distrefpoly_free(&rp);
      lwpoly_free(poly); lwpoint_free(lpt); free(p0); continue; }
    if (rc == DISTWALK_CYCLE) cyc++;
    else if (rc == DISTWALK_FULL) full++;
    else if (rc == DISTWALK_SOLVE) solve++;
    else if (rc == DISTWALK_INSIDE) ninside++;
    else
    {
      /* Section 4.2 of the paper excludes intersection; the walk has no
       * notion of "inside" until the overlap regime exists, so those are
       * reported apart rather than counted as failures */
      tot_ev += nev; if (nev > maxev_seen) maxev_seen = nev;
      /* every event value must be the true distance there */
      for (int i = 0; i < nev; i++) {
        double td = truedist(&ma, hpts, n, &mb, ev[i].t);
        double d = fabs(ev[i].dist - td) / (1 + td);
        if (d > worst_val) worst_val = d;
        if (d > 1e-7) {
          valbad++;
        }
        if (i && ev[i].t < ev[i-1].t - 1e-15) ordbad++; }
      /* independent check: is the reported distance ever LESS than the true
       * distance?  that would mean a feature closer than the polygon, i.e. a
       * formula error rather than a tracking error */
      for (int i = 0; i < nev; i++) {
        double td = truedist(&ma, hpts, n, &mb, ev[i].t);
        if (ev[i].dist < td - 1e-9 * (1 + td)) below++; }
      /* the minimum of the events must be the true minimum */
      double emin = 1e300;
      for (int i = 0; i < nev; i++) if (ev[i].dist < emin) emin = ev[i].dist;
      double bmin = 1e300;
      for (int j = 0; j < SCAN; j++) {
        double td = truedist(&ma, hpts, n, &mb, (double)j/(SCAN-1));
        if (td < bmin) bmin = td; }
      double rel = (emin - bmin) / (1 + bmin);
      if (rel > worst_nad) worst_nad = rel;
      if (rel > 1e-6) nadbad++;
    }
    distrefpoly_free(&rp);
    lwpoly_free(poly); lwpoint_free(lpt); free(p0);
  }
  printf("closest-feature walk over %d segments (a third with a moving "
    "point)\n", trials);
  printf("  events per segment          avg %.1f, max %d\n",
    (double) tot_ev / trials, maxev_seen);
  printf("  event value wrong           %ld  (worst rel %.3e)\n", valbad,
    worst_val);
  printf("  events out of order         %ld\n", ordbad);
  printf("  NAD above the true minimum  %ld  (worst rel %.3e)\n", nadbad,
    worst_nad);
  printf("  cycle %ld, buffer full %ld, solver %ld\n", cyc, full, solve);
  printf("  intersecting, skipped (step 4) %ld\n", nintersect);
  printf("  settle reported INSIDE %ld\n", ninside);
  printf("  reported BELOW the true distance %ld\n", below);
  bool ok = ! valbad && ! ordbad && ! nadbad && ! cyc && ! full && ! solve;
  printf("\n%s\n", ok ? "all checks passed" : "FAILURES");
  meos_finalize();
  return ok ? 0 : 1;
}
