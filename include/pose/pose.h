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
 * @file tpose_static.h
 * Network-based static point/segments
 */

#ifndef __POSE_H__
#define __POSE_H__

#include <postgres.h>
#include <catalog/pg_type.h>

#include "general/temporal.h"

/*****************************************************************************
 * Struct definitions
 *****************************************************************************/

/**
 * Structure to represent a pose values
 *
 * flags: stores dimension (False = 2D, True = 3D)
 * data: 2D: [x, y, theta]
 *       3D: [x, y, z, W, X, Z, Y]
 *
 */
typedef struct
{
  int32         vl_len_;       /**< varlena header (do not touch directly!) */
  int32         flags;         /**< flags */
  double        data[1];       /**< position and orientation values */
} pose;

/*****************************************************************************
 * fmgr macros
 *****************************************************************************/

#define DatumGetPose(X)       ((pose *) DatumGetPointer(X))
#define PoseGetDatum(X)       PointerGetDatum(X)
#define PG_GETARG_POSE(i)     ((pose *) PG_GETARG_POINTER(i))

/*****************************************************************************
 * Macros for manipulating the 'flags' element of a pose object
 *****************************************************************************/

#define POSE_FLAGS_GET_3D(flags)          ((bool) ((flags) & 0x01))

#define POSE_FLAGS_SET_3D(flags, value) \
  ((flags) = (value) ? ((flags) | 0x01) : ((flags) & 0xFE))

/*****************************************************************************
 * pose.c
 *****************************************************************************/

extern Datum pose_in(PG_FUNCTION_ARGS);
extern Datum pose_out(PG_FUNCTION_ARGS);

extern Datum pose_constructor(PG_FUNCTION_ARGS);

extern pose *pose_make_2d(double x, double y, double theta);
extern pose *pose_make_3d(double x, double y, double z,
  double W, double X, double Y, double Z);

/*****************************************************************************/

#endif /* __POSE_H__ */
