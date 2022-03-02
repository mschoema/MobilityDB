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
 * @file tgeometry_inst.h
 * Functions for rigid temporal instant geometries.
 */

#ifndef __TGEOMETRY_INST_H__
#define __TGEOMETRY_INST_H__

#include <postgres.h>
#include <catalog/pg_type.h>

#include "general/temporal.h"

/** Symbolic constants for the temporal instant geometry constuctor */
#define WITH_GEOM       true
#define NO_GEOM         false

/*****************************************************************************
 * General functions
 *****************************************************************************/

extern Datum *tgeometryinst_geom_ptr(const TInstant *inst);
extern Datum tgeometryinst_geom(const TInstant *inst);
extern Datum tgeometryinstset_geom(const TInstantSet *ti);
extern Datum tgeometryseq_geom(const TSequence *seq);
extern Datum tgeometryseqset_geom(const TSequenceSet *ts);
extern Datum tgeometry_geom(const Temporal *temp);

extern size_t tgeometryinst_elem_varsize(const TInstant *inst);
extern void tgeometryinst_set_elem(TInstant *inst);
extern size_t tgeometryseq_elem_varsize(const TSequence *seq);
extern void tgeometryseq_set_elem(TSequence *seq);


extern TInstant *tgeometryinst_make(Datum value,
  TimestampTz t, Oid basetypid, bool hasgeom, Datum geom);

/*****************************************************************************/

#endif
