/*****************************************************************************
 *
 * tgeo.sql
 *    Basic functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

CREATE TYPE tgeometry;

/* temporal, base, contbase, box */
SELECT register_temporal_type('tgeometry', 'geometry', true, 'stbox');

/******************************************************************************
 * Input/Output
 ******************************************************************************/

CREATE FUNCTION tgeometry_in(cstring, oid, integer)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'tgeo_in'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_out(tgeometry)
  RETURNS cstring
  AS 'MODULE_PATHNAME'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE TYPE tgeometry (
  internallength = variable,
  input = tgeometry_in,
  output = temporal_out,
  storage = extended,
  alignment = double
);

/******************************************************************************
 * Constructors
 ******************************************************************************/

CREATE FUNCTION tgeometryinst(geometry, timestamptz)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'tgeoinst_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometryi(tgeometry[])
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'tinstantset_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometryseq(tgeometry[], lower_inc boolean DEFAULT true,
  upper_inc boolean DEFAULT true, linear boolean DEFAULT true)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'tlinearseq_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometrys(tgeometry[])
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'tsequenceset_constructor'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/******************************************************************************
 * Transformations
 ******************************************************************************/

CREATE FUNCTION tgeometryinst(tgeometry)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'temporal_to_tinstant'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometryi(tgeometry)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'temporal_to_tinstantset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometryseq(tgeometry)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'temporal_to_tsequence'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tgeometrys(tgeometry)
  RETURNS tgeometry AS 'MODULE_PATHNAME', 'temporal_to_tsequenceset'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/******************************************************************************
 * Functions
 ******************************************************************************/

CREATE FUNCTION getValue(tgeometry)
  RETURNS geometry
  AS 'MODULE_PATHNAME', 'tinstant_get_value'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION getTimestamp(tgeometry)
  RETURNS timestamptz
  AS 'MODULE_PATHNAME', 'tinstant_timestamp'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/******************************************************************************/

