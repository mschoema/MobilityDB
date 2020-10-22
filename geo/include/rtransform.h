/*****************************************************************************
 *
 * rtransform.h
 *    Functions for 2D and 3D Rigidbody Transformations.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __RTRANSFORM_H__
#define __RTRANSFORM_H__

#include <postgres.h>
#include <catalog/pg_type.h>

#include "temporal.h"
#include "quaternion.h"

/*****************************************************************************
 * Struct definitions
 *****************************************************************************/

/* Affine transformation (only rotation and translation) */

typedef struct
{
  double      theta;         /* rotation in radians (limit to -pi,pi ?) */
  double2     translation;   /* translation */
} RTransform2D;

typedef struct
{
  Quaternion  quat;         /* rotation quaternion (unit length) */
  double3     translation;   /* translation */
} RTransform3D;

/*****************************************************************************
 * fmgr macros
 *****************************************************************************/

/* RTransform2D */
#define DatumGetRTransform2D(X)       ((RTransform2D *) DatumGetPointer(X))
#define RTransform2DGetDatum(X)       PointerGetDatum(X)
#define PG_GETARG_RTRANSFORM2D(i)     ((RTransform2D *) PG_GETARG_POINTER(i))

/* RTransform3D */
#define DatumGetRTransform3D(X)       ((RTransform3D *) DatumGetPointer(X))
#define RTransform3DGetDatum(X)       PointerGetDatum(X)
#define PG_GETARG_RTRANSFORM3D(i)     ((RTransform3D *) PG_GETARG_POINTER(i))

/*****************************************************************************
 * In/Output
 *****************************************************************************/

extern Datum rtransform_in_2d(PG_FUNCTION_ARGS);
extern Datum rtransform_out_2d(PG_FUNCTION_ARGS);

extern Datum rtransform_in_3d(PG_FUNCTION_ARGS);
extern Datum rtransform_out_3d(PG_FUNCTION_ARGS);

/*****************************************************************************
 * Constructor functions
 *****************************************************************************/

extern RTransform2D *rtransform_make_2d(double theta, double2 translation);
extern RTransform3D *rtransform_make_3d(Quaternion quat, double3 translation);

/*****************************************************************************
 * Transformation functions
 *****************************************************************************/

extern Datum rtransform_compute_datum(const Datum geom1, const Datum geom2, Oid valuetypid);
extern Datum rtransform_apply_datum(const Datum rt, const Datum geom, Oid valuetypid);
extern Datum rtransform_combine_datum(const Datum rt1, const Datum rt2, Oid valuetypid);

/*****************************************************************************/

#endif /* __RTRANSFORM_H__ */
