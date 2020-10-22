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

#include "lwgeom_utils.h"

#include <math.h>
#include <float.h>

#include "temporal.h"

/*****************************************************************************
 * Affine Transformations
 *****************************************************************************/

static void
lwgeom_affine_transform(LWGEOM *geom,
  double a, double b, double c,
  double d, double e, double f,
  double g, double h, double i,
  double xoff, double yoff, double zoff)
{
  AFFINE affine;
  affine.afac =  a;
  affine.bfac =  b;
  affine.cfac =  c;
  affine.dfac =  d;
  affine.efac =  e;
  affine.ffac =  f;
  affine.gfac =  g;
  affine.hfac =  h;
  affine.ifac =  i;
  affine.xoff =  xoff;
  affine.yoff =  yoff;
  affine.zoff =  zoff;
  lwgeom_affine(geom, &affine);
  return;
}

void
lwgeom_rotate_2d(LWGEOM *geom,
  double a, double b,
  double c, double d)
{
  lwgeom_affine_transform(geom,
    a, b, 0,
    c, d, 0,
    0, 0, 1,
    0, 0, 0);
  return;
}

void
lwgeom_rotate_3d(LWGEOM *geom,
  double a, double b, double c,
  double d, double e, double f,
  double g, double h, double i)
{
  lwgeom_affine_transform(geom,
    a, b, c,
    d, e, f,
    g, h, i,
    0, 0, 0);
  return;
}

void
lwgeom_translate_2d(LWGEOM *geom,
  double x, double y)
{
  lwgeom_affine_transform(geom,
    1, 0, 0,
    0, 1, 0,
    0, 0, 1,
    x, y, 0);
  return;
}

void
lwgeom_translate_3d(LWGEOM *geom,
  double x, double y, double z)
{
  lwgeom_affine_transform(geom,
    1, 0, 0,
    0, 1, 0,
    0, 0, 1,
    x, y, z);
  return;
}

/*****************************************************************************
 * Centroid Functions
 *****************************************************************************/

LWPOINT *
lwpoly_centroid(const LWPOLY *poly)
{
  return lwgeom_as_lwpoint(lwgeom_centroid(lwpoly_as_lwgeom(poly)));
}

/* TODO: Maybe define it better and ask for support from postgis */
LWPOINT *
lwpsurface_centroid(const LWPSURFACE *psurface)
{
  double x = 0, y = 0, z = 0;
  double tot = 0;
  for (uint32_t i = 0; i < psurface->ngeoms; ++i)
  {
    for (uint32_t j = 0; j < psurface->geoms[i]->nrings; ++j)
    {
      for (uint32_t k = 0; k < psurface->geoms[i]->rings[j]->npoints - 1; ++k)
      {
        POINT4D p = getPoint4d(psurface->geoms[i]->rings[j], k);
        x += p.x;
        y += p.y;
        z += p.z;
        ++tot;
      }
    }
  }
  return lwpoint_make3dz(psurface->srid, x / tot, y / tot, z / tot);
}

/*****************************************************************************
 * Rigidity Testing
 *****************************************************************************/

bool
lwgeom_rigid(const LWGEOM *geom1, const LWGEOM *geom2)
{
  LWPOINTITERATOR *it1 = lwpointiterator_create(geom1);
  LWPOINTITERATOR *it2 = lwpointiterator_create(geom2);
  POINT4D p1;
  POINT4D p2;

  bool result = true;
  while (lwpointiterator_next(it1, &p1)
    && lwpointiterator_next(it2, &p2)
    && result)
  {
    /* TODO: make sure this works for large point values too */
    if (FLAGS_GET_Z(geom1->flags))
    {
      result = fabs(p1.x - p2.x) < EPSILON
        && fabs(p1.y - p2.y) < EPSILON
        && fabs(p1.z - p2.z) < EPSILON;
    }
    else
    {
      result = fabs(p1.x - p2.x) < EPSILON
        && fabs(p1.y - p2.y) < EPSILON;
    }
  }
  lwpointiterator_destroy(it1);
  lwpointiterator_destroy(it2);
  return result;
}

/*****************************************************************************/
