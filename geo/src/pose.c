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
 * @file pose.c
 * Functions for pose type.
 */

#include <postgres.h>

#include <math.h>
#include <float.h>
#include "pose.h"

/*****************************************************************************
 * Input/Output functions for Pose values
 *****************************************************************************/

PG_FUNCTION_INFO_V1(pose_in);
/**
 * Input function for pose values
 */
PGDLLEXPORT Datum
pose_in(PG_FUNCTION_ARGS)
{
  char *str = PG_GETARG_CSTRING(0);
  Pose *result = pose_parse(&str);
  PG_RETURN_POINTER(result);
}

/**
 * Returns the string representation of the pose value
 */
static char *
pose_to_string(const Pose *pose)
{
  bool is3d = POSE_FLAGS_GET_3D(box->flags);
  char *x = call_output(FLOAT8OID, Float8GetDatum(box->data[0]));
  char *y = call_output(FLOAT8OID, Float8GetDatum(box->data[1]));
  char *result;
  if (!is3d) /* 2D */
  {
    char *theta = call_output(FLOAT8OID, Float8GetDatum(box->data[2]));
    result = palloc(strlen(x) + strlen(y) +
      strlen(theta) + strlen("Pose(,,)"));
    sprintf(result, "Pose(%s,%s,%s)", x, y, theta);
    pfree(theta);
  }
  else /* 3D */
  {
    char *z = call_output(FLOAT8OID, Float8GetDatum(box->data[2]));
    char *W = call_output(FLOAT8OID, Float8GetDatum(box->data[3]));
    char *X = call_output(FLOAT8OID, Float8GetDatum(box->data[4]));
    char *Y = call_output(FLOAT8OID, Float8GetDatum(box->data[5]));
    char *Z = call_output(FLOAT8OID, Float8GetDatum(box->data[6]));
    result = palloc(strlen(geom) + strlen(x) + strlen(y) + strlen(z) +
      strlen(W) + strlen(X) + strlen(Y) + strlen(Z) + strlen("Pose(,,,,,,)"));
    sprintf(result, "Pose(%s,%s,%s,%s,%s,%s,%s)", x, y, z, W, X, Y, Z);
    pfree(z);
    pfree(W);
    pfree(X);
    pfree(Y);
    pfree(Z);
  }
  pfree(x);
  pfree(y);
  return result;
}

PG_FUNCTION_INFO_V1(pose_out);
/**
 * Output function for pose values
 */
PGDLLEXPORT Datum
pose_out(PG_FUNCTION_ARGS)
{
  Pose *pose = PG_GETARG_POSE(0);
  char *result = pose_to_string(pose);
  PG_RETURN_CSTRING(result);
}

/*****************************************************************************
 * Constructor functions
 *****************************************************************************/


/* Construct a pose from a reference geometry, positions and orientation */

PG_FUNCTION_INFO_V1(pose_constructor_2d);

PGDLLEXPORT Datum
pose_constructor_2d(PG_FUNCTION_ARGS)
{
  double x = PG_GETARG_FLOAT8(0);
  double y = PG_GETARG_FLOAT8(1);
  double theta = PG_GETARG_FLOAT8(2);
  Pose *result = pose_make_2d(x, y, theta);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(pose_constructor_3d);

PGDLLEXPORT Datum
pose_constructor_3d(PG_FUNCTION_ARGS)
{
  double x = PG_GETARG_FLOAT8(0);
  double y = PG_GETARG_FLOAT8(1);
  double z = PG_GETARG_FLOAT8(2);
  double W = PG_GETARG_FLOAT8(3);
  double X = PG_GETARG_FLOAT8(4);
  double Y = PG_GETARG_FLOAT8(5);
  double Z = PG_GETARG_FLOAT8(6);
  Pose *result = pose_make_3d(x, y, z, W, X, Y, Z);
  PG_RETURN_POINTER(result);
}

Pose *
pose_make_2d(double x, double y, double theta)
{
  if (theta < -M_PI || theta > M_PI)
    ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
      errmsg("Rotation theta must be in ]-pi, pi]. Recieved: %f", theta)));

  /* If we want a unique representation for theta */
  if (theta == -M_PI)
    theta = M_PI;

  size_t memsize = double_pad(sizeof(Pose)) + 2 * sizeof(double);
  Pose *result = palloc0(memsize);
  SET_VARSIZE(result, memsize);
  POSE_FLAGS_SET_3D(result->flags, false);
  result->data[0] = x;
  result->data[1] = y;
  result->data[2] = theta;
  return result;
}

Pose *
pose_make_3d(double x, double y, double z, double W, double X, double Y, double Z)
{
  if (fabs(sqrt(W*W + X*X + Y*Y + Z*Z) - 1)  > EPSILON)
    ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
      errmsg("Rotation quaternion must be of unit norm. Recieved: %f", sqrt(W*W + X*X + Y*Y + Z*Z))));

  /* If we want a unique representation for the quaternion */
  if (W < 0.0)
      W = -W;
      X = -X;
      Y = -Y;
      Z = -Z;

  size_t memsize = double_pad(sizeof(Pose)) + 6 * sizeof(double);
  Pose *result = palloc0(memsize);
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

/*****************************************************************************
 * Comparison functions
 *****************************************************************************/

bool
datum_pose_eq(const Datum pose1_datum, const Datum pose2_datum)
{
  Pose *pose1 = DatumGetPose(pose1_datum);
  Pose *pose2 = DatumGetPose(pose2_datum);
  if (POSE_FLAGS_GET_3D(pose1->flags))
    return FP_EQUALS(pose1->data[0], pose2->data[0]) && FP_EQUALS(pose1->data[1], pose2->data[1]) &&
      FP_EQUALS(pose1->data[2], pose2->data[2]) && FP_EQUALS(pose1->data[3], pose2->data[3]) &&
      FP_EQUALS(pose1->data[4], pose2->data[4]) && FP_EQUALS(pose1->data[5], pose2->data[5]) &&
      FP_EQUALS(pose1->data[6], pose2->data[6]);
  else
    return FP_EQUALS(pose1->data[0], pose2->data[0]) && FP_EQUALS(pose1->data[1], pose2->data[1]) &&
      FP_EQUALS(pose1->data[2], pose2->data[2]);
}

/*****************************************************************************/
