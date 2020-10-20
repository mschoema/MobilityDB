/*****************************************************************************
 *
 * quaternion.h
 *    Quaternion library functions.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __QUATERNION_H__
#define __QUATERNION_H__

#include <postgres.h>
#include <catalog/pg_type.h>

/*****************************************************************************
 * Struct definitions
 *****************************************************************************/

/* Quaternion */

typedef struct
{
  double     W;
  double     X;
  double     Y;
  double     Z;
} Quaternion;

/*****************************************************************************/

extern double quaternion_norm(Quaternion quat);

extern Quaternion quaternion_negate(Quaternion quat);

/*****************************************************************************/

#endif /* __QUATERNION_H__ */
