/*****************************************************************************
 *
 * tgeo_spatialfuncs.sql
 *    Geospatial functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

CREATE FUNCTION trajectory(tgeometry)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'tgeo_trajectory_centre'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION trajectory(tgeometry, tgeompoint, integer DEFAULT 0)
  RETURNS tgeompoint
  AS 'MODULE_PATHNAME', 'tgeo_trajectory'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/******************************************************************************/
