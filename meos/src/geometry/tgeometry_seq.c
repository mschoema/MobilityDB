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
 * @brief Functions for rigid temporal sequence geometries.
 */

#include "geometry/tgeometry_seq.h"

/* C */
#include <assert.h>
/* PostgreSQL */
#include <utils/timestamp.h>
/* MEOS */
#include "meos_internal.h"
#include "general/temporaltypes.h"
#include "general/type_util.h"
#include "general/temporal_boxops.h"
#include "geometry/tgeometry_temporaltypes.h"
#include "geometry/tgeometry_boxops.h"
#include "geometry/tgeometry_spatialfuncs.h"
#include "geometry/tgeometry_utils.h"

/*****************************************************************************
 * General functions
 *****************************************************************************/

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometry_seq_geom(const TSequence *seq)
{
  if (!MEOS_FLAGS_GET_GEOM(seq->flags))
    elog(ERROR, "Cannot access geometry from tgeometry sequence");
  return PointerGetDatum(
    /* start of data */
    ((char *) seq) + DOUBLE_PAD(sizeof(TSequence)) +
      ((seq->bboxsize == 0) ? 0 : (seq->bboxsize - sizeof(Span))) +
      sizeof(size_t) * seq->maxcount +
      /* offset */
      (TSEQUENCE_OFFSETS_PTR(seq))[seq->count]);
}

/**
 * Returns the n-th instant of the temporal geometry
 * Note: This creates a new instant
 */
TInstant *
tgeometry_seq_inst_n(const TSequence *seq, int index)
{
  const TInstant *inst = TSEQUENCE_INST_N(seq, index);
  return tgeometryinst_make1(tgeometry_seq_geom(seq),
    tinstant_value(inst), inst->temptype, inst->t);
}

/*****************************************************************************/

/**
 * Returns the size of the tgeometryseq without reference geometry
 */
size_t
tgeometry_seq_elem_varsize(const TSequence *seq)
{
  Datum geom = tgeometry_seq_geom(seq);
  return VARSIZE(seq) - DOUBLE_PAD(VARSIZE(geom));
}

/**
 * Set the size of the tgeometryseq without reference geometry
 */
void
tgeometry_seq_set_elem(TSequence *seq)
{
  SET_VARSIZE(seq, tgeometry_seq_elem_varsize(seq));
  MEOS_FLAGS_SET_GEOM(seq->flags, NO_GEOM);
  return;
}

/*****************************************************************************/

/**
 * Ensure the validity of the arguments when creating a temporal value
 */
void
tgeometry_seq_make_valid(const Datum geom, const TInstant **instants,
  int count, bool lower_inc, bool upper_inc, bool linear)
{
  tsequence_make_valid1(instants, count, lower_inc, upper_inc, linear);
  ensure_valid_tinstarr(instants, count, MERGE_NO, TSEQUENCE);
  for (int i = 0; i < count; ++i)
    if (MEOS_FLAGS_GET_GEOM(instants[i]->flags))
      ensure_same_geom(geom, tgeometryinst_geom(instants[i]));
  return;
}

/**
 * @brief Construct a temporal sequence from an array of temporal instants
 *
 * For example, the memory structure of a temporal sequence with two instants
 * is as follows:
 * @code
 * ----------------------------------------------------------------------
 * ( TSequence )_X | ( bbox )_X | offset_0 | offset_1 | offset_geom | ...
 * ----------------------------------------------------------------------
 * --------------------------------------------------
 * ( TInstant_0 )_X | ( TInstant_1 )_X | ( Geom )_X |
 * --------------------------------------------------
 * @endcode
 * where the `X` are unused bytes added for double padding, `offset_0` and
 * `offset_1` are offsets for the corresponding instants
 *
 * @pre The validity of the arguments has been tested before
 */
TSequence *
tgeometry_seq_make1_exp(const Datum geom, const TInstant **instants, int count,
  int maxcount, bool lower_inc, bool upper_inc, interpType interp, bool normalize)
{
  /* Normalize the array of instants */
  TInstant **norminsts = (TInstant **) instants;
  int newcount = count;
  if (interp != DISCRETE && normalize && count > 1)
    norminsts = tinstarr_normalize(instants, interp, count, &newcount);

  /* Get the bounding box size */
  size_t bboxsize = DOUBLE_PAD(temporal_bbox_size(instants[0]->temptype));
  /* The period component of the bbox is already declared in the struct */
  size_t bboxsize_extra = bboxsize - sizeof(Span);

  /* Compute the size of the temporal sequence */
  size_t insts_size = 0;
  /* Size of composing instants */
  /* Size of composing instants */
  for (int i = 0; i < newcount; i++)
    insts_size += DOUBLE_PAD(tgeometryinst_elem_varsize(norminsts[i]));
  /* Compute the total size for maxcount instants as a proportion of the size
   * of the count instants provided. Note that this is only an initial
   * estimation. The functions adding instants to a sequence must verify both
   * the maximum number of instants and the remaining space for adding an
   * additional variable-length instant of arbitrary size */
  if (count != maxcount)
    insts_size *= (double) maxcount / count;
  else
    maxcount = newcount;
  /* Size of the reference geometry */
  size_t geom_size = DOUBLE_PAD(VARSIZE(DatumGetPointer(geom)));
  /* Total size of the struct */
  size_t memsize = DOUBLE_PAD(sizeof(TSequence)) + bboxsize_extra +
    (maxcount + 1) * sizeof(size_t) + insts_size + geom_size;

  /* Create the temporal sequence */
  TSequence *result = palloc0(memsize);
  SET_VARSIZE(result, memsize);
  result->count = newcount;
  result->maxcount = maxcount;
  result->temptype = instants[0]->temptype;
  result->subtype = TSEQUENCE;
  result->bboxsize = bboxsize;
  MEOS_FLAGS_SET_CONTINUOUS(result->flags,
    MEOS_FLAGS_GET_CONTINUOUS(norminsts[0]->flags));
  MEOS_FLAGS_SET_INTERP(result->flags, interp);
  MEOS_FLAGS_SET_X(result->flags, true);
  MEOS_FLAGS_SET_T(result->flags, true);
  MEOS_FLAGS_SET_Z(result->flags, MEOS_FLAGS_GET_Z(instants[0]->flags));
  MEOS_FLAGS_SET_GEODETIC(result->flags,
    MEOS_FLAGS_GET_GEODETIC(instants[0]->flags));
  MEOS_FLAGS_SET_GEOM(result->flags, WITH_GEOM);
  /* Initialization of the variable-length part */
  /* Compute the bounding box */
  tgeometry_instarr_compute_bbox(geom, (const TInstant **) norminsts,
    newcount, interp, TSEQUENCE_BBOX_PTR(result));
  /* Set the lower_inc and upper_inc bounds of the period at the beginning
   * of the bounding box */
  Span *p = (Span *) TSEQUENCE_BBOX_PTR(result);
  p->lower_inc = lower_inc;
  p->upper_inc = upper_inc;
  /* Store the composing instants */
  size_t pdata = DOUBLE_PAD(sizeof(TSequence)) + bboxsize_extra +
    sizeof(size_t) * maxcount;
  size_t pos = sizeof(size_t); /* Account for geom offset pointer */
  for (int i = 0; i < newcount; i++)
  {
    size_t inst_size = tgeometryinst_elem_varsize(norminsts[i]);
    memcpy(((char *)result) + pdata + pos, norminsts[i], inst_size);
    (TSEQUENCE_OFFSETS_PTR(result))[i] = pos;
    tgeometryinst_set_elem((TInstant *) (((char *)result) + pdata + pos));
    pos += DOUBLE_PAD(inst_size);
  }
  /* Store the reference geometry */
  void *geom_from = DatumGetPointer(geom);
  memcpy(((char *) result) + pdata + pos, geom_from, VARSIZE(geom_from));
  (TSEQUENCE_OFFSETS_PTR(result))[newcount] = pos;

  if (interp != DISCRETE && normalize && count > 1)
    pfree(norminsts);
  return result;
}

/**
 * @brief Construct a temporal sequence from an array of temporal instants
 * @pre The validity of the arguments has been tested before
 */
TSequence *
tgeometry_seq_make1(const Datum geom, const TInstant **instants, int count,
  bool lower_inc, bool upper_inc, interpType interp, bool normalize)
{
  return tgeometry_seq_make1_exp(geom, instants, count, count,
    lower_inc, upper_inc, interp, normalize);
}

/**
 * @brief Construct a temporal sequence from an array of temporal instants.
 *
 * @param[in] geom Reference geometry
 * @param[in] instants Array of instants
 * @param[in] count Number of elements in the array
 * @param[in] maxcount Maximum number of elements in the array
 * @param[in] lower_inc,upper_inc True if the respective bound is inclusive
 * @param[in] interp Interpolation
 * @param[in] normalize True if the resulting value should be normalized
 */
TSequence *
tgeometry_seq_make_exp(const Datum geom, const TInstant **instants, int count,
  int maxcount, bool lower_inc, bool upper_inc, interpType interp, bool normalize)
{
  tgeometry_seq_make_valid(geom, instants, count, lower_inc, upper_inc, interp);
  return tgeometry_seq_make1_exp(geom, instants, count, maxcount,
    lower_inc, upper_inc, interp, normalize);
}

/**
 * @ingroup libmeos_temporal_constructor
 * @brief Construct a temporal sequence from an array of temporal instants.
 *
 * @param[in] geom Reference geometry
 * @param[in] instants Array of instants
 * @param[in] count Number of elements in the array
 * @param[in] lower_inc,upper_inc True if the respective bound is inclusive
 * @param[in] interp Interpolation
 * @param[in] normalize True if the resulting value should be normalized
 */
TSequence *
tgeometry_seq_make(const Datum geom, const TInstant **instants, int count,
  bool lower_inc, bool upper_inc, interpType interp, bool normalize)
{
  return tgeometry_seq_make_exp(geom, instants, count, count,
    lower_inc, upper_inc, interp, normalize);
}

/**
 * @brief Construct a temporal sequence from an array of temporal instants
 * and free the array and the instants after the creation.
 * Note: Does not free the reference geometry
 *
 * @param[in] geom Reference geometry
 * @param[in] instants Array of instants
 * @param[in] count Number of elements in the array
 * @param[in] maxcount Maximum number of elements in the array
 * @param[in] lower_inc,upper_inc True if the respective bound is inclusive
 * @param[in] interp Interpolation
 * @param[in] normalize True if the resulting value should be normalized
 * @see tsequence_make
 */
TSequence *
tgeometry_seq_make_free_exp(const Datum geom, TInstant **instants, int count,
  int maxcount, bool lower_inc, bool upper_inc, interpType interp, bool normalize)
{
  if (count == 0)
  {
    pfree(instants);
    return NULL;
  }
  TSequence *result = tgeometry_seq_make_exp(geom, (const TInstant **) instants,
    count, maxcount, lower_inc, upper_inc, interp, normalize);
  pfree_array((void **) instants, count);
  return result;
}

/**
 * @ingroup libmeos_temporal_constructor
 * @brief Construct a temporal sequence from an array of temporal instants
 * and free the array and the instants after the creation.
 * Note: Does not free the reference geometry
 *
 * @param[in] geom Reference geometry
 * @param[in] instants Array of instants
 * @param[in] count Number of elements in the array
 * @param[in] lower_inc,upper_inc True if the respective bound is inclusive
 * @param[in] interp Interpolation
 * @param[in] normalize True if the resulting value should be normalized
 * @see tsequence_make
 */
TSequence *
tgeometry_seq_make_free(const Datum geom, TInstant **instants, int count,
  bool lower_inc, bool upper_inc, interpType interp, bool normalize)
{
  return tgeometry_seq_make_free_exp(geom, instants, count, count,
    lower_inc, upper_inc, interp, normalize);
}

/*****************************************************************************
 * Transformation functions
 *****************************************************************************/

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal instant transformed into a temporal sequence.
 */
TSequence *
tgeometry_tinst_to_tseq(const TInstant *inst, interpType interp)
{
  return tgeometry_seq_make(tgeometryinst_geom(inst),
    &inst, 1, true, true, interp, NORMALIZE_NO);
}

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal sequence transformed into discrete interpolation.
 * @return Return an error if a temporal sequence has more than one instant
 */
TSequence *
tgeometry_tseq_to_tdiscseq(const TSequence *seq)
{
  /* If the sequence has discrete interpolation return a copy */
  if (MEOS_FLAGS_DISCRETE_INTERP(seq->flags))
    return tsequence_copy(seq);

  /* General case */
  if (seq->count != 1)
    elog(ERROR, "Cannot transform input value to a temporal discrete sequence");

  const TInstant *inst = TSEQUENCE_INST_N(seq, 0);
  return tgeometry_seq_make(tgeometry_seq_geom(seq),
    &inst, 1, true, true, DISCRETE, NORMALIZE_NO);
}

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal sequence transformed to continuous interpolation.
 */
TSequence *
tgeometry_tseq_to_tcontseq(const TSequence *seq)
{
  if (MEOS_FLAGS_DISCRETE_INTERP(seq->flags))
  {
    if (seq->count != 1)
      elog(ERROR, "Cannot transform input value to a temporal continuous sequence");
    const TInstant *inst = TSEQUENCE_INST_N(seq, 0);
    return tgeometry_seq_make(tgeometry_seq_geom(seq), &inst, 1, true, true,
      MEOS_FLAGS_GET_CONTINUOUS(seq->flags) ? LINEAR : STEP, NORMALIZE_NO);
  }
  else
    /* The sequence has continuous interpolation return a copy */
    return tsequence_copy(seq);
}

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal sequence set transformed into a temporal sequence
 * value.
 */
TSequence *
tgeometry_tseqset_to_tseq(const TSequenceSet *ss)
{
  if (ss->count != 1)
    elog(ERROR, "Cannot transform input to a temporal sequence");
  return tgeometry_seqset_seq_n(ss, 0);
}

/*****************************************************************************
 * Accessor functions
 *****************************************************************************/

/**
 * @ingroup libmeos_internal_tgeometry_accessor
 * @brief Return the singleton array of sequences of a temporal sequence.
 * @post The output parameter @p count is equal to 1
 * @sqlfunc sequences()
 */
TSequence **
tgeometry_seq_sequences(const TSequence *seq, int *count)
{
  TSequence **result;
  if (MEOS_FLAGS_DISCRETE_INTERP(seq->flags))
  {
    /* Discrete sequence */
    result = palloc(sizeof(TSequence *) * seq->count);
    interpType interp = MEOS_FLAGS_GET_CONTINUOUS(seq->flags) ? LINEAR : STEP;
    for (int i = 0; i < seq->count; i++)
    {
      TInstant *inst = tgeometry_seq_inst_n(seq, i);
      result[i] = tgeometry_tinst_to_tseq(inst, interp);
      pfree(inst);
    }
    *count = seq->count;
  }
  else
  {
    /* Continuous sequence */
    result = palloc(sizeof(TSequence *));
    result[0] = tsequence_copy(seq);
    *count = 1;
  }
  return result;
}

/**
 * Return the array of segments of a temporal sequence
 */
int
tgeometry_seq_segments1(Datum geom, const TSequence *seq, TSequence **result)
{
  assert(! MEOS_FLAGS_DISCRETE_INTERP(seq->flags));
  if (seq->count == 1)
  {
    result[0] = tsequence_copy(seq);
    return 1;
  }

  TInstant *instants[2];
  interpType interp = MEOS_FLAGS_GET_INTERP(seq->flags);
  bool lower_inc = seq->period.lower_inc;
  TInstant *inst1, *inst2;
  int k = 0;
  meosType basetype = temptype_basetype(seq->temptype);
  for (int i = 1; i < seq->count; i++)
  {
    inst1 = (TInstant *) TSEQUENCE_INST_N(seq, i - 1);
    inst2 = (TInstant *) TSEQUENCE_INST_N(seq, i);
    instants[0] = inst1;
    instants[1] = (interp == LINEAR) ? inst2 :
      tgeometryinst_make1(geom, tinstant_value(inst1),
        seq->temptype, inst2->t);
    bool upper_inc;
    if (i == seq->count - 1 && (interp == LINEAR ||
      datum_eq(tinstant_value(inst1), tinstant_value(inst2), basetype)))
      upper_inc = seq->period.upper_inc;
    else
      upper_inc = false;
    result[k++] = tgeometry_seq_make1(geom, (const TInstant **) instants,
      2, lower_inc, upper_inc, interp, NORMALIZE_NO);
    if (interp != LINEAR)
      pfree(instants[1]);
    lower_inc = true;
  }
  if (interp != LINEAR && seq->period.upper)
  {
    inst1 = (TInstant *) TSEQUENCE_INST_N(seq, seq->count - 1);
    inst2 = (TInstant *) TSEQUENCE_INST_N(seq, seq->count - 2);
    if (! datum_eq(tinstant_value(inst1), tinstant_value(inst2), basetype))
      result[k++] = tgeometry_tinst_to_tseq(inst1, interp);
  }
  return k;
}

/**
 * @ingroup libmeos_internal_temporal_accessor
 * @brief Return the array of segments of a temporal sequence.
 * @sqlfunc segments()
 */
TSequence **
tgeometry_seq_segments(const TSequence *seq, int *count)
{
  /* Discrete sequence */
  if (MEOS_FLAGS_DISCRETE_INTERP(seq->flags))
    return tgeometry_seq_sequences(seq, count);

  /* Continuous sequence */
  Datum geom = tgeometry_seq_geom(seq);
  TSequence **result = palloc(sizeof(TSequence *) * seq->count);
  *count = tgeometry_seq_segments1(geom, seq, result);
  return result;
}

/*****************************************************************************/
