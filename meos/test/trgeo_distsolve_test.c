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
 * @brief Standalone test for the certified root isolator of
 * meos/src/rgeo/trgeo_distsolve.c
 *
 * The solver is free of PostgreSQL, PostGIS and MEOS headers, so this test
 * compiles the translation unit directly and links nothing but libm.  The
 * translation being fuzzed is therefore the one that ships.
 *
 * @code
 * gcc -O2 -Wall -I../include -o trgeo_distsolve_test \
 *     trgeo_distsolve_test.c ../src/rgeo/trgeo_distsolve.c -lm
 * ./trgeo_distsolve_test [trials]
 * @endcode
 *
 * What it establishes, in order:
 *
 *   1. distfun_add() folds a phase, a negative frequency and a zero frequency
 *      correctly, by comparing against the unfolded expression.
 *   2. distfun_deriv() agrees with a central difference.
 *   3. distfun_absmax() really is an upper bound.
 *   4. distfun_roots() misses no root: every sign change a dense scan finds
 *      is matched by a returned root, and every returned root is one.
 *   5. The closed-form paths agree with the general path.
 *
 * Test 4 is the one that matters.  A bracketing scheme that samples values and
 * infers a slope passes every geometric test in the suite and fails this.
 */

/* C */
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
/* MEOS */
#include "rgeo/trgeo_distsolve.h"

#define SCAN 200003     /* dense scan points; prime, to avoid resonating with
                         * the solver's own uniform cell boundaries */

static uint64_t rng_state = 88172645463325252ULL;

/** @brief xorshift64, so that a failing seed reproduces everywhere */
static double
rnd(double lo, double hi)
{
  rng_state ^= rng_state << 13;
  rng_state ^= rng_state >> 7;
  rng_state ^= rng_state << 17;
  return lo + (hi - lo) * ((double) (rng_state >> 11) / 9007199254740992.0);
}

/**
 * @brief A random member of the family, and the unfolded terms that built it
 */
typedef struct
{
  double w[DISTFUN_MAXTERMS], g[DISTFUN_MAXTERMS];
  double A1[DISTFUN_MAXTERMS], A0[DISTFUN_MAXTERMS];
  double B1[DISTFUN_MAXTERMS], B0[DISTFUN_MAXTERMS];
  int n;
  double c2, c1, c0;
} Recipe;

static void
recipe_random(Recipe *r, int nterm, double wmax)
{
  r->n = nterm;
  for (int i = 0; i < nterm; i++)
  {
    r->w[i] = rnd(-wmax, wmax);
    r->g[i] = rnd(-M_PI, M_PI);
    r->A1[i] = rnd(-5, 5); r->A0[i] = rnd(-5, 5);
    r->B1[i] = rnd(-5, 5); r->B0[i] = rnd(-5, 5);
  }
  r->c2 = rnd(-3, 3); r->c1 = rnd(-3, 3); r->c0 = rnd(-3, 3);
}

static void
recipe_build(const Recipe *r, DistFun *f)
{
  distfun_init(f);
  for (int i = 0; i < r->n; i++)
    distfun_add(f, r->w[i], r->g[i], r->A1[i], r->A0[i], r->B1[i], r->B0[i]);
  distfun_add_poly(f, r->c2, r->c1, r->c0);
}

/** @brief Evaluate the recipe directly, without any folding */
static double
recipe_eval(const Recipe *r, double t)
{
  double v = (r->c2 * t + r->c1) * t + r->c0;
  for (int i = 0; i < r->n; i++)
  {
    double u = r->w[i] * t + r->g[i];
    v += (r->A1[i] * t + r->A0[i]) * cos(u) +
      (r->B1[i] * t + r->B0[i]) * sin(u);
  }
  return v;
}

int
main(int argc, char **argv)
{
  int trials = (argc > 1) ? atoi(argv[1]) : 20000;
  int fail = 0;

  /* 1. Phase, sign and zero-frequency folding */
  {
    double worst = 0.0;
    for (int k = 0; k < trials; k++)
    {
      Recipe r;
      recipe_random(&r, 1 + (int) rnd(0, 2.999), 4.0);
      if (k % 7 == 0)
        r.w[0] = 0.0;                          /* exercise the affine fold */
      DistFun f;
      recipe_build(&r, &f);
      for (int j = 0; j <= 20; j++)
      {
        double t = j / 20.0;
        double d = fabs(distfun_eval(&f, t) - recipe_eval(&r, t));
        if (d > worst)
          worst = d;
      }
    }
    printf("1. distfun_add folding vs unfolded expression   max err %.3e %s\n",
      worst, worst < 1e-11 ? "ok" : "FAIL");
    if (! (worst < 1e-11))
      fail++;
  }

  /* 2. Derivative against a central difference */
  {
    double worst = 0.0;
    for (int k = 0; k < trials; k++)
    {
      Recipe r;
      recipe_random(&r, 1 + (int) rnd(0, 2.999), M_PI);
      DistFun f, df;
      recipe_build(&r, &f);
      distfun_deriv(&f, &df);
      for (int j = 1; j < 20; j++)
      {
        double t = j / 20.0, h = 1e-5;
        double fd = (distfun_eval(&f, t + h) - distfun_eval(&f, t - h)) /
          (2.0 * h);
        double d = fabs(distfun_eval(&df, t) - fd);
        if (d > worst)
          worst = d;
      }
    }
    printf("2. distfun_deriv vs central difference          max err %.3e %s\n",
      worst, worst < 1e-6 ? "ok" : "FAIL");
    if (! (worst < 1e-6))
      fail++;
  }

  /* 3. distfun_absmax is an upper bound */
  {
    int violations = 0;
    double worst_ratio = 0.0;
    for (int k = 0; k < trials; k++)
    {
      Recipe r;
      recipe_random(&r, 1 + (int) rnd(0, 2.999), M_PI);
      DistFun f;
      recipe_build(&r, &f);
      double lo = rnd(0.0, 0.5), hi = lo + rnd(0.05, 0.5);
      double bound = distfun_absmax(&f, lo, hi), peak = 0.0;
      for (int j = 0; j <= 400; j++)
      {
        double v = fabs(distfun_eval(&f, lo + (hi - lo) * j / 400.0));
        if (v > peak)
          peak = v;
      }
      if (peak > bound * (1.0 + 1e-12))
        violations++;
      if (bound > 0.0 && peak / bound > worst_ratio)
        worst_ratio = peak / bound;
    }
    printf("3. distfun_absmax bound violations              %d %s "
      "(tightest peak/bound %.3f)\n", violations,
      violations == 0 ? "ok" : "FAIL", worst_ratio);
    if (violations)
      fail++;
  }

  /* 4. Root isolation: nothing is missed, nothing is invented */
  {
    long missed = 0, spurious = 0, nroots_total = 0, nzero = 0, nbudget = 0;
    int maxroots_seen = 0;
    for (int k = 0; k < trials; k++)
    {
      Recipe r;
      /* Most cases stay inside the paper's theta in [-pi,pi]; a tenth push
       * past it to check that the cell count keeps up */
      recipe_random(&r, 1 + (int) rnd(0, 2.999),
        (k % 10 == 0) ? 3.0 * M_PI : M_PI);
      DistFun f;
      recipe_build(&r, &f);
      double level = rnd(-4, 4);

      double roots[DISTFUN_MAXROOTS];
      int n = distfun_roots(&f, level, 0.0, 1.0, 1e-12, roots,
        DISTFUN_MAXROOTS);
      if (n == DISTFUN_ZERO) { nzero++; continue; }
      if (n == DISTFUN_BUDGET) { nbudget++; continue; }
      if (n < 0) { fail++; continue; }
      nroots_total += n;
      if (n > maxroots_seen)
        maxroots_seen = n;

      /* Every sign change of a dense scan must be matched by a returned
       * root */
      double tprev = 0.0, vprev = distfun_eval(&f, 0.0) - level;
      for (int j = 1; j <= SCAN; j++)
      {
        double t = (double) j / SCAN;
        double v = distfun_eval(&f, t) - level;
        if (vprev * v < 0.0)
        {
          bool found = false;
          for (int i = 0; i < n; i++)
            if (roots[i] >= tprev - 1e-7 && roots[i] <= t + 1e-7)
              found = true;
          if (! found)
          {
            if (missed < 3)
              printf("   MISSED root in [%.9f, %.9f] (trial %d, "
                "returned %d)\n", tprev, t, k, n);
            missed++;
          }
        }
        tprev = t; vprev = v;
      }
      /* Every returned root must be one */
      for (int i = 0; i < n; i++)
        if (fabs(distfun_eval(&f, roots[i]) - level) > 1e-6)
          spurious++;
    }
    printf("4. root isolation over %d fuzzed functions\n", trials);
    printf("     missed roots   %ld %s\n", missed, missed ? "FAIL" : "ok");
    printf("     spurious roots %ld %s\n", spurious, spurious ? "FAIL" : "ok");
    printf("     roots found    %ld (max %d in one call)\n", nroots_total,
      maxroots_seen);
    printf("     identically zero %ld, budget exhausted %ld\n", nzero,
      nbudget);
    if (missed || spurious || nbudget)
      fail++;
  }

  /* 5. The closed-form paths agree with the general path */
  {
    double worst = 0.0;
    int cases = 0;
    for (int k = 0; k < trials; k++)
    {
      DistFun f, gen;
      double roots_a[DISTFUN_MAXROOTS], roots_b[DISTFUN_MAXROOTS];
      int na, nb;
      if (k % 2 == 0)
      {
        /* Non-rotating: nterm == 0, answered as a quadratic.  The comparison
         * function adds a negligible term so that the general path runs. */
        distfun_init(&f);
        distfun_add_poly(&f, rnd(-3, 3), rnd(-3, 3), rnd(-3, 3));
        gen = f;
        distfun_add(&gen, 1.0, 0.0, 0.0, 1e-13, 0.0, 0.0);
      }
      else
      {
        /* Parallel-edge shape: one constant-amplitude sinusoid over a
         * constant, answered by direct enumeration */
        distfun_init(&f);
        distfun_add(&f, rnd(0.3, M_PI), rnd(-M_PI, M_PI), 0.0, rnd(-4, 4),
          0.0, rnd(-4, 4));
        distfun_add_poly(&f, 0.0, 0.0, rnd(-2, 2));
        gen = f;
        distfun_add_poly(&gen, 1e-13, 0.0, 0.0);
      }
      na = distfun_roots(&f, 0.0, 0.0, 1.0, 1e-12, roots_a, DISTFUN_MAXROOTS);
      nb = distfun_roots(&gen, 0.0, 0.0, 1.0, 1e-12, roots_b,
        DISTFUN_MAXROOTS);
      if (na < 0 || nb < 0 || na != nb)
      {
        if (cases < 3)
          printf("   closed form %d roots, general path %d (trial %d)\n",
            na, nb, k);
        cases++;
        continue;
      }
      for (int i = 0; i < na; i++)
        if (fabs(roots_a[i] - roots_b[i]) > worst)
          worst = fabs(roots_a[i] - roots_b[i]);
    }
    printf("5. closed form vs general path   count mismatches %d %s, "
      "max root diff %.3e\n", cases, cases ? "FAIL" : "ok", worst);
    if (cases || worst > 1e-7)
      fail++;
  }

  /* 6. distfun_first_root's direction filter agrees with scanning the roots */
  {
    long mismatch = 0, dirhits = 0;
    for (int k = 0; k < trials; k++)
    {
      Recipe r;
      recipe_random(&r, 1 + (int) rnd(0, 2.999), M_PI);
      DistFun f, df;
      recipe_build(&r, &f);
      distfun_deriv(&f, &df);
      double level = rnd(-4, 4), roots[DISTFUN_MAXROOTS];
      int n = distfun_roots(&f, level, 0.0, 1.0, 1e-12, roots,
        DISTFUN_MAXROOTS);
      if (n < 0)
        continue;
      for (int d = 0; d < 2; d++)
      {
        double dir = d ? -1.0 : 1.0, got;
        int rc = distfun_first_root(&f, level, 0.0, 1.0, 1e-12, dir, &got);
        double want = -1.0;
        for (int i = 0; i < n; i++)
          if (distfun_eval(&df, roots[i]) * dir > 0.0)
          { want = roots[i]; break; }
        if (want < 0.0)
        {
          if (rc != 0) mismatch++;
        }
        else
        {
          dirhits++;
          if (rc != 1 || fabs(got - want) > 1e-15) mismatch++;
        }
      }
    }
    printf("6. distfun_first_root direction filter   mismatches %ld %s "
      "(%ld directed hits)\n", mismatch, mismatch ? "FAIL" : "ok", dirhits);
    if (mismatch)
      fail++;
  }

  printf("\n%s\n", fail ? "FAILURES" : "all checks passed");
  return fail ? 1 : 0;
}
