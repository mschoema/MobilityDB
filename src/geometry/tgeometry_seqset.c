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
 * @file tgeometry_seqset.c
 * Functions for rigid temporal sequence set geometries.
 */

#include "geometry/tgeometry_seqset.h"

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
tgeometryseqset_geom(const TSequenceSet *ts)
{
  return PointerGetDatum(
    /* start of data */
    ((char *)ts) + double_pad(sizeof(TSequenceSet)) + ts->bboxsize +
      (ts->count + 1) * sizeof(size_t) +
      /* offset */
      (tsequenceset_offsets_ptr(ts))[ts->count]);
}

/*****************************************************************************/

/**
 * Construct a temporal sequence set value from the array of temporal
 * sequence values
 *
 * For example, the memory structure of a temporal sequence set value
 * with two sequences is as follows
 * @code
 * ------------------------------------------------------------
 * ( TSequenceSet )_X | ( bbox )_X | offset_0 | offset_1 | ...
 * ------------------------------------------------------------
 * ---------------------------------------
 * ( TSequence_0 )_X | ( TSequence_1 )_X |
 * ---------------------------------------
 * @endcode
 * where the `_X` are unused bytes added for double padding, `offset_0` and
 * `offset_1` are offsets for the corresponding sequences.
 * Temporal sequence set values do not have precomputed trajectory.
 *
 * @param[in] geom Reference geometry
 * @param[in] sequences Array of sequences
 * @param[in] count Number of elements in the array
 * @param[in] normalize True when the resulting value should be normalized.
 * In particular, normalize is false when synchronizing two
 * temporal sequence set values before applying an operation to them.
 */
TSequenceSet *
tgeometry_seqset_make(const Datum geom, const TSequence **sequences,
  int count, bool normalize)
{
  /* Test the validity of the sequences */
  assert(count > 0);
  ensure_valid_tseqarr(sequences, count);
  for (int i = 0; i < count; ++i)
    if (MOBDB_FLAGS_GET_GEOM(sequences[i]->flags))
      ensure_same_geom(geom, tgeometryseq_geom(sequences[i]));

  /* Normalize the array of sequences */
  TSequence **normseqs = (TSequence **) sequences;
  int newcount = count;
  if (normalize && count > 1)
    normseqs = tseqarr_normalize(sequences, count, &newcount);

  /* Get the bounding box size */
  size_t bboxsize = temporal_bbox_size(sequences[0]->basetypid);

  /* Compute the size of the temporal sequence */
  /* Bounding box size */
  size_t memsize = bboxsize;
  /* Size of composing sequences */
  int totalcount = 0;
  for (int i = 0; i < newcount; i++)
  {
    totalcount += normseqs[i]->count;
    memsize += double_pad(tgeometryseq_elem_varsize(normseqs[i]));
  }
  /* Size of the struct and the offset array */
  memsize += double_pad(sizeof(TSequenceSet)) + (newcount + 1) * sizeof(size_t);
  /* Size of the reference geometry */
  memsize += double_pad(VARSIZE(DatumGetPointer(geom)));
  /* Create the temporal sequence set */
  TSequenceSet *result = palloc0(memsize);
  SET_VARSIZE(result, memsize);
  result->count = newcount;
  result->totalcount = totalcount;
  result->basetypid = sequences[0]->basetypid;
  result->subtype = SEQUENCESET;
  result->bboxsize = bboxsize;
  MOBDB_FLAGS_SET_CONTINUOUS(result->flags,
    MOBDB_FLAGS_GET_CONTINUOUS(sequences[0]->flags));
  MOBDB_FLAGS_SET_LINEAR(result->flags,
    MOBDB_FLAGS_GET_LINEAR(sequences[0]->flags));
  MOBDB_FLAGS_SET_X(result->flags, true);
  MOBDB_FLAGS_SET_T(result->flags, true);
  MOBDB_FLAGS_SET_Z(result->flags,
    MOBDB_FLAGS_GET_Z(sequences[0]->flags));
  MOBDB_FLAGS_SET_GEODETIC(result->flags,
    MOBDB_FLAGS_GET_GEODETIC(sequences[0]->flags));
  MOBDB_FLAGS_SET_GEOM(result->flags, WITH_GEOM);
  /* Initialization of the variable-length part */
  /*
   * Compute the bounding box
   * Only external types have bounding box, internal types such
   * as double2, double3, or double4 do not have bounding box
   */
  if (bboxsize != 0)
    tsequenceset_make_bbox((const TSequence **) normseqs, newcount,
      tsequenceset_bbox_ptr(result));
  /* Store the composing instants */
  size_t pdata = double_pad(sizeof(TSequenceSet)) + double_pad(bboxsize) +
    (newcount + 1) * sizeof(size_t);
  size_t pos = 0;
  for (int i = 0; i < newcount; i++)
  {
    size_t seq_size = tgeometryseq_elem_varsize(normseqs[i]);
    memcpy(((char *) result) + pdata + pos, normseqs[i], seq_size);
    (tsequenceset_offsets_ptr(result))[i] = pos;
    tgeometryseq_set_elem((TSequence *) (((char *)result) + pdata + pos));
    pos += double_pad(seq_size);
  }
  /* Store the reference geometry */
  void *geom_from = DatumGetPointer(geom);
  memcpy(((char *) result) + pdata + pos, geom_from, VARSIZE(geom_from));
  (tsequenceset_offsets_ptr(result))[newcount] = pos;

  if (normalize && count > 1)
    pfree_array((void **) normseqs, newcount);
  return result;
}

/**
 * Construct a temporal sequence set value from the array of temporal
 * sequence values and free the array and the sequences after the creation
 *
 * @param[in] geom Reference geometry
 * @param[in] sequences Array of sequences
 * @param[in] count Number of elements in the array
 * @param[in] normalize True when the resulting value should be normalized.
 */
TSequenceSet *
tgeometry_seqset_make_free(const Datum geom, TSequence **sequences,
  int count, bool normalize)
{
  if (count == 0)
  {
    pfree(sequences);
    return NULL;
  }
  TSequenceSet *result = tgeometry_seqset_make(geom, (const TSequence **) sequences,
    count, normalize);
  pfree_array((void **) sequences, count);
  return result;
}

/*****************************************************************************/
