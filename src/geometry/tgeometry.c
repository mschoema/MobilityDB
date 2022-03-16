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

#include "geometry/tgeometry_temporaltypes.h"
#include "geometry/tgeometry_parser.h"

/*****************************************************************************/

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometry_geom(const Temporal *temp)
{
  Datum result;
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT)
    result = tgeometryinst_geom((const TInstant *) temp);
  else if (temp->subtype == INSTANTSET)
    result = tgeometryinstset_geom((const TInstantSet *) temp);
  else if (temp->subtype == SEQUENCE)
    result = tgeometryseq_geom((const TSequence *) temp);
  else /* temp->subtype == SEQUENCESET */
    result = tgeometryseqset_geom((const TSequenceSet *) temp);
  return result;
}

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
 * Construct a temporal instant value from the arguments
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
    PointerGetDatum(gs), PointerGetDatum(p), t, basetypid);
  PG_FREE_IF_COPY(gs, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(tgeometry_instset_constructor);
/**
 * Construct a temporal instant set value from the array of temporal
 * instant values
 */
PGDLLEXPORT Datum
tgeometry_instset_constructor(PG_FUNCTION_ARGS)
{
  ArrayType *array = PG_GETARG_ARRAYTYPE_P(0);
  ensure_non_empty_array(array);
  int count;
  TInstant **instants = (TInstant **) temporalarr_extract(array, &count);
  ensure_tinstarr(instants, count);
  Temporal *result = (Temporal *) tgeometry_instset_make(
    tgeometryinst_geom(instants[0]), (const TInstant **) instants,
    count, MERGE_NO);
  pfree(instants);
  PG_FREE_IF_COPY(array, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(tgeometry_seq_constructor);
/**
 * Construct a temporal sequence value with linear or stepwise
 * interpolation from the array of temporal instant values
 */
PGDLLEXPORT Datum
tgeometry_seq_constructor(PG_FUNCTION_ARGS)
{
  ArrayType *array = PG_GETARG_ARRAYTYPE_P(0);
  bool lower_inc = PG_GETARG_BOOL(1);
  bool upper_inc = PG_GETARG_BOOL(2);
  bool linear = PG_GETARG_BOOL(3);
  ensure_non_empty_array(array);
  int count;
  TInstant **instants = (TInstant **) temporalarr_extract(array, &count);
  ensure_tinstarr(instants, count);
  Temporal *result = (Temporal *) tgeometry_seq_make(
    tgeometryinst_geom(instants[0]), (const TInstant **) instants,
    count, lower_inc, upper_inc, linear, NORMALIZE);
  pfree(instants);
  PG_FREE_IF_COPY(array, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(tgeometry_seqset_constructor);
/**
 * Construct a temporal sequence set value from the array of temporal
 * sequence values
 */
PGDLLEXPORT Datum
tgeometry_seqset_constructor(PG_FUNCTION_ARGS)
{
  ArrayType *array = PG_GETARG_ARRAYTYPE_P(0);
  ensure_non_empty_array(array);
  int count;
  TSequence **sequences = (TSequence **) temporalarr_extract(array, &count);
  bool linear = MOBDB_FLAGS_GET_LINEAR(sequences[0]->flags);
  /* Ensure that all values are of sequence subtype and of the same interpolation */
  for (int i = 0; i < count; i++)
  {
    if (sequences[i]->subtype != SEQUENCE)
    {
      PG_FREE_IF_COPY(array, 0);
      ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
        errmsg("Input values must be temporal sequences")));
    }
    if (MOBDB_FLAGS_GET_LINEAR(sequences[i]->flags) != linear)
    {
      PG_FREE_IF_COPY(array, 0);
      ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
        errmsg("Input sequences must have the same interpolation")));
    }
  }
  Temporal *result = (Temporal *) tgeometry_seqset_make(
    tgeometryseq_geom(sequences[0]), (const TSequence **) sequences,
    count, NORMALIZE);
  pfree(sequences);
  PG_FREE_IF_COPY(array, 0);
  PG_RETURN_POINTER(result);
}

/*****************************************************************************/
