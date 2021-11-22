/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 *
 * Copyright (c) 2016-2021, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2021, PostGIS contributors
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
 * @file pose.c
 * Network-based static point and segment types
 *
 * Several functions are commented out since they are not currently used.
 * They are kept if needed in the future.
 */

#include "pose/pose.h"

#include <assert.h>
#include <libpq/pqformat.h>
#include <executor/spi.h>
#include <liblwgeom.h>

#include "general/temporaltypes.h"
#include "general/tempcache.h"
#include "general/temporal_util.h"
#include "general/tnumber_mathfuncs.h"

#include "pose/pose_parser.h"

/** Buffer size for input and output of pose values */
#define MAXPOSELEN    128

/*****************************************************************************
 * Input/Output functions for pose
 *****************************************************************************/

PG_FUNCTION_INFO_V1(pose_in);
/**
 * Input function for pose values
 * Example of input:
 *    (1, 0.5)
 */
PGDLLEXPORT Datum
pose_in(PG_FUNCTION_ARGS)
{
  char *str = PG_GETARG_CSTRING(0);
  pose *result = pose_parse(&str);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(pose_out);
/**
 * Output function for pose values
 */
PGDLLEXPORT Datum
pose_out(PG_FUNCTION_ARGS)
{
  static size_t size = MAXPOSELEN + 1;
  char *result = (char *) palloc(size);
  pose *p = PG_GETARG_POSE(0);

  if (!POSE_FLAGS_GET_3D(p->flags))
  {
    char *x = call_output(FLOAT8OID, Float8GetDatum(p->data[0]));
    char *y = call_output(FLOAT8OID, Float8GetDatum(p->data[1]));
    char *theta = call_output(FLOAT8OID, Float8GetDatum(p->data[2]));
    snprintf(result, size, "POSE (%s, %s, %s)", x, y, theta);
  }
  else
  {
    char *x = call_output(FLOAT8OID, Float8GetDatum(p->data[0]));
    char *y = call_output(FLOAT8OID, Float8GetDatum(p->data[1]));
    char *z = call_output(FLOAT8OID, Float8GetDatum(p->data[2]));
    char *W = call_output(FLOAT8OID, Float8GetDatum(p->data[3]));
    char *X = call_output(FLOAT8OID, Float8GetDatum(p->data[4]));
    char *Y = call_output(FLOAT8OID, Float8GetDatum(p->data[5]));
    char *Z = call_output(FLOAT8OID, Float8GetDatum(p->data[6]));
    snprintf(result, size, "POSE Z (%s, %s, %s, %s, %s, %s, %s)",
      x, y, z, W, X, Y, Z);
  }

  PG_RETURN_CSTRING(result);
}

/*****************************************************************************
 * Constructors
 *****************************************************************************/

/**
 * Construct a 2d pose value from the arguments
 */
pose *
pose_make_2d(double x, double y, double theta)
{
  if (theta < -M_PI || theta > M_PI)
    ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
      errmsg("Rotation theta must be in ]-pi, pi]. Recieved: %f", theta)));

  /* If we want a unique representation for theta */
  if (theta == -M_PI)
    theta = M_PI;

  size_t memsize = double_pad(sizeof(pose)) + 2 * sizeof(double);
  pose *result = palloc0(memsize);
  SET_VARSIZE(result, memsize);
  POSE_FLAGS_SET_3D(result->flags, false);
  result->data[0] = x;
  result->data[1] = y;
  result->data[2] = theta;
  return result;
}

/**
 * Construct a 3d pose value from the arguments
 */
pose *
pose_make_3d(double x, double y, double z,
  double W, double X, double Y, double Z)
{
  if (fabs(sqrt(W*W + X*X + Y*Y + Z*Z) - 1)  > MOBDB_EPSILON)
    ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
      errmsg("Rotation quaternion must be of unit norm. Recieved: %f", sqrt(W*W + X*X + Y*Y + Z*Z))));

  /* If we want a unique representation for the quaternion */
  if (W < 0.0)
  {
    W = -W;
    X = -X;
    Y = -Y;
    Z = -Z;
  }

  size_t memsize = double_pad(sizeof(pose)) + 6 * sizeof(double);
  pose *result = palloc0(memsize);
  SET_VARSIZE(result, memsize);
  POSE_FLAGS_SET_3D(result->flags, true);
  result->data[0] = x;
  result->data[1] = y;
  result->data[2] = z;
  result->data[3] = W;
  result->data[4] = X;
  result->data[5] = Y;
  result->data[6] = Z;
  return result;
}

PG_FUNCTION_INFO_V1(pose_constructor);
/**
 * Construct a pose value from the arguments
 */
PGDLLEXPORT Datum
pose_constructor(PG_FUNCTION_ARGS)
{
  double x, y, z, theta;
  double W, X, Y, Z;
  pose *result;

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
