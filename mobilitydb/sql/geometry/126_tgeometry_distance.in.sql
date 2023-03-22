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
 * tgeometry_distance.sql
 * Distance functions for rigid temporal geometries.
 */

/*****************************************************************************
 * Distance functions
 *****************************************************************************/

CREATE FUNCTION temporal_distance(tgeometry, geometry)
  RETURNS tfloat
  AS 'MODULE_PATHNAME', 'Distance_tgeometry_geo'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_distance(geometry, tgeometry)
  RETURNS tfloat
  AS 'MODULE_PATHNAME', 'Distance_geo_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_distance(tgeometry, tgeompoint)
  RETURNS tfloat
  AS 'MODULE_PATHNAME', 'Distance_tgeometry_tgeompoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_distance(tgeompoint, tgeometry)
  RETURNS tfloat
  AS 'MODULE_PATHNAME', 'Distance_tgeompoint_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_distance(tgeometry, tgeometry)
  RETURNS tfloat
  AS 'MODULE_PATHNAME', 'Distance_tgeometry_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR <-> (
  PROCEDURE = temporal_distance,
  LEFTARG = tgeometry, RIGHTARG = geometry,
  COMMUTATOR = <->
);
CREATE OPERATOR <-> (
  PROCEDURE = temporal_distance,
  LEFTARG = geometry, RIGHTARG = tgeometry,
  COMMUTATOR = <->
);
CREATE OPERATOR <-> (
  PROCEDURE = temporal_distance,
  LEFTARG = tgeometry, RIGHTARG = tgeompoint,
  COMMUTATOR = <->
);
CREATE OPERATOR <-> (
  PROCEDURE = temporal_distance,
  LEFTARG = tgeompoint, RIGHTARG = tgeometry,
  COMMUTATOR = <->
);
CREATE OPERATOR <-> (
  PROCEDURE = temporal_distance,
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  COMMUTATOR = <->
);

/*****************************************************************************
 * Nearest approach instant/distance and shortest line functions
 *****************************************************************************/

CREATE FUNCTION NearestApproachInstant(tgeometry, geometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'NAI_tgeometry_geo'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION NearestApproachInstant(geometry, tgeometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'NAI_geo_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION NearestApproachInstant(tgeometry, tgeompoint)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'NAI_tgeometry_tgeompoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
/* TODO: Maybe change output type here.
 * Currently we return a tgeometry instant
 * even if the left argument is a tgeompoint */
CREATE FUNCTION NearestApproachInstant(tgeompoint, tgeometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'NAI_tgeompoint_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION NearestApproachInstant(tgeometry, tgeometry)
  RETURNS tgeometry
  AS 'MODULE_PATHNAME', 'NAI_tgeometry_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION nearestApproachDistance(tgeometry, geometry)
  RETURNS float
  AS 'MODULE_PATHNAME', 'NAD_tgeometry_geo'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION nearestApproachDistance(geometry, tgeometry)
  RETURNS float
  AS 'MODULE_PATHNAME', 'NAD_geo_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION nearestApproachDistance(tgeometry, stbox)
  RETURNS float
  AS 'MODULE_PATHNAME', 'NAD_tgeometry_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION nearestApproachDistance(stbox, tgeometry)
  RETURNS float
  AS 'MODULE_PATHNAME', 'NAD_stbox_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION nearestApproachDistance(tgeometry, tgeompoint)
  RETURNS float
  AS 'MODULE_PATHNAME', 'NAD_tgeometry_tgeompoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION nearestApproachDistance(tgeompoint, tgeometry)
  RETURNS float
  AS 'MODULE_PATHNAME', 'NAD_tgeompoint_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION nearestApproachDistance(tgeometry, tgeometry)
  RETURNS float
  AS 'MODULE_PATHNAME', 'NAD_tgeometry_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR |=| (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = nearestApproachDistance,
  COMMUTATOR = '|=|'
);
CREATE OPERATOR |=| (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = nearestApproachDistance,
  COMMUTATOR = '|=|'
);
CREATE OPERATOR |=| (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = nearestApproachDistance,
  COMMUTATOR = '|=|'
);
CREATE OPERATOR |=| (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = nearestApproachDistance,
  COMMUTATOR = '|=|'
);
CREATE OPERATOR |=| (
  LEFTARG = tgeometry, RIGHTARG = tgeompoint,
  PROCEDURE = nearestApproachDistance,
  COMMUTATOR = '|=|'
);
CREATE OPERATOR |=| (
  LEFTARG = tgeompoint, RIGHTARG = tgeometry,
  PROCEDURE = nearestApproachDistance,
  COMMUTATOR = '|=|'
);
CREATE OPERATOR |=| (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = nearestApproachDistance,
  COMMUTATOR = '|=|'
);

CREATE FUNCTION shortestLine(tgeometry, geometry)
  RETURNS geometry
  AS 'MODULE_PATHNAME', 'Shortestline_tgeometry_geo'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION shortestLine(geometry, tgeometry)
  RETURNS geometry
  AS 'MODULE_PATHNAME', 'Shortestline_geo_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION shortestLine(tgeometry, tgeompoint)
  RETURNS geometry
  AS 'MODULE_PATHNAME', 'Shortestline_tgeometry_tgeompoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION shortestLine(tgeompoint, tgeometry)
  RETURNS geometry
  AS 'MODULE_PATHNAME', 'Shortestline_tgeompoint_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION shortestLine(tgeometry, tgeometry)
  RETURNS geometry
  AS 'MODULE_PATHNAME', 'Shortestline_tgeometry_tgeometry'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

/*****************************************************************************/
