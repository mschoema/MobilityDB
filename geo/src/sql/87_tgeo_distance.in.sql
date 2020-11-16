/*****************************************************************************
 *
 * tgeo_distance.sql
 *    Distance functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

/*****************************************************************************
 * Nearest approach distance functions
 *****************************************************************************/

CREATE FUNCTION nearestApproachDistance(geometry, tgeometry)
  RETURNS float
  AS 'MODULE_PATHNAME', 'NAD_geo_tgeo'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION nearestApproachDistance(tgeometry, geometry)
  RETURNS float
  AS 'MODULE_PATHNAME', 'NAD_tgeo_geo'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR |=| (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = nearestApproachDistance,
  COMMUTATOR = '|=|'
);
CREATE OPERATOR |=| (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = nearestApproachDistance,
  COMMUTATOR = '|=|'
);

/******************************************************************************/
