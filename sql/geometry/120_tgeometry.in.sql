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
 * tgeometry.sql
 * Basic functions for rigid temporal geometries.
 */

CREATE TYPE tgeometry;

/* temporal, base, contbase, box */
SELECT register_temporal_type('tgeometry', 'pose', true, 'stbox');

/******************************************************************************
 * Input/Output
 ******************************************************************************/

CREATE FUNCTION tgeometry_in(cstring, oid, integer)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME'
  LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION tgeometry_out(tgeometry)
  RETURNS cstring
  AS 'MODULE_PATHNAME'
  LANGUAGE C IMMUTABLE STRICT;

/*CREATE FUNCTION tgeometry_recv(internal)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME'
  LANGUAGE C IMMUTABLE STRICT;*/

/*CREATE FUNCTION tgeometry_send(tgeometry)
  RETURNS bytea
  AS 'MODULE_PATHNAME'
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
  AS 'MODULE_PATHNAME', 'tgeometryinst_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometry_instset(tgeometry[])
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'tgeometry_instset_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometry_seq(tgeometry[], lower_inc boolean DEFAULT true,
    upper_inc boolean DEFAULT true, linear boolean DEFAULT true)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'tgeometry_seq_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometry_seqset(tgeometry[])
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'tgeometry_seqset_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/******************************************************************************
 * Casting
 ******************************************************************************/

CREATE FUNCTION period(tgeometry)
  RETURNS period
  AS 'MODULE_PATHNAME', 'temporal_to_period'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Casting CANNOT be implicit to avoid ambiguity
CREATE CAST (tgeometry AS period) WITH FUNCTION period(tgeometry);

/******************************************************************************
 * Transformations
 ******************************************************************************/

CREATE FUNCTION tgeometry_inst(tgeometry)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'temporal_to_tinstant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeometry_instset(tgeometry)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'temporal_to_tinstantset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeometry_seq(tgeometry)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'temporal_to_tsequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeometry_seqset(tgeometry)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'temporal_to_tsequenceset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometry_instset(geometry, timestampset)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'tinstantset_from_base'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeometry_seq(geometry, period, linear boolean DEFAULT true)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'tsequence_from_base'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION tgeometry_seqset(geometry, periodset, linear boolean DEFAULT true)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'tsequenceset_from_base'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION appendInstant(tgeometry, tgeometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'temporal_append_tinstant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Function is not strict
CREATE FUNCTION merge(tgeometry, tgeometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'temporal_merge'
  LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION merge(tgeometry[])
  RETURNS tgeometry
AS 'MODULE_PATHNAME', 'temporal_merge_array'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;


/******************************************************************************/
