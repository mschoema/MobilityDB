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
 * @brief Basic functions for temporal pose objects.
 */


#include "pose/tpose_static.h"

/* C */
#include <assert.h>
#include <math.h>
/* MobilityDB */
#include "general/pg_types.h"
#include "general/type_out.h"
#include "general/type_util.h"
#include "pose/tpose_static.h"

/*****************************************************************************
 * Input/Output functions for pose
 *****************************************************************************/

PG_FUNCTION_INFO_V1(Pose_in);
/**
 * Input function for pose values
 * Example of input:
 *    (1, 0.5)
 */
PGDLLEXPORT Datum
Pose_in(PG_FUNCTION_ARGS)
{
  const char *str = PG_GETARG_CSTRING(0);
  PG_RETURN_POINTER(pose_in(str, true));
}

PG_FUNCTION_INFO_V1(Pose_out);
/**
 * Output function for pose values
 */
PGDLLEXPORT Datum
Pose_out(PG_FUNCTION_ARGS)
{
  Pose *pose = PG_GETARG_POSE(0);
  PG_RETURN_CSTRING(pose_out(pose, OUT_DEFAULT_DECIMAL_DIGITS));
}

/*****************************************************************************
 * Constructors
 *****************************************************************************/

PG_FUNCTION_INFO_V1(Pose_constructor);
/**
 * Construct a pose value from the arguments
 */
PGDLLEXPORT Datum
Pose_constructor(PG_FUNCTION_ARGS)
{
  double x, y, z, theta;
  double W, X, Y, Z;
  Pose *result;

  x = PG_GETARG_FLOAT8(0);
  y = PG_GETARG_FLOAT8(1);
  z = theta = PG_GETARG_FLOAT8(2);

  if (PG_NARGS() == 3)
    result = pose_make_2d(x, y, theta);
  else if (PG_NARGS() == 7)
  {
    W = PG_GETARG_FLOAT8(3);
    X = PG_GETARG_FLOAT8(4);
    Y = PG_GETARG_FLOAT8(5);
    Z = PG_GETARG_FLOAT8(6);
    result = pose_make_3d(x, y, z, W, X, Y, Z);
  }
  else
  {
    elog(ERROR, "pose_constructor: unsupported number of args: %d",
         PG_NARGS());
    PG_RETURN_NULL();
  }

  PG_RETURN_POINTER(result);
}

/*****************************************************************************/
