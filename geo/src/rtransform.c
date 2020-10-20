/*****************************************************************************
 *
 * rtransform.c
 *    Functions for 2D and 3D Rigidbody Transformations.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/


#include "rtransform.h"

#include <libpq/pqformat.h>
#include <executor/spi.h>
#include <liblwgeom.h>
#include <math.h>
#include <float.h>

#include "temporaltypes.h"
#include "oidcache.h"
#include "quaternion.h"
#include "tgeo_parser.h"

/*****************************************************************************
 * Input/Output functions for RTransform2D and RTransform3D
 *****************************************************************************/

/*
 * Input function.
 * Example of input:
 *      (1.1, 1.2, 3.5)
 *      (theta, dx, dy)
 */
PG_FUNCTION_INFO_V1(rtransform_in_2d);

PGDLLEXPORT Datum
rtransform_in_2d(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    RTransform2D *result = rtransform2d_parse(&str);
    if (result == NULL)
        PG_RETURN_NULL();
    PG_RETURN_POINTER(result);
}

/* Output function */

PG_FUNCTION_INFO_V1(rtransform_out_2d);

PGDLLEXPORT Datum
rtransform_out_2d(PG_FUNCTION_ARGS)
{
    RTransform2D *rt = PG_GETARG_RTRANSFORM2D(0);
    char *result = psprintf("RTransform2D(%.*g, %.*g, %.*g)",
            DBL_DIG, rt->theta,
            DBL_DIG, rt->translation.a,
            DBL_DIG, rt->translation.b);
    PG_RETURN_CSTRING(result);
}

/*
 * Input function.
 * Example of input:
 *      (1, 0, 0, 0, 1.2, 3.5, -2.4)
 *      (W, X, Y, Z, dx, dy, dz)
 */
PG_FUNCTION_INFO_V1(rtransform_in_3d);

PGDLLEXPORT Datum
rtransform_in_3d(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    RTransform3D *result = rtransform3d_parse(&str);
    if (result == NULL)
        PG_RETURN_NULL();
    PG_RETURN_POINTER(result);
}

/* Output function */

PG_FUNCTION_INFO_V1(rtransform_out_3d);

PGDLLEXPORT Datum
rtransform_out_3d(PG_FUNCTION_ARGS)
{
    RTransform3D *rt = PG_GETARG_RTRANSFORM3D(0);
    char *result = psprintf("RTransform3D(%.*g, %.*g, %.*g, %.*g, %.*g, %.*g, %.*g)",
            DBL_DIG, rt->quat.W,
            DBL_DIG, rt->quat.X,
            DBL_DIG, rt->quat.Y,
            DBL_DIG, rt->quat.Z,
            DBL_DIG, rt->translation.a,
            DBL_DIG, rt->translation.b,
            DBL_DIG, rt->translation.c);
    PG_RETURN_CSTRING(result);
}

/*****************************************************************************
 * Constructor functions
 *****************************************************************************/

RTransform2D *
rtransform_make_2d(double theta, double2 translation)
{
    if (theta < -M_PI || theta > M_PI)
        ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Rotation theta must be in ]-pi, pi]. Recieved: %f", theta)));

    /* If we want a unique representation for theta */
    if (theta == -M_PI)
        theta = M_PI;

    RTransform2D *result = (RTransform2D *)palloc(sizeof(RTransform2D));
    result->theta = theta;
    result->translation = translation;
    return result;
}

RTransform3D *
rtransform_make_3d(Quaternion quat, double3 translation)
{
    if (fabs(quaternion_norm(quat) - 1)  > EPSILON)
        ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Rotation quaternion must be of unit norm. Recieved: %f", quaternion_norm(quat))));

    /* If we want a unique representation for the quaternion */
    if (quat.W < 0.0)
        quat = quaternion_negate(quat);

    RTransform3D *result = (RTransform3D *)palloc(sizeof(RTransform3D));
    result->quat = quat;
    result->translation = translation;
    return result;
}

/*****************************************************************************/
