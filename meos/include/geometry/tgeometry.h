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
 * @brief General functions for rigid temporal geometries.
 */

#ifndef __TGEOMETRY_H__
#define __TGEOMETRY_H__

/* PostgreSQL */
#include <postgres.h>
#include <catalog/pg_type.h>
/* MEOS */
#include "general/temporal.h"

/** Symbolic constants for the temporal instant geometry constuctor */
#define WITH_GEOM       true
#define NO_GEOM         false

/*****************************************************************************
 * Miscellaneous functions defined in tgeometry.c
 *****************************************************************************/

extern Datum tgeometry_geom(const Temporal *temp);

/* Input/output functions */

extern char *tgeometry_out(const Temporal *temp, int maxdd);

/* Casting functions */

extern Temporal *tgeometry_to_tgeompoint(const Temporal *temp);

/* Accessor functions */

extern TInstant *tgeometry_start_instant(const Temporal *temp);
extern TInstant *tgeometry_end_instant(const Temporal *temp);
extern TInstant *tgeometry_instant_n(const Temporal *temp, int n);
extern TInstant **tgeometry_instants(const Temporal *temp, int *count);

extern TSequence *tgeometry_start_sequence(const Temporal *temp);
extern TSequence *tgeometry_end_sequence(const Temporal *temp);
extern TSequence *tgeometry_sequence_n(const Temporal *temp, int i);
extern TSequence **tgeometry_sequences(const Temporal *temp, int *count);
extern TSequence **tgeometry_segments(const Temporal *temp, int *count);

extern bool tgeometry_value_at_timestamp(const Temporal *temp, TimestampTz t,
  bool strict, Datum *result);

/*****************************************************************************/

#endif
