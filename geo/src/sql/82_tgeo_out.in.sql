/*****************************************************************************
 *
 * tgeo_out.sql
 *    Output of temporal geometries in WKT and EWKT format
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/


/******************************************************************************
 * Output as region
 ******************************************************************************/

CREATE FUNCTION asText(tgeometry)
    RETURNS text
    AS 'MODULE_PATHNAME', 'tpoint_as_text'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION asText(tgeometry[])
    RETURNS text[]
    AS 'MODULE_PATHNAME', 'tpointarr_as_text'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION asEWKT(tgeometry)
    RETURNS text
    AS 'MODULE_PATHNAME', 'tpoint_as_ewkt'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION asEWKT(tgeometry[])
    RETURNS text[]
    AS 'MODULE_PATHNAME', 'tpointarr_as_ewkt'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************/
