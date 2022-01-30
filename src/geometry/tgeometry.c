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
 * @file tgeometry.c
 * Basic functions for rigid temporal geometries.
 */

#include "geometry/tgeometry.h"

#include <utils/builtins.h>
#include <utils/timestamp.h>

#include "general/temporaltypes.h"
#include "general/tempcache.h"
#include "general/temporal_util.h"

#include "point/tpoint_out.h"
#include "point/tpoint_spatialfuncs.h"

#include "pose/pose.h"

#include "geometry/tgeometry_inst.h"
#include "geometry/tgeometry_parser.h"

/*****************************************************************************
 * Input/output functions
 *****************************************************************************/

PG_FUNCTION_INFO_V1(tgeometry_in);
/**
 * Generic input function for rigid temporal geometries
 *
 * @note Examples of input for the various temporal types:
 * - Instant
 * @code
 * Polygon((0 0, 1 0, 0 1, 0 0)); Pose(0, 0, 0) @ 2012-01-01 08:00:00
 * @endcode
 * - Instant set
 * @code
 * Polygon((0 0, 1 0, 0 1, 0 0));{ Pose(0, 0, 0) @ 2012-01-01 08:00:00 ,
 * Pose(1, 1, 0) @ 2012-01-01 08:10:00 }
 * @endcode
 * - Sequence
 * @code
 * Polygon((0 0, 1 0, 0 1, 0 0));[ Pose(0, 0, 0) @ 2012-01-01 08:00:00 ,
 * Pose(1, 1, 0) @ 2012-01-01 08:10:00 )
 * @endcode
 * - Sequence set
 * @code
 * Polygon((0 0, 1 0, 0 1, 0 0));{ [ Pose(0, 0, 0) @ 2012-01-01 08:00:00 ,
 * Pose(1, 1, 0) @ 2012-01-01 08:10:00 ) , [ Pose(1, 1, 0) @ 2012-01-01 08:20:00 ,
 * Pose(0, 0, 0) @ 2012-01-01 08:30:00 ] }
 * @endcode
 */
PGDLLEXPORT Datum
tgeometry_in(PG_FUNCTION_ARGS)
{
  char *input = PG_GETARG_CSTRING(0);
  Oid temptypid = PG_GETARG_OID(1);
  Oid basetypid = temporal_basetypid(temptypid);
  Temporal *result = tgeometry_parse(&input, basetypid);
  PG_RETURN_POINTER(result);
}

/**
 * Output a rigid temporal geometry in Well-Known Text (WKT) format
 */
static char *
tgeometry_to_str(const Temporal *temp)
{
  char *geom = wkt_out(type_oid(T_GEOMETRY), tgeometry_geom(temp));
  char *rest = temporal_to_string(temp, &call_output);
  char *result = palloc(strlen(geom) + strlen(rest) + 2);
  sprintf(result, "%s;%s", geom, rest);
  pfree(geom);
  pfree(rest);
  return result;
}

PG_FUNCTION_INFO_V1(tgeometry_out);
/**
 * Generic output function for rigid temporal geometries
 */
PGDLLEXPORT Datum
tgeometry_out(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  char *result = tgeometry_to_str(temp);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_CSTRING(result);
}

/*****************************************************************************
 * Constructor functions
 *****************************************************************************/

PG_FUNCTION_INFO_V1(tgeometryinst_constructor);
/**
 * Construct a temporal instant geometry value from the arguments
 */
PGDLLEXPORT Datum
tgeometryinst_constructor(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  pose *p = PG_GETARG_POSE(1);
  ensure_non_empty(gs);
  ensure_has_not_M_gs(gs);
  TimestampTz t = PG_GETARG_TIMESTAMPTZ(2);
  Oid basetypid = get_fn_expr_argtype(fcinfo->flinfo, 1);
  Temporal *result = (Temporal *) tgeometryinst_make(
    PointerGetDatum(p), t, basetypid, WITH_GEOM, PointerGetDatum(gs));
  PG_FREE_IF_COPY(gs, 0);
  PG_RETURN_POINTER(result);
}

/*****************************************************************************/
