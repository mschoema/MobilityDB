/*****************************************************************************
 *
 * tgeo_distance.h
 *    Distance functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __TGEO_DISTANCE_H__
#define __TGEO_DISTANCE_H__

#include <postgres.h>
#include <catalog/pg_type.h>
#include <utils/builtins.h>

/*****************************************************************************/

/* Nearest approach distance functions */

extern Datum NAD_geo_tgeo(PG_FUNCTION_ARGS);
extern Datum NAD_tgeo_geo(PG_FUNCTION_ARGS);

/*****************************************************************************/

#endif
