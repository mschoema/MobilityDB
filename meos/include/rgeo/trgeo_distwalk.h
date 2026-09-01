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
 * This file turns the geometry of one temporal segment into members of the
 * function family of trgeo_distsolve.h, and walks the closest features over
 * that segment.  It knows about poses and polygons but not about time: no
 * @p TimestampTz and no @p TSequence appear in it.  Assembling those into a
 * temporal value is trgeo_distance.c.
 *
 * See meos/src/rgeo/trgeo_distance.txt for the derivation of the closed forms
 * built here, and for how the pieces fit together.
 */

#ifndef __TRGEO_DISTWALK_H__
#define __TRGEO_DISTWALK_H__

/* MEOS */
#include "pose/pose.h"
#include "rgeo/trgeo_distsolve.h"

/*****************************************************************************
 * Motion over one temporal segment
 *
 * Both operands are described the same way: a rotation centre that translates
 * linearly and an angle that turns linearly, which is Equation (5) of the
 * paper written with a nonzero starting angle,
 *
 *   v(t) = R(th0 + w*t) * a + (cx,cy) + t*(dx,dy),   t in [0,1]
 *
 * where a is a vertex in body coordinates, that is, relative to the rotation
 * centre.  A static operand is the case w = 0, (dx,dy) = 0 and a = 0, with the
 * centre placed at the static point, so one set of builders serves the moving
 * and the static target alike.
 *
 * The shortest-arc convention of #posesegm_interpolate() is read ONCE here,
 * into @p w, rather than at every evaluation.
 *****************************************************************************/

/** @brief Motion of one operand over a temporal segment */
typedef struct
{
  double cx, cy;   /**< Rotation centre at t = 0 */
  double dx, dy;   /**< Displacement of the centre over the segment */
  double th0;      /**< Rotation angle at t = 0 */
  double w;        /**< Rotation over the segment, by the shortest arc */
} DistMotion;

/**
 * @brief Both operands over one temporal segment, with the relative centre
 * offset they share
 * @details W(t) = (cB - cA) + t*(dB - dA) is affine and carries both
 * translations.  Every builder below reads it, and the fact that it traces a
 * straight line is what bounds the phase of the resulting functions, hence
 * what makes root isolation complete
 */
typedef struct
{
  DistMotion ma;             /**< The operand carrying the edge */
  DistMotion mb;             /**< The operand carrying the vertex */
  double wx1, wx0;           /**< W_x(t) = wx1*t + wx0 */
  double wy1, wy0;           /**< W_y(t) = wy1*t + wy0 */
} DistSegm;

/**
 * @brief An edge of a reference polygon in body coordinates, with the
 * quantities a rigid motion leaves unchanged
 */
typedef struct
{
  double sx, sy;   /**< Start vertex */
  double ex, ey;   /**< End vertex */
  double len;      /**< Length, constant under the motion */
  double beta;     /**< Direction angle, constant in body coordinates */
  double dots;     /**< dot(start, end - start) */
  double crss;     /**< cross(start, end - start) */
} DistRefEdge;

/** @brief A vertex of a reference polygon in body coordinates */
typedef struct
{
  double x, y;
  double rho;      /**< Distance from the rotation centre */
  double alpha;    /**< Angle about the rotation centre */
} DistRefVert;

/*****************************************************************************
 * Setting up a segment
 *****************************************************************************/

extern void distmotion_set(DistMotion *m, double x1, double y1, double th1,
  double x2, double y2, double th2);

extern void distmotion_set_static(DistMotion *m, double x, double y);

extern void distmotion_from_pose(DistMotion *m, const Pose *p1,
  const Pose *p2);

extern void distmotion_place(const DistMotion *m, double px, double py,
  double t, double *x, double *y);

extern void distsegm_set(DistSegm *seg, const DistMotion *ma,
  const DistMotion *mb);

extern void distrefedge_set(DistRefEdge *e, double sx, double sy, double ex,
  double ey);

extern void distrefvert_set(DistRefVert *v, double x, double y);

/*****************************************************************************
 * Coefficient builders
 *
 * Each fills a #DistFun whose roots answer one of the equations of the paper.
 * The frequencies are those of the segment -- wA, wB and wA - wB -- so within
 * a segment every function built here shares one frequency set, and sums and
 * differences of them are termwise.
 *****************************************************************************/

extern void distwalk_transition(const DistSegm *seg, const DistRefEdge *e,
  const DistRefVert *v, DistFun *f);

extern void distwalk_cross(const DistSegm *seg, const DistRefEdge *e,
  const DistRefVert *v, DistFun *f);

extern void distwalk_vertdist2(const DistSegm *seg, const DistRefVert *va,
  const DistRefVert *vb, DistFun *f);

extern void distwalk_parallel(const DistSegm *seg, const DistRefEdge *ea,
  const DistRefEdge *eb, DistFun *f);

/*****************************************************************************
 * The closest-feature walk
 *
 * Features of a polygon are indexed in [0, 2n): an even index 2i is the vertex
 * i and an odd index 2i+1 is the edge from vertex i to vertex i+1, so the
 * transitions of Equations (11) and (12) are a step of one, modulo 2n.  The
 * walk carries that index across temporal segments, which is what makes it
 * cost O(1) per segment rather than a rescan of the polygon.
 *****************************************************************************/

/**
 * @brief A reference polygon with the quantities a rigid motion leaves
 * unchanged, computed once and valid for every pose the body ever takes
 * @details Canonical by construction: #distrefpoly_set() drops the closing
 * repeat, removes repeated and collinear vertices, and orients the ring
 * counterclockwise.  The walk may therefore assume that every edge has a
 * direction, that every vertex turns, and that outside is the left of an
 * edge -- none of which needs testing or a flag to record.
 */
typedef struct
{
  int nvert;             /**< Vertices after canonicalization */
  DistRefVert *verts;    /**< @p nvert vertices, counterclockwise */
  DistRefEdge *edges;    /**< @p nvert edges; @p edges[i] leaves @p verts[i] */
} DistRefPoly;

/** @brief One point of the piecewise linear distance over a segment */
typedef struct
{
  double t;              /**< Ratio in [0,1] */
  double dist;           /**< Distance there */
} DistEvent;

/** @brief Results of #distwalk_poly_point() */
#define DISTWALK_OK       0   /**< The walk reached the end of the segment */
#define DISTWALK_CYCLE  (-1)  /**< The walk stopped advancing */
#define DISTWALK_FULL   (-2)  /**< The event buffer is too small */
#define DISTWALK_SOLVE  (-3)  /**< The root isolator reported a condition */
#define DISTWALK_INSIDE (-4)  /**< No feature region holds the target, so it
                                   is inside the polygon.  Section 4.2 of the
                                   paper excludes this; handling it is what
                                   the overlap regime adds */

extern bool distrefpoly_set(DistRefPoly *rp, const LWPOLY *poly);

extern void distrefpoly_free(DistRefPoly *rp);

extern int distwalk_poly_point(const DistSegm *seg, const DistRefPoly *rp,
  const DistRefVert *target, double ftol, uint32_t *cf, DistEvent *ev,
  int maxev, int *nev);

/*****************************************************************************/

#endif /* __TRGEO_DISTWALK_H__ */
