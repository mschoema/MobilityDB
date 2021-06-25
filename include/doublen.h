/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 *
 * Copyright (c) 2016-2021, Université libre de Bruxelles and MobilityDB
 * contributors
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
 * @file doublen.h
 * Internal types used in particular for computing the average and centroid
 * temporal aggregates.
 */

#ifndef __DOUBLEN_H__
#define __DOUBLEN_H__

#include <postgres.h>
#include <catalog/pg_type.h>

#include "temporal.h"

/*****************************************************************************/

extern Datum double2_in(PG_FUNCTION_ARGS);
extern Datum double2_out(PG_FUNCTION_ARGS);
extern Datum double2_recv(PG_FUNCTION_ARGS);
extern Datum double2_send(PG_FUNCTION_ARGS);

extern void double2_set(double2 *result, double a, double b);
extern double2 *double2_add(double2 *d1, double2 *d2);
extern bool double2_eq(double2 *d1, double2 *d2);
/* extern int double2_cmp(double2 *d1, double2 *d2); */

extern Datum double3_in(PG_FUNCTION_ARGS);
extern Datum double3_out(PG_FUNCTION_ARGS);
extern Datum double3_recv(PG_FUNCTION_ARGS);
extern Datum double3_send(PG_FUNCTION_ARGS);

extern void double3_set(double3 *result, double a, double b, double c);
extern double3 *double3_add(double3 *d1, double3 *d2);
extern bool double3_eq(double3 *d1, double3 *d2);
/* extern int double3_cmp(double3 *d1, double3 *d2); */

extern Datum double4_in(PG_FUNCTION_ARGS);
extern Datum double4_out(PG_FUNCTION_ARGS);
extern Datum double4_recv(PG_FUNCTION_ARGS);
extern Datum double4_send(PG_FUNCTION_ARGS);

extern void double4_set(double4 *result, double a, double b, double c, double d);
extern double4 *double4_add(double4 *d1, double4 *d2);
extern bool double4_eq(double4 *d1, double4 *d2);

extern Datum tdouble2_in(PG_FUNCTION_ARGS);
extern Datum tdouble3_in(PG_FUNCTION_ARGS);
extern Datum tdouble4_in(PG_FUNCTION_ARGS);

/*****************************************************************************/

/* 2D Vector Functions */

extern bool vec2_eq(double2 v1, double2 v2);

extern double vec2_norm(double2 v);
extern double vec2_dist2(double2 v1, double2 v2);
extern double vec2_dist(double2 v1, double2 v2);
extern double vec2_dot(double2 v1, double2 v2);
extern double vec2_angle(double2 p, double2 q, double2 r);

extern double2 vec2_normalize(double2 v);

/* 3D Vector Functions */

extern double vec3_norm(double3 v);
extern double vec3_dot(double3 v1, double3 v2);

extern double3 vec3_normalize(double3 v);
extern double3 vec3_mult(double3 v, double s);
extern double3 vec3_add(double3 v1, double3 v2);
extern double3 vec3_diff(double3 v1, double3 v2);
extern double3 vec3_cross(double3 v1, double3 v2);

/*****************************************************************************/

#endif
