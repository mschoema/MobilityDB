/*****************************************************************************
 *
 * tgeo_spatialfuncs.c
 *    Geospatial functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __TGEO_SPATIALFUNCS_H__
#define __TGEO_SPATIALFUNCS_H__

#include <postgres.h>
#include <liblwgeom.h>
#include <catalog/pg_type.h>

#include "temporal.h"

/*****************************************************************************/

extern bool tgeo_rigid_body_instant(const TInstant *inst);
extern bool tgeo_3d_inst(const TInstant *inst);

extern void ensure_geo_type(const GSERIALIZED *gs);
extern void ensure_similar_geo(const TInstant *inst1, const TInstant *inst2);
extern void ensure_rigid_body(const Datum geom1_datum, const Datum geom2_datum);

/*****************************************************************************/

extern Datum tgeo_trajectory_centre(PG_FUNCTION_ARGS);
extern Datum tgeo_trajectory(PG_FUNCTION_ARGS);

/*****************************************************************************/

#endif
