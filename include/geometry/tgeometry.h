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
 * @file tgeometry.h
 * Functions for rigid temporal geometries.
 */

#ifndef __TGEOMETRY_H__
#define __TGEOMETRY_H__

#include <postgres.h>
#include <catalog/pg_type.h>

#include "general/temporal.h"

/** Symbolic constants for the temporal instant geometry constuctor */
#define WITH_GEOM       true
#define NO_GEOM         false

/*****************************************************************************
 * Miscellaneous functions defined in tgeometry.c
 *****************************************************************************/

extern Datum tgeometry_geom(const Temporal *temp);

/* Input/output functions */

extern Datum tgeometry_in(PG_FUNCTION_ARGS);
extern Datum tgeometry_out(PG_FUNCTION_ARGS);

/* Constructor functions */

extern Datum tgeometryinst_constructor(PG_FUNCTION_ARGS);
extern Datum tgeometry_instset_constructor(PG_FUNCTION_ARGS);
extern Datum tgeometry_seq_constructor(PG_FUNCTION_ARGS);
extern Datum tgeometry_seqset_constructor(PG_FUNCTION_ARGS);

extern Datum tgeometry_to_tinstant(PG_FUNCTION_ARGS);
extern Datum tgeometry_to_tinstantset(PG_FUNCTION_ARGS);
extern Datum tgeometry_to_tsequence(PG_FUNCTION_ARGS);
extern Datum tgeometry_to_tsequenceset(PG_FUNCTION_ARGS);

extern Datum tgeometry_value_at_timestamp(PG_FUNCTION_ARGS);

/*****************************************************************************/

#endif
