/*****************************************************************************
 *
 * tgeo_parser.h
 *    Functions for parsing temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __TGEO_PARSER_H__
#define __TGEO_PARSER_H__

#include "temporal.h"
#include "tgeo.h"
#include "rtransform.h"

/*****************************************************************************/

extern RTransform2D *rtransform2d_parse(char **str);
extern RTransform3D *rtransform3d_parse(char **str);

extern Temporal *tgeo_parse(char **str, Oid basetype);

/*****************************************************************************/

#endif