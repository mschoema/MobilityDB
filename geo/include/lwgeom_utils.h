/*****************************************************************************
 *
 * lwgeom_utils.h
 *    LWGEOM functions that are not handled by postgis yet.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __LWGEOM_UTILS_H__
#define __LWGEOM_UTILS_H__

#include <postgres.h>
#include <liblwgeom.h>
#include <catalog/pg_type.h>

/*****************************************************************************/

/* Affine Transformations */

extern void lwgeom_rotate_2d(LWGEOM *geom,
  double a, double b,
  double c, double d);
extern void lwgeom_rotate_3d(LWGEOM *geom,
  double a, double b, double c,
  double d, double e, double f,
  double g, double h, double i);
extern void lwgeom_translate_2d(LWGEOM *geom,
  double x, double y);
extern void lwgeom_translate_3d(LWGEOM *geom,
  double x, double y, double z);

/* Centroid Functions */

extern LWPOINT *lwpoly_centroid(const LWPOLY *poly);
extern LWPOINT *lwpsurface_centroid(const LWPSURFACE *psurface);

/* Distance Functions */

extern double lwpoly_max_vertex_distance(const LWPOLY *poly, const LWPOINT *point);
extern double lwpsurface_max_vertex_distance(const LWPSURFACE *psurface, const LWPOINT *point);

/* Rigidity Testing */

extern bool lwgeom_rigid(const LWGEOM *geom1, const LWGEOM *geom2);

/*****************************************************************************/

#endif /* __LWGEOM_UTILS_H__ */
