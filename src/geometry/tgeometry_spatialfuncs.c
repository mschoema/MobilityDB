/***********************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 *
 * Copyright (c) 2016-2021, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2021, PostGIS contributors
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without a written
 * agreement is hereby granted, provided that the above copyright notice and
 * this paragraph and the following two paragraphs appear in all copies.
 *
 * IN NO EVENT SHALL UNIVERSITE LIBRE DE BRUXELLES BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
 * LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF UNIVERSITE LIBRE DE BRUXELLES HAS BEEN ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * UNIVERSITE LIBRE DE BRUXELLES SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON
 * AN "AS IS" BASIS, AND UNIVERSITE LIBRE DE BRUXELLES HAS NO OBLIGATIONS TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 
 *
 *****************************************************************************/

/**
 * @file tgeometry_spatialfuncs.c
 * Spatial functions for rigid temporal geometries.
 */

#include "geometry/tgeometry_spatialfuncs.h"

#include <liblwgeom.h>

#include "general/temporal.h"

#include "point/tpoint_spatialfuncs.h"

#include "geometry/tgeometry_inst.h"

/*****************************************************************************/

static void
ensure_same_rings_lwpoly(const LWPOLY *poly1, const LWPOLY *poly2)
{
  if (poly1->nrings != poly2->nrings)
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Operation on different reference geometries")));
  for (int i = 0; i < (int) poly1->nrings; ++i)
  {
    if (poly1->rings[i]->npoints != poly2->rings[i]->npoints)
      ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Operation on different reference geometries")));
  }
}

static void
ensure_same_geoms_lwpsurface(const LWPSURFACE *psurface1, const LWPSURFACE *psurface2)
{
  if (psurface1->ngeoms != psurface2->ngeoms)
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Operation on different reference geometries")));
  for (int i = 0; i < (int) psurface1->ngeoms; ++i)
    ensure_same_rings_lwpoly(psurface1->geoms[i], psurface2->geoms[i]);
}

static bool
same_lwgeom(const LWGEOM *geom1, const LWGEOM *geom2)
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
    if (FLAGS_GET_Z(geom1->flags))
    {
      result = fabs(p1.x - p2.x) < MOBDB_EPSILON
        && fabs(p1.y - p2.y) < MOBDB_EPSILON
        && fabs(p1.z - p2.z) < MOBDB_EPSILON;
    }
    else
    {
      result = fabs(p1.x - p2.x) < MOBDB_EPSILON
        && fabs(p1.y - p2.y) < MOBDB_EPSILON;
    }
  }
  lwpointiterator_destroy(it1);
  lwpointiterator_destroy(it2);
  return result;
}

/**
 * Ensure that the rigid temporal geometry instants have the same reference geometry
 */
void
ensure_same_geom(Datum geom_datum1, Datum geom_datum2)
{
  if (geom_datum1 == geom_datum2)
    return;

  GSERIALIZED *gs1 = (GSERIALIZED *) DatumGetPointer(geom_datum1);
  GSERIALIZED *gs2 = (GSERIALIZED *) DatumGetPointer(geom_datum2);

  if (gserialized_get_type(gs1) != gserialized_get_type(gs2))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Operation on different reference geometries")));

  LWGEOM *geom1 = lwgeom_from_gserialized(gs1);
  LWGEOM *geom2 = lwgeom_from_gserialized(gs2);

  if (gserialized_get_type(gs1) == POLYGONTYPE)
    ensure_same_rings_lwpoly((LWPOLY *) geom1, (LWPOLY *) geom2);
  else
    ensure_same_geoms_lwpsurface((LWPSURFACE *) geom1, (LWPSURFACE *) geom2);

  /* TODO: uncomment */
  /*if (!same_lwgeom(geom1, geom2))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Operation on different reference geometries")));*/

  lwgeom_free(geom1);
  lwgeom_free(geom2);
  return;
}

/*****************************************************************************/

/**
 * Returns the SRID of a rigid temporal instant geometry
 */
int
tgeometryinst_srid(const TInstant *inst)
{
  GSERIALIZED *gs = (GSERIALIZED *) DatumGetPointer(tgeometryinst_geom_ptr(inst));
  return gserialized_get_srid(gs);
}

/**
 * Returns the SRID of a rigid temporal geometry (dispatch function)
 */
int
tgeometry_srid_internal(const Temporal *temp)
{
  int result;
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT)
    result = tgeometryinst_srid((TInstant *) temp);
  else if (temp->subtype == INSTANTSET)
    result = tpointinstset_srid((TInstantSet *) temp);
  else if (temp->subtype == SEQUENCE)
    result = tpointseq_srid((TSequence *) temp);
  else /* temp->subtype == SEQUENCESET */
    result = tpointseqset_srid((TSequenceSet *) temp);
  return result;
}

PG_FUNCTION_INFO_V1(tgeometry_srid);
/**
 * Returns the SRID of a rigid temporal geometry
 */
PGDLLEXPORT Datum
tgeometry_srid(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  int result = tgeometry_srid_internal(temp);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_INT32(result);
}

/*****************************************************************************/
