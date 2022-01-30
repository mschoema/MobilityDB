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
 * @file tgeometry_distance.h
 * Distance functions for rigid temporal geometries.
 */

#ifndef __TGEOMETRY_DISTANCE_H__
#define __TGEOMETRY_DISTANCE_H__

#include <postgres.h>
#include <liblwgeom.h>
#include <catalog/pg_type.h>

#include "general/temporal.h"

#include "pose/pose.h"

/*****************************************************************************
 * Struct definitions
 *****************************************************************************/

/** Symbolic constants for equation solving */
#define MOBDB_SOLVE_0            true
#define MOBDB_SOLVE_1            false

/** Symbolic constants for cfp_elem */
#define MOBDB_CFP_STORE       true
#define MOBDB_CFP_STORE_NO    false

#define MOBDB_CFP_FREE        true
#define MOBDB_CFP_FREE_NO     false

/* Closest features pair */

typedef struct {
  LWGEOM *geom_1;
  LWGEOM *geom_2;
  pose *pose_1;
  pose *pose_2;
  bool free_pose_1;
  bool free_pose_2;
  uint32_t cf_1;
  uint32_t cf_2;
  TimestampTz t;
  bool store;
} cfp_elem;

/* List of CFPs */

typedef struct {
  size_t count;
  size_t size;
  cfp_elem *arr;
} cfp_array;

/* Closest features pair */

typedef struct {
  double dist;;
  TimestampTz t;
} tdist_elem;

/* List of CFPs */

typedef struct {
  size_t count;
  size_t size;
  tdist_elem *arr;
} tdist_array;


/*****************************************************************************/

/* V-clip functions */

extern Datum v_clip_tpoly_point(PG_FUNCTION_ARGS);

/* Distance functions */

extern Datum distance_geo_tgeometry(PG_FUNCTION_ARGS);
extern Datum distance_tgeometry_geo(PG_FUNCTION_ARGS);
extern Datum distance_tgeometry_tgeometry(PG_FUNCTION_ARGS);

extern Temporal *distance_tgeometry_geo_internal(const Temporal *temp, Datum geo);
extern Temporal *distance_tgeometry_tgeometry_internal(const Temporal *temp1,
  const Temporal *temp2);

/* Nearest approach distance/instance and shortest line functions */

extern Datum NAI_geo_tgeometry(PG_FUNCTION_ARGS);
extern Datum NAI_tgeometry_geo(PG_FUNCTION_ARGS);
extern Datum NAI_tgeometry_tgeometry(PG_FUNCTION_ARGS);

extern TInstant *NAI_tgeometry_geo_internal(FunctionCallInfo fcinfo,
  const Temporal *temp, GSERIALIZED *gs);

extern Datum NAD_geo_tgeometry(PG_FUNCTION_ARGS);
extern Datum NAD_tgeometry_geo(PG_FUNCTION_ARGS);
extern Datum NAD_stbox_tgeometry(PG_FUNCTION_ARGS);
extern Datum NAD_tgeometry_stbox(PG_FUNCTION_ARGS);
extern Datum NAD_tgeometry_tgeometry(PG_FUNCTION_ARGS);

extern Datum shortestline_geo_tgeometry(PG_FUNCTION_ARGS);
extern Datum shortestline_tgeometry_geo(PG_FUNCTION_ARGS);
extern Datum shortestline_tgeometry_tgeometry(PG_FUNCTION_ARGS);

extern bool shortestline_tgeometry_tgeometry_internal(const Temporal *temp1,
  const Temporal *temp2, Datum *line);

extern Datum tdwithin_geo_tgeometry(PG_FUNCTION_ARGS);
extern Datum tdwithin_tgeometry_geo(PG_FUNCTION_ARGS);
extern Datum tdwithin_tgeometry_tgeometry(PG_FUNCTION_ARGS);

extern Temporal *tdwithin_tgeometry_geo_internal(const Temporal *temp,
  GSERIALIZED *gs, Datum dist);
extern Temporal *tdwithin_tgeometry_tgeometry_internal(const Temporal *temp1,
  const Temporal *temp2, Datum dist);

/*****************************************************************************/

#endif
