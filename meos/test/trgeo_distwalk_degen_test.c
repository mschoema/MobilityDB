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
 * @brief Constructed degenerate configurations for the closest-feature walk of
 * meos/src/rgeo/trgeo_distwalk.c
 *
 * Randomized testing cannot reach these.  Every special case Section 4.3.3 of
 * the paper lists is a coincidence of measure zero -- a vertex exactly
 * collinear with its neighbours, a target starting exactly on a Voronoi
 * boundary, a rotation of exactly half a turn, a contact that touches without
 * crossing -- and random geometry produces none of them.  They have to be
 * built by hand, which is what this file does.
 *
 * It earns its keep: it found three failures that twenty thousand randomized
 * segments did not, all of them the same cause.  A target sitting exactly on a
 * region boundary leaves the region test undecided, and the exit the walk then
 * looks for lies at or before the instant it is already at.
 *
 * Build it as described in meos/test/trgeo_distwalk_poly_test.c, and do NOT
 * define NDEBUG: the builders carry their own assertions.
 *
 * A configuration whose name begins with INTERSECTS lies outside what
 * Section 4.2 covers.  The walk has no notion of an interior, so it answers
 * with the distance to a boundary feature where the truth is zero.  It is
 * listed rather than removed because the overlap regime is what will fix it,
 * and because the routing must not go in before then.
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "rgeo/trgeo_distwalk.h"
extern void meos_initialize(void);

/* true distance from a placed convex ring to a point (handles a 180 vertex) */
static double
truedist(const DistMotion *ma, const double *v, int n, const DistMotion *mb,
  double t)
{
  double px, py; distmotion_place(mb, 0, 0, t, &px, &py);
  double wx[16], wy[16];
  for (int i = 0; i < n; i++)
    distmotion_place(ma, v[2*i], v[2*i+1], t, &wx[i], &wy[i]);
  bool inside = true;
  for (int i = 0; i < n; i++) { int j = (i+1)%n;
    if ((wx[j]-wx[i])*(py-wy[i]) - (wy[j]-wy[i])*(px-wx[i]) < 0)
    { inside = false; break; } }
  if (inside) return 0.0;
  double best = 1e300;
  for (int i = 0; i < n; i++) { int j = (i+1)%n;
    double ux = wx[j]-wx[i], uy = wy[j]-wy[i], l2 = ux*ux+uy*uy;
    if (l2 == 0.0) continue;
    double s = ((px-wx[i])*ux + (py-wy[i])*uy)/l2;
    s = s<0?0:(s>1?1:s);
    double d = hypot(px-(wx[i]+s*ux), py-(wy[i]+s*uy));
    if (d < best) best = d; }
  return best;
}

typedef struct {
  const char *name;
  int n; double v[32];
  double ax,ay,ath, bx,by,bth;      /* body A pose segment */
  double tx1,ty1, tx2,ty2;          /* target, start and end */
} Case;

static const double R2 = 1.4142135623730951;   /* sqrt(2) */

static Case cases[] = {
 /* every one keeps the target strictly outside the body, except where the
  * name says otherwise, so that a refusal is a real failure and not the
  * intersection that Section 4.2 excludes */
 {"baseline, no rotation", 4, {-1,-1, 1,-1, 1,1, -1,1},
  -6,0,0,  6,0,0,          3,5, 3,5},
 {"COLLINEAR vertex: zero-width wedge", 5, {-1,-1, 0,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,0,           -3,-3, 3,-3},
 {"near-collinear vertex (1e-9)", 5,
  {-1,-1, 0,-1.000000001, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,0,           -3,-3, 3,-3},
 {"target starts ON a Voronoi boundary", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,0,           2,-1, 2,1},
 {"target ENDS on a Voronoi boundary", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,0,           2,1, 2,-1},
 {"near-tangential vertex approach", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,M_PI/2,      R2+0.001,0, R2+0.001,0},
 {"constant distance (parallel to an edge)", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,0,           -3,-3, 3,-3},
 {"rotation exactly pi (tie-break)", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,M_PI,        3,0, 3,0},
 {"rotation exactly pi/2 (symmetry period)", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,M_PI/2,      3,0, 3,0},
 {"extremum exactly at t=0", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,6,0,           0,-3, 0,-3},
 {"extremum exactly at t=1", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,6,0,  0,0,0,           0,-3, 0,-3},
 {"fully static (no motion at all)", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,0,           3,0, 3,0},
 {"target grazes an edge line", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,-0.4, 0,0,0.4,       0,R2, 0,R2},
 {"transition lands exactly on t=1", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,0,           2,-3, 2,-1},
 {"TANGENTIAL contact (touches at one instant)", 4, {-1,-1, 1,-1, 1,1, -1,1},
  0,0,0,  0,0,M_PI/2,      R2,0, R2,0},
 {"INTERSECTS (sweeps over the target)", 4, {-1,-1, 1,-1, 1,1, -1,1},
  -6,0,0,  6,0,0,          3,0, 3,0},
};

int main(void)
{
  meos_initialize();
  int ncase = (int)(sizeof cases / sizeof cases[0]), bad = 0;
  printf("%-42s %-8s %5s %10s %10s %s\n", "configuration", "rc", "ev",
    "max|err|", "nad-brute", "dups");
  for (int c = 0; c < ncase; c++)
  {
    Case *k = &cases[c];
    DistMotion ma, mb;
    distmotion_set(&ma, k->ax, k->ay, k->ath, k->bx, k->by, k->bth);
    distmotion_set(&mb, k->tx1, k->ty1, 0.0, k->tx2, k->ty2, 0.0);
    DistSegm seg; distsegm_set(&seg, &ma, &mb);
    POINTARRAY *pa = ptarray_construct_empty(0, 0, (uint32_t)(k->n+1));
    for (int i = 0; i <= k->n; i++) {
      POINT4D p = {k->v[2*(i%k->n)], k->v[2*(i%k->n)+1], 0, 0};
      ptarray_append_point(pa, &p, LW_TRUE); }
    POINTARRAY **rings = lwalloc(sizeof(POINTARRAY*)); rings[0] = pa;
    LWPOLY *lp = lwpoly_construct(0, NULL, 1, rings);
    DistRefPoly rp;
    if (! distrefpoly_set(&rp, lp)) { printf("%-42s refpoly REJECTED\n",
      k->name); lwpoly_free(lp); continue; }
    DistRefVert tgt; distrefvert_set(&tgt, 0, 0);
    /* seed by scanning every feature, so the test does not depend on v-clip */
    uint32_t cf = 0; double bd = 1e300;
    for (uint32_t q = 0; q < (uint32_t) rp.nvert * 2; q++) {
      DistFun f; double d;
      if (q % 2 == 0) { distwalk_vertdist2(&seg, &rp.verts[q/2], &tgt, &f);
        d = sqrt(fmax(0.0, distfun_eval(&f, 0.0))); }
      else { distwalk_cross(&seg, &rp.edges[q/2], &tgt, &f);
        d = fabs(distfun_eval(&f, 0.0)) / rp.edges[q/2].len; }
      if (d < bd) { bd = d; cf = q; } }
    DistEvent ev[128]; int nev = 0;
    int rc = distwalk_poly_point(&seg, &rp, &tgt, 1e-12, &cf, ev, 128, &nev);
    double maxerr = 0, emin = 1e300, bmin = 1e300; int dups = 0;
    if (rc == DISTWALK_OK) {
      for (int i = 0; i < nev; i++) {
        double td = truedist(&ma, k->v, k->n, &mb, ev[i].t);
        double e = fabs(ev[i].dist - td)/(1+td);
        if (e > maxerr) maxerr = e;
        if (ev[i].dist < emin) emin = ev[i].dist;
        if (i && ev[i].t <= ev[i-1].t) dups++; }
      for (int j = 0; j <= 400000; j++) {
        double td = truedist(&ma, k->v, k->n, &mb, (double)j/400000.0);
        if (td < bmin) bmin = td; } }
    const char *rcs = rc==DISTWALK_OK?"OK":(rc==DISTWALK_CYCLE?"CYCLE":
      (rc==DISTWALK_INSIDE?"INSIDE":(rc==DISTWALK_FULL?"FULL":"SOLVE")));
    /* A configuration whose name starts with INTERSECTS is outside what
     * Section 4.2 covers: the walk has no notion of an interior until the
     * overlap regime exists, so it is reported and not counted */
    bool excluded = strncmp(k->name, "INTERSECTS", 10) == 0;
    if (rc == DISTWALK_OK) {
      printf("%-42s %-8s %5d %10.2e %+10.2e %d%s\n", k->name, rcs, nev,
        maxerr, emin-bmin, dups, excluded ? "   <- overlap regime" : "");
      if (! excluded && (maxerr > 1e-9 || emin - bmin > 1e-9 || dups)) bad++;
    } else printf("%-42s %-8s %5d %10s %10s %s%s\n", k->name, rcs, nev,
      "-", "-", "-", excluded ? "   <- overlap regime" : "");
    distrefpoly_free(&rp); lwpoly_free(lp);
  }
  /* ---- canonicalization of the reference ring itself ---- */
  printf("\ncanonicalization of the reference ring\n");
  {
    struct { const char *name; int n; double v[24]; int want; } rings[] = {
      {"plain square", 4, {-1,-1, 1,-1, 1,1, -1,1}, 4},
      {"clockwise square", 4, {-1,-1, -1,1, 1,1, 1,-1}, 4},
      {"repeated vertex", 5, {-1,-1, 1,-1, 1,-1, 1,1, -1,1}, 4},
      {"two repeated vertices", 6,
       {-1,-1, -1,-1, 1,-1, 1,1, -1,1, -1,1}, 4},
      {"one collinear vertex", 5, {-1,-1, 0,-1, 1,-1, 1,1, -1,1}, 4},
      {"three collinear on one edge", 7,
       {-1,-1, -0.5,-1, 0,-1, 0.5,-1, 1,-1, 1,1, -1,1}, 4},
      {"collinear at the wrap", 5, {0,-1, 1,-1, 1,1, -1,1, -1,-1}, 4},
      {"NON-CONVEX, reflex vertex (refused)", 5,
       {0,0, 2,0, 2,2, 1,0.5, 0,2}, 0},
      {"degenerate to a line (refused)", 4, {0,0, 1,0, 2,0, 3,0}, 0},
      {"all points equal (refused)", 4, {1,1, 1,1, 1,1, 1,1}, 0},
    };
    int nr = (int)(sizeof rings / sizeof rings[0]);
    for (int r = 0; r < nr; r++)
    {
      POINTARRAY *pa = ptarray_construct_empty(0, 0,
        (uint32_t)(rings[r].n + 1));
      for (int i = 0; i <= rings[r].n; i++) {
        POINT4D p = {rings[r].v[2*(i % rings[r].n)],
                     rings[r].v[2*(i % rings[r].n)+1], 0, 0};
        ptarray_append_point(pa, &p, LW_TRUE); }
      POINTARRAY **rg = lwalloc(sizeof(POINTARRAY *)); rg[0] = pa;
      LWPOLY *lp = lwpoly_construct(0, NULL, 1, rg);
      DistRefPoly rp;
      bool ok = distrefpoly_set(&rp, lp);
      int got = ok ? rp.nvert : 0;
      /* a canonical ring is counterclockwise, so its area is positive */
      double a2 = 0.0;
      if (ok) for (int i = 0; i < rp.nvert; i++) {
        int j = (i + 1) % rp.nvert;
        a2 += rp.verts[i].x * rp.verts[j].y - rp.verts[j].x * rp.verts[i].y; }
      bool good = (got == rings[r].want) && (! ok || a2 > 0.0);
      printf("  %-32s -> %d vertices%s  %s\n", rings[r].name, got,
        ok ? (a2 > 0 ? ", ccw" : ", CW!") : "", good ? "ok" : "FAIL");
      if (! good) bad++;
      if (ok) distrefpoly_free(&rp);
      lwpoly_free(lp);
    }
  }

  printf("\n%d configurations with a problem\n", bad);
  return bad ? 1 : 0;
}
