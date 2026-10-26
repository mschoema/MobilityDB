-------------------------------------------------------------------------------
--
-- This MobilityDB code is provided under The PostgreSQL License.
-- Copyright (c) 2016-2026, Université libre de Bruxelles and MobilityDB
-- contributors
--
-- MobilityDB includes portions of PostGIS version 3 source code released
-- under the GNU General Public License (GPLv2 or later).
-- Copyright (c) 2001-2026, PostGIS contributors
--
-- Permission to use, copy, modify, and distribute this software and its
-- documentation for any purpose, without fee, and without a written
-- agreement is hereby granted, provided that the above copyright notice and
-- this paragraph and the following two paragraphs appear in all copies.
--
-- IN NO EVENT SHALL UNIVERSITE LIBRE DE BRUXELLES BE LIABLE TO ANY PARTY FOR
-- DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
-- LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
-- EVEN IF UNIVERSITE LIBRE DE BRUXELLES HAS BEEN ADVISED OF THE POSSIBILITY
-- OF SUCH DAMAGE.
--
-- UNIVERSITE LIBRE DE BRUXELLES SPECIFICALLY DISCLAIMS ANY WARRANTIES,
-- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
-- AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON
-- AN "AS IS" BASIS, AND UNIVERSITE LIBRE DE BRUXELLES HAS NO OBLIGATIONS TO
-- PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
--
-------------------------------------------------------------------------------

\getenv srcdir MOBILITYDB_SOURCE_DIR

CREATE TABLE tbl_ais_instant(k integer PRIMARY KEY, mmsi integer,
  t timestamptz, geom geometry(Point, 4326), sog double precision,
  heading double precision);
\set filename :srcdir '/mobilitydb/test/geo/data/tbl_ais_instant.data'
COPY tbl_ais_instant (k, mmsi, t, geom, sog, heading) FROM :'filename';

CREATE TABLE tbl_ais_tgeompoint(k integer PRIMARY KEY, mmsi integer,
  temp tgeompoint);
\set filename :srcdir '/mobilitydb/test/geo/data/tbl_ais_tgeompoint.data'
COPY tbl_ais_tgeompoint (k, mmsi, temp) FROM :'filename';

CREATE TABLE tbl_ais_tgeometry(k integer PRIMARY KEY, mmsi integer,
  temp tgeometry);
\set filename :srcdir '/mobilitydb/test/geo/data/tbl_ais_tgeometry.data'
COPY tbl_ais_tgeometry (k, mmsi, temp) FROM :'filename';

ANALYZE tbl_ais_instant, tbl_ais_tgeompoint, tbl_ais_tgeometry;
