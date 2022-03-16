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
 * @file tgeometry_seq.c
 * Functions for rigid temporal sequence geometries.
 */

#include "geometry/tgeometry_seq.h"

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
tgeometryseq_geom(const TSequence *seq)
{
  if (!MOBDB_FLAGS_GET_GEOM(seq->flags))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Cannot access geometry from tgeometry sequence")));
  return PointerGetDatum(
    /* start of data */
    ((char *)seq) + double_pad(sizeof(TSequence)) + seq->bboxsize +
      (seq->count + 1) * sizeof(size_t) +
      /* offset */
      (tsequence_offsets_ptr(seq))[seq->count]);
}

/*****************************************************************************/

/**
 * Returns the size of the tgeometryseq without reference geometry
 */
size_t
tgeometryseq_elem_varsize(const TSequence *seq)
{
  void *geom = DatumGetPointer(tgeometryseq_geom(seq));
  return VARSIZE(seq) - double_pad(VARSIZE(geom));
}

/**
 * Set the size of the tgeometryseq without reference geometry
 */
void
tgeometryseq_set_elem(TSequence *seq)
{
  SET_VARSIZE(seq, tgeometryseq_elem_varsize(seq));
  MOBDB_FLAGS_SET_GEOM(seq->flags, NO_GEOM);
  return;
}

/*****************************************************************************/

/**
 * Ensure the validity of the arguments when creating a temporal value
 */
static void
tgeometry_seq_make_valid(const Datum geom, const TInstant **instants,
  int count, bool lower_inc, bool upper_inc, bool linear)
{
  tsequence_make_valid1(instants, count, lower_inc, upper_inc, linear);
  ensure_valid_tinstarr(instants, count, MERGE_NO, SEQUENCE);
  for (int i = 0; i < count; ++i)
    if (MOBDB_FLAGS_GET_GEOM(instants[i]->flags))
      ensure_same_geom(geom, tgeometryinst_geom(instants[i]));
  return;
}

/**
 * Creating a temporal value from its arguments
 * @pre The validity of the arguments has been tested before
 */
TSequence *
tgeometry_seq_make1(const Datum geom, const TInstant **instants,
  int count, bool lower_inc, bool upper_inc, bool linear, bool normalize)
{
  /* Normalize the array of instants */
  TInstant **norminsts = (TInstant **) instants;
  int newcount = count;
  if (normalize && count > 1)
    norminsts = tinstarr_normalize(instants, linear, count, &newcount);

  /* Get the bounding box size */
  size_t bboxsize = double_pad(temporal_bbox_size(instants[0]->basetypid));

  /* Compute the size of the temporal sequence */
  /* Bounding box size */
  size_t memsize = bboxsize;
  /* Size of composing instants */
  for (int i = 0; i < newcount; i++)
    memsize += double_pad(tgeometryinst_elem_varsize(norminsts[i]));
  /* Size of the struct and the offset array */
  memsize += double_pad(sizeof(TSequence)) + (newcount + 1) * sizeof(size_t);
  /* Size of the reference geometry */
  memsize += double_pad(VARSIZE(DatumGetPointer(geom)));
  /* Create the temporal sequence */
  TSequence *result = palloc0(memsize);
  SET_VARSIZE(result, memsize);
  result->count = newcount;
  result->basetypid = norminsts[0]->basetypid;
  result->subtype = SEQUENCE;
  result->bboxsize = bboxsize;
  period_set(norminsts[0]->t, norminsts[newcount - 1]->t, lower_inc, upper_inc,
    &result->period);
  MOBDB_FLAGS_SET_CONTINUOUS(result->flags,
    MOBDB_FLAGS_GET_CONTINUOUS(norminsts[0]->flags));
  MOBDB_FLAGS_SET_LINEAR(result->flags, linear);
  MOBDB_FLAGS_SET_X(result->flags, true);
  MOBDB_FLAGS_SET_T(result->flags, true);
  MOBDB_FLAGS_SET_Z(result->flags, MOBDB_FLAGS_GET_Z(norminsts[0]->flags));
  MOBDB_FLAGS_SET_GEODETIC(result->flags, MOBDB_FLAGS_GET_GEODETIC(norminsts[0]->flags));
  MOBDB_FLAGS_SET_GEOM(result->flags, WITH_GEOM);
  /* Initialization of the variable-length part */
  /*
   * Compute the bounding box
   * Only external types have bounding box, internal types such
   * as double2, double3, or double4 do not have bounding box
   */
  if (bboxsize != 0)
    tgeometry_seq_make_bbox(geom, (const TInstant **) norminsts, newcount,
      lower_inc, upper_inc, linear, tsequence_bbox_ptr(result));
  /* Store the composing instants */
  size_t pdata = double_pad(sizeof(TSequence)) + double_pad(bboxsize) +
    (newcount + 1) * sizeof(size_t);
  size_t pos = 0;
  for (int i = 0; i < newcount; i++)
  {
    size_t inst_size = tgeometryinst_elem_varsize(norminsts[i]);
    memcpy(((char *)result) + pdata + pos, norminsts[i], inst_size);
    (tsequence_offsets_ptr(result))[i] = pos;
    tgeometryinst_set_elem((TInstant *) (((char *)result) + pdata + pos));
    pos += double_pad(inst_size);
  }
  /* Store the reference geometry */
  void *geom_from = DatumGetPointer(geom);
  memcpy(((char *) result) + pdata + pos, geom_from, VARSIZE(geom_from));
  (tsequence_offsets_ptr(result))[newcount] = pos;

  if (normalize && count > 1)
    pfree(norminsts);
  return result;
}

/**
 * Construct a temporal sequence value from the array of temporal
 * instant values
 *
 * For example, the memory structure of a temporal sequence value with
 * two instants and without precomputed trajectory is as follows:
 * @code
 * ---------------------------------------------------------
 * ( TSequence )_X | ( bbox )_X | offset_0 | offset_1 | ...
 * ---------------------------------------------------------
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
 * @param[in] lower_inc,upper_inc True when the respective bound is inclusive
 * @param[in] linear True when the interpolation is linear
 * @param[in] normalize True when the resulting value should be normalized
 */
TSequence *
tgeometry_seq_make(const Datum geom, const TInstant **instants,
  int count, bool lower_inc, bool upper_inc, bool linear, bool normalize)
{
  tgeometry_seq_make_valid(geom, instants, count, lower_inc, upper_inc, linear);
  return tgeometry_seq_make1(geom, instants, count, lower_inc, upper_inc,
    linear, normalize);
}

/**
 * Construct a temporal sequence value from the array of temporal
 * instant values and free the array and the instants after the creation
 *
 * @param[in] geom Reference geometry
 * @param[in] instants Array of instants
 * @param[in] count Number of elements in the array
 * @param[in] lower_inc,upper_inc True when the respective bound is inclusive
 * @param[in] linear True when the interpolation is linear
 * @param[in] normalize True when the resulting value should be normalized
 */
TSequence *
tgeometry_seq_make_free(const Datum geom, TInstant **instants, int count,
  bool lower_inc, bool upper_inc, bool linear, bool normalize)
{
  if (count == 0)
  {
    pfree(instants);
    return NULL;
  }
  TSequence *result = tgeometry_seq_make(geom, (const TInstant **) instants,
    count, lower_inc, upper_inc, linear, normalize);
  pfree_array((void **) instants, count);
  return result;
}

/*****************************************************************************/
