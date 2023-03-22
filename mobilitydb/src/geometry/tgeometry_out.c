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
 * @brief Output of rigid temporal geometries in WKT and EWKT format.
 */

/* PostgreSQL */
#include <postgres.h>
/* MEOS */
#include <meos.h>
#include <meos_internal.h>
#include "general/type_out.h"
#include "general/type_util.h"
#include "geometry/tgeometry_out.h"
/* MobilityDB */
#include "pg_general/type_util.h"

/*****************************************************************************
 * Output in WKT and EWKT format
 *****************************************************************************/

/**
 * @ingroup mobilitydb_temporal_inout
 * @brief Output a rigid temporal geometry in Well-Known Text (WKT) format
 * @sqlfunc asText()
 */
static Datum
Tgeometry_as_text_ext(FunctionCallInfo fcinfo, bool extended)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  int dbl_dig_for_wkt = OUT_DEFAULT_DECIMAL_DIGITS;
  if (PG_NARGS() > 1 && ! PG_ARGISNULL(1))
    dbl_dig_for_wkt = PG_GETARG_INT32(1);
  char *str = extended ?
    tgeometry_as_ewkt(temp, dbl_dig_for_wkt) :
    tgeometry_as_text(temp, dbl_dig_for_wkt);
  text *result = cstring2text(str);
  pfree(str);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_TEXT_P(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_as_text);
/**
 * @ingroup mobilitydb_temporal_inout
 * @brief Output a rigid temporal geometry in Well-Known Text (WKT) format
 * @sqlfunc asText()
 */
PGDLLEXPORT Datum
Tgeometry_as_text(PG_FUNCTION_ARGS)
{
  return Tgeometry_as_text_ext(fcinfo, false);
}

PG_FUNCTION_INFO_V1(Tgeometry_as_ewkt);
/**
 * @ingroup mobilitydb_temporal_inout
 * @brief Output a rigid temporal geometry in Extended Well-Known Text (EWKT) format,
 * that is, in WKT format prefixed with the SRID
 * @sqlfunc asEWKT()
 */
PGDLLEXPORT Datum
Tgeometry_as_ewkt(PG_FUNCTION_ARGS)
{
  return Tgeometry_as_text_ext(fcinfo, true);
}

/*****************************************************************************/
