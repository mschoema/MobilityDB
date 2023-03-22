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

#ifndef __TGEOMETRY_SEQSET_H__
#define __TGEOMETRY_SEQSET_H__

/* PostgreSQL */
#include <postgres.h>
#include <catalog/pg_type.h>
/* MEOS */
#include "general/temporal.h"

/*****************************************************************************
 * General functions
 *****************************************************************************/

extern Datum tgeometry_seqset_geom(const TSequenceSet *ts);
extern TSequence *tgeometry_seqset_seq_n(const TSequenceSet *ts, int index);

/* Constructor functions */

extern TSequenceSet *tgeometry_seqset_make1_exp(const Datum geom,
  const TSequence **sequences, int count, int maxcount, bool normalize);
extern TSequenceSet *tgeometry_seqset_make_exp(const Datum geom,
  const TSequence **sequences, int count, int maxcount, bool normalize);
extern TSequenceSet *tgeometry_seqset_make(const Datum geom,
  const TSequence **sequences, int count, bool normalize);
extern TSequenceSet *tgeometry_seqset_make_free(const Datum geom,
  TSequence **sequences, int count, bool normalize);
extern TSequenceSet *tgeometry_seqset_make_gaps(const Datum geom,
  const TInstant **instants, int count, interpType interp,
  Interval *maxt, double maxdist);


/* Transformation functions */

extern TSequenceSet *tgeometry_tinst_to_tseqset(const TInstant *inst, interpType interp);
extern TSequenceSet *tgeometry_tdiscseq_to_tseqset(const TSequence *seq, interpType interp);
extern TSequence *tgeometry_tseqset_to_tdiscseq(const TSequenceSet *ss);
extern TSequenceSet *tgeometry_tseq_to_tseqset(const TSequence *seq);

/* Accessor functions */

extern TSequence **tgeometry_seqset_sequences(const TSequenceSet *ss, int *count);
extern TSequence **tgeometry_seqset_segments(const TSequenceSet *ss, int *count);

/*****************************************************************************/

#endif
