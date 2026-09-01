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
 * @brief Closest-feature walk for the distance between rigid geometries
 *
 * The closed forms built here are derived in meos/src/rgeo/trgeo_distance.txt.
 * Each is checked against the expression it stands for whenever assertions are
 * enabled: see #distwalk_check().  A sign transcribed wrongly then fails at
 * the point of the mistake, on real inputs, rather than as an unexplained
 * distance much later.
 */

#include "rgeo/trgeo_distwalk.h"

/* C */
#include <assert.h>
#include <math.h>
/* MEOS */
#include "temporal/temporal.h"

/*****************************************************************************
 * Setting up a segment
 *****************************************************************************/

/**
 * @brief Return the rotation of a pose segment, by the shortest arc
 * @details Reproduces exactly the convention of #posesegm_interpolate(),
 * including its counterclockwise tie-break at half a turn, so that a distance
 * computed from @p w agrees with a body placed by interpolating the poses.
 * Reading the convention once per segment is also what keeps the five-way test
 * out of the inner loops.
 */
static double
motion_omega(double th1, double th2)
{
  double d = th2 - th1;
  if (fabs(d) < MEOS_EPSILON)
    return 0.0;
  if (d > 0.0)
    return (d <= M_PI) ? d : d - 2.0 * M_PI;
  return (d > -M_PI) ? d : d + 2.0 * M_PI;
}

/**
 * @brief Set the motion of an operand from the two ends of a pose segment
 */
void
distmotion_set(DistMotion *m, double x1, double y1, double th1, double x2,
  double y2, double th2)
{
  assert(m);
  m->cx = x1;
  m->cy = y1;
  m->dx = x2 - x1;
  m->dy = y2 - y1;
  m->th0 = th1;
  m->w = motion_omega(th1, th2);
}

/**
 * @brief Set the motion of a static operand placed at (@p x, @p y)
 * @details A static geometry is the degenerate motion: no rotation, no
 * translation, and its point taken as the rotation centre so that the body
 * vertex offset is zero.  Every builder then answers the static case without a
 * branch of its own
 */
void
distmotion_set_static(DistMotion *m, double x, double y)
{
  assert(m);
  m->cx = x;
  m->cy = y;
  m->dx = m->dy = 0.0;
  m->th0 = m->w = 0.0;
}

/**
 * @brief Set the motion of an operand from two poses
 */
void
distmotion_from_pose(DistMotion *m, const Pose *p1, const Pose *p2)
{
  assert(m); assert(p1); assert(p2);
  distmotion_set(m, p1->data[0], p1->data[1], p1->data[2], p2->data[0],
    p2->data[1], p2->data[2]);
}

/**
 * @brief Return in the last arguments the position at @p t of the body point
 * (@p px, @p py) carried by @p m
 */
void
distmotion_place(const DistMotion *m, double px, double py, double t,
  double *x, double *y)
{
  assert(m); assert(x); assert(y);
  double th = m->th0 + m->w * t;
  double c = cos(th), s = sin(th);
  *x = px * c - py * s + m->cx + m->dx * t;
  *y = px * s + py * c + m->cy + m->dy * t;
}

/**
 * @brief Set a segment from the motion of its two operands
 */
void
distsegm_set(DistSegm *seg, const DistMotion *ma, const DistMotion *mb)
{
  assert(seg); assert(ma); assert(mb);
  seg->ma = *ma;
  seg->mb = *mb;
  seg->wx0 = mb->cx - ma->cx;
  seg->wy0 = mb->cy - ma->cy;
  seg->wx1 = mb->dx - ma->dx;
  seg->wy1 = mb->dy - ma->dy;
}

/**
 * @brief Set the motion constants of a reference edge
 */
void
distrefedge_set(DistRefEdge *e, double sx, double sy, double ex, double ey)
{
  assert(e);
  double ux = ex - sx, uy = ey - sy;
  e->sx = sx; e->sy = sy;
  e->ex = ex; e->ey = ey;
  e->len = hypot(ux, uy);
  assert(e->len > 0.0);
  e->beta = atan2(uy, ux);
  e->dots = sx * ux + sy * uy;
  e->crss = sx * uy - sy * ux;
}

/**
 * @brief Set the motion constants of a reference vertex
 */
void
distrefvert_set(DistRefVert *v, double x, double y)
{
  assert(v);
  v->x = x;
  v->y = y;
  v->rho = hypot(x, y);
  v->alpha = (v->rho > 0.0) ? atan2(y, x) : 0.0;
}

/*****************************************************************************
 * Self-check
 *****************************************************************************/

#ifndef NDEBUG
/**
 * @brief Fail an assertion if @p f does not reproduce @p direct at @p t
 * @details Compiled out under NDEBUG.  The comparison is relative, because the
 * quantities involved are squared lengths and so span the square of the
 * coordinate range
 */
static void
distwalk_check(const DistFun *f, double direct, double t)
{
  double got = distfun_eval(f, t);
  double scale = 1.0 + fabs(direct) + fabs(got);
  assert(fabs(got - direct) <= 1e-6 * scale);
  (void) got; (void) scale; (void) t;
}
#endif

/*****************************************************************************
 * Coefficient builders
 *****************************************************************************/

/**
 * @brief Build the numerator of the projection parameter of Equation (8)
 * @details Solving f(t) = 0 answers s(t) = 0 and solving f(t) = len*len
 * answers s(t) = 1: one function asked at two levels, because
 * s(t) = f(t)/len^2.  These are Equations (11), (12), (15), (16) and (17) of
 * the paper.
 *
 *   f(t) = dot( p(t) - vs(t), ve(t) - vs(t) )
 *        = L*[ Wx(t)*cos(wA*t + thA + beta)
 *            + Wy(t)*sin(wA*t + thA + beta) ]
 *        + rb*L*cos( (wA - wB)*t + (thA - thB) + beta - alpha_b )
 *        - dot(s, u)
 *
 * The rotation of the operand carrying the VERTEX enters only through the
 * frequency wA - wB and only with a constant amplitude; the rotation of the
 * one carrying the EDGE enters with affine coefficients.  A static target has
 * rb = 0, which deletes the second term.
 */
void
distwalk_transition(const DistSegm *seg, const DistRefEdge *e,
  const DistRefVert *v, DistFun *f)
{
  assert(seg); assert(e); assert(v); assert(f);
  const DistMotion *ma = &seg->ma, *mb = &seg->mb;
  double L = e->len;
  distfun_init(f);
  distfun_add(f, ma->w, ma->th0 + e->beta, L * seg->wx1, L * seg->wx0,
    L * seg->wy1, L * seg->wy0);
  if (v->rho > 0.0)
    distfun_add(f, ma->w - mb->w,
      (ma->th0 - mb->th0) + e->beta - v->alpha, 0.0, v->rho * L, 0.0, 0.0);
  distfun_add_poly(f, 0.0, 0.0, -e->dots);
#ifndef NDEBUG
  for (int i = 0; i <= 2; i++)
  {
    double t = 0.5 * i, qsx, qsy, qex, qey, px, py;
    distmotion_place(ma, e->sx, e->sy, t, &qsx, &qsy);
    distmotion_place(ma, e->ex, e->ey, t, &qex, &qey);
    distmotion_place(mb, v->x, v->y, t, &px, &py);
    distwalk_check(f, (px - qsx) * (qex - qsx) + (py - qsy) * (qey - qsy), t);
  }
#endif
}

/**
 * @brief Build the cross-product sibling of #distwalk_transition()
 * @details Its roots are Equation (13), the instants at which the vertex meets
 * the line of the edge, and its value divided by the edge length is the SIGNED
 * distance from the vertex to that line.  Inside a vertex-to-edge feature
 * interval the projection parameter lies strictly between zero and one, so
 * |f(t)|/len is exactly the distance of Equation (21) -- without substituting
 * s(t) back into it, which is the step the paper leaves out.  The extrema of
 * the distance are therefore the roots of this function's derivative, and its
 * own roots are the contact instants.
 */
void
distwalk_cross(const DistSegm *seg, const DistRefEdge *e,
  const DistRefVert *v, DistFun *f)
{
  assert(seg); assert(e); assert(v); assert(f);
  const DistMotion *ma = &seg->ma, *mb = &seg->mb;
  double L = e->len;
  distfun_init(f);
  /* The same term with cos and sin exchanged: the cos coefficient carries
   * -Wy and the sin coefficient carries Wx */
  distfun_add(f, ma->w, ma->th0 + e->beta, -L * seg->wy1, -L * seg->wy0,
    L * seg->wx1, L * seg->wx0);
  if (v->rho > 0.0)
    distfun_add(f, ma->w - mb->w,
      (ma->th0 - mb->th0) + e->beta - v->alpha, 0.0, 0.0, 0.0, v->rho * L);
  distfun_add_poly(f, 0.0, 0.0, -e->crss);
#ifndef NDEBUG
  for (int i = 0; i <= 2; i++)
  {
    double t = 0.5 * i, qsx, qsy, qex, qey, px, py;
    distmotion_place(ma, e->sx, e->sy, t, &qsx, &qsy);
    distmotion_place(ma, e->ex, e->ey, t, &qex, &qey);
    distmotion_place(mb, v->x, v->y, t, &px, &py);
    distwalk_check(f, (px - qsx) * (qey - qsy) - (py - qsy) * (qex - qsx), t);
  }
#endif
}

/**
 * @brief Build the squared distance between two moving vertices,
 * Equation (20)
 * @details
 *
 *   f(t) = |W(t)|^2 + ra^2 + rb^2
 *        + 2*rb*[ Wx(t)*cos(wB*t + thB + alpha_b)
 *               + Wy(t)*sin(wB*t + thB + alpha_b) ]
 *        - 2*ra*[ Wx(t)*cos(wA*t + thA + alpha_a)
 *               + Wy(t)*sin(wA*t + thA + alpha_a) ]
 *        - 2*ra*rb*cos( (wB - wA)*t + (thB - thA) + alpha_b - alpha_a )
 *
 * This is the one builder that uses all three frequencies of the segment.
 * With neither operand rotating it collapses to the quadratic |W(t)|^2 plus a
 * constant, whose single extremum #distfun_roots() answers in closed form.
 */
void
distwalk_vertdist2(const DistSegm *seg, const DistRefVert *va,
  const DistRefVert *vb, DistFun *f)
{
  assert(seg); assert(va); assert(vb); assert(f);
  const DistMotion *ma = &seg->ma, *mb = &seg->mb;
  double wx1 = seg->wx1, wx0 = seg->wx0, wy1 = seg->wy1, wy0 = seg->wy0;
  distfun_init(f);
  /* |W(t)|^2, a quadratic, plus the two constant radii */
  distfun_add_poly(f, wx1 * wx1 + wy1 * wy1,
    2.0 * (wx0 * wx1 + wy0 * wy1),
    wx0 * wx0 + wy0 * wy0 + va->rho * va->rho + vb->rho * vb->rho);
  if (vb->rho > 0.0)
  {
    double k = 2.0 * vb->rho;
    distfun_add(f, mb->w, mb->th0 + vb->alpha, k * wx1, k * wx0, k * wy1,
      k * wy0);
  }
  if (va->rho > 0.0)
  {
    double k = -2.0 * va->rho;
    distfun_add(f, ma->w, ma->th0 + va->alpha, k * wx1, k * wx0, k * wy1,
      k * wy0);
  }
  if (va->rho > 0.0 && vb->rho > 0.0)
    distfun_add(f, mb->w - ma->w,
      (mb->th0 - ma->th0) + vb->alpha - va->alpha,
      0.0, -2.0 * va->rho * vb->rho, 0.0, 0.0);
#ifndef NDEBUG
  for (int i = 0; i <= 2; i++)
  {
    double t = 0.5 * i, ax, ay, bx, by;
    distmotion_place(ma, va->x, va->y, t, &ax, &ay);
    distmotion_place(mb, vb->x, vb->y, t, &bx, &by);
    distwalk_check(f, (bx - ax) * (bx - ax) + (by - ay) * (by - ay), t);
  }
#endif
}

/**
 * @brief Build the parallel-edge test of Equations (18) and (19)
 * @details A rotation preserves the cross product, so the amplitude is
 * constant and the whole test is one sinusoid,
 *
 *   f(t) = La*Lb*sin( (wB - wA)*t + (thB - thA) + beta_b - beta_a )
 *
 * whose roots #distfun_roots() enumerates directly rather than isolating.  The
 * paper states that these equations must be solved numerically; they need not
 * be.  When the two operands rotate at the same rate the frequency is zero and
 * the function is constant: the edges are parallel for the whole segment or
 * never, which is the special case of Section 4.3.3, here visible as a
 * coefficient rather than as a root finder failing to bracket.
 */
void
distwalk_parallel(const DistSegm *seg, const DistRefEdge *ea,
  const DistRefEdge *eb, DistFun *f)
{
  assert(seg); assert(ea); assert(eb); assert(f);
  const DistMotion *ma = &seg->ma, *mb = &seg->mb;
  distfun_init(f);
  distfun_add(f, mb->w - ma->w,
    (mb->th0 - ma->th0) + eb->beta - ea->beta, 0.0, 0.0, 0.0,
    ea->len * eb->len);
#ifndef NDEBUG
  for (int i = 0; i <= 2; i++)
  {
    double t = 0.5 * i, asx, asy, aex, aey, bsx, bsy, bex, bey;
    distmotion_place(ma, ea->sx, ea->sy, t, &asx, &asy);
    distmotion_place(ma, ea->ex, ea->ey, t, &aex, &aey);
    distmotion_place(mb, eb->sx, eb->sy, t, &bsx, &bsy);
    distmotion_place(mb, eb->ex, eb->ey, t, &bex, &bey);
    distwalk_check(f, (aex - asx) * (bey - bsy) - (aey - asy) * (bex - bsx),
      t);
  }
#endif
}


/*****************************************************************************
 * The closest-feature walk
 *****************************************************************************/

/** The width below which two instants of a segment are one.  It has three
 * jobs, none of which is rejecting the re-reported crossing that
 * #distfun_first_root() takes a direction for: that one is settled without a
 * tolerance.  It makes each transition land strictly later than the last, so
 * the walk advances and terminates rather than leaning on the step cap below;
 * it keeps an extremum that coincides with a feature boundary from being
 * emitted twice, once as a boundary and once as an extremum; and it collapses
 * the instants where the two separate solves of a feature interval, for
 * extrema and for contacts, agree.
 *
 * Sweeping it over the randomized suite changes nothing anywhere from zero to
 * 1e-6, because the configurations that need it are degenerate ones that
 * random geometry does not produce.  That is a reason to keep it, not to
 * remove it. */
#define DISTWALK_TADV      1e-12

/** How far outside its region the target must be before #settle_feature()
 * moves off a feature.  A transition lands EXACTLY on a region boundary, where
 * the test is a coin toss on the last bit; settling there would undo the
 * transition that just happened and strand the walk, since the exit it would
 * then look for lies in the past.  The projection parameter is dimensionless,
 * so unlike a distance this tolerance needs no length scale. */
#define DISTWALK_SEPS      1e-9

/** Steps one segment may take before the walk is declared stuck */
#define DISTWALK_MAXSTEP   4096

/**
 * @brief Build the function whose value gives the distance realized by the
 * feature @p cf
 * @details A vertex carries its squared distance and an edge carries the cross
 * product whose magnitude over the edge length is the distance, so the two are
 * read back through #feature_dist() rather than being made uniform here.
 * Keeping the squared form for a vertex and the signed form for an edge is
 * what lets the extrema be roots of an exact derivative in both cases.
 */
static void
feature_distfun(const DistSegm *seg, const DistRefPoly *rp,
  const DistRefVert *target, uint32_t cf, DistFun *f)
{
  uint32_t i = cf / 2;
  if (cf % 2 == 0)
    distwalk_vertdist2(seg, &rp->verts[i], target, f);
  else
    distwalk_cross(seg, &rp->edges[i], target, f);
}

/**
 * @brief Return the distance realized by the feature @p cf at @p t
 */
static double
feature_dist(const DistRefPoly *rp, uint32_t cf, const DistFun *f, double t)
{
  if (cf % 2 == 0)
  {
    double q = distfun_eval(f, t);
    return (q > 0.0) ? sqrt(q) : 0.0;
  }
  return fabs(distfun_eval(f, t)) / rp->edges[cf / 2].len;
}

/**
 * @brief Return true if the target has left the region bounded by
 * s = @p level of edge @p i, on the side @p dir
 * @details @p dir is the direction that leads OUT: the boundary a region sits
 * below is left by rising and the one it sits above by falling.
 *
 * Exactly on the boundary the value cannot decide, and that is not a rare
 * position: every transition puts the target there, and so does a segment that
 * merely begins or ends on one.  The derivative decides instead, which is the
 * same answer #distfun_first_root() gives to the same question, and the same
 * one Section 4.2 of the paper reaches by looking at an instant just after.
 * Reading the sign is exact where probing just after would need a step size.
 */
static bool
region_left(const DistSegm *seg, const DistRefPoly *rp,
  const DistRefVert *target, uint32_t i, double level, double dir, double t)
{
  DistFun f;
  distwalk_transition(seg, &rp->edges[i], target, &f);
  double s = distfun_eval(&f, t) /
    (rp->edges[i].len * rp->edges[i].len) - level;
  if (s * dir > DISTWALK_SEPS)
    return true;                        /* clear of the boundary, outside */
  if (fabs(s) > DISTWALK_SEPS)
    return false;                       /* clear of the boundary, inside */
  DistFun df;
  distfun_deriv(&f, &df);
  return distfun_eval(&df, t) * dir > 0.0;
}

/**
 * @brief Return the distance of the target from the line of edge @p i at @p t,
 * positive on the outer side of the ring
 */
static double
distwalk_signed_side(const DistSegm *seg, const DistRefPoly *rp,
  const DistRefVert *target, uint32_t i, double t)
{
  DistFun g;
  distwalk_cross(seg, &rp->edges[i], target, &g);
  /* The ring is counterclockwise by construction, so outside is the left of
   * an edge and the cross product needs no orientation correction */
  return distfun_eval(&g, t) / rp->edges[i].len;
}

/**
 * @brief Move @p cf to the feature whose Voronoi region holds the target at
 * @p t
 * @details The region of a vertex i is where the projection parameter of the
 * edge leaving it is at most zero and that of the edge entering it is at least
 * one; the region of an edge is where its own parameter lies between them.
 * Each violated condition names the neighbour to step to, so this converges in
 * at most one lap of the polygon, exactly as the v-clip oracle does -- but on
 * the closed forms already at hand, with no geometry to place.
 *
 * The walk needs this because two transition times computed from two different
 * equations need not be consistent when the region between them is thin.  A
 * vertex whose edges are short, on a body that rotates, can have its wedge
 * crossed in a few parts per million of a segment, and then the walk arrives
 * at that vertex at an instant already past the exit it will go looking for.
 * Re-establishing the invariant on arrival costs one or two evaluations and
 * removes the whole class.
 *
 * @return #DISTWALK_OK, or #DISTWALK_INSIDE when no region holds the target,
 * which for a convex polygon means it is inside
 */
static int
settle_feature(const DistSegm *seg, const DistRefPoly *rp,
  const DistRefVert *target, double t, uint32_t *cf)
{
  uint32_t n = (uint32_t) rp->nvert, n2 = n * 2;
  for (uint32_t guard = 0; guard <= n2; guard++)
  {
    uint32_t i = *cf / 2;
    if (*cf % 2 == 0)
    {
      /* A vertex is held while the edge leaving it has not started and the
       * edge entering it has finished */
      if (region_left(seg, rp, target, i, 0.0, 1.0, t))
      {
        *cf = (*cf + 1) % n2;
        continue;
      }
      if (region_left(seg, rp, target, (i + n - 1) % n, 1.0, -1.0, t))
      {
        *cf = (*cf + n2 - 1) % n2;
        continue;
      }
      return DISTWALK_OK;
    }
    /* An edge is held while its own projection parameter is between its two
     * vertices */
    if (region_left(seg, rp, target, i, 0.0, -1.0, t))
    {
      *cf = (*cf + n2 - 1) % n2;
      continue;
    }
    if (region_left(seg, rp, target, i, 1.0, 1.0, t))
    {
      *cf = (*cf + 1) % n2;
      continue;
    }
    /* The strip where the projection lands on the edge reaches BOTH sides of
     * it, so several edges satisfy the test above and it does not by itself
     * name the outer region.  The region also requires the target to be on the
     * outer side, which is the sign of the cross product against the ring
     * orientation.  Omitting this is the mistake the v-clip oracle avoids with
     * its own angle test. */
    double side = distwalk_signed_side(seg, rp, target, i, t);
    if (side >= 0.0)
      return DISTWALK_OK;
    /* On the inner side: no local step names the right edge, so take the one
     * the target is most outside of, as the oracle does.  When it is outside
     * none of them it is inside the polygon. */
    {
      double bestd = 0.0;
      uint32_t beste = i;
      bool any = false;
      for (uint32_t q = 0; q < n; q++)
      {
        double sq = distwalk_signed_side(seg, rp, target, q, t);
        if (sq > 0.0 && (! any || sq > bestd))
        {
          bestd = sq; beste = q; any = true;
        }
      }
      if (! any)
        return DISTWALK_INSIDE;
      if (2 * beste + 1 == *cf)
        return DISTWALK_OK;
      *cf = 2 * beste + 1;
    }
  }
  return DISTWALK_INSIDE;
}

/**
 * @brief Return in the last arguments the earliest closest-feature transition
 * after @p t, or leave them at the end of the segment
 * @details Both directions are solved at every step.  Restricting to the
 * direction of the previous step, which an implementation may be tempted to
 * do, assumes the target sweeps monotonically around the polygon and is not
 * part of Algorithm 1 of the paper.
 *
 * From an edge the two tests are the SAME function at two levels, because the
 * projection parameter is this function over the squared edge length: zero
 * exits by the start vertex and the squared length by the end vertex.  Only
 * the vertex case needs two functions, since its two tests belong to the two
 * different edges meeting there.
 *
 * A root of one of those equations is not by itself a transition.  Leaving a
 * region means crossing its boundary OUTWARD, and each of the four tests knows
 * which direction that is: the two that bound a region from above are left by
 * rising and the two that bound it from below by falling.  A crossing the
 * other way is the boundary being ENTERED, which is where the walk already is.
 *
 * That direction is passed to #distfun_first_root(), which explains there why
 * asking for the first root alone would return the crossing just taken.
 * @return #DISTWALK_OK, or #DISTWALK_SOLVE if the isolator reported a
 * condition other than an identically zero function
 */
static int
next_transition(const DistSegm *seg, const DistRefPoly *rp,
  const DistRefVert *target, uint32_t cf, double t, double ftol,
  double *tnext, uint32_t *cfnext)
{
  uint32_t n2 = (uint32_t) rp->nvert * 2, i = cf / 2;
  uint32_t n = (uint32_t) rp->nvert;
  double lo = t + DISTWALK_TADV;
  DistFun f;
  double best = 1.0;
  uint32_t bestcf = cf;
  bool found = false;

  if (lo >= 1.0)
  {
    *tnext = 1.0; *cfnext = cf;
    return DISTWALK_OK;
  }

  for (int side = 0; side < 2; side++)
  {
    double level, root;
    uint32_t to;
    /* Side zero is bounded from above and is left by rising, side one is
     * bounded from below and is left by falling.  The two cases agree, which
     * is why one expression serves both. */
    double outward = side ? -1.0 : 1.0;
    if (cf % 2 == 0)
    {
      /* Equation (11): leave the vertex onto the edge after it, where its
       * parameter reaches zero, or onto the edge before it, where that one's
       * reaches one */
      uint32_t e = side ? (i + n - 1) % n : i;
      distwalk_transition(seg, &rp->edges[e], target, &f);
      level = side ? rp->edges[e].len * rp->edges[e].len : 0.0;
      to = side ? (cf + n2 - 1) % n2 : (cf + 1) % n2;
    }
    else
    {
      /* Equation (12): leave the edge by its end vertex where its parameter
       * reaches one, or by its start vertex where it reaches zero */
      distwalk_transition(seg, &rp->edges[i], target, &f);
      level = side ? 0.0 : rp->edges[i].len * rp->edges[i].len;
      to = side ? (cf + n2 - 1) % n2 : (cf + 1) % n2;
    }
    int rc = distfun_first_root(&f, level, lo, 1.0, ftol, outward, &root);
    if (rc < 0)
    {
      /* An identically zero function means the target sits on the boundary of
       * the region for the whole segment, which is not a transition */
      if (rc != DISTFUN_ZERO)
        return DISTWALK_SOLVE;
      continue;
    }
    if (rc == 1 && root < best)
    {
      best = root; bestcf = to; found = true;
    }
  }
  *tnext = best;
  *cfnext = found ? bestcf : cf;
  return DISTWALK_OK;
}

/**
 * @brief Append the distance of the feature @p cf at @p t
 */
static bool
event_add(DistEvent *ev, int maxev, int *nev, double t, double dist)
{
  if (*nev >= maxev)
    return false;
  ev[*nev].t = t;
  ev[*nev].dist = dist;
  (*nev)++;
  return true;
}

/**
 * @brief Walk the closest feature of a polygon to a point over one temporal
 * segment, and return the piecewise linear distance it realizes
 * @details Section 4.2 of the paper.  Between two transitions the feature pair
 * is fixed, so the distance is one explicit member of the function family and
 * its extrema are the roots of an exact derivative.  For an edge the roots of
 * the function ITSELF are also emitted: those are the instants at which the
 * distance is zero, where the absolute value kinks, so they are turning points
 * of the result as much as any extremum is.
 *
 * The emitted instants are the start of every feature interval, every extremum
 * and contact inside one, and the end of the segment.  That is exactly the set
 * a piecewise linear approximation needs in order to keep every extremum of
 * the true distance, and hence for its minimum to be the nearest approach
 * distance.
 *
 * @param[in] seg Motion of the polygon and of the point over the segment
 * @param[in] rp Reference polygon, whose motion is @p seg->ma
 * @param[in] target Body vertex of the point, whose motion is @p seg->mb; the
 * origin for a point, since a point has no extent
 * @param[in] ftol Magnitude below which a function counts as zero, set by the
 * caller from the length scale of the geometry
 * @param[in,out] cf Closest feature: the estimate at t = 0 on entry, the
 * feature at t = 1 on exit, ready to seed the next segment
 * @param[out] ev,nev Distance points, in increasing order of ratio
 * @param[in] maxev Size of @p ev
 * @return #DISTWALK_OK, or one of the negative results
 */
int
distwalk_poly_point(const DistSegm *seg, const DistRefPoly *rp,
  const DistRefVert *target, double ftol, uint32_t *cf, DistEvent *ev,
  int maxev, int *nev)
{
  assert(seg); assert(rp); assert(target); assert(cf); assert(ev); assert(nev);
  assert(rp->nvert >= 3);

  *nev = 0;
  double t = 0.0;
  uint32_t cur = *cf % ((uint32_t) rp->nvert * 2);
  DistFun f, df;
  double roots[DISTFUN_MAXROOTS];

  for (int step = 0; ; step++)
  {
    if (step > DISTWALK_MAXSTEP)
      return DISTWALK_CYCLE;

    /* The invariant is re-established rather than assumed: see
     * settle_feature() for why the transition times alone do not suffice */
    int st = settle_feature(seg, rp, target, t, &cur);
    if (st != DISTWALK_OK)
      return st;

    double tnext;
    uint32_t cfnext;
    int rc = next_transition(seg, rp, target, cur, t, ftol, &tnext, &cfnext);
    if (rc != DISTWALK_OK)
      return rc;

    feature_distfun(seg, rp, target, cur, &f);
    if (! event_add(ev, maxev, nev, t, feature_dist(rp, cur, &f, t)))
      return DISTWALK_FULL;

    /* Interior extrema of this feature's distance, as roots of its exact
     * derivative rather than as sign changes of sampled values */
    if (tnext - t > DISTWALK_TADV)
    {
      distfun_deriv(&f, &df);
      int n = distfun_roots(&df, 0.0, t, tnext, ftol, roots,
        DISTFUN_MAXROOTS);
      for (int i = 0; i < n; i++)
        if (roots[i] > t + DISTWALK_TADV && roots[i] < tnext - DISTWALK_TADV &&
            ! event_add(ev, maxev, nev, roots[i],
              feature_dist(rp, cur, &f, roots[i])))
          return DISTWALK_FULL;
      /* For an edge the zeros of the function are contact instants, where the
       * distance kinks at zero */
      if (cur % 2 == 1)
      {
        n = distfun_roots(&f, 0.0, t, tnext, ftol, roots, DISTFUN_MAXROOTS);
        for (int i = 0; i < n; i++)
          if (roots[i] > t + DISTWALK_TADV &&
              roots[i] < tnext - DISTWALK_TADV &&
              ! event_add(ev, maxev, nev, roots[i], 0.0))
            return DISTWALK_FULL;
      }
    }

    if (cfnext == cur)
    {
      /* No further transition was found, so this feature is claimed to hold to
       * the end of the segment.  Verify it: a degenerate crossing whose
       * transitions all fall inside the resolution of the root isolator can
       * leave the walk stranded on a stale feature, and a stale feature is
       * silently wrong for the whole remainder of the segment.  Better to say
       * so than to answer with it. */
      if (1.0 - t > DISTWALK_TADV)
      {
        /* Probe strictly INSIDE the interval being claimed.  At its end the
         * target may sit on a region boundary, and there the rule that
         * resolves a boundary looks at where the target is heading -- which
         * past t = 1 is outside the segment and says nothing about it. */
        uint32_t endcf = cur;
        int est = settle_feature(seg, rp, target, 0.5 * (t + 1.0), &endcf);
        if (est == DISTWALK_OK && endcf != cur)
          return DISTWALK_CYCLE;
      }
      if (! event_add(ev, maxev, nev, 1.0, feature_dist(rp, cur, &f, 1.0)))
        return DISTWALK_FULL;
      /* Extrema and contacts are found by two separate solves, so they come
       * out interleaved in time; one insertion pass is enough because the
       * sequence is already sorted apart from those */
      for (int i = 1; i < *nev; i++)
      {
        DistEvent tmp = ev[i];
        int j = i - 1;
        while (j >= 0 && ev[j].t > tmp.t)
        {
          ev[j + 1] = ev[j];
          j--;
        }
        ev[j + 1] = tmp;
      }
      /* A transition landing on an extremum, or two solves agreeing on one
       * instant, would otherwise leave the same instant twice */
      int w = 0;
      for (int i = 1; i < *nev; i++)
      {
        if (ev[i].t - ev[w].t <= DISTWALK_TADV)
        {
          if (ev[i].dist < ev[w].dist)
            ev[w].dist = ev[i].dist;
        }
        else
          ev[++w] = ev[i];
      }
      *nev = w + 1;
      *cf = cur;
      return DISTWALK_OK;
    }
    t = tnext;
    cur = cfnext;
  }
}

/*****************************************************************************
 * Reference polygon
 *****************************************************************************/

/** A vertex closer than this fraction of the ring's extent to the one before
 * it is the same vertex; an edge between them would have no direction */
#define DISTREF_DUPTOL     1e-12

/** A turn whose sine is below this is no turn; such a vertex lies on the
 * straight edge through its neighbours and its Voronoi wedge has no width.
 * A sine is dimensionless, so this needs no length scale */
#define DISTREF_COLTOL     1e-12

/**
 * @brief Reduce a ring to its canonical form and return the vertex count
 * @details Removes repeated vertices, removes vertices that lie on the
 * straight edge through their neighbours, and orients the result
 * counterclockwise.
 *
 * None of this changes the distance the ring realizes.  A repeated vertex adds
 * an edge with no length and no direction, and a collinear vertex splits one
 * straight edge into two while adding a Voronoi wedge of no width; both are
 * positions the walk would otherwise have to be taught to occupy and leave
 * without time passing.  Removing the cases is worth more than handling them:
 * it deletes a field, a branch in the side test, and a class of degeneracy.
 *
 * The reference geometry the temporal value stores is untouched.  Only this
 * working copy is cleaned.
 * @return The canonical vertex count, or zero if fewer than three remain
 */
static int
refring_canonicalize(double *px, double *py, int n)
{
  if (n < 3)
    return 0;
  double xmin = px[0], xmax = px[0], ymin = py[0], ymax = py[0];
  for (int i = 1; i < n; i++)
  {
    if (px[i] < xmin) xmin = px[i];
    if (px[i] > xmax) xmax = px[i];
    if (py[i] < ymin) ymin = py[i];
    if (py[i] > ymax) ymax = py[i];
  }
  double dtol = DISTREF_DUPTOL * hypot(xmax - xmin, ymax - ymin);

  /* Repeated vertices, including across the closing wrap */
  int m = 0;
  for (int i = 0; i < n; i++)
  {
    if (m > 0 && hypot(px[i] - px[m - 1], py[i] - py[m - 1]) <= dtol)
      continue;
    px[m] = px[i]; py[m] = py[i]; m++;
  }
  while (m > 1 && hypot(px[m - 1] - px[0], py[m - 1] - py[0]) <= dtol)
    m--;

  /* Collinear vertices.  One pass can leave a neighbour collinear that was
   * not before, so passes repeat until the ring stops shrinking */
  for (int pass = 0; pass < n && m >= 3; pass++)
  {
    int w = 0;
    for (int i = 0; i < m; i++)
    {
      int p = (i + m - 1) % m, q = (i + 1) % m;
      double ux = px[i] - px[p], uy = py[i] - py[p];
      double vx = px[q] - px[i], vy = py[q] - py[i];
      double lu = hypot(ux, uy), lv = hypot(vx, vy);
      if (lu > 0.0 && lv > 0.0 &&
          fabs(ux * vy - uy * vx) <= DISTREF_COLTOL * lu * lv)
        continue;
      px[w] = px[i]; py[w] = py[i]; w++;
    }
    if (w == m)
      break;
    m = w;
  }
  if (m < 3)
    return 0;

  /* Counterclockwise */
  double area2 = 0.0;
  for (int i = 0; i < m; i++)
  {
    int j = (i + 1) % m;
    area2 += px[i] * py[j] - px[j] * py[i];
  }
  if (area2 < 0.0)
    for (int i = 0, j = m - 1; i < j; i++, j--)
    {
      double tx = px[i], ty = py[i];
      px[i] = px[j]; py[i] = py[j];
      px[j] = tx;    py[j] = ty;
    }
  else if (area2 == 0.0)
    return 0;

  /* Convex.  Section 4.4 of the paper decomposes a non-convex body into
   * convex parts; until that exists such a body must be refused rather than
   * answered wrongly */
  for (int i = 0; i < m; i++)
  {
    int j = (i + 1) % m, l = (i + 2) % m;
    if ((px[j] - px[i]) * (py[l] - py[j]) -
        (py[j] - py[i]) * (px[l] - px[j]) <= 0.0)
      return 0;
  }
  return m;
}

/**
 * @brief Set the motion constants of every feature of a reference polygon
 * @details None of this depends on the pose, so it belongs to the reference
 * geometry and not to a call: a body is rigid, so its edge lengths, edge
 * directions and vertex radii are the same at every instant it ever occupies.
 * The ring is canonicalized on the way in; see #refring_canonicalize().
 * @return False if the ring is not a usable convex polygon
 */
bool
distrefpoly_set(DistRefPoly *rp, const LWPOLY *poly)
{
  assert(rp);
  rp->nvert = 0;
  rp->verts = NULL;
  rp->edges = NULL;
  if (! poly || poly->nrings < 1 || poly->rings[0]->npoints < 4)
    return false;
  int nraw = (int) poly->rings[0]->npoints - 1;
  double *px = palloc(sizeof(double) * nraw);
  double *py = palloc(sizeof(double) * nraw);
  for (int i = 0; i < nraw; i++)
  {
    POINT4D p;
    getPoint4d_p(poly->rings[0], (uint32_t) i, &p);
    px[i] = p.x; py[i] = p.y;
  }
  int n = refring_canonicalize(px, py, nraw);
  if (n == 0)
  {
    pfree(px); pfree(py);
    return false;
  }
  rp->nvert = n;
  rp->verts = palloc(sizeof(DistRefVert) * n);
  rp->edges = palloc(sizeof(DistRefEdge) * n);
  for (int i = 0; i < n; i++)
    distrefvert_set(&rp->verts[i], px[i], py[i]);
  for (int i = 0; i < n; i++)
  {
    int j = (i + 1) % n;
    distrefedge_set(&rp->edges[i], px[i], py[i], px[j], py[j]);
  }
  pfree(px); pfree(py);
  return true;
}

/**
 * @brief Free the feature arrays of a reference polygon
 */
void
distrefpoly_free(DistRefPoly *rp)
{
  assert(rp);
  if (rp->verts)
    pfree(rp->verts);
  if (rp->edges)
    pfree(rp->edges);
  rp->verts = NULL;
  rp->edges = NULL;
  rp->nvert = 0;
}

/*****************************************************************************/
