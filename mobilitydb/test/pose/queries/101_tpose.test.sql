-------------------------------------------------------------------------------
--
-- This MobilityDB code is provided under The PostgreSQL License.
-- Copyright (c) 2016-2023, Université libre de Bruxelles and MobilityDB
-- contributors
--
-- MobilityDB includes portions of PostGIS version 3 source code released
-- under the GNU General Public License (GPLv2 or later).
-- Copyright (c) 2001-2023, PostGIS contributors
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

-------------------------------------------------------------------------------
-- Input/output functions
-------------------------------------------------------------------------------

-- Temporal instant

SELECT asText(tpose 'Pose(1, 1, 1)@2012-01-01 08:00:00');
SELECT asText(tpose 'Pose Z (1, 1, 1, 1, 0, 0, 0)@2012-01-01 08:00:00');
SELECT asText(tpose '  Pose(2, 2, 2)@2012-01-01 08:00:00  ');
/* Errors */
SELECT tpose 'TRUE@2012-01-01 08:00:00';
SELECT tpose 'Pose(1, 1, 1)@2000-01-01 00:00:00+01 ,';

-------------------------------------------------------------------------------

-- Temporal instant set

SELECT asText(tpose ' { Pose(1, 1, 1)@2001-01-01 08:00:00 , Pose(2, 2, 2)@2001-01-01 08:05:00 , Pose(3, 3, 3)@2001-01-01 08:06:00 } ');
SELECT asText(tpose '{Pose(1, 1, 1)@2001-01-01 08:00:00,Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00}');
/* Errors */
SELECT tpose '{Pose(1, 1, 1)@2001-01-01 08:00:00,PoseZ(2, 2, 2, 0, 0, 1, 0)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00}';
SELECT tpose '{Pose(1, 1, 1)@2001-01-01 08:00:00,Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00]';

-------------------------------------------------------------------------------

-- Temporal sequence

SELECT asText(tpose ' [ Pose(1, 1, 1)@2001-01-01 08:00:00 , Pose(2, 2, 2)@2001-01-01 08:05:00 , Pose(3, 3, 3)@2001-01-01 08:06:00 ] ');
SELECT asText(tpose '[Pose(1, 1, 1)@2001-01-01 08:00:00,Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00]');
SELECT asText(tpose '[PoseZ(1, 1, 1, 0, 1, 0, 0)@2001-01-01, PoseZ(2, 2, 2, 0, 0, 1, 0)@2001-01-02, PoseZ(3, 3, 3, 0, 0, 0, 1)@2001-01-03]');
/* Errors */
SELECT tpose '[Pose(1, 1, 1)@2001-01-01 08:00:00,PoseZ(2, 2, 2, 0, 0, 1, 0)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00]';
SELECT tpose '[Pose(1, 1, 1)@2001-01-01 08:00:00,Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00}';
SELECT tpose '[Pose(1, 1, 1)@2001-01-01 08:00:00,Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00] xxx';

-------------------------------------------------------------------------------

-- Temporal sequence set

SELECT asText(tpose '  { [ Pose(1, 1, 1)@2001-01-01 08:00:00 , Pose(2, 2, 2)@2001-01-01 08:05:00 , Pose(3, 3, 3)@2001-01-01 08:06:00 ],
 [ Pose(1, 1, 1)@2001-01-01 09:00:00 , Pose(2, 2, 2)@2001-01-01 09:05:00 , Pose(1, 1, 1)@2001-01-01 09:06:00 ] } ');
SELECT asText(tpose '{[Pose(1, 1, 1)@2001-01-01 08:00:00,Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00],
 [Pose(1, 1, 1)@2001-01-01 09:00:00,Pose(2, 2, 2)@2001-01-01 09:05:00,Pose(1, 1, 1)@2001-01-01 09:06:00]}');
/* Errors */
SELECT tpose '{[Pose(1, 1, 1)@2001-01-01 08:00:00],[PoseZ(2, 2, 2, 0, 0, 1, 0)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00]}';
SELECT tpose '{[Pose(1, 1, 1)@2001-01-01 08:00:00],[PoseZ(2, 2, 2, 0, 0, 1, 0)@2001-01-01 08:05:00,PoseZ(3, 3, 3, 0, 0, 0, 1)@2001-01-01 08:06:00]}';
SELECT tpose '{[Pose(1, 1, 1)@2001-01-01 08:00:00],[Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00]';
SELECT tpose '{[Pose(1, 1, 1)@2001-01-01 08:00:00],[Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00]} xxx';

-------------------------------------------------------------------------------
-- SRID
-------------------------------------------------------------------------------

-- SELECT asEWKT(tpose 'SRID=4326;[Point(0 1)@2000-01-01, Point(0 1)@2000-01-02]');
-- SELECT asEWKT(tpose '[SRID=4326;Point(0 1)@2000-01-01, Point(0 1)@2000-01-02]');
-- SELECT asEWKT(tpose '[SRID=4326;Point(0 1)@2000-01-01, SRID=4326;Point(0 1)@2000-01-02]');

-- SELECT asEWKT(tpose 'SRID=4326;{[Point(0 1)@2000-01-01], [Point(0 1)@2000-01-02]}');
-- SELECT asEWKT(tpose '{[SRID=4326;Point(0 1)@2000-01-01], [Point(0 1)@2000-01-02]}');
-- SELECT asEWKT(tpose '{[SRID=4326;Point(0 1)@2000-01-01], [SRID=4326;Point(0 1)@2000-01-02]}');

-- /* Errors */
-- SELECT tpose '{SRID=5676;Point(0 1)@2000-01-01, SRID=3812;Point(0 1)@2000-01-02}';
-- SELECT tpose 'SRID=5676;{Point(0 1)@2000-01-01, SRID=3812;Point(0 1)@2000-01-02}';
-- SELECT tpose '[SRID=5676;Point(0 1)@2000-01-01, SRID=3812;Point(0 1)@2000-01-02]';
-- SELECT tpose 'SRID=5676;[Point(0 1)@2000-01-01, SRID=3812;Point(0 1)@2000-01-02]';
-- SELECT tpose '{[SRID=5676;Point(0 1)@2000-01-01], [SRID=3812;Point(0 1)@2000-01-02]';
-- SELECT tpose 'SRID=5676;{[Point(0 1)@2000-01-01], [SRID=3812;Point(0 1)@2000-01-02]}';
-- SELECT tpose 'SRID=5676;{Pose(1, 1, 1)@2001-01-01 08:00:00,SRID=3812;Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00}';
-- SELECT tpose 'SRID=5676;[Pose(1, 1, 1)@2001-01-01 08:00:00,SRID=3812;Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00]';
-- SELECT tpose 'SRID=5676;{[Pose(1, 1, 1)@2001-01-01 08:00:00],[SRID=3812;Pose(2, 2, 2)@2001-01-01 08:05:00,Pose(3, 3, 3)@2001-01-01 08:06:00]';

-------------------------------------------------------------------------------
-- typmod
-------------------------------------------------------------------------------

-- SELECT format_type(oid, -1) FROM (SELECT oid FROM pg_type WHERE typname = 'tpose') t;
-- SELECT format_type(oid, tpose_typmod_in(ARRAY[cstring 'Instant','PoseZ','5676']))
-- FROM (SELECT oid FROM pg_type WHERE typname = 'tpose') t;
-- /* Errors */
-- SELECT tpose_typmod_in(ARRAY[cstring 'Instant', NULL,'5676']);
-- SELECT tpose_typmod_in(ARRAY[[cstring 'Instant'],[cstring 'PointZ'],[cstring '5676']]);
-- SELECT asEWKT(tpose('') 'Point(0 1)@2000-01-01');

-- SELECT asEWKT(tpose(Instant) 'Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(Instant) 'Point(0 1 1)@2000-01-01');
-- SELECT asEWKT(tpose(Instant, Point) 'Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(Instant, PointZ) 'Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(Point, 4326) 'SRID=4326;Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(PointZ, 4326) 'SRID=4326;Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(Instant, Point, 4326) 'SRID=4326;Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(Instant, PointZ, 4326) 'SRID=4326;Point(0 1 0)@2000-01-01');

-- SELECT asEWKT(tpose(Sequence) '{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence) '{Point(0 1 1)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, Point) '{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, PointZ) '{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(Point, 4326) 'SRID=4326;{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(PointZ, 4326) 'SRID=4326;{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, Point, 4326) 'SRID=4326;{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, PointZ, 4326) 'SRID=4326;{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');

-- SELECT asEWKT(tpose(Sequence) '[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence) '[Point(0 1 1)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, Point) '[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, PointZ) '[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(Point, 4326) 'SRID=4326;[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(PointZ, 4326) 'SRID=4326;[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, Point, 4326) 'SRID=4326;[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, PointZ, 4326) 'SRID=4326;[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');

-- SELECT asEWKT(tpose(SequenceSet) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02], [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02], [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, Point) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02], [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, PointZ) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02], [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(Point, 4326) 'SRID=4326;{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02], [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(PointZ, 4326) 'SRID=4326;{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02], [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, Point, 4326) 'SRID=4326;{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02], [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, PointZ, 4326) 'SRID=4326;{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02], [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');

-- SELECT asEWKT(tpose(Point) 'Pose(0, 0, 0)@2000-01-01');

-- /* Errors */
-- SELECT tpose(Instant,PointZ,5676,1234) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(Instan,PointZ,5676) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(Instant,PointZZ,5676) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(Instant,Point,5676) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(Instant,Polygon,5676) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(PointZZ,5676) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(Polygon,5676) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(Instant,PointZZ) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(Instant,Polygon) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(PointZZ) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(Polygon) 'SRID=5676;Point(0 0 0)@2000-01-01';
-- SELECT tpose(1, 2) '{Pose(1, 1, 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}';
-- /* Errors */
-- SELECT asEWKT(tpose(Instant, PointZ) 'Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(Instant, Point, 4326) 'Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(Instant, Point, 4326) 'SRID=5434;Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(Sequence, Point) 'Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(Sequence, PointZ) 'Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(Sequence, Point) 'Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(Sequence, PointZ) 'Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(SequenceSet, Point) 'Point(0 1)@2000-01-01');
-- SELECT asEWKT(tpose(SequenceSet, PointZ) 'Point(0 1)@2000-01-01');
-- /* Errors */
-- SELECT asEWKT(tpose(Instant, Point) 'Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(Instant, PointZ, 4326) 'Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(Instant, PointZ, 4326) 'SRID=5434;Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(Sequence, Point) 'Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(Sequence, PointZ) 'Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(Sequence, Point) 'Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(Sequence, PointZ) 'Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(SequenceSet, Point) 'Point(0 1 0)@2000-01-01');
-- SELECT asEWKT(tpose(SequenceSet, PointZ) 'Point(0 1 0)@2000-01-01');
-- /* Errors */
-- SELECT asEWKT(tpose(Instant, Point) '{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(Instant, PointZ) '{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, Point, 4326) '{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, Point, 4326) 'SRID=5434;{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, PointZ) '{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, PointZ) '{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(SequenceSet, Point) '{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- SELECT asEWKT(tpose(SequenceSet, PointZ) '{Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}');
-- /* Errors */
-- SELECT asEWKT(tpose(Instant, Point) '{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(Instant, PointZ) '{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, Point) '{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, PointZ, 4326) '{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, PointZ, 4326) 'SRID=5434;{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(Sequence, Point) '{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(SequenceSet, Point) '{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- SELECT asEWKT(tpose(SequenceSet, PointZ) '{Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02}');
-- /* Errors */
-- SELECT asEWKT(tpose(Instant, Point) '[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(Instant, PointZ) '[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, PointZ) '[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, Point, 4326) '[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, Point, 4326) 'SRID=5434;[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, PointZ) '[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(SequenceSet, Point) '[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- SELECT asEWKT(tpose(SequenceSet, PointZ) '[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]');
-- /* Errors */
-- SELECT asEWKT(tpose(Instant, Point) '[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(Instant, PointZ) '[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, Point) '[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, Point) '[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, PointZ, 4326) '[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(Sequence, PointZ, 4326) 'SRID=5434;[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(SequenceSet, Point) '[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- SELECT asEWKT(tpose(SequenceSet, PointZ) '[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02]');
-- /* Errors */
-- SELECT asEWKT(tpose(Instant, Point) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02],
--   [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(Instant, PointZ) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02],
--   [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(Sequence, Point) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02],
--   [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(Sequence, PointZ) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02],
--   [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(Sequence, Point) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02],
--   [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(Sequence, PointZ) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02],
--   [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, Point, 4326) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02],
--   [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, Point, 4326) 'SRID=5434;{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02],
--   [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, PointZ) '{[Point(0 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02],
--   [Point(0 1)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}');
-- /* Errors */
-- SELECT asEWKT(tpose(Instant, Point) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02],
--   [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(Instant, PointZ) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02],
--   [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(Sequence, Point) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02],
--   [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(Sequence, PointZ) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02],
--   [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(Sequence, Point) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02],
--   [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(Sequence, PointZ) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02],
--   [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, Point) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02],
--   [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, PointZ, 4326) '{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02],
--   [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');
-- SELECT asEWKT(tpose(SequenceSet, PointZ, 4326) 'SRID=5434;{[Point(0 1 0)@2000-01-01, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02],
--   [Point(0 1 0)@2000-01-03, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04]}');

-------------------------------------------------------------------------------
-- Constructor functions
-------------------------------------------------------------------------------

SELECT asText(tpose_inst(Pose(1, 1, 1), timestamptz '2012-01-01 08:00:00'));
-- NULL
SELECT asText(tpose_inst(NULL, timestamptz '2012-01-01 08:00:00'));


SELECT asText(tpose_seq(Pose(1, 1, 1), tstzset '{2012-01-01, 2012-01-02, 2012-01-03}'));
-- NULL
SELECT asText(tpose_seq(NULL, tstzset '{2012-01-01, 2012-01-02, 2012-01-03}'));

SELECT asText(tpose_seq(Pose(1, 1, 1), tstzspan '[2012-01-01, 2012-01-03]'));
SELECT asText(tpose_seq(Pose(1, 1, 1), tstzspan '[2012-01-01, 2012-01-03]', 'step'));
-- NULL
SELECT asText(tpose_seq(NULL, tstzspan '[2012-01-01, 2012-01-03]'));

SELECT asText(tpose_seqset(Pose(1, 1, 1), tstzspanset '{[2012-01-01, 2012-01-03]}'));
SELECT asText(tpose_seqset(Pose(1, 1, 1), tstzspanset '{[2012-01-01, 2012-01-03]}', 'step'));
-- NULL
SELECT asText(tpose_seqset(NULL, tstzspanset '{[2012-01-01, 2012-01-03]}'));


-------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS tbl_tposeinst_test;
-- CREATE TABLE tbl_tposeinst_test AS SELECT k, unnest(instants(seq)) AS inst FROM tbl_tpose_seq;
-- WITH temp AS (
--   SELECT numSequences(tpose_seqset_gaps(array_agg(inst ORDER BY getTime(inst)), '5 minutes'::interval, 5.0))
--   FROM tbl_tposeinst_test GROUP BY k )
-- SELECT MAX(numSequences) FROM temp;
-- DROP TABLE tbl_tposeinst_test;

-- DROP TABLE IF EXISTS tbl_tgeogpointinst_test;
-- CREATE TABLE tbl_tgeogpointinst_test AS SELECT k, unnest(instants(seq)) AS inst FROM tbl_tgeogpoint_seq;
-- WITH temp AS (
--   SELECT numSequences(tgeogpoint_seqset_gaps(array_agg(inst ORDER BY getTime(inst)), '5 minutes'::interval, 5.0))
--   FROM tbl_tgeogpointinst_test GROUP BY k )
-- SELECT MAX(numSequences) FROM temp;
-- DROP TABLE tbl_tgeogpointinst_test;

-------------------------------------------------------------------------------

SELECT asText(tpose_seq(ARRAY[
tpose_inst(Pose(1, 1, 1), timestamptz '2012-01-01 08:00:00'),
tpose_inst(Pose(2, 2, 2), timestamptz '2012-01-01 08:10:00'),
tpose_inst(Pose(1, 1, 1), timestamptz '2012-01-01 08:20:00')
], 'discrete'));
/* Errors */
SELECT tpose_seq(ARRAY[tpose 'SRID=5676;Pose(1, 1, 1)@2001-01-01', 'SRID=4326;Pose(2, 2, 2)@2001-01-02'], 'discrete');
SELECT tpose_seq(ARRAY[tpose 'Pose(1, 1, 1)@2001-01-01', 'PoseZ(2, 2, 2, 0, 0, 1, 0)@2001-01-02'], 'discrete');

-------------------------------------------------------------------------------

SELECT asText(tpose_seq(ARRAY[
tpose_inst(Pose(1, 1, 1), timestamptz '2012-01-01 08:00:00'),
tpose_inst(Pose(2, 2, 2), timestamptz '2012-01-01 08:10:00'),
tpose_inst(Pose(1, 1, 1), timestamptz '2012-01-01 08:20:00')
]));
/* Errors */
SELECT tpose_seq(ARRAY[tpose 'SRID=5676;Pose(1, 1, 1)@2001-01-01', 'SRID=4326;Pose(2, 2, 2)@2001-01-02']);
SELECT tpose_seq(ARRAY[tpose 'Pose(1, 1, 1)@2001-01-01', 'PoseZ(2, 2, 2, 0, 0, 1, 0)@2001-01-02']);

-------------------------------------------------------------------------------

SELECT asText(tpose_seqset(ARRAY[
tpose_seq(ARRAY[
tpose_inst(Pose(1, 1, 1), timestamptz '2012-01-01 08:00:00'),
tpose_inst(Pose(2, 2, 2), timestamptz '2012-01-01 08:10:00'),
tpose_inst(Pose(1, 1, 1), timestamptz '2012-01-01 08:20:00')
]),
tpose_seq(ARRAY[
tpose_inst(Pose(1, 1, 1), timestamptz '2012-01-01 09:00:00'),
tpose_inst(Pose(2, 2, 2), timestamptz '2012-01-01 09:10:00'),
tpose_inst(Pose(1, 1, 1), timestamptz '2012-01-01 09:20:00')
])]));
/* Errors */
SELECT tpose_seqset(ARRAY[tpose '[SRID=5676;Pose(1, 1, 1)@2001-01-01]', '[SRID=4326;Pose(2, 2, 2)@2001-01-02]']);
SELECT tpose_seqset(ARRAY[tpose '[Pose(1, 1, 1)@2001-01-01]', '[PoseZ(2, 2, 2, 0, 0, 1, 0)@2001-01-02]']);

-------------------------------------------------------------------------------
-- Casting
-------------------------------------------------------------------------------

SELECT timeSpan(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT timeSpan(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT timeSpan(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT timeSpan(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

-------------------------------------------------------------------------------
-- Transformation functions
-------------------------------------------------------------------------------

SELECT asText(tpose_inst(tpose 'Pose(1, 1, 1)@2000-01-01'));
SELECT asText(setInterp(tpose 'Pose(1, 1, 1)@2000-01-01', 'discrete'));
SELECT asText(setInterp(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', 'discrete'));
SELECT asText(tpose_seq(tpose 'Pose(1, 1, 1)@2000-01-01'));
SELECT asText(tpose_seq(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]'));
SELECT asText(tpose_seqset(tpose 'Pose(1, 1, 1)@2000-01-01'));
SELECT asText(tpose_seqset(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}'));
SELECT asText(tpose_seqset(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]'));
SELECT asText(tpose_seqset(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}'));
/* Errors */
SELECT asText(tpose_inst(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}'));
SELECT asText(tpose_inst(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]'));
SELECT asText(tpose_inst(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}'));
SELECT asText(setInterp(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', 'discrete'));
SELECT asText(setInterp(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', 'discrete'));
SELECT asText(tpose_seq(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}'));

-------------------------------------------------------------------------------

SELECT asText(setInterp(tpose 'Interp=Step;[Pose(1, 1, 1)@2000-01-01]', 'linear'));
SELECT asText(setInterp(tpose 'Interp=Step;[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04]', 'linear'));
SELECT asText(setInterp(tpose 'Interp=Step;{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04], [Pose(3, 3, 3)@2000-01-05, Pose(4, 4, 0)@2000-01-06]}', 'linear'));

-------------------------------------------------------------------------------

SELECT asText(appendInstant(tpose 'Pose(1, 1, 1)@2000-01-01', tpose 'Pose(1, 1, 1)@2000-01-02'));
SELECT asText(appendInstant(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tpose 'Pose(1, 1, 1)@2000-01-04'));
SELECT asText(appendInstant(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tpose 'Pose(1, 1, 1)@2000-01-04'));
SELECT asText(appendInstant(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tpose 'Pose(1, 1, 1)@2000-01-06'));

SELECT asText(appendInstant(tpose 'PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-01', tpose 'PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02'));
SELECT asText(appendInstant(tpose '{PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-01, PoseZ(2, 2, 2, 0, 0, 1, 0)@2000-01-02, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-03}', tpose 'PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04'));
SELECT asText(appendInstant(tpose '[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-01, PoseZ(2, 2, 2, 0, 0, 1, 0)@2000-01-02, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-03]', tpose 'PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04'));
SELECT asText(appendInstant(tpose 'Interp=Step;[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-01, PoseZ(2, 2, 2, 0, 0, 1, 0)@2000-01-02, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-03]', tpose 'PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-04'));
SELECT asText(appendInstant(tpose '{[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-01, PoseZ(2, 2, 2, 0, 0, 1, 0)@2000-01-02, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-03],[PoseZ(3, 3, 3, 0, 0, 0, 1)@2000-01-04, PoseZ(3, 3, 3, 0, 0, 0, 1)@2000-01-05]}', tpose 'PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-06'));
SELECT asText(appendInstant(tpose 'Interp=Step;{[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-01, PoseZ(2, 2, 2, 0, 0, 1, 0)@2000-01-02, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-03],[PoseZ(3, 3, 3, 0, 0, 0, 1)@2000-01-04, PoseZ(3, 3, 3, 0, 0, 0, 1)@2000-01-05]}', tpose 'PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-06'));

SELECT asText(appendInstant(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', tpose 'Pose(3, 3, 3)@2000-01-03'));
SELECT asText(appendInstant(tpose 'Interp=Step;[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', 'Pose(3, 3, 3)@2000-01-04'));
/* Errors */
SELECT asText(appendInstant(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02}', tpose 'Pose(3, 3, 3)@2000-01-02'));
SELECT asText(appendInstant(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02}', tpose 'PoseZ(3, 3, 3, 0, 0, 0, 1)@2000-01-03'));
SELECT asText(appendInstant(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02}', tpose 'SRID=5676;Pose(3, 3, 3)@2000-01-03'));
SELECT asText(appendInstant(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', tpose 'Pose(3, 3, 3)@2000-01-02'));
SELECT asText(appendInstant(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', tpose 'PoseZ(3, 3, 3, 0, 0, 0, 1)@2000-01-03'));
SELECT asText(appendInstant(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', tpose 'SRID=5676;Pose(3, 3, 3)@2000-01-03'));

-------------------------------------------------------------------------------

SELECT asText(merge(tpose 'Pose(1, 1, 1)@2000-01-01', tpose 'Pose(1, 1, 1)@2000-01-02'));
SELECT asText(merge(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tpose '{Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05}'));
SELECT asText(merge(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tpose '{Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05}'));
SELECT asText(merge(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tpose '[Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05]'));
SELECT asText(merge(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tpose '[Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05]'));
SELECT asText(merge(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', tpose '{[Pose(1, 1, 1)@2000-01-05, Pose(2, 2, 2)@2000-01-06, Pose(1, 1, 1)@2000-01-07],[Pose(1, 1, 1)@2000-01-08, Pose(1, 1, 1)@2000-01-09]}'));
SELECT asText(merge(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', tpose '{[Pose(2, 2, 2)@2000-01-06, Pose(1, 1, 1)@2000-01-07],[Pose(1, 1, 1)@2000-01-08, Pose(1, 1, 1)@2000-01-09]}'));

SELECT asText(merge(tpose 'Pose(1, 1, 1)@2000-01-01', tpose 'Pose(1, 1, 1)@2000-01-01'));
SELECT asText(merge(tpose 'Pose(1, 1, 1)@2000-01-01', tpose '{Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05}'));

/* Errors */
SELECT merge(tpose 'SRID=5676;Pose(1, 1, 1)@2000-01-01', tpose 'Pose(1, 1, 1)@2000-01-02');
SELECT merge(tpose 'Pose(1, 1, 1)@2000-01-01', tpose 'PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02');
SELECT merge(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tpose '{Pose(2, 2, 2)@2000-01-02, Pose(2, 2, 2)@2000-01-03, Pose(1, 1, 1)@2000-01-04}');
SELECT merge(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tpose '{Pose(2, 2, 2)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05}');
SELECT merge(tpose 'SRID=5676;{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tpose '{Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05}');
SELECT merge(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tpose '{PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-03, PoseZ(2, 2, 2, 0, 0, 1, 0)@2000-01-04, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-05}');
SELECT merge(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tpose '[Pose(2, 2, 2)@2000-01-02, Pose(2, 2, 2)@2000-01-03, Pose(1, 1, 1)@2000-01-04]');
SELECT merge(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tpose '[Pose(2, 2, 2)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05]');
SELECT merge(tpose 'SRID=5676;[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tpose '[Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05]');
SELECT merge(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tpose '[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-03, PoseZ(2, 2, 2, 0, 0, 1, 0)@2000-01-04, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-05]');
SELECT merge(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', tpose '{[Pose(2, 2, 2)@2000-01-04, Pose(2, 2, 2)@2000-01-05, Pose(1, 1, 1)@2000-01-06],[Pose(1, 1, 1)@2000-01-08, Pose(1, 1, 1)@2000-01-09]}');
SELECT merge(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', tpose '{[Pose(2, 2, 2)@2000-01-05, Pose(2, 2, 2)@2000-01-06, Pose(1, 1, 1)@2000-01-07],[Pose(1, 1, 1)@2000-01-08, Pose(1, 1, 1)@2000-01-09]}');
SELECT merge(tpose 'SRID=5676;{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', tpose '{[Pose(1, 1, 1)@2000-01-05, Pose(1, 1, 1)@2000-01-06],[Pose(1, 1, 1)@2000-01-08, Pose(1, 1, 1)@2000-01-09]}');
SELECT merge(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', tpose '{[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-05, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-06],[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-08, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-09]}');

-------------------------------------------------------------------------------

SELECT asText(merge(ARRAY[tpose 'Pose(1, 1, 1)@2000-01-01', 'Pose(1, 1, 1)@2000-01-02']));
SELECT asText(merge(ARRAY[tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02}', '{Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}']));
SELECT asText(merge(ARRAY[tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02}', '{Pose(3, 3, 3)@2000-01-03, Pose(4, 4, 0)@2000-01-04}']));
SELECT asText(merge(ARRAY[tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', '[Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]']));
SELECT asText(merge(ARRAY[tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', '[Pose(3, 3, 3)@2000-01-03, Pose(4, 4, 0)@2000-01-04]']));
SELECT asText(merge(ARRAY[tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02], [Pose(3, 3, 3)@2000-01-03, Pose(4, 4, 0)@2000-01-04]}',
  '{[Pose(4, 4, 0)@2000-01-04, Pose(5, 5, 0)@2000-01-05], [Pose(6, 6, 0)@2000-01-06, Pose(7, 7, 0)@2000-01-07]}']));
SELECT asText(merge(ARRAY[tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]}', '{[Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]}']));
SELECT asText(merge(ARRAY [tpose 'Pose(1, 1, 1)@2000-01-01', '{Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05}']));
SELECT asText(merge(ARRAY [tpose 'Pose(1, 1, 1)@2000-01-01', 'Pose(1, 1, 1)@2000-01-01']));
SELECT asText(merge(ARRAY [tpose 'Pose(1, 1, 1)@2000-01-01', 'Pose(1, 1, 1)@2000-01-01']));

/* Errors */
SELECT merge(ARRAY [tpose 'SRID=5676;Pose(1, 1, 1)@2000-01-01', 'Pose(1, 1, 1)@2000-01-02']);
SELECT merge(ARRAY [tpose 'Pose(1, 1, 1)@2000-01-01', 'PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-02']);
SELECT merge(ARRAY [tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', '{Pose(2, 2, 2)@2000-01-02, Pose(2, 2, 2)@2000-01-03, Pose(1, 1, 1)@2000-01-04}']);
SELECT merge(ARRAY [tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', '{Pose(2, 2, 2)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05}']);
SELECT merge(ARRAY [tpose 'SRID=5676;{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', '{Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05}']);
SELECT merge(ARRAY [tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', '{PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-03, PoseZ(2, 2, 2, 0, 0, 1, 0)@2000-01-04, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-05}']);
SELECT merge(ARRAY [tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', '[Pose(2, 2, 2)@2000-01-02, Pose(2, 2, 2)@2000-01-03, Pose(1, 1, 1)@2000-01-04]']);
SELECT merge(ARRAY [tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', '[Pose(2, 2, 2)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05]']);
SELECT merge(ARRAY [tpose 'SRID=5676;[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', '[Pose(1, 1, 1)@2000-01-03, Pose(2, 2, 2)@2000-01-04, Pose(1, 1, 1)@2000-01-05]']);
SELECT merge(ARRAY [tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', '[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-03, PoseZ(2, 2, 2, 0, 0, 1, 0)@2000-01-04, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-05]']);
SELECT merge(ARRAY [tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', '{[Pose(2, 2, 2)@2000-01-04, Pose(2, 2, 2)@2000-01-05, Pose(1, 1, 1)@2000-01-06],[Pose(1, 1, 1)@2000-01-08, Pose(1, 1, 1)@2000-01-09]}']);
SELECT merge(ARRAY [tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', '{[Pose(2, 2, 2)@2000-01-05, Pose(2, 2, 2)@2000-01-06, Pose(1, 1, 1)@2000-01-07],[Pose(1, 1, 1)@2000-01-08, Pose(1, 1, 1)@2000-01-09]}']);
SELECT merge(ARRAY [tpose 'SRID=5676;{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', '{[Pose(1, 1, 1)@2000-01-05, Pose(1, 1, 1)@2000-01-06],[Pose(1, 1, 1)@2000-01-08, Pose(1, 1, 1)@2000-01-09]}']);
SELECT merge(ARRAY [tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(1, 1, 1)@2000-01-04, Pose(1, 1, 1)@2000-01-05]}', '{[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-05, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-06],[PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-08, PoseZ(1, 1, 1, 0, 1, 0, 0)@2000-01-09]}']);

-------------------------------------------------------------------------------
-- Accessor functions
-------------------------------------------------------------------------------

SELECT tempSubtype(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT tempSubtype(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT tempSubtype(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT tempSubtype(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT memSize(tpose 'Pose(1, 1, 1)@2000-01-01') > 0;
SELECT memSize(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}') > 0;
SELECT memSize(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]') > 0;
SELECT memSize(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}') > 0;

SELECT stbox(tpose 'Pose(1, 1, 1)@2000-01-01');

SELECT getValue(tpose 'Pose(1, 1, 1)@2000-01-01');
/* Errors */
SELECT getValue(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT getValue(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT getValue(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

-- SELECT valueSet(tpose 'Pose(1, 1, 1)@2000-01-01');
-- SELECT valueSet(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
-- SELECT valueSet(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}'));
-- SELECT valueSet(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
-- SELECT valueSet(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT startValue(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT startValue(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT startValue(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT startValue(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT endValue(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT endValue(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT endValue(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT endValue(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT getTimestamp(tpose 'Pose(1, 1, 1)@2000-01-01');
/* Errors */
SELECT getTimestamp(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT getTimestamp(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT getTimestamp(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT getTime(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT getTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT getTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT getTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT duration(tpose 'Pose(1, 1, 1)@2000-01-01', true);
SELECT duration(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', true);
SELECT duration(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', true);
SELECT duration(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', true);

SELECT duration(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT duration(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT duration(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT duration(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT numSequences(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT numSequences(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');
/* Errors */
SELECT numSequences(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT numSequences(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');

SELECT startSequence(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT startSequence(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');
/* Errors */
SELECT startSequence(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT startSequence(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');

SELECT endSequence(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT endSequence(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');
/* Errors */
SELECT endSequence(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT endSequence(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');

SELECT sequenceN(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', 1);
SELECT sequenceN(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', 1);
/* Errors */
SELECT sequenceN(tpose 'Pose(1, 1, 1)@2000-01-01', 1);
SELECT sequenceN(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', 1);

SELECT sequences(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT sequences(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');
/* Errors */
SELECT sequences(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT sequences(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');

SELECT numInstants(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT numInstants(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT numInstants(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT numInstants(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT startInstant(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT startInstant(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT startInstant(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT startInstant(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT endInstant(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT endInstant(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT endInstant(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT endInstant(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT instantN(tpose 'Pose(1, 1, 1)@2000-01-01', 1);
SELECT instantN(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', 1);
SELECT instantN(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', 1);
SELECT instantN(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', 1);

SELECT instants(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT instants(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT instants(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT instants(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT numTimestamps(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT numTimestamps(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT numTimestamps(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT numTimestamps(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT startTimestamp(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT startTimestamp(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT startTimestamp(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT startTimestamp(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT endTimestamp(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT endTimestamp(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT endTimestamp(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT endTimestamp(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

SELECT timestampN(tpose 'Pose(1, 1, 1)@2000-01-01', 1);
SELECT timestampN(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', 1);
SELECT timestampN(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', 1);
SELECT timestampN(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', 1);

SELECT timestamps(tpose 'Pose(1, 1, 1)@2000-01-01');
SELECT timestamps(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
SELECT timestamps(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
SELECT timestamps(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

-------------------------------------------------------------------------------
-- Shift and tscale functions
-------------------------------------------------------------------------------

SELECT shift(tpose 'Pose(1, 1, 1)@2000-01-01', '5 min');
SELECT shift(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', '5 min');
SELECT shift(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', '5 min');
SELECT shift(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', '5 min');

SELECT tscale(tpose 'Pose(1, 1, 1)@2000-01-01', '1 day');
SELECT tscale(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', '1 day');
SELECT tscale(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', '1 day');
SELECT tscale(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', '1 day');

SELECT shiftTscale(tpose 'Pose(1, 1, 1)@2000-01-01', '1 day', '1 day');
SELECT shiftTscale(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', '1 day', '1 day');
SELECT shiftTscale(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', '1 day', '1 day');
SELECT shiftTscale(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', '1 day', '1 day');

/* Errors */
SELECT tscale(tpose 'Pose(1, 1, 1)@2000-01-01', '0');
SELECT tscale(tpose 'Pose(1, 1, 1)@2000-01-01', '-1 day');

-------------------------------------------------------------------------------
-- Ever/always comparison functions
-------------------------------------------------------------------------------

SELECT tpose 'Pose(1, 1, 1)@2000-01-01' ?= Pose(1, 1, 1);
SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' ?= Pose(1, 1, 1);
SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02}' ?= Pose(2, 2, 2);
SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' ?= Pose(1, 1, 1);
SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' ?= Pose(1, 1, 1);

SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02}' ?= 'Pose(1.5, 1.5, 1.5)';
SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(1, 1, 1)@2000-01-02]' ?= 'Pose(1, 1, 1)';
SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]' ?= 'Pose(2, 2, 2)';
SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]' ?= 'Pose(1.5, 1.5, 1.5)';
SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02],[Pose(2, 2, 2)@2000-01-03, Pose(1, 1, 1)@2000-01-04]}' ?= 'Pose(0, 0, 0)';
SELECT tpose 'Interp=Step;[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]' ?= 'Pose(1.5, 1.5, 1.5)';

SELECT tpose '[PoseZ(1, 1, 1, 0, 0, 0, 1)@2000-01-01, PoseZ(3, 3, 3, 0, 0, 0, 1)@2000-01-03]' ?= 'PoseZ(2, 2, 2, 0, 0, 0, 1)';

SELECT tpose 'Pose(1, 1, 1)@2000-01-01' ?<> 'Pose(1, 1, 1)';

/* Errors */
SELECT tpose 'Pose(1, 1, 1)@2000-01-01' ?= pose 'SRID=5676;Pose(1, 1, 1)';
SELECT tpose 'Pose(1, 1, 1)@2000-01-01' ?= pose 'PoseZ(1, 1, 1, 0, 1, 0, 0)';

SELECT tpose 'Pose(1, 1, 1)@2000-01-01' %= Pose(1, 1, 1);
SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' %= Pose(1, 1, 1);
SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' %= Pose(1, 1, 1);
SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' %= Pose(1, 1, 1);

SELECT tpose 'Pose(1, 1, 1)@2000-01-01' %<> pose 'Pose(1, 1, 1)';

/* Errors */
SELECT tpose 'Pose(1, 1, 1)@2000-01-01' %= pose 'SRID=5676;Pose(1, 1, 1)';
SELECT tpose 'Pose(1, 1, 1)@2000-01-01' %= pose 'PoseZ(1, 1, 1, 0, 1, 0, 0)';

-------------------------------------------------------------------------------
-- Restriction functions
-------------------------------------------------------------------------------

-- SELECT asText(atValues(tpose 'Pose(1, 1, 1)@2000-01-01', Pose(1, 1, 1)));
-- SELECT asText(atValues(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', Pose(1, 1, 1)));
-- SELECT asText(atValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', Pose(1, 1, 1)));
-- SELECT asText(atValues(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', Pose(1, 1, 1)));
-- SELECT asText(atValues(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', ST_Point(1.5,1.5)));
-- SELECT asText(atValues(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', ST_Point(1.5,1.5)));
-- SELECT asText(atValues(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', ST_Point(1.5,1.5)));
-- SELECT asText(atValues(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', ST_Point(1.5,1.5)));

-- SELECT asText(atValues(tpose 'Pose(1, 1, 1)@2000-01-01', geometry 'Pose empty'));
-- SELECT asText(atValues(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', geometry 'Pose empty'));
-- SELECT asText(atValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', geometry 'Pose empty'));
-- SELECT asText(atValues(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', geometry 'Pose empty'));
-- SELECT asText(atValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', geography 'Pose empty'));
-- SELECT asText(atValues(tgeogpoint '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', geography 'Pose empty'));
-- SELECT asText(atValues(tgeogpoint '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', geography 'Pose empty'));
-- SELECT asText(atValues(tgeogpoint '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', geography 'Pose empty'));

-- /* Roundoff errors */
-- SELECT asText(atValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', ST_MakePoint(1.0 - 1e-16, 1.0 - 1e-16)));
-- SELECT asText(atValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', ST_MakePoint(1.0 - 1e-17, 1.0 - 1e-17)));
-- SELECT asText(atValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', ST_MakePoint(1.0 + 1e-16, 1.0 + 1e-16)));

-- /* Errors */
-- SELECT atValues(tpose 'Pose(1, 1, 1)@2000-01-01', geometry 'Linestring(1 1,2 2)');
-- SELECT atValues(tpose 'Pose(1, 1, 1)@2000-01-01', geometry 'SRID=5676;Pose(1, 1, 1)');
-- SELECT atValues(tpose 'Pose(1, 1, 1)@2000-01-01', geometry 'PoseZ(1, 1, 1, 0, 1, 0, 0)');
-- SELECT atValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', geography 'Linestring(1 1,2 2)');
-- SELECT atValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', geography 'SRID=4283;Pose(1, 1, 1)');
-- SELECT atValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', geography 'PoseZ(1, 1, 1, 0, 1, 0, 0)');

-- SELECT asText(minusValues(tpose 'Pose(1, 1, 1)@2000-01-01', Pose(1, 1, 1)));
-- SELECT asText(minusValues(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', Pose(1, 1, 1)));
-- SELECT asText(minusValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', Pose(1, 1, 1)));
-- SELECT asText(minusValues(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', Pose(1, 1, 1)));
-- SELECT asText(minusValues(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', ST_Point(1.5,1.5)));
-- SELECT asText(minusValues(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', ST_Point(1.5,1.5)));
-- SELECT asText(minusValues(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', ST_Point(1.5,1.5)));
-- SELECT asText(minusValues(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', ST_Point(1.5,1.5)));

-- SELECT asText(minusValues(tpose 'Pose(1, 1, 1)@2000-01-01', geometry 'Pose empty'));
-- SELECT asText(minusValues(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', geometry 'Pose empty'));
-- SELECT asText(minusValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', geometry 'Pose empty'));
-- SELECT asText(minusValues(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', geometry 'Pose empty'));
-- SELECT asText(minusValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', geography 'Pose empty'));
-- SELECT asText(minusValues(tgeogpoint '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', geography 'Pose empty'));
-- SELECT asText(minusValues(tgeogpoint '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', geography 'Pose empty'));
-- SELECT asText(minusValues(tgeogpoint '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', geography 'Pose empty'));

-- /* Roundoff errors */
-- SELECT asText(minusValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', ST_MakePoint(1.0 - 1e-16, 1.0 - 1e-16)));
-- SELECT asText(minusValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', ST_MakePoint(1.0 - 1e-17, 1.0 - 1e-17)));
-- SELECT asText(minusValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02]', ST_MakePoint(1.0 + 1e-16, 1.0 + 1e-16)));

-- /* Errors */
-- SELECT minusValues(tpose 'Pose(1, 1, 1)@2000-01-01', geometry 'Linestring(1 1,2 2)');
-- SELECT minusValues(tpose 'Pose(1, 1, 1)@2000-01-01', geometry 'SRID=5676;Pose(1, 1, 1)');
-- SELECT minusValues(tpose 'Pose(1, 1, 1)@2000-01-01', geometry 'PoseZ(1, 1, 1, 0, 1, 0, 0)');
-- SELECT minusValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', geography 'Linestring(1 1,2 2)');
-- SELECT minusValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', geography 'SRID=4283;Pose(1, 1, 1)');
-- SELECT minusValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', geography 'PoseZ(1, 1, 1, 0, 1, 0, 0)');

-- SELECT asText(atValues(tpose 'Pose(1, 1, 1)@2000-01-01', geomset '{"Pose(1, 1, 1)"}'));
-- SELECT asText(atValues(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', geomset '{"Pose(1, 1, 1)"}'));
-- SELECT asText(atValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', geomset '{"Pose(1, 1, 1)"}'));
-- SELECT asText(atValues(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', geomset '{"Pose(1, 1, 1)"}'));
-- SELECT asText(atValues(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', geogset '{"Pose(1.5, 1.5, 1.5)"}'));
-- SELECT asText(atValues(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', geogset '{"Pose(1.5, 1.5, 1.5)"}'));
-- SELECT asText(atValues(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', geogset '{"Pose(1.5, 1.5, 1.5)"}'));
-- SELECT asText(atValues(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', geogset '{"Pose(1.5, 1.5, 1.5)"}'));

-- /* Errors */
-- SELECT atValues(tpose 'Pose(1, 1, 1)@2000-01-01', set(geometry 'Linestring(1 1,2 2)'));
-- SELECT atValues(tpose 'Pose(1, 1, 1)@2000-01-01', set(geometry 'SRID=5676;Pose(1, 1, 1)'));
-- SELECT atValues(tpose 'Pose(1, 1, 1)@2000-01-01', set(geometry 'PoseZ(1, 1, 1, 0, 1, 0, 0)'));
-- SELECT atValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', set(geography 'Linestring(1 1,2 2)'));
-- SELECT atValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', set(geography 'SRID=4283;Pose(1, 1, 1)'));
-- SELECT atValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', set(geography 'PoseZ(1, 1, 1, 0, 1, 0, 0)'));

-- SELECT asText(minusValues(tpose 'Pose(1, 1, 1)@2000-01-01', geomset '{"Pose(1, 1, 1)"}'));
-- SELECT asText(minusValues(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', geomset '{"Pose(1, 1, 1)"}'));
-- SELECT asText(minusValues(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', geomset '{"Pose(1, 1, 1)"}'));
-- SELECT asText(minusValues(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', geomset '{"Pose(1, 1, 1)"}'));
-- SELECT asText(minusValues(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', geogset '{"Pose(1.5, 1.5, 1.5)"}'));
-- SELECT asText(minusValues(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', geogset '{"Pose(1.5, 1.5, 1.5)"}'));
-- SELECT asText(minusValues(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', geogset '{"Pose(1.5, 1.5, 1.5)"}'));
-- SELECT asText(minusValues(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', geogset '{"Pose(1.5, 1.5, 1.5)"}'));

-- /* Errors */
-- SELECT minusValues(tpose 'Pose(1, 1, 1)@2000-01-01', set(geometry 'Linestring(1 1,2 2)'));
-- SELECT minusValues(tpose 'Pose(1, 1, 1)@2000-01-01', set(geometry 'SRID=5676;Pose(1, 1, 1)'));
-- SELECT minusValues(tpose 'Pose(1, 1, 1)@2000-01-01', set(geometry 'PoseZ(1, 1, 1, 0, 1, 0, 0)'));
-- SELECT minusValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', set(geography 'Linestring(1 1,2 2)'));
-- SELECT minusValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', set(geography 'SRID=4283;Pose(1, 1, 1)'));
-- SELECT minusValues(tgeogpoint 'Pose(1, 1, 1)@2000-01-01', set(geography 'PoseZ(1, 1, 1, 0, 1, 0, 0)'));

-- SELECT atTime(tpose 'Pose(1, 1, 1)@2000-01-01', timestamptz '2000-01-01');
-- SELECT atTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', timestamptz '2000-01-01');
-- SELECT atTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', timestamptz '2000-01-01');
-- SELECT atTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', timestamptz '2000-01-01');

-- SELECT valueAtTimestamp(tpose 'Pose(1, 1, 1)@2000-01-01', timestamptz '2000-01-01');
-- SELECT valueAtTimestamp(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', timestamptz '2000-01-01');
-- SELECT valueAtTimestamp(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', timestamptz '2000-01-01');
-- SELECT valueAtTimestamp(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', timestamptz '2000-01-01');

-- SELECT asText(minusTime(tpose 'Pose(1, 1, 1)@2000-01-01', timestamptz '2000-01-01'));
-- SELECT asText(minusTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', timestamptz '2000-01-01'));
-- SELECT asText(minusTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', timestamptz '2000-01-01'));
-- SELECT asText(minusTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', timestamptz '2000-01-01'));
-- SELECT asText(minusTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', timestamptz '2000-01-01'));
-- SELECT asText(minusTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', timestamptz '2000-01-01'));
-- SELECT asText(minusTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', timestamptz '2000-01-01'));
-- SELECT asText(minusTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', timestamptz '2000-01-01'));

-- SELECT asText(atTime(tpose 'Pose(1, 1, 1)@2000-01-01', tstzset '{2000-01-01}'));
-- SELECT asText(atTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tstzset '{2000-01-01}'));
-- SELECT asText(atTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tstzset '{2000-01-01}'));
-- SELECT asText(atTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tstzset '{2000-01-01}'));
-- SELECT asText(atTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', tstzset '{2000-01-01}'));
-- SELECT asText(atTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', tstzset '{2000-01-01}'));
-- SELECT asText(atTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', tstzset '{2000-01-01}'));
-- SELECT asText(atTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', tstzset '{2000-01-01}'));

-- SELECT asText(minusTime(tpose 'Pose(1, 1, 1)@2000-01-01', tstzset '{2000-01-01}'));
-- SELECT asText(minusTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tstzset '{2000-01-01}'));
-- SELECT asText(minusTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tstzset '{2000-01-01}'));
-- SELECT asText(minusTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tstzset '{2000-01-01}'));
-- SELECT asText(minusTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', tstzset '{2000-01-01}'));
-- SELECT asText(minusTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', tstzset '{2000-01-01}'));
-- SELECT asText(minusTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', tstzset '{2000-01-01}'));
-- SELECT asText(minusTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', tstzset '{2000-01-01}'));

-- SELECT asText(atTime(tpose 'Pose(1, 1, 1)@2000-01-01', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(atTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(atTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(atTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(atTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(atTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(atTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(atTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', tstzspan '[2000-01-01,2000-01-02]'));

-- SELECT asText(minusTime(tpose 'Pose(1, 1, 1)@2000-01-01', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(minusTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(minusTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(minusTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(minusTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(minusTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(minusTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(minusTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', tstzspan '[2000-01-01,2000-01-02]'));

-- SELECT asText(atTime(tpose 'Pose(1, 1, 1)@2000-01-01', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(atTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(atTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(atTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(atTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(atTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(atTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(atTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', tstzspanset '{[2000-01-01,2000-01-02]}'));

-- SELECT asText(minusTime(tpose 'Pose(1, 1, 1)@2000-01-01', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(minusTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(minusTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(minusTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(minusTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(minusTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(minusTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(minusTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', tstzspanset '{[2000-01-01,2000-01-02]}'));

-------------------------------------------------------------------------------
-- Modification functions
-------------------------------------------------------------------------------

-- SELECT asText(deleteTime(tpose 'Pose(1, 1, 1)@2000-01-01', timestamptz '2000-01-01'));
-- SELECT asText(deleteTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', timestamptz '2000-01-01'));
-- SELECT asText(deleteTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', timestamptz '2000-01-01'));
-- SELECT asText(deleteTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', timestamptz '2000-01-01'));
-- SELECT asText(deleteTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', timestamptz '2000-01-01'));
-- SELECT asText(deleteTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', timestamptz '2000-01-01'));
-- SELECT asText(deleteTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', timestamptz '2000-01-01'));
-- SELECT asText(deleteTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', timestamptz '2000-01-01'));

-- SELECT asText(deleteTime(tpose 'Pose(1, 1, 1)@2000-01-01', tstzset '{2000-01-01}'));
-- SELECT asText(deleteTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tstzset '{2000-01-01}'));
-- SELECT asText(deleteTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tstzset '{2000-01-01}'));
-- SELECT asText(deleteTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tstzset '{2000-01-01}'));
-- SELECT asText(deleteTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', tstzset '{2000-01-01}'));
-- SELECT asText(deleteTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', tstzset '{2000-01-01}'));
-- SELECT asText(deleteTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', tstzset '{2000-01-01}'));
-- SELECT asText(deleteTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', tstzset '{2000-01-01}'));

-- SELECT asText(deleteTime(tpose 'Pose(1, 1, 1)@2000-01-01', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(deleteTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(deleteTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(deleteTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(deleteTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(deleteTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(deleteTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', tstzspan '[2000-01-01,2000-01-02]'));
-- SELECT asText(deleteTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', tstzspan '[2000-01-01,2000-01-02]'));

-- SELECT asText(deleteTime(tpose 'Pose(1, 1, 1)@2000-01-01', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(deleteTime(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(deleteTime(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(deleteTime(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(deleteTime(tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(deleteTime(tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(deleteTime(tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]', tstzspanset '{[2000-01-01,2000-01-02]}'));
-- SELECT asText(deleteTime(tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}', tstzspanset '{[2000-01-01,2000-01-02]}'));

-------------------------------------------------------------------------------
-- Comparison functions and B-tree indexing
-------------------------------------------------------------------------------

-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' = tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' = tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' = tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' = tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' = tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' = tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' = tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' = tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' = tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' = tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' = tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' = tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' = tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' = tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' = tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' = tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';

-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' <> tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' <> tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' <> tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' <> tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' <> tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' <> tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' <> tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' <> tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' <> tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' <> tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' <> tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' <> tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' <> tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' <> tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' <> tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' <> tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';

-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' < tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' < tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' < tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' < tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' < tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' < tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' < tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' < tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' < tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' < tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' < tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' < tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' < tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' < tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' < tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' < tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';

-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' <= tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' <= tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' <= tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' <= tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' <= tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' <= tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' <= tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' <= tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' <= tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' <= tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' <= tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' <= tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' <= tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' <= tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' <= tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' <= tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';

-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' > tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' > tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' > tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' > tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' > tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' > tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' > tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' > tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' > tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' > tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' > tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' > tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' > tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' > tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' > tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' > tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';

-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' >= tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' >= tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' >= tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' >= tpose 'Pose(1, 1, 1)@2000-01-01';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' >= tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' >= tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' >= tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' >= tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' >= tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' >= tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' >= tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' >= tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]';
-- SELECT tpose 'Pose(1, 1, 1)@2000-01-01' >= tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}' >= tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]' >= tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';
-- SELECT tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}' >= tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}';

-- SELECT tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' = tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01';
-- SELECT tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' = tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01';
-- SELECT tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' = tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01';
-- SELECT tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' = tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01';
-- SELECT tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' = tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}';
-- SELECT tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' = tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}';
-- SELECT tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' = tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}';
-- SELECT tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' = tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}';
-- SELECT tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' = tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]';
-- SELECT tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' = tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]';
-- SELECT tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' = tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]';
-- SELECT tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' = tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]';
-- SELECT tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' = tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}';
-- SELECT tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' = tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}';
-- SELECT tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' = tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}';
-- SELECT tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' = tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}';

-- SELECT tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' <> tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01';
-- SELECT tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' <> tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01';
-- SELECT tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' <> tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01';
-- SELECT tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' <> tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01';
-- SELECT tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' <> tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}';
-- SELECT tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' <> tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}';
-- SELECT tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' <> tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}';
-- SELECT tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' <> tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}';
-- SELECT tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' <> tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]';
-- SELECT tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' <> tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]';
-- SELECT tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' <> tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]';
-- SELECT tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' <> tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]';
-- SELECT tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' <> tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}';
-- SELECT tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' <> tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}';
-- SELECT tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' <> tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}';
-- SELECT tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' <> tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}';

-- PostGIS changed the function of the function lwgeom_hash from version 3

-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' < tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' < tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' < tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' < tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' < tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' < tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' < tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' < tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' < tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' < tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' < tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' < tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' < tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' < tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' < tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' < tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;

-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' <= tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' <= tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' <= tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' <= tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' <= tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' <= tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' <= tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' <= tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' <= tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' <= tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' <= tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' <= tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' <= tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' <= tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' <= tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' <= tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;

-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' > tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' > tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' > tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' > tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' > tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' > tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' > tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' > tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' > tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' > tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' > tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' > tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' > tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' > tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' > tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' > tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;

-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' >= tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' >= tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' >= tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' >= tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' >= tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' >= tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' >= tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' >= tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' >= tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' >= tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' >= tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' >= tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint 'Pose(1.5, 1.5, 1.5)@2000-01-01' >= tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03}' >= tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03]' >= tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;
-- SELECT 1 WHERE tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' >= tgeogpoint '{[Pose(1.5, 1.5, 1.5)@2000-01-01, Point(2.5 2.5)@2000-01-02, Pose(1.5, 1.5, 1.5)@2000-01-03],[Point(3.5 3.5)@2000-01-04, Point(3.5 3.5)@2000-01-05]}' IS NOT NULL;

-------------------------------------------------------------------------------

-- SELECT temporal_hash(tpose 'Pose(1, 1, 1)@2000-01-01');
-- SELECT temporal_hash(tpose '{Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03}');
-- SELECT temporal_hash(tpose '[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03]');
-- SELECT temporal_hash(tpose '{[Pose(1, 1, 1)@2000-01-01, Pose(2, 2, 2)@2000-01-02, Pose(1, 1, 1)@2000-01-03],[Pose(3, 3, 3)@2000-01-04, Pose(3, 3, 3)@2000-01-05]}');

------------------------------------------------------------------------------
