/*****************************************************************************
 *
 * quaternion.c
 *    Quaternion library functions.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "quaternion.h"

#include <math.h>
#include <float.h>

#include "doublen.h"

/*****************************************************************************
 * Constructor functions
 *****************************************************************************/

Quaternion
quaternion_from_axis_angle(double3 axis, double theta)
{
  axis = vec3_normalize(axis);
  double sin_theta_2 = sin(theta / 2);
  double W = cos(theta / 2);
  double X = axis.a * sin_theta_2;
  double Y = axis.b * sin_theta_2;
  double Z = axis.c * sin_theta_2;
  return (Quaternion) {W, X, Y, Z};
}

/*****************************************************************************
 * Math functions
 *****************************************************************************/

double
quaternion_norm(Quaternion quat)
{
  return sqrt(quat.W*quat.W + quat.X*quat.X + quat.Y*quat.Y + quat.Z*quat.Z);
}

Quaternion
quaternion_normalize(Quaternion quat)
{
  double norm = quaternion_norm(quat);
  return (Quaternion) {
    quat.W / norm,
    quat.X / norm,
    quat.Y / norm,
    quat.Z / norm
  };
}

Quaternion
quaternion_negate(Quaternion quat)
{
  return (Quaternion) {-quat.W, -quat.X, -quat.Y, -quat.Z};
}

static Quaternion
quaternion_multiply_scalar(Quaternion quat, double s)
{
  return (Quaternion) {quat.W * s, quat.X *s, quat.Y * s, quat.Z * s};
}

static double
quaternion_dot(Quaternion q1, Quaternion q2)
{
  return q1.W*q2.W + q1.X*q2.X + q1.Y*q2.Y + q1.Z*q2.Z;
}

bool
quaternion_eq(Quaternion q1, Quaternion q2)
{
  return (q1.W == q2.W && q1.X == q2.X && q1.Y == q2.Y && q1.Z == q2.Z);
}

static Quaternion
quaternion_add(Quaternion q1, Quaternion q2)
{
  return (Quaternion) {q1.W + q2.W, q1.X + q2.X, q1.Y +q2.Y, q1.Z + q2.Z};
}

static Quaternion
quaternion_diff(Quaternion q1, Quaternion q2)
{
  return (Quaternion) {q1.W - q2.W, q1.X - q2.X, q1.Y - q2.Y, q1.Z - q2.Z};
}

Quaternion
quaternion_multiply(Quaternion q1, Quaternion q2)
{
  double W = q1.W * q2.W - q1.X * q2.X - q1.Y * q2.Y - q1.Z * q2.Z;
  double X = q1.W * q2.X + q1.X * q2.W + q1.Y * q2.Z - q1.Z * q2.Y;
  double Y = q1.W * q2.Y - q1.X * q2.Z + q1.Y * q2.W + q1.Z * q2.X;
  double Z = q1.W * q2.Z + q1.X * q2.Y - q1.Y * q2.X + q1.Z * q2.W;
  return (Quaternion) {W, X, Y, Z};
}

Quaternion
quaternion_slerp(Quaternion q1, Quaternion q2, double ratio)
{
  q1 = quaternion_normalize(q1);
  q2 = quaternion_normalize(q2);

  double dot = quaternion_dot(q1, q2);

  if (dot < 0.0f)
  {
    q2 = quaternion_negate(q2);
    dot = -dot;
  }

  const double DOT_THRESHOLD = 0.9995;
  if (dot > DOT_THRESHOLD)
  {
    Quaternion result = quaternion_add(q1,
      quaternion_multiply_scalar(quaternion_diff(q2, q1), ratio));
    return quaternion_normalize(result);
  }

  double theta_0 = acos(dot);
  double theta = theta_0*ratio;
  double sin_theta = sin(theta);
  double sin_theta_0 = sin(theta_0);

  double s1 = cos(theta) - dot * sin_theta / sin_theta_0;
  double s2 = sin_theta / sin_theta_0;

  Quaternion result = quaternion_add(
    quaternion_multiply_scalar(q1, s1),
    quaternion_multiply_scalar(q2, s2)
  );
  return quaternion_normalize(result);
}

/*****************************************************************************/
