/*****************************************************************************
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
 * @file tgeometry_instset.c
 * Functions for rigid temporal instant set geometries.
 */

#include "geometry/tgeometry_instset.h"

#include <assert.h>
#include <utils/builtins.h>
#include <utils/timestamp.h>

#include "general/temporaltypes.h"
#include "general/temporal_util.h"
#include "general/temporal_boxops.h"

#include "geometry/tgeometry_temporaltypes.h"
#include "geometry/tgeometry_boxops.h"
#include "geometry/tgeometry_spatialfuncs.h"

/*****************************************************************************
 * General functions
 *****************************************************************************/

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometryinstset_geom(const TInstantSet *ti)
{
  return PointerGetDatum(
    /* start of data */
    ((char *)ti) + double_pad(sizeof(TInstantSet)) + ti->bboxsize +
      (ti->count + 1) * sizeof(size_t) +
      /* offset */
      (tinstantset_offsets_ptr(ti))[ti->count]);
}

/*****************************************************************************/

/**
 * Ensure the validity of the arguments when creating a temporal value
 */
static void
tgeometry_instset_make_valid(const Datum geom, const TInstant **instants,
  int count, bool merge)
{
  /* Test the validity of the instants */
  assert(count > 0);
  ensure_valid_tinstarr(instants, count, merge, INSTANTSET);
  for (int i = 0; i < count; ++i)
    if (MOBDB_FLAGS_GET_GEOM(instants[i]->flags))
      ensure_same_geom(geom, tgeometryinst_geom(instants[i]));
  return;
}

/**
 * Creating a temporal value from its arguments
 * @pre The validity of the arguments has been tested before
 */
TInstantSet *
tgeometry_instset_make1(const Datum geom, const TInstant **instants,
  int count)
{
  /* Get the bounding box size */
  size_t bboxsize = temporal_bbox_size(instants[0]->basetypid);

  /* Compute the size of the temporal instant set */
  /* Bounding box size */
  size_t memsize = bboxsize;
  /* Size of composing instants */
  for (int i = 0; i < count; i++)
    memsize += double_pad(tgeometryinst_elem_varsize(instants[i]));
  /* Size of the struct and the offset array */
  memsize +=  double_pad(sizeof(TInstantSet)) + (count + 1) * sizeof(size_t);
  /* Size of the reference geometry */
  memsize += double_pad(VARSIZE(DatumGetPointer(geom)));
  /* Create the TInstantSet */
  TInstantSet *result = palloc0(memsize);
  SET_VARSIZE(result, memsize);
  result->count = count;
  result->basetypid = instants[0]->basetypid;
  result->subtype = INSTANTSET;
  result->bboxsize = bboxsize;
  bool continuous = MOBDB_FLAGS_GET_CONTINUOUS(instants[0]->flags);
  MOBDB_FLAGS_SET_CONTINUOUS(result->flags, continuous);
  MOBDB_FLAGS_SET_LINEAR(result->flags, continuous);
  MOBDB_FLAGS_SET_X(result->flags, true);
  MOBDB_FLAGS_SET_T(result->flags, true);
  MOBDB_FLAGS_SET_Z(result->flags, MOBDB_FLAGS_GET_Z(instants[0]->flags));
  MOBDB_FLAGS_SET_GEODETIC(result->flags, MOBDB_FLAGS_GET_GEODETIC(instants[0]->flags));
  MOBDB_FLAGS_SET_GEOM(result->flags, WITH_GEOM);
  /* Initialization of the variable-length part */
  /*
   * Compute the bounding box
   * Only external types have bounding box, internal types such
   * as double2, double3, or double4 do not have bounding box
   */
  if (bboxsize != 0)
    tgeometry_instset_make_bbox(geom, instants, count, tinstantset_bbox_ptr(result));
  /* Store the composing instants */
  size_t pdata = double_pad(sizeof(TInstantSet)) + double_pad(bboxsize) +
    (count + 1) * sizeof(size_t);
  size_t pos = 0;
  for (int i = 0; i < count; i++)
  {
    size_t inst_size = tgeometryinst_elem_varsize(instants[i]);
    memcpy(((char *)result) + pdata + pos, instants[i], inst_size);
    (tinstantset_offsets_ptr(result))[i] = pos;
    tgeometryinst_set_elem((TInstant *)(((char *)result) + pdata + pos));
    pos += double_pad(inst_size);
  }
  /* Store the reference geometry */
  void *geom_from = DatumGetPointer(geom);
  memcpy(((char *) result) + pdata + pos, geom_from, VARSIZE(geom_from));
  (tinstantset_offsets_ptr(result))[count] = pos;

  return result;
}

/**
 * Construct a temporal geometry instant set value from
 * the array of temporal instant values
 *
 * For example, the memory structure of a temporal instant set value
 * with two instants is as follows
 * @code
 *  -----------------------------------------------------------
 *  ( TInstantSet )_X | ( bbox )_X | offset_0 | offset_1 | ...
 *  -----------------------------------------------------------
 *  --------------------------------------------------------------
 *  offset_geom | ( TInstant_0 )_X | ( TInstant_1 )_X | ( geom )_X
 *  --------------------------------------------------------------
 * @endcode
 * where the `_X` are unused bytes added for double padding, `offset_0` and
 * `offset_1` are offsets for the corresponding instants and `offset_geom`
 * is the offset of the reference geometry
 *
 * @param[in] geom Reference geometry
 * @param[in] instants Array of instants
 * @param[in] count Number of elements in the array
 * @param[in] merge True when overlapping instants are allowed as required in
 * merge operations
 */
TInstantSet *
tgeometry_instset_make(const Datum geom, const TInstant **instants,
  int count, bool merge)
{
  tgeometry_instset_make_valid(geom, instants, count, merge);
  return tgeometry_instset_make1(geom, instants, count);
}

/**
 * Construct a temporal instant set value from the array of temporal
 * instant values and free the array and the instants after the creation
 *
 * @param[in] geom Reference geometry
 * @param[in] instants Array of instants
 * @param[in] count Number of elements in the array
 * @param[in] merge True when overlapping instants are allowed as required in
 * merge operations
 */
TInstantSet *
tgeometry_instset_make_free(const Datum geom, TInstant **instants,
  int count, bool merge)
{
  if (count == 0)
  {
    pfree(instants);
    return NULL;
  }
  TInstantSet *result = tgeometry_instset_make(geom, (const TInstant **) instants,
    count, merge);
  pfree_array((void **) instants, count);
  return result;
}

/*****************************************************************************/
