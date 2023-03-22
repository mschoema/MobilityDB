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

#ifndef __TGEOMETRY_SEQ_H__
#define __TGEOMETRY_SEQ_H__

/* PostgreSQL */
#include <postgres.h>
#include <catalog/pg_type.h>
/* MEOS */
#include "general/temporal.h"

/*****************************************************************************
 * General functions
 *****************************************************************************/

extern Datum tgeometry_seq_geom(const TSequence *seq);
extern TInstant *tgeometry_seq_inst_n(const TSequence *seq, int index);

extern size_t tgeometry_seq_elem_varsize(const TSequence *seq);
extern void tgeometry_seq_set_elem(TSequence *seq);

/* Constructor functions */

extern void tgeometry_seq_make_valid(const Datum geom, const TInstant **instants,
  int count, bool lower_inc, bool upper_inc, bool linear);
extern TSequence *tgeometry_seq_make1_exp(const Datum geom, const TInstant **instants,
  int count, int maxcount, bool lower_inc, bool upper_inc, interpType interp, bool normalize);
extern TSequence *tgeometry_seq_make1(const Datum geom, const TInstant **instants,
  int count, bool lower_inc, bool upper_inc, interpType interp, bool normalize);
extern TSequence *tgeometry_seq_make_exp(const Datum geom, const TInstant **instants,
  int count, int maxcount, bool lower_inc, bool upper_inc, interpType interp, bool normalize);
extern TSequence *tgeometry_seq_make(const Datum geom, const TInstant **instants,
  int count, bool lower_inc, bool upper_inc, interpType interp, bool normalize);
extern TSequence *tgeometry_seq_make_free_exp(const Datum geom, TInstant **instants,
  int count, int maxcount, bool lower_inc, bool upper_inc, interpType interp, bool normalize);
extern TSequence *tgeometry_seq_make_free(const Datum geom, TInstant **instants,
  int count, bool lower_inc, bool upper_inc, interpType interp, bool normalize);

/* Transformation functions */

extern TSequence *tgeometry_tinst_to_tseq(const TInstant *inst, interpType interp);
extern TSequence *tgeometry_tseq_to_tdiscseq(const TSequence *seq);
extern TSequence *tgeometry_tseq_to_tcontseq(const TSequence *seq);
extern TSequence *tgeometry_tseqset_to_tseq(const TSequenceSet *ss);

/* Accessor functions */

extern TSequence **tgeometry_seq_sequences(const TSequence *seq, int *count);
extern int tgeometry_seq_segments1(Datum geom, const TSequence *seq,
  TSequence **result);
extern TSequence **tgeometry_seq_segments(const TSequence *seq, int *count);

/*****************************************************************************/

#endif
