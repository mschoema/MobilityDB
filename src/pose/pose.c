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
#include <math.h>

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

  if (!MOBDB_FLAGS_GET_Z(p->flags))
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
  MOBDB_FLAGS_SET_Z(result->flags, false);
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
  MOBDB_FLAGS_SET_Z(result->flags, true);
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

/*****************************************************************************
 * Functions for defining B-tree index
 *****************************************************************************/

/**
 * Returns true if the first pose is equal to the second one
 */
bool
pose_eq_internal(const pose *p1, const pose *p2)
{
  if (MOBDB_FLAGS_GET_Z(p1->flags) != MOBDB_FLAGS_GET_Z(p2->flags))
    return false;
  bool result = (fabs(p1->data[0] - p2->data[0]) < MOBDB_EPSILON &&
    fabs(p1->data[1] - p2->data[1]) < MOBDB_EPSILON &&
    fabs(p1->data[2] - p2->data[2]) < MOBDB_EPSILON);
  if (MOBDB_FLAGS_GET_Z(p1->flags))
    result &= (fabs(p1->data[3] - p2->data[3]) < MOBDB_EPSILON &&
    fabs(p1->data[4] - p2->data[4]) < MOBDB_EPSILON &&
    fabs(p1->data[5] - p2->data[5]) < MOBDB_EPSILON &&
    fabs(p1->data[6] - p2->data[6]) < MOBDB_EPSILON);
  return result;
}

/*****************************************************************************/

pose *
pose_interpolate(const pose *p1, const pose *p2, double ratio)
{
  pose *result;
  if (!MOBDB_FLAGS_GET_Z(p1->flags))
  {
    double x = p1->data[0] * (1 - ratio) + p2->data[0] * ratio;
    double y = p1->data[1] * (1 - ratio) + p2->data[1] * ratio;
    double theta;
    double theta_delta = p2->data[2] - p1->data[2];
    /* If fabs(theta_delta) == M_PI: Always turn counter-clockwise */
    if (fabs(theta_delta) < MOBDB_EPSILON)
        theta = p1->data[2];
    else if (theta_delta > 0 && fabs(theta_delta) <= M_PI)
        theta = p1->data[2] + theta_delta*ratio;
    else if (theta_delta > 0 && fabs(theta_delta) > M_PI)
        theta = p2->data[2] + (2*M_PI - theta_delta)*(1 - ratio);
    else if (theta_delta < 0 && fabs(theta_delta) < M_PI)
        theta = p1->data[2] + theta_delta*ratio;
    else /* (theta_delta < 0 && fabs(theta_delta) >= M_PI) */
        theta = p1->data[2] + (2*M_PI + theta_delta)*ratio;
    if (theta > M_PI)
        theta = theta - 2*M_PI;
    result = pose_make_2d(x, y, theta);
  }
  else
  {
    double x = p1->data[0] * (1 - ratio) + p2->data[0] * ratio;
    double y = p1->data[1] * (1 - ratio) + p2->data[1] * ratio;
    double z = p1->data[2] * (1 - ratio) + p2->data[2] * ratio;
    double W, X, Y, Z;
    double W1 = p1->data[0], X1 = p1->data[1];
    double Y1 = p1->data[2], Z1 = p1->data[3];
    double W2 = p2->data[0], X2 = p2->data[1];
    double Y2 = p2->data[2], Z2 = p2->data[3];
    double dot =  W1*W2 + X1*X2 + Y1*Y2 + Z1*Z2;
    if (dot < 0.0f)
    {
      W2 = -W2;
      X2 = -X2;
      Y2 = -Y2;
      Z2 = -Z2;
      dot = -dot;
    }
    const double DOT_THRESHOLD = 0.9995;
    if (dot > DOT_THRESHOLD)
    {
      W = W1 + (W2 - W1)*ratio;
      X = X1 + (X2 - X1)*ratio;
      Y = Y1 + (Y2 - Y1)*ratio;
      Z = Z1 + (Z2 - Z1)*ratio;
    }
    else
    {
      double theta_0 = acos(dot);
      double theta = theta_0*ratio;
      double sin_theta = sin(theta);
      double sin_theta_0 = sin(theta_0);
      double s1 = cos(theta) - dot * sin_theta / sin_theta_0;
      double s2 = sin_theta / sin_theta_0;
      W = W1*s1 + W2*s2;
      X = X1*s1 + X2*s2;
      Y = Y1*s1 + Y2*s2;
      Z = Z1*s1 + Z2*s2;
    }
    double norm = W*W + X*X + Y*Y + Z*Z;
    W /= norm;
    X /= norm;
    Y /= norm;
    Z /= norm;
    result = pose_make_3d(x, y, z, W, X, Y, Z);
  }
  return result;
}

/*****************************************************************************/
