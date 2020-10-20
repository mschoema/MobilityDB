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

#include "tgeo_spatialfuncs.h"

#include <assert.h>
#include <float.h>
#include <utils/builtins.h>
#include <utils/timestamp.h>

#include "temporaltypes.h"

/*****************************************************************************
 * Parameter tests
 *****************************************************************************/

void
ensure_geo_type(const GSERIALIZED *gs)
{
    if (!(gserialized_get_type(gs) == POLYGONTYPE && !FLAGS_GET_Z(gs->flags)) &&
        !(gserialized_get_type(gs) == POLYHEDRALSURFACETYPE && FLAGS_GET_Z(gs->flags)))
        ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
            errmsg("Only 2D polygons or 3D polyhedral surfaces accepted")));
}

/*****************************************************************************/
