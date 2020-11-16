/*****************************************************************************
 *
 * tgeo.h
 *    Functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __TGEO_H__
#define __TGEO_H__

#include <postgres.h>
#include <catalog/pg_type.h>
#include <liblwgeom.h>

#include "temporal.h"

/*****************************************************************************
 * tgeo.c
 *****************************************************************************/

/* Input/output functions */

extern Datum tgeo_in(PG_FUNCTION_ARGS);

/* Constructor functions */

extern Datum tgeoinst_constructor(PG_FUNCTION_ARGS);

/* Rotation at timestamp functions */

extern Datum tgeo_angle_at_timestamp(PG_FUNCTION_ARGS);
extern Datum tgeo_quaternion_at_timestamp(PG_FUNCTION_ARGS);
extern Datum tgeo_rot_matrix_2d_at_timestamp(PG_FUNCTION_ARGS);
extern Datum tgeo_rot_matrix_3d_at_timestamp(PG_FUNCTION_ARGS);

/*****************************************************************************/

#endif
