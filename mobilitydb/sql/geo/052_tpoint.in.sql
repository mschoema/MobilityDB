/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 * Copyright (c) 2016-2025, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2025, PostGIS contributors
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
 * @file
 * @brief Basic functions for temporal geometry/geography points
 */

CREATE TYPE tgeompoint;
CREATE TYPE tgeogpoint;

/******************************************************************************
 * Input/Output
 ******************************************************************************/

CREATE FUNCTION tgeompoint_in(cstring, oid, integer)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tpoint_in'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_out(tgeompoint)
  RETURNS cstring
  AS 'MODULE_PATHNAME', 'Temporal_out'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeompoint_recv(internal, oid, integer)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_recv'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_send(tgeompoint)
  RETURNS bytea
  AS 'MODULE_PATHNAME', 'Temporal_send'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeompoint_typmod_in(cstring[])
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Tgeompoint_typmod_in'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE TYPE tgeompoint (
  internallength = variable,
  input = tgeompoint_in,
  output = temporal_out,
  send = temporal_send,
  receive = tgeompoint_recv,
  typmod_in = tgeompoint_typmod_in,
  typmod_out = tspatial_typmod_out,
  storage = extended,
  alignment = double,
  analyze = tspatial_analyze
);

CREATE FUNCTION tgeogpoint_in(cstring, oid, integer)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Tpoint_in'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_out(tgeogpoint)
  RETURNS cstring
  AS 'MODULE_PATHNAME', 'Temporal_out'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeogpoint_recv(internal, oid, integer)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_recv'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_send(tgeogpoint)
  RETURNS bytea
  AS 'MODULE_PATHNAME', 'Temporal_send'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeogpoint_typmod_in(cstring[])
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Tgeogpoint_typmod_in'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE TYPE tgeogpoint (
  internallength = variable,
  input = tgeogpoint_in,
  output = temporal_out,
  send = temporal_send,
  receive = tgeogpoint_recv,
  typmod_in = tgeogpoint_typmod_in,
  typmod_out = tspatial_typmod_out,
  storage = extended,
  alignment = double,
  analyze = tspatial_analyze
);

-- Special cast for enforcing the typmod restrictions
CREATE FUNCTION tgeompoint(tgeompoint, integer)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tspatial_enforce_typmod'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeogpoint(tgeogpoint, integer)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Tspatial_enforce_typmod'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (tgeompoint AS tgeompoint) WITH FUNCTION tgeompoint(tgeompoint, integer) AS IMPLICIT;
CREATE CAST (tgeogpoint AS tgeogpoint) WITH FUNCTION tgeogpoint(tgeogpoint, integer) AS IMPLICIT;

/******************************************************************************
 * Constructors
 ******************************************************************************/

CREATE FUNCTION tgeompoint(geometry(Point), timestamptz)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tpointinst_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeogpoint(geography(Point), timestamptz)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Tpointinst_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeompoint(geometry, tstzset)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tsequence_from_base_tstzset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeogpoint(geography, tstzset)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Tsequence_from_base_tstzset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeompoint(geometry, tstzspan, text DEFAULT 'linear')
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tsequence_from_base_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeogpoint(geography, tstzspan, text DEFAULT 'linear')
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Tsequence_from_base_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeompoint(geometry, tstzspanset, text DEFAULT 'linear')
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tsequenceset_from_base_tstzspanset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeogpoint(geography, tstzspanset, text DEFAULT 'linear')
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tsequenceset_from_base_tstzspanset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/******************************************************************************/

CREATE FUNCTION tgeompointSeq(tgeompoint[], text DEFAULT 'linear',
    lower_inc boolean DEFAULT true, upper_inc boolean DEFAULT true)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tsequence_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeogpointSeq(tgeogpoint[], text DEFAULT 'linear',
    lower_inc boolean DEFAULT true, upper_inc boolean DEFAULT true)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Tsequence_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeompointSeqSet(tgeompoint[])
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tsequenceset_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeogpointSeqSet(tgeogpoint[])
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Tsequenceset_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- The function is not strict
CREATE FUNCTION tgeompointSeqSetGaps(tgeompoint[], maxt interval DEFAULT NULL,
    maxdist float DEFAULT NULL, text DEFAULT 'linear')
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tsequenceset_constructor_gaps'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;
CREATE FUNCTION tgeogpointSeqSetGaps(tgeogpoint[], maxt interval DEFAULT NULL,
    maxdist float DEFAULT NULL, text DEFAULT 'linear')
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Tsequenceset_constructor_gaps'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;

/******************************************************************************
 * Conversions
 ******************************************************************************/

CREATE FUNCTION timeSpan(tgeompoint)
  RETURNS tstzspan
  AS 'MODULE_PATHNAME', 'Temporal_to_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION timeSpan(tgeogpoint)
  RETURNS tstzspan
  AS 'MODULE_PATHNAME', 'Temporal_to_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (tgeompoint AS tstzspan) WITH FUNCTION timeSpan(tgeompoint);
CREATE CAST (tgeogpoint AS tstzspan) WITH FUNCTION timeSpan(tgeogpoint);

/******************************************************************************
 * Transformations
 ******************************************************************************/

CREATE FUNCTION tgeompointInst(tgeompoint)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_to_tinstant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- The function is not strict
CREATE FUNCTION tgeompointSeq(tgeompoint, text)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_to_tsequence'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;
-- The function is not strict
CREATE FUNCTION tgeompointSeq(tgeompoint)
  RETURNS tgeompoint
  AS 'SELECT @extschema@.tgeompointSeq($1, NULL)'
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
-- The function is not strict
CREATE FUNCTION tgeompointSeqSet(tgeompoint, text)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_to_tsequenceset'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;
-- The function is not strict
CREATE FUNCTION tgeompointSeqSet(tgeompoint)
  RETURNS tgeompoint
  AS 'SELECT @extschema@.tgeompointSeqSet($1, NULL)'
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION tgeogpointInst(tgeogpoint)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_to_tinstant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- The function is not strict
CREATE FUNCTION tgeogpointSeq(tgeogpoint, text)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_to_tsequence'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;
-- The function is not strict
CREATE FUNCTION tgeogpointSeq(tgeogpoint)
  RETURNS tgeogpoint
  AS 'SELECT @extschema@.tgeogpointSeq($1, NULL)'
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
-- The function is not strict
CREATE FUNCTION tgeogpointSeqSet(tgeogpoint, text)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_to_tsequenceset'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;
-- The function is not strict
CREATE FUNCTION tgeogpointSeqSet(tgeogpoint)
  RETURNS tgeogpoint
  AS 'SELECT @extschema@.tgeogpointSeqSet($1, NULL)'
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION setInterp(tgeompoint, text)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_set_interp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION setInterp(tgeogpoint, text)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_set_interp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION appendInstant(tgeompoint, tgeompoint)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_append_tinstant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION appendInstant(tgeogpoint, tgeogpoint)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_append_tinstant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION appendSequence(tgeompoint, tgeompoint)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_append_tsequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION appendSequence(tgeogpoint, tgeogpoint)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_append_tsequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- The function is not strict
CREATE FUNCTION merge(tgeompoint, tgeompoint)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_merge'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;
CREATE FUNCTION merge(tgeogpoint, tgeogpoint)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_merge'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION merge(tgeompoint[])
  RETURNS tgeompoint
AS 'MODULE_PATHNAME', 'Temporal_merge_array'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION merge(tgeogpoint[])
  RETURNS tgeogpoint
AS 'MODULE_PATHNAME', 'Temporal_merge_array'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/******************************************************************************
 * Accessor Functions
 ******************************************************************************/

CREATE FUNCTION tempSubtype(tgeompoint)
  RETURNS text
  AS 'MODULE_PATHNAME', 'Temporal_subtype'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tempSubtype(tgeogpoint)
  RETURNS text
  AS 'MODULE_PATHNAME', 'Temporal_subtype'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION interp(tgeompoint)
  RETURNS text
  AS 'MODULE_PATHNAME', 'Temporal_interp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION interp(tgeogpoint)
  RETURNS text
  AS 'MODULE_PATHNAME', 'Temporal_interp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION memSize(tgeompoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_mem_size'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION memSize(tgeogpoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_mem_size'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- value is a reserved word in SQL
CREATE FUNCTION getValue(tgeompoint)
  RETURNS geometry(Point)
  AS 'MODULE_PATHNAME', 'Tinstant_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION getValue(tgeogpoint)
  RETURNS geography(Point)
  AS 'MODULE_PATHNAME', 'Tinstant_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- There is no getValues() function for temporal points,
-- it is called trajectory() for temporal points

CREATE FUNCTION getTimestamp(tgeompoint)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Tinstant_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION getTimestamp(tgeogpoint)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Tinstant_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION valueSet(tgeompoint)
  RETURNS geomset
  AS 'MODULE_PATHNAME', 'Temporal_valueset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION valueSet(tgeogpoint)
  RETURNS geogset
  AS 'MODULE_PATHNAME', 'Temporal_valueset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION valueN(tgeompoint, integer)
  RETURNS geometry
  AS 'MODULE_PATHNAME', 'Temporal_value_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION valueN(tgeogpoint, integer)
  RETURNS geography
  AS 'MODULE_PATHNAME', 'Temporal_value_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- time is a reserved word in SQL
CREATE FUNCTION getTime(tgeompoint)
  RETURNS tstzspanset
  AS 'MODULE_PATHNAME', 'Temporal_time'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION getTime(tgeogpoint)
  RETURNS tstzspanset
  AS 'MODULE_PATHNAME', 'Temporal_time'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION startValue(tgeompoint)
  RETURNS geometry(Point)
  AS 'MODULE_PATHNAME', 'Temporal_start_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION startValue(tgeogpoint)
  RETURNS geography(Point)
  AS 'MODULE_PATHNAME', 'Temporal_start_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION endValue(tgeompoint)
  RETURNS geometry(Point)
  AS 'MODULE_PATHNAME', 'Temporal_end_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION endValue(tgeogpoint)
  RETURNS geography(Point)
  AS 'MODULE_PATHNAME', 'Temporal_end_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION duration(tgeompoint, boundspan boolean DEFAULT FALSE)
  RETURNS interval
  AS 'MODULE_PATHNAME', 'Temporal_duration'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION duration(tgeogpoint, boundspan boolean DEFAULT FALSE)
  RETURNS interval
  AS 'MODULE_PATHNAME', 'Temporal_duration'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION lowerInc(tgeompoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_lower_inc'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION lowerInc(tgeogpoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_lower_inc'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION upperInc(tgeompoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_upper_inc'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION upperInc(tgeogpoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_upper_inc'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION numInstants(tgeompoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_num_instants'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION numInstants(tgeogpoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_num_instants'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION startInstant(tgeompoint)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_start_instant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION startInstant(tgeogpoint)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_start_instant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION endInstant(tgeompoint)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_end_instant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION endInstant(tgeogpoint)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_end_instant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION instantN(tgeompoint, integer)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_instant_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION instantN(tgeogpoint, integer)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_instant_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION instants(tgeompoint)
  RETURNS tgeompoint[]
  AS 'MODULE_PATHNAME', 'Temporal_instants'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION instants(tgeogpoint)
  RETURNS tgeogpoint[]
  AS 'MODULE_PATHNAME', 'Temporal_instants'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION numTimestamps(tgeompoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_num_timestamps'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION numTimestamps(tgeogpoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_num_timestamps'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION startTimestamp(tgeompoint)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Temporal_start_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION startTimestamp(tgeogpoint)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Temporal_start_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION endTimestamp(tgeompoint)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Temporal_end_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION endTimestamp(tgeogpoint)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Temporal_end_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION timestampN(tgeompoint, integer)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Temporal_timestamptz_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION timestampN(tgeogpoint, integer)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Temporal_timestamptz_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION timestamps(tgeompoint)
  RETURNS timestamptz[]
  AS 'MODULE_PATHNAME', 'Temporal_timestamps'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION timestamps(tgeogpoint)
  RETURNS timestamptz[]
  AS 'MODULE_PATHNAME', 'Temporal_timestamps'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION numSequences(tgeompoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_num_sequences'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION numSequences(tgeogpoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_num_sequences'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION startSequence(tgeompoint)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_start_sequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION startSequence(tgeogpoint)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_start_sequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION endSequence(tgeompoint)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_end_sequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION endSequence(tgeogpoint)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_end_sequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sequenceN(tgeompoint, integer)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_sequence_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION sequenceN(tgeogpoint, integer)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_sequence_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sequences(tgeompoint)
  RETURNS tgeompoint[]
  AS 'MODULE_PATHNAME', 'Temporal_sequences'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION sequences(tgeogpoint)
  RETURNS tgeogpoint[]
  AS 'MODULE_PATHNAME', 'Temporal_sequences'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION segments(tgeompoint)
  RETURNS tgeompoint[]
  AS 'MODULE_PATHNAME', 'Temporal_segments'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION segments(tgeogpoint)
  RETURNS tgeogpoint[]
  AS 'MODULE_PATHNAME', 'Temporal_segments'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Shift and scale functions
 *****************************************************************************/

CREATE FUNCTION shiftTime(tgeompoint, interval)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_shift_time'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION shiftTime(tgeogpoint, interval)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_shift_time'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION scaleTime(tgeompoint, interval)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_scale_time'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION scaleTime(tgeogpoint, interval)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_scale_time'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION shiftScaleTime(tgeompoint, interval, interval)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_shift_scale_time'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION shiftScaleTime(tgeogpoint, interval, interval)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_shift_scale_time'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tprecision(tgeompoint, duration interval,
  origin timestamptz DEFAULT '2000-01-03')
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_tprecision'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tprecision(tgeogpoint, duration interval,
  origin timestamptz DEFAULT '2000-01-03')
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_tprecision'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tsample(tgeompoint, duration interval,
  origin timestamptz DEFAULT '2000-01-03', interp text DEFAULT 'discrete')
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_tsample'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tsample(tgeogpoint, duration interval,
  origin timestamptz DEFAULT '2000-01-03', interp text DEFAULT 'discrete')
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_tsample'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Unnest Function
 *****************************************************************************/

CREATE TYPE geom_tstzspanset AS (
  value geometry,
  time tstzspanset
);
CREATE TYPE geog_tstzspanset AS (
  value geography,
  time tstzspanset
);

CREATE FUNCTION unnest(tgeompoint)
  RETURNS SETOF geom_tstzspanset
  AS 'MODULE_PATHNAME', 'Temporal_unnest'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION unnest(tgeogpoint)
  RETURNS SETOF geog_tstzspanset
  AS 'MODULE_PATHNAME', 'Temporal_unnest'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Restriction Functions
 *****************************************************************************/

CREATE FUNCTION atValues(tgeompoint, geometry(Point))
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_at_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION atValues(tgeogpoint, geography(Point))
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_at_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION minusValues(tgeompoint, geometry(Point))
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION minusValues(tgeogpoint, geography(Point))
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION atValues(tgeompoint, geomset)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_at_values'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION atValues(tgeogpoint, geogset)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_at_values'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION minusValues(tgeompoint, geomset)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_values'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION minusValues(tgeogpoint, geogset)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_values'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION atTime(tgeompoint, timestamptz)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_at_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION atTime(tgeogpoint, timestamptz)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_at_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION minusTime(tgeompoint, timestamptz)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION minusTime(tgeogpoint, timestamptz)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION valueAtTimestamp(tgeompoint, timestamptz)
  RETURNS geometry(Point)
  AS 'MODULE_PATHNAME', 'Temporal_value_at_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION valueAtTimestamp(tgeogpoint, timestamptz)
  RETURNS geography(Point)
  AS 'MODULE_PATHNAME', 'Temporal_value_at_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION atTime(tgeompoint, tstzset)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_at_tstzset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION atTime(tgeogpoint, tstzset)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_at_tstzset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION minusTime(tgeompoint, tstzset)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_tstzset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION minusTime(tgeogpoint, tstzset)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_tstzset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION atTime(tgeompoint, tstzspan)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_at_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION atTime(tgeogpoint, tstzspan)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_at_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION minusTime(tgeompoint, tstzspan)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION minusTime(tgeogpoint, tstzspan)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION atTime(tgeompoint, tstzspanset)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_at_tstzspanset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION atTime(tgeogpoint, tstzspanset)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_at_tstzspanset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION minusTime(tgeompoint, tstzspanset)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_tstzspanset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION minusTime(tgeogpoint, tstzspanset)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_minus_tstzspanset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Modification Functions
 *****************************************************************************/

CREATE FUNCTION insert(tgeompoint, tgeompoint, connect boolean DEFAULT TRUE)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_update'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION insert(tgeogpoint, tgeompoint, connect boolean DEFAULT TRUE)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_update'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION update(tgeompoint, tgeompoint, connect boolean DEFAULT TRUE)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_update'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION update(tgeogpoint, tgeogpoint, connect boolean DEFAULT TRUE)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_update'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION deleteTime(tgeompoint, timestamptz, connect boolean DEFAULT TRUE)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_delete_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION deleteTime(tgeogpoint, timestamptz, connect boolean DEFAULT TRUE)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_delete_timestamptz'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION deleteTime(tgeompoint, tstzset, connect boolean DEFAULT TRUE)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_delete_tstzset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION deleteTime(tgeogpoint, tstzset, connect boolean DEFAULT TRUE)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_delete_tstzset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION deleteTime(tgeompoint, tstzspan, connect boolean DEFAULT TRUE)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_delete_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION deleteTime(tgeogpoint, tstzspan, connect boolean DEFAULT TRUE)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_delete_tstzspan'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION deleteTime(tgeompoint, tstzspanset, connect boolean DEFAULT TRUE)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_delete_tstzspanset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION deleteTime(tgeogpoint, tstzspanset, connect boolean DEFAULT TRUE)
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_delete_tstzspanset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Stops Function
 *****************************************************************************/

CREATE FUNCTION stops(tgeompoint, maxdist float DEFAULT 0.0,
    minduration interval DEFAULT '0 minutes')
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_stops'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION stops(tgeogpoint, maxdist float DEFAULT 0.0,
    minduration interval DEFAULT '0 minutes')
  RETURNS tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_stops'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;


/******************************************************************************
 * Multidimensional tiling
 ******************************************************************************/

CREATE TYPE time_tgeompoint AS (
  time timestamptz,
  temp tgeompoint
);
CREATE TYPE time_tgeogpoint AS (
  time timestamptz,
  temp tgeogpoint
);

CREATE FUNCTION timeSplit(tgeompoint, bin_width interval,
    origin timestamptz DEFAULT '2000-01-03')
  RETURNS setof time_tgeompoint
  AS 'MODULE_PATHNAME', 'Temporal_time_split'
  LANGUAGE C IMMUTABLE PARALLEL SAFE STRICT;
CREATE FUNCTION timeSplit(tgeogpoint, bin_width interval,
    origin timestamptz DEFAULT '2000-01-03')
  RETURNS setof time_tgeogpoint
  AS 'MODULE_PATHNAME', 'Temporal_time_split'
  LANGUAGE C IMMUTABLE PARALLEL SAFE STRICT;

/******************************************************************************
 * Comparison functions and B-tree indexing
 ******************************************************************************/

CREATE FUNCTION temporal_lt(tgeompoint, tgeompoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_lt'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_le(tgeompoint, tgeompoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_le'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_eq(tgeompoint, tgeompoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_eq'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_ne(tgeompoint, tgeompoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_ne'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_ge(tgeompoint, tgeompoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_ge'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_gt(tgeompoint, tgeompoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_gt'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_cmp(tgeompoint, tgeompoint)
  RETURNS int4
  AS 'MODULE_PATHNAME', 'Temporal_cmp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR < (
  LEFTARG = tgeompoint, RIGHTARG = tgeompoint,
  PROCEDURE = temporal_lt,
  COMMUTATOR = >, NEGATOR = >=,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR <= (
  LEFTARG = tgeompoint, RIGHTARG = tgeompoint,
  PROCEDURE = temporal_le,
  COMMUTATOR = >=, NEGATOR = >,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR = (
  LEFTARG = tgeompoint, RIGHTARG = tgeompoint,
  PROCEDURE = temporal_eq,
  COMMUTATOR = =, NEGATOR = <>,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR <> (
  LEFTARG = tgeompoint, RIGHTARG = tgeompoint,
  PROCEDURE = temporal_ne,
  COMMUTATOR = <>, NEGATOR = =,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR >= (
  LEFTARG = tgeompoint, RIGHTARG = tgeompoint,
  PROCEDURE = temporal_ge,
  COMMUTATOR = <=, NEGATOR = <,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR > (
  LEFTARG = tgeompoint, RIGHTARG = tgeompoint,
  PROCEDURE = temporal_gt,
  COMMUTATOR = <, NEGATOR = <=,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);

CREATE OPERATOR CLASS tgeompoint_btree_ops
  DEFAULT FOR TYPE tgeompoint USING btree AS
    OPERATOR  1  <,
    OPERATOR  2  <=,
    OPERATOR  3  =,
    OPERATOR  4  >=,
    OPERATOR  5  >,
    FUNCTION  1  temporal_cmp(tgeompoint, tgeompoint);

/******************************************************************************/

CREATE FUNCTION temporal_lt(tgeogpoint, tgeogpoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_lt'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_le(tgeogpoint, tgeogpoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_le'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_eq(tgeogpoint, tgeogpoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_eq'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_ne(tgeogpoint, tgeogpoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_ne'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_ge(tgeogpoint, tgeogpoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_ge'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_gt(tgeogpoint, tgeogpoint)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'Temporal_gt'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_cmp(tgeogpoint, tgeogpoint)
  RETURNS int4
  AS 'MODULE_PATHNAME', 'Temporal_cmp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR < (
  LEFTARG = tgeogpoint, RIGHTARG = tgeogpoint,
  PROCEDURE = temporal_lt,
  COMMUTATOR = >,  NEGATOR = >=,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR <= (
  LEFTARG = tgeogpoint, RIGHTARG = tgeogpoint,
  PROCEDURE = temporal_le,
  COMMUTATOR = >=, NEGATOR = >,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR = (
  LEFTARG = tgeogpoint, RIGHTARG = tgeogpoint,
  PROCEDURE = temporal_eq,
  COMMUTATOR = =, NEGATOR = <>,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR <> (
  LEFTARG = tgeogpoint, RIGHTARG = tgeogpoint,
  PROCEDURE = temporal_ne,
  COMMUTATOR = <>, NEGATOR = =,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR >= (
  LEFTARG = tgeogpoint, RIGHTARG = tgeogpoint,
  PROCEDURE = temporal_ge,
  COMMUTATOR = <=, NEGATOR = <,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);
CREATE OPERATOR > (
  LEFTARG = tgeogpoint, RIGHTARG = tgeogpoint,
  PROCEDURE = temporal_gt,
  COMMUTATOR = <, NEGATOR = <=,
  RESTRICT = tspatial_sel, JOIN = tspatial_joinsel
);

CREATE OPERATOR CLASS tgeogpoint_btree_ops
  DEFAULT FOR TYPE tgeogpoint USING btree AS
    OPERATOR  1  <,
    OPERATOR  2  <=,
    OPERATOR  3  =,
    OPERATOR  4  >=,
    OPERATOR  5  >,
    FUNCTION  1  temporal_cmp(tgeogpoint, tgeogpoint);

/******************************************************************************/

CREATE FUNCTION temporal_hash(tgeompoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_hash'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_hash(tgeogpoint)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_hash'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR CLASS tgeompoint_hash_ops
  DEFAULT FOR TYPE tgeompoint USING hash AS
    OPERATOR    1   = ,
    FUNCTION    1   temporal_hash(tgeompoint);
CREATE OPERATOR CLASS tgeogpoint_hash_ops
  DEFAULT FOR TYPE tgeogpoint USING hash AS
    OPERATOR    1   = ,
    FUNCTION    1   temporal_hash(tgeogpoint);

/******************************************************************************/

