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

/*****************************************************************************/

double
quaternion_norm(Quaternion quat)
{
  return quat.W*quat.W + quat.X*quat.X + quat.Y*quat.Y + quat.Z*quat.Z;
}

Quaternion
quaternion_negate(Quaternion quat)
{
  return (Quaternion) {-quat.W, -quat.X, -quat.Y, -quat.Z};
}

/*****************************************************************************/
