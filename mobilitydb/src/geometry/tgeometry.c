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


#include "geometry/tgeometry.h"

/* PostgreSQL */
#include <postgres.h>
#include "utils/array.h"
#include "utils/timestamp.h"
/* MEOS */
#include <meos.h>
#include <stdio.h>
#include "general/type_out.h"
#include "general/type_util.h"
#include "geometry/tgeometry_parser.h"
#include "geometry/tgeometry_temporaltypes.h"
#include "point/tpoint_spatialfuncs.h"
#include "pose/tpose_static.h"
/* MobilityDB */
#include "pg_general/meos_catalog.h"
#include "pg_general/temporal.h"
#include "pg_general/type_util.h"
#include "pg_point/postgis.h"

/*****************************************************************************
 * Input/output functions
 *****************************************************************************/

PG_FUNCTION_INFO_V1(Tgeometry_in);
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
Tgeometry_in(PG_FUNCTION_ARGS)
{
  const char *input = PG_GETARG_CSTRING(0);
  Oid temptypid = PG_GETARG_OID(1);
  Temporal *result = tgeometry_parse(&input, oid_type(temptypid));
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_out);
/**
 * Generic output function for rigid temporal geometries
 */
PGDLLEXPORT Datum
Tgeometry_out(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  char *result = tgeometry_out(temp, OUT_DEFAULT_DECIMAL_DIGITS);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_CSTRING(result);
}

/*****************************************************************************
 * Constructor functions
 *****************************************************************************/

PG_FUNCTION_INFO_V1(Tgeometryinst_constructor);
/**
 * Construct a temporal instant value from the arguments
 */
PGDLLEXPORT Datum
Tgeometryinst_constructor(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  Pose *pose = PG_GETARG_POSE(1);
  ensure_not_empty(gs);
  ensure_has_not_M_gs(gs);
  TimestampTz t = PG_GETARG_TIMESTAMPTZ(2);
  meosType temptype = oid_type(get_fn_expr_rettype(fcinfo->flinfo));
  Temporal *result = (Temporal *) tgeometryinst_make(
    PointerGetDatum(gs), PointerGetDatum(pose), temptype, t);
  PG_FREE_IF_COPY(gs, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_seq_constructor);
/**
 * @ingroup mobilitydb_temporal_constructor
 * @brief Construct a temporal sequence from an array of temporal instants
 * @sqlfunc tbool_seq(), tint_seq(), tfloat_seq(), ttext_seq(), ...
 */
PGDLLEXPORT Datum
Tgeometry_seq_constructor(PG_FUNCTION_ARGS)
{
  ArrayType *array = PG_GETARG_ARRAYTYPE_P(0);
  meosType temptype = oid_type(get_fn_expr_rettype(fcinfo->flinfo));
  interpType interp = temptype_continuous(temptype) ? LINEAR : STEP;
  if (PG_NARGS() > 1 && !PG_ARGISNULL(1))
  {
    text *interp_txt = PG_GETARG_TEXT_P(1);
    char *interp_str = text2cstring(interp_txt);
    interp = interp_from_string(interp_str);
    pfree(interp_str);
  }
  bool lower_inc = true, upper_inc = true;
  if (PG_NARGS() > 2 && !PG_ARGISNULL(2))
    lower_inc = PG_GETARG_BOOL(2);
  if (PG_NARGS() > 3 && !PG_ARGISNULL(3))
    upper_inc = PG_GETARG_BOOL(3);
  ensure_not_empty_array(array);
  int count;
  TInstant **instants = (TInstant **) temporalarr_extract(array, &count);
  Temporal *result = (Temporal *) tgeometry_seq_make(
    tgeometryinst_geom(instants[0]), (const TInstant **) instants,
    count, lower_inc, upper_inc, interp, NORMALIZE);
  pfree(instants);
  PG_FREE_IF_COPY(array, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_seqset_constructor);
/**
 * Construct a temporal sequence set value from the array of temporal
 * sequence values
 */
PGDLLEXPORT Datum
Tgeometry_seqset_constructor(PG_FUNCTION_ARGS)
{
  ArrayType *array = PG_GETARG_ARRAYTYPE_P(0);
  ensure_not_empty_array(array);
  int count;
  TSequence **sequences = (TSequence **) temporalarr_extract(array, &count);
  Temporal *result = (Temporal *) tgeometry_seqset_make(
    tgeometry_seq_geom(sequences[0]), (const TSequence **) sequences,
    count, NORMALIZE);
  pfree(sequences);
  PG_FREE_IF_COPY(array, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_seqset_constructor_gaps);
/**
 * @ingroup mobilitydb_temporal_constructor
 * @brief Construct a temporal sequence set from an array of temporal instants
 * accounting for potential gaps
 * @note The SQL function is not strict
 * @sqlfunc tint_seqset_gaps(), tfloat_seqset_gaps(), tgeompoint_seqset_gaps()
 */
PGDLLEXPORT Datum
Tgeometry_seqset_constructor_gaps(PG_FUNCTION_ARGS)
{
  if (PG_ARGISNULL(0))
    PG_RETURN_NULL();

  ArrayType *array = PG_GETARG_ARRAYTYPE_P(0);
  ensure_not_empty_array(array);
  double maxdist = -1.0;
  Interval *maxt = NULL;
  meosType temptype = oid_type(get_fn_expr_rettype(fcinfo->flinfo));
  interpType interp = temptype_continuous(temptype) ? LINEAR : STEP;
  if (PG_NARGS() > 1 && !PG_ARGISNULL(1))
    maxt = PG_GETARG_INTERVAL_P(1);
  if (PG_NARGS() > 2 && !PG_ARGISNULL(2))
    maxdist = PG_GETARG_FLOAT8(2);
  if (PG_NARGS() > 3 && !PG_ARGISNULL(3))
  {
    text *interp_txt = PG_GETARG_TEXT_P(3);
    char *interp_str = text2cstring(interp_txt);
    interp = interp_from_string(interp_str);
    pfree(interp_str);
  }
  /* Store fcinfo into a global variable */
  /* Needed for the distance function for temporal geographic points */
  store_fcinfo(fcinfo);
  /* Extract the array of instants */
  int count;
  TInstant **instants = (TInstant **) temporalarr_extract(array, &count);
  TSequenceSet *result = tgeometry_seqset_make_gaps(
    tgeometryinst_geom(instants[0]), (const TInstant **) instants,
    count, interp, maxt, maxdist);
  pfree(instants);
  PG_FREE_IF_COPY(array, 0);
  PG_RETURN_POINTER(result);
}

/*****************************************************************************
 * Casting functions
 *****************************************************************************/

PG_FUNCTION_INFO_V1(Tgeometry_to_tgeompoint);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the end instant of a temporal value
 * @sqlfunc endInstant()
 */
PGDLLEXPORT Datum
Tgeometry_to_tgeompoint(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  Temporal *result = tgeometry_to_tgeompoint(temp);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_POINTER(result);
}

/*****************************************************************************
 * Accessor functions
 *****************************************************************************/

PG_FUNCTION_INFO_V1(Tgeometry_start_instant);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the start instant of a temporal value
 * @sqlfunc startInstant()
 */
PGDLLEXPORT Datum
Tgeometry_start_instant(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  TInstant *result = tgeometry_start_instant(temp);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_end_instant);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the end instant of a temporal value
 * @sqlfunc endInstant()
 */
PGDLLEXPORT Datum
Tgeometry_end_instant(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  TInstant *result = tgeometry_end_instant(temp);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_instant_n);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the n-th instant of a temporal value
 * @sqlfunc instantN()
 */
PGDLLEXPORT Datum
Tgeometry_instant_n(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  int n = PG_GETARG_INT32(1); /* Assume 1-based */
  TInstant *result = tgeometry_instant_n(temp, n);
  PG_FREE_IF_COPY(temp, 0);
  if (! result)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_instants);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the distinct instants of a temporal value as an array
 * @sqlfunc instants()
 */
PGDLLEXPORT Datum
Tgeometry_instants(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  int count;
  TInstant **instants = tgeometry_instants(temp, &count);
  ArrayType *result = temporalarr_to_array((const Temporal **) instants,
    count);
  pfree_array((void **) instants, count);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_ARRAYTYPE_P(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_start_sequence);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the start sequence of a temporal sequence (set)
 * @sqlfunc startSequence()
 */
PGDLLEXPORT Datum
Tgeometry_start_sequence(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  TSequence *result = tgeometry_start_sequence(temp);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_end_sequence);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the end sequence of a temporal sequence (set)
 * @sqlfunc endSequence()
 */
PGDLLEXPORT Datum
Tgeometry_end_sequence(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  TSequence *result = tgeometry_end_sequence(temp);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_sequence_n);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the n-th sequence of a temporal sequence (set)
 * @sqlfunc sequenceN()
 */
PGDLLEXPORT Datum
Tgeometry_sequence_n(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  int n = PG_GETARG_INT32(1); /* Assume 1-based */
  TSequence *result = tgeometry_sequence_n(temp, n);
  PG_FREE_IF_COPY(temp, 0);
  if (! result)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_sequences);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the sequences of a temporal sequence (set) as an array
 * @sqlfunc sequences()
 */
PGDLLEXPORT Datum
Tgeometry_sequences(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  int count;
  TSequence **sequences = tgeometry_sequences(temp, &count);
  ArrayType *result = temporalarr_to_array((const Temporal **) sequences,
    count);
  pfree_array((void **) sequences, count);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_ARRAYTYPE_P(result);
}

PG_FUNCTION_INFO_V1(Tgeometry_segments);
/**
 * @ingroup mobilitydb_tgeometry_accessor
 * @brief Return the segments of a temporal sequence (set) as an array
 * @sqlfunc segments()
 */
PGDLLEXPORT Datum
Tgeometry_segments(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  int count;
  TSequence **segments = tgeometry_segments(temp, &count);
  ArrayType *result = temporalarr_to_array((const Temporal **) segments,
    count);
  pfree_array((void **) segments, count);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_ARRAYTYPE_P(result);
}

/*****************************************************************************
 * Restriction Functions
 *****************************************************************************/

PG_FUNCTION_INFO_V1(Tgeometry_value_at_timestamp);
/**
 * @ingroup mobilitydb_temporal_accessor
 * @brief Return the base value of a temporal value at the timestamp
 * @sqlfunc valueAtTimestamp()
 */
PGDLLEXPORT Datum
Tgeometry_value_at_timestamp(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL_P(0);
  TimestampTz t = PG_GETARG_TIMESTAMPTZ(1);
  Datum result;
  bool found = tgeometry_value_at_timestamp(temp, t, true, &result);
  PG_FREE_IF_COPY(temp, 0);
  if (! found)
    PG_RETURN_NULL();
  PG_RETURN_DATUM(result);
}

/*****************************************************************************/
