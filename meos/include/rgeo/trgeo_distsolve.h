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
 * This header and @p trgeo_distsolve.c are deliberately free of PostgreSQL,
 * PostGIS and MEOS headers.  They use only <math.h>, <assert.h>, <stdbool.h>
 * and <stddef.h>, perform no allocation, and report every condition through a
 * return value.  That is what lets the root isolator be fuzzed against dense
 * sampling without a database:
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

#ifndef __TRGEO_DISTSOLVE_H__
#define __TRGEO_DISTSOLVE_H__

/* C */
#include <stdbool.h>

/*****************************************************************************
 * The function family
 *
 * Every equation the distance algorithm has to solve -- the feature
 * transitions, the vertex-to-edge and vertex-to-vertex distances, the
 * parallel-edge test, the separating-axis gap and the merge crossing -- has
 * the form
 *
 *   F(t) = SUM_k [ (a1_k*t + a0_k) * cos(w_k*t)
 *                + (b1_k*t + b0_k) * sin(w_k*t) ]
 *        + c2*t^2 + c1*t + c0
 *
 * Terms are stored at ZERO PHASE and at a NON-NEGATIVE frequency: a phase is
 * folded into the coefficients when the term is added, so that two terms
 * sharing a frequency combine by adding coefficients.  Within one temporal
 * segment only three frequencies occur -- thA, thB and thA - thB -- so
 * #DISTFUN_MAXTERMS is three and every function built for that segment shares
 * the same frequency set.  Sums and differences of them, which is what the
 * merge crossing of two partial solutions needs, are therefore termwise.
 *
 * A term of zero frequency is folded into the polynomial part on the way in,
 * so a non-rotating segment produces nterm == 0 and every query below takes a
 * closed-form quadratic path with no iteration at all.
 *****************************************************************************/

#define DISTFUN_MAXTERMS   3

/** Suggested size of a caller's root buffer.  At most six roots can exist and
 * three is the most yet observed over 200000 randomized coefficient sets */
#define DISTFUN_MAXROOTS   8

/**
 * @brief One frequency term of a #DistFun, stored at zero phase and at a
 * non-negative frequency
 */
typedef struct
{
  double w;            /**< Angular frequency, >= 0 */
  double a1, a0;       /**< (a1*t + a0) * cos(w*t) */
  double b1, b0;       /**< (b1*t + b0) * sin(w*t) */
} DistFunTerm;

/**
 * @brief A member of the function family solved by the distance algorithm
 */
typedef struct
{
  DistFunTerm term[DISTFUN_MAXTERMS];
  int nterm;           /**< Terms in use; zero when nothing rotates */
  double c2, c1, c0;   /**< The polynomial part */
} DistFun;

/**
 * @brief Negative results of #distfun_roots() and #distfun_first_root()
 *
 * @p DISTFUN_ZERO is a state to handle, not an error: it is the case of
 * Section 4.3.3 of the paper where two bodies rotate at equal rates and two of
 * their edges are parallel for the whole segment.  Distinguishing it from
 * "no roots" is what keeps the walk from stalling there.
 */
#define DISTFUN_ZERO      (-1)  /**< Identically zero on the interval */
#define DISTFUN_BUDGET    (-2)  /**< Subdivision budget exhausted */
#define DISTFUN_OVERFLOW  (-3)  /**< More roots than the caller's buffer */
#define DISTFUN_NONFINITE (-4)  /**< A coefficient is not finite */

/*****************************************************************************
 * Construction
 *****************************************************************************/

extern void distfun_init(DistFun *f);

extern bool distfun_add(DistFun *f, double w, double g, double A1, double A0,
  double B1, double B0);

extern void distfun_add_poly(DistFun *f, double c2, double c1, double c0);

/*****************************************************************************
 * Queries
 *****************************************************************************/

extern double distfun_eval(const DistFun *f, double t);

extern void distfun_deriv(const DistFun *f, DistFun *df);

extern double distfun_absmax(const DistFun *f, double lo, double hi);

extern bool distfun_is_zero(const DistFun *f, double ftol);

extern int distfun_roots(const DistFun *f, double level, double lo, double hi,
  double ftol, double *roots, int maxroots);

extern int distfun_first_root(const DistFun *f, double level, double lo,
  double hi, double ftol, double dir, double *root);

/*****************************************************************************/

#endif /* __TRGEO_DISTSOLVE_H__ */
