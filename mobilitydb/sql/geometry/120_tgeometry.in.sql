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
 * tgeometry.sql
 * Basic functions for rigid temporal geometries.
 */

CREATE TYPE tgeometry;

/******************************************************************************
 * Input/Output
 ******************************************************************************/

CREATE FUNCTION tgeometry_in(cstring, oid, integer)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_in'
  LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION tgeometry_out(tgeometry)
  RETURNS cstring
  AS 'MODULE_PATHNAME', 'Tgeometry_out'
  LANGUAGE C IMMUTABLE STRICT;

/*CREATE FUNCTION tgeometry_recv(internal)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_recv'
  LANGUAGE C IMMUTABLE STRICT;*/

/*CREATE FUNCTION tgeometry_send(tgeometry)
  RETURNS bytea
  AS 'MODULE_PATHNAME', 'Tgeometry_send'
  LANGUAGE C IMMUTABLE STRICT;*/

CREATE TYPE tgeometry (
  internallength = variable,
  input = tgeometry_in,
  output = tgeometry_out,
--receive = tgeometry_recv,
--send = tgeometry_send,
  storage = extended,
  alignment = double
);

/******************************************************************************
 * Constructors
 ******************************************************************************/

CREATE FUNCTION tgeometry_inst(geometry, pose, timestamptz)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometryinst_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometry_seq(tgeometry[], text DEFAULT 'linear',
    lower_inc boolean DEFAULT true, upper_inc boolean DEFAULT true)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_seq_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometry_seqset(tgeometry[])
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_seqset_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- The function is not strict
CREATE FUNCTION tgeometry_seqset_gaps(tgeometry[], maxt interval DEFAULT NULL,
    maxdist float DEFAULT NULL, text DEFAULT 'linear')
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_seqset_constructor_gaps'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;

/******************************************************************************
 * Casting
 ******************************************************************************/

CREATE FUNCTION timeSpan(tgeometry)
  RETURNS tstzspan
  AS 'MODULE_PATHNAME', 'Temporal_to_period'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Casting CANNOT be implicit to avoid ambiguity
CREATE CAST (tgeometry AS tstzspan) WITH FUNCTION timeSpan(tgeometry);

CREATE FUNCTION tgeompoint(tgeometry)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'Tgeometry_to_tgeompoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Casting CANNOT be implicit to avoid ambiguity
CREATE CAST (tgeometry AS tgeompoint) WITH FUNCTION tgeompoint(tgeometry);

/******************************************************************************
 * Transformations
 ******************************************************************************/

-- CREATE FUNCTION tgeometry_inst(tgeometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_to_tinstant'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- CREATE FUNCTION tgeometry_discseq(tgeometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_to_tdiscseq'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- CREATE FUNCTION tgeometry_contseq(tgeometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_to_tcontseq'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- CREATE FUNCTION tgeometry_seqset(tgeometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_to_tsequenceset'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION toLinear(tgeometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Tempstep_to_templinear'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION appendInstant(tgeometry, tgeometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_append_tinstant'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION appendSequence(tgeometry, tgeometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_append_tsequence'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- -- The function is not strict
-- CREATE FUNCTION merge(tgeometry, tgeometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_merge'
--   LANGUAGE C IMMUTABLE PARALLEL SAFE;

-- CREATE FUNCTION merge(tgeometry[])
--   RETURNS tgeometry
-- AS 'MODULE_PATHNAME', 'Temporal_merge_array'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;


/******************************************************************************
 * Accessor Functions
 ******************************************************************************/

CREATE FUNCTION tempSubtype(tgeometry)
  RETURNS text
  AS 'MODULE_PATHNAME', 'Temporal_subtype'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION interp(tgeometry)
  RETURNS text
  AS 'MODULE_PATHNAME', 'Temporal_interp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION memSize(tgeometry)
  RETURNS int
  AS 'MODULE_PATHNAME', 'Temporal_mem_size'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- value is a reserved word in SQL
-- CREATE FUNCTION getValue(tgeometry)
--   RETURNS geometry
--   AS 'MODULE_PATHNAME', 'Tinstant_get_value'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION getValues(tgeometry)
--   RETURNS geomset
--   AS 'MODULE_PATHNAME', 'Temporal_values'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- time is a reserved word in SQL
CREATE FUNCTION getTime(tgeometry)
  RETURNS tstzspanset
  AS 'MODULE_PATHNAME', 'Temporal_time'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION getTimestamp(tgeometry)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Tinstant_timestamp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION startValue(tgeometry)
--   RETURNS geometry
--   AS 'MODULE_PATHNAME', 'Temporal_start_value'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION endValue(tgeometry)
--   RETURNS geometry
--   AS 'MODULE_PATHNAME', 'Temporal_end_value'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION duration(tgeometry, boundspan boolean DEFAULT FALSE)
  RETURNS interval
  AS 'MODULE_PATHNAME', 'Temporal_duration'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION numInstants(tgeometry)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_num_instants'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION startInstant(tgeometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_start_instant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION endInstant(tgeometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_end_instant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION instantN(tgeometry, integer)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_instant_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION instants(tgeometry)
  RETURNS tgeometry[]
  AS 'MODULE_PATHNAME', 'Tgeometry_instants'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION numTimestamps(tgeometry)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_num_timestamps'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION startTimestamp(tgeometry)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Temporal_start_timestamp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION endTimestamp(tgeometry)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Temporal_end_timestamp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION timestampN(tgeometry, integer)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'Temporal_timestamp_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION timestamps(tgeometry)
  RETURNS timestamptz[]
  AS 'MODULE_PATHNAME', 'Temporal_timestamps'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION numSequences(tgeometry)
  RETURNS integer
  AS 'MODULE_PATHNAME', 'Temporal_num_sequences'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION startSequence(tgeometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_start_sequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION endSequence(tgeometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_end_sequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sequenceN(tgeometry, integer)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'Tgeometry_sequence_n'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sequences(tgeometry)
  RETURNS tgeometry[]
  AS 'MODULE_PATHNAME', 'Tgeometry_sequences'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION segments(tgeometry)
  RETURNS tgeometry[]
  AS 'MODULE_PATHNAME', 'Tgeometry_segments'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Shift and tscale functions
 *****************************************************************************/

-- CREATE FUNCTION shift(tgeometry, interval)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_shift'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION tscale(tgeometry, interval)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_tscale'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION shiftTscale(tgeometry, interval, interval)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_shift_tscale'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION tprecision(tgeometry, duration interval,
--   origin timestamptz DEFAULT '2000-01-03')
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_tprecision'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION tsample(tgeometry, duration interval,
--   origin timestamptz DEFAULT '2000-01-03')
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_tsample'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Unnest Function
 *****************************************************************************/

-- CREATE FUNCTION unnest(tgeometry)
--   RETURNS SETOF geom_periodset
--   AS 'MODULE_PATHNAME', 'Temporal_unnest'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Index Support Function
 *****************************************************************************/

-- CREATE FUNCTION tpoint_supportfn(internal)
--   RETURNS internal
--   AS 'MODULE_PATHNAME', 'Tpoint_supportfn'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Ever/Always Comparison Functions
 *****************************************************************************/

-- CREATE FUNCTION ever_eq(tgeometry, geometry)
--   RETURNS boolean
--   AS 'MODULE_PATHNAME', 'Tpoint_ever_eq'
--   SUPPORT tpoint_supportfn
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE OPERATOR ?= (
--   LEFTARG = tgeometry, RIGHTARG = geometry,
--   PROCEDURE = ever_eq,
--   NEGATOR = %<>,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );

-- CREATE FUNCTION always_eq(tgeometry, geometry)
--   RETURNS boolean
--   AS 'MODULE_PATHNAME', 'Tpoint_always_eq'
--   SUPPORT tpoint_supportfn
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE OPERATOR %= (
--   LEFTARG = tgeogpoint, RIGHTARG = geography(Point),
--   PROCEDURE = always_eq,
--   NEGATOR = ?<>,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );

-- CREATE FUNCTION ever_ne(tgeometry, geometry)
--   RETURNS boolean
--   AS 'MODULE_PATHNAME', 'Tpoint_ever_ne'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE OPERATOR ?<> (
--   LEFTARG = tgeometry, RIGHTARG = geometry,
--   PROCEDURE = ever_ne,
--   NEGATOR = %=,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );

-- CREATE FUNCTION always_ne(tgeometry, geometry)
--   RETURNS boolean
--   AS 'MODULE_PATHNAME', 'Tpoint_always_ne'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE OPERATOR %<> (
--   LEFTARG = tgeometry, RIGHTARG = geometry,
--   PROCEDURE = always_ne,
--   NEGATOR = ?=,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );

/*****************************************************************************
 * Restriction Functions
 *****************************************************************************/

-- CREATE FUNCTION atValues(tgeometry, geometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_at_value'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION minusValues(tgeometry, geometry)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_minus_value'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION atValues(tgeometry, geomset)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_at_values'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION minusValues(tgeometry, geomset)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_minus_values'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION atTime(tgeometry, timestamptz)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_at_timestamp'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION minusTime(tgeometry, timestamptz)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_minus_timestamp'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION valueAtTimestamp(tgeometry, timestamptz)
  RETURNS geometry
  AS 'MODULE_PATHNAME', 'Tgeometry_value_at_timestamp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION atTime(tgeometry, tstzset)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_at_timestampset'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION minusTime(tgeometry, tstzset)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_minus_timestampset'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION atTime(tgeometry, tstzspan)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_at_period'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION minusTime(tgeometry, tstzspan)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_minus_period'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION atTime(tgeometry, tstzspanset)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_at_periodset'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION minusTime(tgeometry, tstzspanset)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_minus_periodset'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Modification Functions
 *****************************************************************************/

-- CREATE FUNCTION insert(tgeometry, tgeometry, connect boolean DEFAULT TRUE)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_update'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION update(tgeometry, tgeometry, connect boolean DEFAULT TRUE)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_update'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION deleteTime(tgeometry, timestamptz, connect boolean DEFAULT TRUE)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_delete_timestamp'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION deleteTime(tgeometry, tstzset, connect boolean DEFAULT TRUE)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_delete_timestampset'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION deleteTime(tgeometry, tstzspan, connect boolean DEFAULT TRUE)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_delete_period'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE FUNCTION deleteTime(tgeometry, tstzspanset, connect boolean DEFAULT TRUE)
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_delete_periodset'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************
 * Stops Function
 *****************************************************************************/

-- CREATE FUNCTION stops(tgeometry, maxdist float DEFAULT 0.0,
--     minduration interval DEFAULT '0 minutes')
--   RETURNS tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_stops'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;


/******************************************************************************
 * Multidimensional tiling
 ******************************************************************************/

-- CREATE TYPE time_tgeometry AS (
--   time timestamptz,
--   temp tgeometry
-- );

-- CREATE FUNCTION timeSplit(tgeometry, bucket_width interval,
--     origin timestamptz DEFAULT '2000-01-03')
--   RETURNS setof time_tgeometry
--   AS 'MODULE_PATHNAME', 'Temporal_time_split'
--   LANGUAGE C IMMUTABLE PARALLEL SAFE STRICT;

/******************************************************************************
 * Comparison functions and B-tree indexing
 ******************************************************************************/

-- CREATE FUNCTION temporal_lt(tgeometry, tgeometry)
--   RETURNS bool
--   AS 'MODULE_PATHNAME', 'Temporal_lt'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- CREATE FUNCTION temporal_le(tgeometry, tgeometry)
--   RETURNS bool
--   AS 'MODULE_PATHNAME', 'Temporal_le'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- CREATE FUNCTION temporal_eq(tgeometry, tgeometry)
--   RETURNS bool
--   AS 'MODULE_PATHNAME', 'Temporal_eq'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- CREATE FUNCTION temporal_ne(tgeometry, tgeometry)
--   RETURNS bool
--   AS 'MODULE_PATHNAME', 'Temporal_ne'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- CREATE FUNCTION temporal_ge(tgeometry, tgeometry)
--   RETURNS bool
--   AS 'MODULE_PATHNAME', 'Temporal_ge'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- CREATE FUNCTION temporal_gt(tgeometry, tgeometry)
--   RETURNS bool
--   AS 'MODULE_PATHNAME', 'Temporal_gt'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- CREATE FUNCTION temporal_cmp(tgeometry, tgeometry)
--   RETURNS int4
--   AS 'MODULE_PATHNAME', 'Temporal_cmp'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE OPERATOR < (
--   LEFTARG = tgeometry, RIGHTARG = tgeometry,
--   PROCEDURE = temporal_lt,
--   COMMUTATOR = >, NEGATOR = >=,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );
-- CREATE OPERATOR <= (
--   LEFTARG = tgeometry, RIGHTARG = tgeometry,
--   PROCEDURE = temporal_le,
--   COMMUTATOR = >=, NEGATOR = >,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );
-- CREATE OPERATOR = (
--   LEFTARG = tgeometry, RIGHTARG = tgeometry,
--   PROCEDURE = temporal_eq,
--   COMMUTATOR = =, NEGATOR = <>,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );
-- CREATE OPERATOR <> (
--   LEFTARG = tgeometry, RIGHTARG = tgeometry,
--   PROCEDURE = temporal_ne,
--   COMMUTATOR = <>, NEGATOR = =,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );
-- CREATE OPERATOR >= (
--   LEFTARG = tgeometry, RIGHTARG = tgeometry,
--   PROCEDURE = temporal_ge,
--   COMMUTATOR = <=, NEGATOR = <,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );
-- CREATE OPERATOR > (
--   LEFTARG = tgeometry, RIGHTARG = tgeometry,
--   PROCEDURE = temporal_gt,
--   COMMUTATOR = <, NEGATOR = <=,
--   RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
-- );

-- CREATE OPERATOR CLASS tgeometry_btree_ops
--   DEFAULT FOR TYPE tgeometry USING btree AS
--     OPERATOR  1  <,
--     OPERATOR  2  <=,
--     OPERATOR  3  =,
--     OPERATOR  4  >=,
--     OPERATOR  5  >,
--     FUNCTION  1  temporal_cmp(tgeometry, tgeometry);

/******************************************************************************/

-- CREATE FUNCTION temporal_hash(tgeometry)
--   RETURNS integer
--   AS 'MODULE_PATHNAME', 'Temporal_hash'
--   LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- CREATE OPERATOR CLASS tgeometry_hash_ops
--   DEFAULT FOR TYPE tgeometry USING hash AS
--     OPERATOR    1   = ,
--     FUNCTION    1   temporal_hash(tgeometry);

/******************************************************************************/
