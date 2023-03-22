/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 * Copyright (c) 2016-2023, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2023, PostGIS contributors
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
 * @brief Functions for rigid temporal sequence set geometries.
 */

#include "geometry/tgeometry_seqset.h"

/* C */
#include <assert.h>
/* MEOS */
#include "meos_internal.h"
#include "general/tsequenceset.h"
#include "general/temporaltypes.h"
#include "general/type_util.h"
#include "general/temporal_boxops.h"
#include "geometry/tgeometry_temporaltypes.h"
#include "geometry/tgeometry_boxops.h"
#include "geometry/tgeometry_seq.h"
#include "geometry/tgeometry_spatialfuncs.h"
#include "geometry/tgeometry_utils.h"

/*****************************************************************************
 * General functions
 *****************************************************************************/

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometry_seqset_geom(const TSequenceSet *ss)
{
  return PointerGetDatum(
    /* start of data */
    ((char *)ss) + DOUBLE_PAD(sizeof(TSequenceSet)) +
      /* The period component of the bbox is already declared in the struct */
      (ss->bboxsize - sizeof(Span)) + ss->count * sizeof(size_t) +
      /* offset */
      (TSEQUENCESET_OFFSETS_PTR(ss))[ss->count]);
}

/**
 * Returns the n-th sequence of the temporal value
 * Note: This creates a new sequence
 */
TSequence *
tgeometry_seqset_seq_n(const TSequenceSet *ss, int index)
{
  const TSequence *seq = TSEQUENCESET_SEQ_N(ss, index);
  const TInstant **instants = palloc(sizeof(TInstant *) * seq->count);
  for (int i = 0; i < seq->count; i++)
    instants[i] = TSEQUENCE_INST_N(seq, i);
  TSequence *result = tgeometry_seq_make1(tgeometry_seqset_geom(ss),
    instants, seq->count, seq->period.lower_inc, seq->period.upper_inc,
    MEOS_FLAGS_GET_INTERP(seq->flags), NORMALIZE_NO);
  pfree(instants);
  return result;
}

/*****************************************************************************/

/**
 * @brief Construct a temporal sequence set from an array of temporal sequences
 *
 * For example, the memory structure of a temporal sequence set with two
 * sequences is as follows
 * @code
 * -------------------------------------------------------------------------
 * ( TSequenceSet )_X | ( bbox )_X | offset_0 | offset_1 | offset_geom | ...
 * -------------------------------------------------------------------------
 * ----------------------------------------------------
 * ( TSequence_0 )_X | ( TSequence_1 )_X | ( Geom )_X |
 * ----------------------------------------------------
 * @endcode
 * where the `_X` are unused bytes added for double padding, `offset_0` and
 * `offset_1` are offsets for the corresponding sequences.
 *
 * @param[in] geom Reference geometry
 * @param[in] sequences Array of sequences
 * @param[in] count Number of elements in the array
 * @param[in] maxcount Maximum number of elements in the array
 * @param[in] normalize True if the resulting value should be normalized.
 * In particular, normalize is false when synchronizing two temporal sequence
 * sets before applying an operation to them.
 */
TSequenceSet *
tgeometry_seqset_make1_exp(const Datum geom, const TSequence **sequences,
  int count, int maxcount, bool normalize)
{
  assert(maxcount >= count);

  /* Test the validity of the sequences */
  assert(count > 0);
  ensure_valid_tseqarr(sequences, count);
  for (int i = 0; i < count; ++i)
    if (MEOS_FLAGS_GET_GEOM(sequences[i]->flags))
      ensure_same_geom(geom, tgeometry_seq_geom(sequences[i]));

  /* Normalize the array of sequences */
  TSequence **normseqs = (TSequence **) sequences;
  int newcount = count;
  if (normalize && count > 1)
    normseqs = tseqarr_normalize(sequences, count, &newcount);

  /* Get the bounding box size */
  size_t bboxsize = temporal_bbox_size(sequences[0]->temptype);
  /* The period component of the bbox is already declared in the struct */
  size_t bboxsize_extra = bboxsize - sizeof(Span);

  /* Compute the size of the temporal sequence set */
  size_t seqs_size = 0;
  int totalcount = 0;
  for (int i = 0; i < newcount; i++)
  {
    totalcount += normseqs[i]->count;
    seqs_size += DOUBLE_PAD(tgeometry_seq_elem_varsize(normseqs[i]));
  }
  /* Compute the total size for maxcount sequences as a proportion of the size
   * of the count sequences provided. Note that this is only an initial
   * estimation. The functions adding sequences to a sequence set must verify
   * both the maximum number of sequences and the remaining space for adding an
   * additional variable-length sequences of arbitrary size */
  if (count != maxcount)
    seqs_size *= (double) maxcount / count;
  else
    maxcount = newcount;
  /* Size of the reference geometry */
  size_t geom_size = DOUBLE_PAD(VARSIZE(DatumGetPointer(geom)));
  /* Total size of the struct */
  size_t memsize = DOUBLE_PAD(sizeof(TSequenceSet)) + bboxsize_extra +
    (maxcount + 1) * sizeof(size_t) + seqs_size + geom_size;

  /* Create the temporal sequence set */
  TSequenceSet *result = palloc0(memsize);
  SET_VARSIZE(result, memsize);
  result->count = newcount;
  result->maxcount = maxcount;
  result->totalcount = totalcount;
  result->temptype = sequences[0]->temptype;
  result->subtype = TSEQUENCESET;
  result->bboxsize = bboxsize;
  MEOS_FLAGS_SET_CONTINUOUS(result->flags,
    MEOS_FLAGS_GET_CONTINUOUS(sequences[0]->flags));
  MEOS_FLAGS_SET_INTERP(result->flags,
    MEOS_FLAGS_GET_INTERP(sequences[0]->flags));
  MEOS_FLAGS_SET_X(result->flags, true);
  MEOS_FLAGS_SET_T(result->flags, true);
  MEOS_FLAGS_SET_Z(result->flags,
    MEOS_FLAGS_GET_Z(sequences[0]->flags));
  MEOS_FLAGS_SET_GEODETIC(result->flags,
    MEOS_FLAGS_GET_GEODETIC(sequences[0]->flags));
  MEOS_FLAGS_SET_GEOM(result->flags, WITH_GEOM);
  /* Initialization of the variable-length part */
  /* Compute the bounding box */
  tseqarr_compute_bbox((const TSequence **) normseqs, newcount,
    TSEQUENCESET_BBOX_PTR(result));
  /* Store the composing instants */
  size_t pdata = DOUBLE_PAD(sizeof(TSequenceSet)) + bboxsize_extra +
    sizeof(size_t) * newcount;
  size_t pos = sizeof(size_t); /* Account for geom offset pointer */
  for (int i = 0; i < newcount; i++)
  {
    size_t seq_size = tgeometry_seq_elem_varsize(normseqs[i]);
    memcpy(((char *) result) + pdata + pos, normseqs[i], seq_size);
    (TSEQUENCESET_OFFSETS_PTR(result))[i] = pos;
    tgeometry_seq_set_elem((TSequence *) (((char *)result) + pdata + pos));
    pos += DOUBLE_PAD(seq_size);
  }
  /* Store the reference geometry */
  void *geom_from = DatumGetPointer(geom);
  memcpy(((char *) result) + pdata + pos, geom_from, VARSIZE(geom_from));
  (TSEQUENCESET_OFFSETS_PTR(result))[newcount] = pos;

  if (normalize && count > 1)
    pfree_array((void **) normseqs, newcount);
  return result;
}

/**
 * @ingroup libmeos_temporal_constructor
 * @brief Construct a temporal sequence set from an array of temporal sequences.
 *
 * @param[in] geom Reference geometry
 * @param[in] sequences Array of sequences
 * @param[in] count Number of elements in the array
 * @param[in] maxcount Maximum number of elements in the array
 * @param[in] normalize True if the resulting value should be normalized.
 * In particular, normalize is false when synchronizing two
 * temporal sequence sets before applying an operation to them.
 */
TSequenceSet *
tgeometry_seqset_make_exp(const Datum geom, const TSequence **sequences, int count,
  int maxcount, bool normalize)
{
  ensure_valid_tseqarr(sequences, count);
  return tgeometry_seqset_make1_exp(geom, sequences, count, maxcount, normalize);
}

/**
 * @ingroup libmeos_temporal_constructor
 * @brief Construct a temporal sequence set from an array of temporal sequences.
 *
 * @param[in] geom Reference geometry
 * @param[in] sequences Array of sequences
 * @param[in] count Number of elements in the array
 * @param[in] normalize True if the resulting value should be normalized.
 * In particular, normalize is false when synchronizing two
 * temporal sequence sets before applying an operation to them.
 * @sqlfunc tbool_seqset(), tint_seqset(), tfloat_seqset(), ttext_seqset(), etc.
 */
TSequenceSet *
tgeometry_seqset_make(const Datum geom, const TSequence **sequences, int count,
  bool normalize)
{
  return tgeometry_seqset_make_exp(geom, sequences, count, count, normalize);
}

/**
 * @ingroup libmeos_temporal_constructor
 * @brief Construct a temporal sequence set from an array of temporal
 * sequences and free the array and the sequences after the creation.
 * Note: Does not free the reference geometry
 *
 * @param[in] geom Reference geometry
 * @param[in] sequences Array of sequences
 * @param[in] count Number of elements in the array
 * @param[in] normalize True if the resulting value should be normalized.
 * @see tsequenceset_make
 */
TSequenceSet *
tgeometry_seqset_make_free(const Datum geom, TSequence **sequences, int count,
  bool normalize)
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

/**
 * @brief Ensure the validity of the arguments when creating a temporal value
 * This function extends function tsequence_make_valid by spliting the
 * sequences according the maximum distance or interval between instants.
 */
static int *
tgeometry_seqset_make_valid_gaps(const Datum geom, const TInstant **instants, int count,
  bool lower_inc, bool upper_inc, interpType interp, double maxdist,
  Interval *maxt, int *nsplits)
{
  assert(interp != DISCRETE);
  tgeometry_seq_make_valid(geom, instants, count, lower_inc, upper_inc, interp);
  return ensure_valid_tinstarr_gaps(instants, count, MERGE_NO, maxdist, maxt,
    nsplits);
}

/**
 * @ingroup libmeos_temporal_constructor
 * @brief Construct a temporal sequence set from an array of temporal instants
 * introducing a gap when two consecutive instants are separated from each
 * other by at least the given distance or the given time interval.
 *
 * @param[in] instants Array of instants
 * @param[in] count Number of elements in the array
 * @param[in] interp Interpolation
 * @param[in] maxdist Maximum distance for defining a gap
 * @param[in] maxt Maximum time interval for defining a gap
 * @sqlfunc tint_seqset_gaps(), tfloat_seqset_gaps(),
 * tgeompoint_seqset_gaps(), tgeogpoint_seqset_gaps()
 */
TSequenceSet *
tgeometry_seqset_make_gaps(const Datum geom, const TInstant **instants, int count,
  interpType interp, Interval *maxt, double maxdist)
{
  TSequence *seq;
  TSequenceSet *result;

  /* If no gaps are given construt call the standard sequence constructor */
  if (maxt == NULL && maxdist <= 0.0)
  {
    seq = tgeometry_seq_make(geom, (const TInstant **) instants,
      count, true, true, interp, NORMALIZE);
    result = tgeometry_seqset_make(geom, (const TSequence **) &seq, 1, NORMALIZE_NO);
    pfree(seq);
    return result;
  }

  /* Ensure that the array of instants is valid and determine the splits */
  int countsplits;
  int *splits = tgeometry_seqset_make_valid_gaps(geom, (const TInstant **) instants,
    count, true, true, interp, maxdist, maxt, &countsplits);
  if (countsplits == 0)
  {
    /* There are no gaps  */
    pfree(splits);
    seq = tgeometry_seq_make1(geom, (const TInstant **) instants, count, true, true,
      interp, NORMALIZE);
    result = tgeometry_seqset_make(geom, (const TSequence **) &seq, 1, NORMALIZE_NO);
    pfree(seq);
  }
  else
  {
    int newcount = 0;
    /* Split according to gaps  */
    const TInstant **newinsts = palloc(sizeof(TInstant *) * count);
    TSequence **sequences = palloc(sizeof(TSequence *) * (countsplits + 1));
    int j = 0, k = 0;
    for (int i = 0; i < count; i++)
    {
      if (j < countsplits && splits[j] == i)
      {
        /* Finalize the current sequence and start a new one */
        assert(k > 0);
        sequences[newcount++] = tgeometry_seq_make1(geom, (const TInstant **) newinsts,
          k, true, true, interp, NORMALIZE);
        j++; k = 0;
      }
      /* Continue with the current sequence */
      newinsts[k++] = instants[i];
    }
    /* Construct last sequence */
    if (k > 0)
      sequences[newcount++] = tgeometry_seq_make1(geom, (const TInstant **) newinsts,
        k, true, true, interp, NORMALIZE);
    result = tgeometry_seqset_make(geom, (const TSequence **) sequences, newcount,
      NORMALIZE);
    pfree(newinsts); pfree(sequences);
  }
  return result;
}

/*****************************************************************************
 * Transformation functions
 *****************************************************************************/

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal instant transformed into a temporal sequence set.
 */
TSequenceSet *
tgeometry_tinst_to_tseqset(const TInstant *inst, interpType interp)
{
  assert(interp == STEP || interp == LINEAR);
  TSequence *seq = tgeometry_tinst_to_tseq(inst, interp);
  TSequenceSet *result = tgeometry_tseq_to_tseqset(seq);
  pfree(seq);
  return result;
}

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal discrete sequence transformed into a temporal
 * sequence set.
 */
TSequenceSet *
tgeometry_tdiscseq_to_tseqset(const TSequence *seq, interpType interp)
{
  assert(interp == STEP || interp == LINEAR);
  TSequence **sequences = palloc(sizeof(TSequence *) * seq->count);
  for (int i = 0; i < seq->count; i++)
  {
    const TInstant *inst = TSEQUENCE_INST_N(seq, i);
    sequences[i] = tgeometry_seq_make(tgeometry_seq_geom(seq),
      &inst, 1, true, true, interp, NORMALIZE_NO);
  }
  TSequenceSet *result = tgeometry_seqset_make(tgeometry_seq_geom(seq),
    (const TSequence **) sequences, seq->count, NORMALIZE_NO);
  pfree_array((void **) sequences, seq->count);
  return result;
}

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal sequence set transformed into discrete interpolation.
 * @return Return an error if any of the composing temporal sequences has
 * more than one instant
 */
TSequence *
tgeometry_tseqset_to_tdiscseq(const TSequenceSet *ss)
{
  const TSequence *seq;
  for (int i = 0; i < ss->count; i++)
  {
    seq = TSEQUENCESET_SEQ_N(ss, i);
    if (seq->count != 1)
      elog(ERROR, "Cannot transform input to a temporal discrete sequence");
  }

  const TInstant **instants = palloc(sizeof(TInstant *) * ss->count);
  for (int i = 0; i < ss->count; i++)
  {
    seq = TSEQUENCESET_SEQ_N(ss, i);
    instants[i] = TSEQUENCE_INST_N(seq, 0);
  }
  TSequence *result = tgeometry_seq_make(tgeometry_seqset_geom(ss),
    instants, ss->count, true, true, DISCRETE, NORMALIZE_NO);
  pfree(instants);
  return result;
}

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal sequence transformed into a temporal sequence set.
 */
TSequenceSet *
tgeometry_tseq_to_tseqset(const TSequence *seq)
{
  assert(seq);
  if (MEOS_FLAGS_DISCRETE_INTERP(seq->flags))
  {
    interpType interp = MEOS_FLAGS_GET_CONTINUOUS(seq->flags) ? LINEAR : STEP;
    return tgeometry_tdiscseq_to_tseqset(seq, interp);
  }
  return tgeometry_seqset_make(tgeometry_seq_geom(seq), &seq, 1, NORMALIZE_NO);
}

/*****************************************************************************
 * Accessor functions
 *****************************************************************************/

/**
 * @ingroup libmeos_internal_tgeometry_accessor
 * @brief Return the array of sequences of a temporal sequence set.
 * @post The output parameter @p count is equal to the number of sequences of
 * the input temporal sequence set
 * @sqlfunc sequences()
 */
TSequence **
tgeometry_seqset_sequences(const TSequenceSet *ss, int *count)
{
  TSequence **result = palloc(sizeof(TSequence *) * ss->count);
  for (int i = 0; i < ss->count; i++)
    result[i] = tgeometry_seqset_seq_n(ss, i);
  *count = ss->count;
  return result;
}

/**
 * @ingroup libmeos_internal_tgeometry_accessor
 * @brief Return the array of segments of a temporal sequence set.
 * @sqlfunc segments()
 */
TSequence **
tgeometry_seqset_segments(const TSequenceSet *ss, int *count)
{
  Datum geom = tgeometry_seqset_geom(ss);
  TSequence **result = palloc(sizeof(TSequence *) * ss->totalcount);
  int k = 0;
  for (int i = 0; i < ss->count; i++)
  {
    const TSequence *seq = TSEQUENCESET_SEQ_N(ss, i);
    k += tgeometry_seq_segments1(geom, seq, &result[k]);
  }
  *count = k;
  return result;
}

/*****************************************************************************/
