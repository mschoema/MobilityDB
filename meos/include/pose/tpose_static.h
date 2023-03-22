/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 * Copyright (c) 2016-2023, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2023, PostGIS contributors
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
 * @brief Basic functions for static pose objects.
 */

#ifndef __POSE_STATIC_H__
#define __POSE_STATIC_H__

#include <postgres.h>
#include <catalog/pg_type.h>
#include "liblwgeom.h"
#include "meos.h"

/*****************************************************************************
 * Struct definitions
 *****************************************************************************/

/**
 * Structure to represent a pose values
 *
 * flags (8 bits, x = unused): xxxZxxxx
 * data: 2D: [x, y, theta]
 *       3D: [x, y, z, W, X, Z, Y]
 *
 */
typedef struct
{
  int32         vl_len_;       /**< varlena header (do not touch directly!) */
  int8          flags;         /**< flags */
  uint8_t       srid[3];       /**< srid */
  double        data[];        /**< position and orientation values */
} Pose;

/*****************************************************************************
 * fmgr macros
 *****************************************************************************/

#define DatumGetPose(X)       ((Pose *) DatumGetPointer(X))
#define PoseGetDatum(X)       PointerGetDatum(X)
#define PG_GETARG_POSE(i)     ((Pose *) PG_GETARG_POINTER(i))

/*****************************************************************************
 * tpose_static.c
 *****************************************************************************/

extern Pose *pose_in(const char *str, bool end);
extern char *pose_out(const Pose *pose, int maxdd);

extern Pose *pose_make_2d(double x, double y, double theta);
extern Pose *pose_make_3d(double x, double y, double z,
  double W, double X, double Y, double Z);

extern int32 pose_get_srid(const Pose *pose);
extern void pose_set_srid(Pose *pose, int32 srid);

extern void pose_set_stbox(const Pose *pose, STBox *box);

extern GSERIALIZED *pose_geom(const Pose *pose, int srid);
extern Datum datum_pose_geom(Datum pose, Datum srid);

extern Datum pose_distance(Datum pose1, Datum pose2);

extern bool pose_eq(const Pose *pose1, const Pose *pose2);

extern Pose *pose_interpolate(const Pose *pose1, const Pose *pose2, double ratio);

/*****************************************************************************/

#endif /* __POSE_STATIC_H__ */
