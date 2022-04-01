-------------------------------------------------------------------------------
--
-- This MobilityDB code is provided under The PostgreSQL License.
-- Copyright (c) 2016-2022, Université libre de Bruxelles and MobilityDB
-- contributors
--
-- MobilityDB includes portions of PostGIS version 3 source code released
-- under the GNU General Public License (GPLv2 or later).
-- Copyright (c) 2001-2022, PostGIS contributors
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

SELECT tgeometry 'Polygon((0 0, 1 0, 0 1, 0 0));Pose(0, 0, 0)@2012-01-01';
SELECT tgeometry '  Polygon((0 0, 1 0, 0 1, 0 0));Pose(0, 0, 0)@2012-01-01  ';
/* Errors */
SELECT tgeometry 'TRUE@2012-01-01';
SELECT tgeometry 'Point(0 0)@2012-01-01';
SELECT tgeometry 'Polygon empty;Pose(0, 0, 0)@2012-01-01';
SELECT tgeometry 'Polygon((0 0, 1 0, 0 1, 0 0));Pose(0, 0, 0)@2012-01-01 ,';

-------------------------------------------------------------------------------

-- Temporal instant set

SELECT tgeometry 'Polygon((0 0, 1 0, 0 1, 0 0));{Pose(1, 1, 0)@2012-01-01, Pose(2, 2, 0)@2012-01-02, Pose(3, 3, 0)@2012-01-03}';
SELECT tgeometry 'Polygon((0 0, 1 0, 0 1, 0 0)) ; { Pose(1, 1, 0)@2012-01-01 , Pose(2, 2, 0)@2012-01-02 , Pose(3, 3, 0)@2012-01-03 }';
/* Errors */
SELECT tgeometry 'Polygon((0 0, 1 0, 0 1, 0 0));{Pose(1, 1, 0)@2012-01-01, Pose(2, 2, 2, 1, 0, 0, 0)@2012-01-02, Pose(3, 3, 0)@2012-01-03}';
SELECT tgeometry '{Point(1 1)@2001-01-01,Point(2 2 2)@2001-01-01,Point(3 3)@2001-01-01}';
SELECT tgeometry '{Point(1 1)@2001-01-01,Point(2 2)@2001-01-01,Point(3 3)@2001-01-01]';

-------------------------------------------------------------------------------

-- Temporal sequence

SELECT tgeometry ' [ Point(1 1)@2001-01-01 , Point(2 2)@2001-01-01 , Point(3 3)@2001-01-01 ] ';
SELECT tgeometry '[Point(1 1)@2001-01-01,Point(2 2)@2001-01-01,Point(3 3)@2001-01-01]';
SELECT tgeometry '[Point(1 1 1)@2001-01-01, Point(2 2 2)@2001-01-02, Point(3 3 3)@2001-01-03]';
/* Errors */
SELECT tgeometry '[Point(1 1)@2001-01-01,Point empty@2001-01-01,Point(3 3)@2001-01-01]';
SELECT tgeometry '[Point(1 1)@2001-01-01,Point(2 2 2)@2001-01-01,Point(3 3)@2001-01-01]';
SELECT tgeometry '[Point(1 1)@2001-01-01,Point(2 2)@2001-01-01,Point(3 3)@2001-01-01}';
SELECT tgeometry '[Point(1 1)@2001-01-01,Point(2 2)@2001-01-01,Point(3 3)@2001-01-01] xxx';

-------------------------------------------------------------------------------

-- Temporal sequence set

SELECT tgeometry '  { [ Point(1 1)@2001-01-01 , Point(2 2)@2001-01-01 , Point(3 3)@2001-01-01 ],
 [ Point(1 1)@2001-01-01 , Point(2 2)@2001-01-01 , Point(1 1)@2001-01-01 ] } ';
SELECT tgeometry '{[Point(1 1)@2001-01-01,Point(2 2)@2001-01-01,Point(3 3)@2001-01-01],
 [Point(1 1)@2001-01-01,Point(2 2)@2001-01-01,Point(1 1)@2001-01-01]}';

/* Errors */
SELECT tgeometry '{[Point(1 1)@2001-01-01, Point(2 2)@2001-01-01, Point(3 3)@2001-01-01],
 [Point(1 1)@2001-01-01, Point empty@2001-01-01, Point(1 1)@2001-01-01]}';
SELECT tgeometry '{[Point(1 1)@2001-01-01],[Point(2 2 2)@2001-01-01,Point(3 3)@2001-01-01]}';
SELECT tgeometry '{[Point(1 1)@2001-01-01],[Point(2 2)@2001-01-01,Point(3 3)@2001-01-01]';
SELECT tgeometry '{[Point(1 1)@2001-01-01],[Point(2 2)@2001-01-01,Point(3 3)@2001-01-01]} xxx';

-------------------------------------------------------------------------------
-- SRID
-------------------------------------------------------------------------------

SELECT tgeometry 'SRID=4326;[Point(0 1)@2000-01-01, Point(0 1)@2000-01-02]';
SELECT tgeometry '[SRID=4326;Point(0 1)@2000-01-01, Point(0 1)@2000-01-02]';
SELECT tgeometry '[SRID=4326;Point(0 1)@2000-01-01, SRID=4326;Point(0 1)@2000-01-02]';

SELECT tgeometry 'SRID=4326;{[Point(0 1)@2000-01-01], [Point(0 1)@2000-01-02]}';
SELECT tgeometry '{[SRID=4326;Point(0 1)@2000-01-01], [Point(0 1)@2000-01-02]}';
SELECT tgeometry '{[SRID=4326;Point(0 1)@2000-01-01], [SRID=4326;Point(0 1)@2000-01-02]}';

/* Errors */
SELECT tgeometry '{SRID=5676;Point(0 1)@2000-01-01, SRID=3812;Point(0 1)@2000-01-02}';
SELECT tgeometry 'SRID=5676;{Point(0 1)@2000-01-01, SRID=3812;Point(0 1)@2000-01-02}';
SELECT tgeometry '[SRID=5676;Point(0 1)@2000-01-01, SRID=3812;Point(0 1)@2000-01-02]';
SELECT tgeometry 'SRID=5676;[Point(0 1)@2000-01-01, SRID=3812;Point(0 1)@2000-01-02]';
SELECT tgeometry '{[SRID=5676;Point(0 1)@2000-01-01], [SRID=3812;Point(0 1)@2000-01-02]';
SELECT tgeometry 'SRID=5676;{[Point(0 1)@2000-01-01], [SRID=3812;Point(0 1)@2000-01-02]}';
SELECT tgeometry 'SRID=5676;{Point(1 1)@2001-01-01,SRID=3812;Point(2 2)@2001-01-01,Point(3 3)@2001-01-01}';
SELECT tgeometry 'SRID=5676;[Point(1 1)@2001-01-01,SRID=3812;Point(2 2)@2001-01-01,Point(3 3)@2001-01-01]';
SELECT tgeometry 'SRID=5676;{[Point(1 1)@2001-01-01],[SRID=3812;Point(2 2)@2001-01-01,Point(3 3)@2001-01-01]';

-------------------------------------------------------------------------------
-- Constructor functions
-------------------------------------------------------------------------------

SELECT tgeometry_inst(ST_Point(1,1), timestamptz '2012-01-01');
-- NULL
SELECT tgeometry_inst(NULL, timestamptz '2012-01-01');
/* Errors */
SELECT tgeometry_inst(geometry 'point empty', timestamptz '2000-01-01');


SELECT tgeometry_instset(ST_Point(1,1), timestampset '{2012-01-01, 2012-01-02, 2012-01-03}');
-- NULL
SELECT tgeometry_instset(NULL, timestampset '{2012-01-01, 2012-01-02, 2012-01-03}');

SELECT tgeometry_seq(ST_Point(1,1), period '[2012-01-01, 2012-01-03]');
SELECT tgeometry_seq(ST_Point(1,1), period '[2012-01-01, 2012-01-03]', false));
-- NULL
SELECT tgeometry_seq(NULL, period '[2012-01-01, 2012-01-03]');

SELECT tgeometry_seqset(ST_Point(1,1), periodset '{[2012-01-01, 2012-01-03]}');
SELECT tgeometry_seqset(ST_Point(1,1), periodset '{[2012-01-01, 2012-01-03]}', false));
-- NULL
SELECT tgeometry_seqset(NULL, periodset '{[2012-01-01, 2012-01-03]}');

-------------------------------------------------------------------------------

SELECT tgeometry_instset(ARRAY[
tgeometry_inst(ST_Point(1,1), timestamptz '2012-01-01'),
tgeometry_inst(ST_Point(2,2), timestamptz '2012-01-01'),
tgeometry_inst(ST_Point(1,1), timestamptz '2012-01-01')
]));

/* Errors */
SELECT tgeometry_instset(ARRAY[tgeometry 'SRID=5676;Point(1 1)@2001-01-01', 'SRID=4326;Point(2 2)@2001-01-02']);
SELECT tgeometry_instset(ARRAY[tgeometry 'Point(1 1)@2001-01-01', 'Point(2 2 2)@2001-01-02']);

-------------------------------------------------------------------------------

SELECT tgeometry_seq(ARRAY[
tgeometry_inst(ST_Point(1,1), timestamptz '2012-01-01'),
tgeometry_inst(ST_Point(2,2), timestamptz '2012-01-01'),
tgeometry_inst(ST_Point(1,1), timestamptz '2012-01-01')
]));

/* Errors */
SELECT tgeometry_seq(ARRAY[tgeometry 'SRID=5676;Point(1 1)@2001-01-01', 'SRID=4326;Point(2 2)@2001-01-02']);
SELECT tgeometry_seq(ARRAY[tgeometry 'Point(1 1)@2001-01-01', 'Point(2 2 2)@2001-01-02']);

-------------------------------------------------------------------------------

SELECT tgeometry_seqset(ARRAY[
tgeometry_seq(ARRAY[
tgeometry_inst(ST_Point(1,1), timestamptz '2012-01-01'),
tgeometry_inst(ST_Point(2,2), timestamptz '2012-01-01'),
tgeometry_inst(ST_Point(1,1), timestamptz '2012-01-01')
]),
tgeometry_seq(ARRAY[
tgeometry_inst(ST_Point(1,1), timestamptz '2012-01-01'),
tgeometry_inst(ST_Point(2,2), timestamptz '2012-01-01'),
tgeometry_inst(ST_Point(1,1), timestamptz '2012-01-01')
])]));

/* Errors */
SELECT tgeometry_seqset(ARRAY[tgeometry '[SRID=5676;Point(1 1)@2001-01-01]', '[SRID=4326;Point(2 2)@2001-01-02]']);
SELECT tgeometry_seqset(ARRAY[tgeometry '[Point(1 1)@2001-01-01]', '[Point(2 2 2)@2001-01-02]']);

-------------------------------------------------------------------------------
-- Transformation functions
-------------------------------------------------------------------------------

SELECT tgeometry_inst(tgeometry 'Point(1 1)@2000-01-01');
SELECT tgeometry_instset(tgeometry 'Point(1 1)@2000-01-01');
SELECT tgeometry_instset(tgeometry '{Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03}');
SELECT tgeometry_seq(tgeometry 'Point(1 1)@2000-01-01');
SELECT tgeometry_seq(tgeometry '[Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03]');
SELECT tgeometry_seqset(tgeometry 'Point(1 1)@2000-01-01');
SELECT tgeometry_seqset(tgeometry '{Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03}');
SELECT tgeometry_seqset(tgeometry '[Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03]');
SELECT tgeometry_seqset(tgeometry '{[Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03],[Point(3 3)@2000-01-04, Point(3 3)@2000-01-05]}');
/* Errors */
SELECT tgeometry_inst(tgeometry '{Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03}');
SELECT tgeometry_inst(tgeometry '[Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03]');
SELECT tgeometry_inst(tgeometry '{[Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03],[Point(3 3)@2000-01-04, Point(3 3)@2000-01-05]}');
SELECT tgeometry_instset(tgeometry '[Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03]');
SELECT tgeometry_instset(tgeometry '{[Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03],[Point(3 3)@2000-01-04, Point(3 3)@2000-01-05]}');
SELECT tgeometry_seq(tgeometry '{Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03}');
SELECT tgeometry_seq(tgeometry '{[Point(1 1)@2000-01-01, Point(2 2)@2000-01-02, Point(1 1)@2000-01-03],[Point(3 3)@2000-01-04, Point(3 3)@2000-01-05]}');

------------------------------------------------------------------------------
