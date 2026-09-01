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
 * @brief The function family solved by the rigid-geometry distance algorithm,
 * and a certified root isolator for it
 *
 * This file is deliberately free of PostgreSQL, PostGIS and MEOS headers.  It
 * uses only <math.h>, <assert.h>, <stdbool.h> and <stddef.h>, performs no
 * allocation, and reports every condition through a return value.  That is
 * what lets the root isolator be fuzzed against dense sampling without a
 * database:
 *
 * @code
 * gcc -O2 -Wall -o trgeo_distsolve_test meos/test/trgeo_distsolve_test.c \
 *     meos/src/rgeo/trgeo_distsolve.c -lm
 * @endcode
 *
 * Do not add palloc, Assert or meos_error here: the latter two longjmp inside
 * MEOS, which would give this file different control flow in the two builds
 * and stop the fuzzed translation from matching the shipped one.
 *
 * The derivation of the family is in meos/src/rgeo/trgeo_distance.txt.
 */

#include "rgeo/trgeo_distsolve.h"

/* C */
#include <assert.h>
#include <math.h>
#include <stddef.h>

/** Frequencies this close are the same frequency and their terms merge */
#define DISTFUN_WTOL       1e-12

/** Cells held by the subdivision stack.  The initial uniform split is at most
 * 64 cells and a bisection chain adds one entry per level, of which there are
 * about fifty before a cell reaches the resolution below */
#define DISTFUN_STACKMAX   160

/** Cells the subdivision may process before giving up */
#define DISTFUN_CELLMAX    4000

/*****************************************************************************
 * Static helpers
 *****************************************************************************/

/**
 * @brief Return the largest amplitude of one frequency term over [lo,hi]
 * @details The term is (a1*t + a0)*cos(w*t) + (b1*t + b0)*sin(w*t), which is
 * R(t)*cos(w*t - phi(t)) with R = hypot of the two affine coefficients, so the
 * amplitude is what bounds it.  R is the distance from the origin to a point
 * travelling along a straight line, hence convex, hence largest at an endpoint
 * of the interval.  Bounding the two coefficients separately and adding them,
 * as an earlier form did, gives away up to a factor of sqrt(2).
 */
static double
term_absmax(const DistFunTerm *k, double lo, double hi)
{
  double vlo = hypot(k->a1 * lo + k->a0, k->b1 * lo + k->b0);
  double vhi = hypot(k->a1 * hi + k->a0, k->b1 * hi + k->b0);
  return (vlo > vhi) ? vlo : vhi;
}

/**
 * @brief Return the largest |c2*t^2 + c1*t + c0| over [lo,hi]
 * @details The extremes of a quadratic on an interval are its endpoints and,
 * when it lies inside, its vertex
 */
static double
quad_absmax(double c2, double c1, double c0, double lo, double hi)
{
  double best = fabs(c2 * lo * lo + c1 * lo + c0);
  double v = fabs(c2 * hi * hi + c1 * hi + c0);
  if (v > best)
    best = v;
  if (c2 != 0.0)
  {
    double tv = -c1 / (2.0 * c2);
    if (tv > lo && tv < hi)
    {
      v = fabs(c2 * tv * tv + c1 * tv + c0);
      if (v > best)
        best = v;
    }
  }
  return best;
}

/**
 * @brief Insert @p t into the sorted root array, skipping a value already
 * present within @p xacc
 * @return False if the array is full
 */
static bool
root_insert(double *roots, int *nroots, int maxroots, double t, double xacc)
{
  int i;
  for (i = 0; i < *nroots; i++)
  {
    if (fabs(roots[i] - t) <= xacc)
      return true;
    if (roots[i] > t)
      break;
  }
  if (*nroots >= maxroots)
    return false;
  for (int j = *nroots; j > i; j--)
    roots[j] = roots[j - 1];
  roots[i] = t;
  (*nroots)++;
  return true;
}

/**
 * @brief Append the roots of c2*t^2 + c1*t + c0 that lie in [lo,hi]
 * @details Uses the cancellation-free form of the quadratic formula: the root
 * of larger magnitude is computed from the discriminant and the other from
 * their product, so a small leading coefficient degrades to the linear answer
 * rather than to a subtraction of two nearly equal numbers.
 */
static bool
quad_roots(double c2, double c1, double c0, double lo, double hi,
  double *roots, int *nroots, int maxroots, double xacc)
{
  if (c2 == 0.0)
  {
    if (c1 == 0.0)
      return true;
    double t = -c0 / c1;
    if (t >= lo && t <= hi)
      return root_insert(roots, nroots, maxroots, t, xacc);
    return true;
  }
  double disc = c1 * c1 - 4.0 * c2 * c0;
  if (disc < 0.0)
    return true;
  double sd = sqrt(disc);
  double q = -0.5 * (c1 + ((c1 >= 0.0) ? sd : -sd));
  double t1 = q / c2;
  if (t1 >= lo && t1 <= hi && ! root_insert(roots, nroots, maxroots, t1, xacc))
    return false;
  if (q != 0.0)
  {
    double t2 = c0 / q;
    if (t2 >= lo && t2 <= hi &&
        ! root_insert(roots, nroots, maxroots, t2, xacc))
      return false;
  }
  return true;
}

/**
 * @brief Append the roots of A*cos(w*t) + B*sin(w*t) + C over [lo,hi]
 * @details Writing A*cos(u) + B*sin(u) as R*cos(u - phi) with R = hypot(A,B)
 * and phi = atan2(B,A) turns the equation into cos(w*t - phi) = -C/R, whose
 * solutions are enumerated directly.  This is the shape of the parallel-edge
 * test of Equations (18) and (19), which therefore never subdivides.
 * @return -1 when the enumeration would be unreasonably long, so that the
 * caller falls through to the general path; 0 on a full root array; 1 on
 * success
 */
static int
sinusoid_roots(double w, double A, double B, double C, double lo, double hi,
  double *roots, int *nroots, int maxroots, double xacc)
{
  double R = hypot(A, B);
  if (R == 0.0)
    return -1;
  double ratio = -C / R;
  if (ratio > 1.0 || ratio < -1.0)
    return 1;                      /* the level is out of reach: no root */
  double phi = atan2(B, A);
  double u0 = acos(ratio);
  double twopi = 2.0 * M_PI;
  double klo = floor((w * lo - phi - M_PI) / twopi) - 1.0;
  double khi = ceil((w * hi - phi + M_PI) / twopi) + 1.0;
  if (! (khi - klo <= 64.0))
    return -1;
  for (double k = klo; k <= khi; k += 1.0)
  {
    for (int s = 0; s < 2; s++)
    {
      double u = phi + (s ? u0 : -u0) + k * twopi;
      double t = u / w;
      if (t >= lo && t <= hi &&
          ! root_insert(roots, nroots, maxroots, t, xacc))
        return 0;
    }
  }
  return 1;
}

/**
 * @brief Refine the root of @p f bracketed by [x1,x2] where @p f changes sign
 * @details Newton's method with a bisection fallback: a Newton step that would
 * leave the bracket, or that is not halving the interval fast enough, is
 * replaced by a bisection step.  This keeps the quadratic convergence of
 * Newton where the function is well behaved without ever losing the bracket,
 * which matters because a stationary point may sit arbitrarily close to the
 * root.
 */
static double
root_refine(const DistFun *f, const DistFun *df, double x1, double x2,
  double f1, double xacc)
{
  double xl, xh;
  if (f1 < 0.0)
  {
    xl = x1; xh = x2;
  }
  else
  {
    xl = x2; xh = x1;
  }
  double rts = 0.5 * (x1 + x2);
  double dxold = fabs(x2 - x1), dx = dxold;
  double fv = distfun_eval(f, rts), dv = distfun_eval(df, rts);
  for (int j = 0; j < 100; j++)
  {
    if ((((rts - xh) * dv - fv) * ((rts - xl) * dv - fv) > 0.0) ||
        (fabs(2.0 * fv) > fabs(dxold * dv)))
    {
      /* Newton would leave the bracket or is converging too slowly */
      dxold = dx;
      dx = 0.5 * (xh - xl);
      rts = xl + dx;
      if (xl == rts)
        return rts;
    }
    else
    {
      dxold = dx;
      dx = fv / dv;
      double prev = rts;
      rts -= dx;
      if (prev == rts)
        return rts;
    }
    if (fabs(dx) < xacc)
      return rts;
    fv = distfun_eval(f, rts);
    dv = distfun_eval(df, rts);
    if (fv < 0.0)
      xl = rts;
    else
      xh = rts;
  }
  return rts;
}

/*****************************************************************************
 * Construction
 *****************************************************************************/

/**
 * @brief Initialize @p f to the zero function
 */
void
distfun_init(DistFun *f)
{
  assert(f);
  f->nterm = 0;
  f->c2 = f->c1 = f->c0 = 0.0;
}

/**
 * @brief Add (A1*t + A0)*cos(w*t + g) + (B1*t + B0)*sin(w*t + g) to @p f
 * @details The phase @p g is folded into the coefficients, a negative
 * frequency is folded into their signs, a zero frequency is folded into the
 * polynomial part, and a frequency already present is merged into its term.
 * This is the single place the phase algebra is written, so an error in it
 * fails everywhere at once rather than in one caller.
 * @return False if the term would exceed #DISTFUN_MAXTERMS
 */
bool
distfun_add(DistFun *f, double w, double g, double A1, double A0, double B1,
  double B0)
{
  assert(f);
  double cg = cos(g), sg = sin(g);
  /* cos(w*t + g) = cos(g)*cos(w*t) - sin(g)*sin(w*t) and
   * sin(w*t + g) = cos(g)*sin(w*t) + sin(g)*cos(w*t) */
  double a1 = A1 * cg + B1 * sg;
  double a0 = A0 * cg + B0 * sg;
  double b1 = B1 * cg - A1 * sg;
  double b0 = B0 * cg - A0 * sg;
  /* cos is even and sin is odd, so a negative frequency is the same term at
   * its absolute value with the sin coefficients negated */
  if (w < 0.0)
  {
    w = -w;
    b1 = -b1;
    b0 = -b0;
  }
  /* A zero frequency leaves cos at one and sin at zero: the term is affine */
  if (w <= DISTFUN_WTOL)
  {
    f->c1 += a1;
    f->c0 += a0;
    return true;
  }
  for (int i = 0; i < f->nterm; i++)
  {
    if (fabs(f->term[i].w - w) <= DISTFUN_WTOL * (1.0 + w))
    {
      f->term[i].a1 += a1;
      f->term[i].a0 += a0;
      f->term[i].b1 += b1;
      f->term[i].b0 += b0;
      return true;
    }
  }
  if (f->nterm >= DISTFUN_MAXTERMS)
    return false;
  f->term[f->nterm].w = w;
  f->term[f->nterm].a1 = a1;
  f->term[f->nterm].a0 = a0;
  f->term[f->nterm].b1 = b1;
  f->term[f->nterm].b0 = b0;
  f->nterm++;
  return true;
}

/**
 * @brief Add c2*t^2 + c1*t + c0 to @p f
 */
void
distfun_add_poly(DistFun *f, double c2, double c1, double c0)
{
  assert(f);
  f->c2 += c2;
  f->c1 += c1;
  f->c0 += c0;
}

/*****************************************************************************
 * Queries
 *****************************************************************************/

/**
 * @brief Return the value of @p f at @p t
 */
double
distfun_eval(const DistFun *f, double t)
{
  assert(f);
  double res = (f->c2 * t + f->c1) * t + f->c0;
  for (int i = 0; i < f->nterm; i++)
  {
    const DistFunTerm *k = &f->term[i];
    double u = k->w * t;
    res += (k->a1 * t + k->a0) * cos(u) + (k->b1 * t + k->b0) * sin(u);
  }
  return res;
}

/**
 * @brief Store the derivative of @p f in @p df
 * @details The family is closed under differentiation and the frequency set is
 * unchanged, so this is arithmetic on the coefficients.  @p df may alias @p f.
 */
void
distfun_deriv(const DistFun *f, DistFun *df)
{
  assert(f); assert(df);
  for (int i = 0; i < f->nterm; i++)
  {
    const DistFunTerm *k = &f->term[i];
    double w = k->w;
    double a1 = w * k->b1;
    double a0 = k->a1 + w * k->b0;
    double b1 = -w * k->a1;
    double b0 = k->b1 - w * k->a0;
    df->term[i].w = w;
    df->term[i].a1 = a1;
    df->term[i].a0 = a0;
    df->term[i].b1 = b1;
    df->term[i].b0 = b0;
  }
  df->nterm = f->nterm;
  double c1 = 2.0 * f->c2, c0 = f->c1;
  df->c2 = 0.0;
  df->c1 = c1;
  df->c0 = c0;
}

/**
 * @brief Return an upper bound on |f| over [lo,hi]
 * @details Bounds each sinusoid by one and each coefficient by its extreme on
 * the interval.  The bound is conservative, which is the direction the no-root
 * certificate of #distfun_roots() needs: a bound that is too large only costs
 * a subdivision, while one that is too small would discard a cell holding a
 * root.
 */
double
distfun_absmax(const DistFun *f, double lo, double hi)
{
  assert(f);
  double res = quad_absmax(f->c2, f->c1, f->c0, lo, hi);
  for (int i = 0; i < f->nterm; i++)
  {
    res += term_absmax(&f->term[i], lo, hi);
  }
  return res;
}

/**
 * @brief Return true if @p f is identically zero to within @p ftol
 * @details Tests the coefficients rather than sampled values, so that the
 * answer does not depend on where a caller happened to look.  Over the unit
 * parameter interval a coefficient bounds the value it contributes.
 */
bool
distfun_is_zero(const DistFun *f, double ftol)
{
  assert(f);
  if (fabs(f->c2) > ftol || fabs(f->c1) > ftol || fabs(f->c0) > ftol)
    return false;
  for (int i = 0; i < f->nterm; i++)
  {
    const DistFunTerm *k = &f->term[i];
    if (fabs(k->a1) > ftol || fabs(k->a0) > ftol || fabs(k->b1) > ftol ||
        fabs(k->b0) > ftol)
      return false;
  }
  return true;
}

/*****************************************************************************
 * Root isolation
 *****************************************************************************/

/**
 * @brief Isolate every solution of f(t) = @p level on [@p lo, @p hi]
 * @details The interval is split into cells whose count follows from the
 * coefficients: the phase of the family advances by at most (hi-lo)*SUM|w|
 * plus pi, the latter because the affine coefficients trace a straight line
 * and a straight line subtends less than a half turn.  Each cell is then
 * resolved either by refining a sign change or by the certificate
 *
 *   |f(midpoint)| > (width/2) * max|f'| over the cell   =>   no root here
 *
 * which is a proof rather than an inference: every point of the cell is within
 * half its width of the midpoint, so no excursion can reach zero.  A cell that
 * fails both tests is bisected.  Completeness is therefore a consequence of
 * the coefficients and not an assumption about sampling density.
 *
 * Two shapes are answered in closed form and never subdivide, and callers may
 * rely on it: no terms at all, which is the non-rotating case and a quadratic,
 * and a single constant-coefficient term over a constant polynomial, which is
 * the parallel-edge test.
 *
 * @param[in] f Function
 * @param[in] level Value to solve for
 * @param[in] lo,hi Interval, @p lo < @p hi
 * @param[in] ftol Magnitude below which |f| counts as zero.  The caller sets
 * it from the length scale of its geometry; there is deliberately no global
 * default, because the right value for a two-metre robot is wrong for a
 * three-hundred-metre vessel
 * @param[out] roots Solutions, in increasing order
 * @param[in] maxroots Size of @p roots
 * @return Number of roots written, or one of #DISTFUN_ZERO, #DISTFUN_BUDGET,
 * #DISTFUN_OVERFLOW and #DISTFUN_NONFINITE
 */
int
distfun_roots(const DistFun *f, double level, double lo, double hi,
  double ftol, double *roots, int maxroots)
{
  assert(f); assert(roots); assert(maxroots > 0); assert(lo < hi);

  /* The level moves into the constant term, so that s(t) = 0 and s(t) = 1 are
   * one function asked twice rather than two functions built twice */
  DistFun g = *f;
  g.c0 -= level;

  if (! isfinite(g.c2) || ! isfinite(g.c1) || ! isfinite(g.c0))
    return DISTFUN_NONFINITE;
  double wsum = 0.0;
  for (int i = 0; i < g.nterm; i++)
  {
    const DistFunTerm *k = &g.term[i];
    if (! isfinite(k->w) || ! isfinite(k->a1) || ! isfinite(k->a0) ||
        ! isfinite(k->b1) || ! isfinite(k->b0))
      return DISTFUN_NONFINITE;
    wsum += k->w;
  }
  if (distfun_is_zero(&g, ftol))
    return DISTFUN_ZERO;

  double xacc = (hi - lo) * 1e-14;
  if (xacc < 1e-16)
    xacc = 1e-16;
  int nroots = 0;

  /* Closed form: nothing rotates, so the function is a quadratic */
  if (g.nterm == 0)
  {
    if (! quad_roots(g.c2, g.c1, g.c0, lo, hi, roots, &nroots, maxroots, xacc))
      return DISTFUN_OVERFLOW;
    return nroots;
  }

  /* Closed form: one constant-amplitude sinusoid over a constant, which is the
   * parallel-edge test of Equations (18) and (19) */
  if (g.nterm == 1 && g.term[0].a1 == 0.0 && g.term[0].b1 == 0.0 &&
      g.c2 == 0.0 && g.c1 == 0.0)
  {
    int rc = sinusoid_roots(g.term[0].w, g.term[0].a0, g.term[0].b0, g.c0, lo,
      hi, roots, &nroots, maxroots, xacc);
    if (rc == 0)
      return DISTFUN_OVERFLOW;
    if (rc == 1)
      return nroots;
    /* rc < 0: fall through to the general path */
    nroots = 0;
  }

  DistFun dg, d2g;
  distfun_deriv(&g, &dg);
  distfun_deriv(&dg, &d2g);

  /* Cells no wider than a quarter turn of the total phase */
  double phase = (hi - lo) * wsum + M_PI;
  int ncell = (int) ceil(phase / (M_PI / 4.0));
  if (ncell < 4)
    ncell = 4;
  if (ncell > 64)
    ncell = 64;

  double stack[DISTFUN_STACKMAX][2];
  int nstack = 0;
  double step = (hi - lo) / ncell;
  for (int i = ncell - 1; i >= 0; i--)
  {
    stack[nstack][0] = lo + step * i;
    stack[nstack][1] = (i == ncell - 1) ? hi : lo + step * (i + 1);
    nstack++;
  }

  int ncells = 0;
  while (nstack > 0)
  {
    if (++ncells > DISTFUN_CELLMAX)
      return DISTFUN_BUDGET;
    nstack--;
    double a = stack[nstack][0], b = stack[nstack][1];
    double va = distfun_eval(&g, a), vb = distfun_eval(&g, b);

    /* A root sitting on a cell boundary is recorded directly; the neighbouring
     * cell will offer it again and root_insert() will drop the duplicate */
    if (fabs(va) <= ftol &&
        ! root_insert(roots, &nroots, maxroots, a, xacc))
      return DISTFUN_OVERFLOW;
    if (fabs(vb) <= ftol &&
        ! root_insert(roots, &nroots, maxroots, b, xacc))
      return DISTFUN_OVERFLOW;

    if (va * vb < 0.0)
    {
      double t = root_refine(&g, &dg, a, b, va, xacc);
      if (! root_insert(roots, &nroots, maxroots, t, xacc))
        return DISTFUN_OVERFLOW;
      continue;
    }

    if (b - a <= xacc)
      continue;

    double m = 0.5 * (a + b);
    double half = 0.5 * (b - a);

    /* Certificate one: no excursion from the midpoint can reach zero, because
     * every point of the cell is within half its width of the midpoint */
    if (fabs(distfun_eval(&g, m)) > half * distfun_absmax(&dg, a, b))
      continue;

    /* Certificate two: the same argument one derivative down proves that f'
     * does not vanish in the cell, so f is monotone there; it does not change
     * sign across the cell either, so it has no root inside.  This is what
     * terminates the chain of cells beside a simple root, where f is small --
     * so certificate one cannot fire -- but f' is not.  Without it those cells
     * bisect to the resolution limit and exhaust the budget. */
    if (fabs(distfun_eval(&dg, m)) > half * distfun_absmax(&d2g, a, b))
      continue;

    if (nstack + 2 > DISTFUN_STACKMAX)
      return DISTFUN_BUDGET;
    stack[nstack][0] = m; stack[nstack][1] = b; nstack++;
    stack[nstack][0] = a; stack[nstack][1] = m; nstack++;
  }
  return nroots;
}

/**
 * @brief Return the earliest solution of f(t) = @p level on [@p lo, @p hi]
 * that crosses the level in the direction @p dir
 * @details The workhorse of the feature walk, which asks this of up to four
 * equations per step and keeps the smallest answer.
 *
 * @p dir is why this takes a direction rather than simply returning the first
 * root.  A caller that walks from one crossing to the next arrives AT a
 * crossing, and this function counts anything within @p ftol of the level as a
 * root, so a search starting there reports that same crossing again -- one
 * unit in the last place later and still inside its own accuracy.  Starting
 * the search a little further along only asks how far is far enough, which
 * depends on the slope and so is not a constant.  The sign of the derivative,
 * which this family gives exactly, separates the two with no tolerance: a
 * crossing that rises is not one that falls, however close together they lie.
 *
 * @param[in] dir Positive to accept only rising crossings, negative only
 * falling, zero to accept any.  A root where the function merely touches the
 * level has no direction and is accepted only by zero
 * @return 1 and set @p root, 0 when there is none, or one of the negative
 * results of #distfun_roots()
 */
int
distfun_first_root(const DistFun *f, double level, double lo, double hi,
  double ftol, double dir, double *root)
{
  assert(root);
  double buf[DISTFUN_MAXROOTS];
  int n = distfun_roots(f, level, lo, hi, ftol, buf, DISTFUN_MAXROOTS);
  if (n <= 0)
    return n;
  if (dir == 0.0)
  {
    *root = buf[0];
    return 1;
  }
  DistFun df;
  distfun_deriv(f, &df);
  for (int i = 0; i < n; i++)
    if (distfun_eval(&df, buf[i]) * dir > 0.0)
    {
      *root = buf[i];
      return 1;
    }
  return 0;
}

/*****************************************************************************/
