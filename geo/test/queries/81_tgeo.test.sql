-------------------------------------------------------------------------------
-- Input/output functions
-------------------------------------------------------------------------------

-- Temporal instant

SELECT asText(tgeometry 'Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2012-01-01 08:00:00');
SELECT asText(tgeometry 'Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2012-01-01 08:00:00');
SELECT asText(tgeometry '  Polygon((0 0, 2 0, 2 2, 0 2, 0 0))@2012-01-01 08:00:00  ');
SELECT asText(tgeometry '  Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2012-01-01 08:00:00  ');
/* Errors */
SELECT tgeometry 'TRUE@2012-01-01 08:00:00';
SELECT tgeometry 'Polygon empty@2000-01-01 00:00:00+01';
SELECT tgeometry 'Polyhedralsurface Z empty@2012-01-01 08:00:00';
SELECT tgeometry 'Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01 00:00:00+01 ,';
SELECT tgeometry 'Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2012-01-01 08:00:00 ,';

-------------------------------------------------------------------------------

-- Temporal instant set

SELECT asText(tgeometry ' { Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00 , Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 08:05:00 , Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00 } ');
SELECT asText(tgeometry ' { Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2001-01-01 08:00:00 , Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 08:05:00 , Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2001-01-01 08:06:00 } ');
SELECT asText(tgeometry '{Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 08:05:00,Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00}');
SELECT asText(tgeometry '{Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2001-01-01 08:00:00,Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 08:05:00,Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2001-01-01 08:06:00}');
/* Errors */
SELECT asText(tgeometry '{Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((0 0, 2 0, 2 2, 0 2, 0 0))@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00}');
SELECT asText(tgeometry '{Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2001-01-01 08:00:00,Polyhedralsurface Z (((1 0 0, 1 0 1, 1 1 0, 1 0 0)),((1 0 0, 1 1 0, 2 0 0, 1 0 0)),((1 0 0, 2 0 0, 1 0 1, 1 0 0)),((2 0 0, 1 1 0, 1 0 1, 2 0 0)))@2001-01-01 08:05:00,Polyhedralsurface Z (((0 0 0, 0 0 2, 0 2 0, 0 0 0)),((0 0 0, 0 2 0, 2 0 0, 0 0 0)),((0 0 0, 2 0 0, 0 0 2, 0 0 0)),((2 0 0, 0 2 0, 0 0 2, 2 0 0)))@2001-01-01 08:06:00}');
SELECT tgeometry '{Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon empty@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00}';
SELECT tgeometry '{Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2001-01-01 08:00:00,Polyhedralsurface Z empty@2001-01-01 08:05:00,Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 08:06:00}';
SELECT tgeometry '{Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((0 0 0, 2 0 0, 2 2 0, 0 2 0, 0 0 0))@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00}';
SELECT tgeometry '{Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((0 0, 2 0, 2 2, 0 2, 0 0))@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00]';
SELECT asText(tgeometry '{Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2001-01-01 08:00:00,Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 08:05:00,Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2001-01-01 08:06:00]');

-------------------------------------------------------------------------------
-- Constructor functions
-------------------------------------------------------------------------------

SELECT asText(tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'));
SELECT asText(tgeometryinst('Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))'::geometry, '2012-01-01 08:00:00'));
SELECT asText(tgeometryinst(NULL, '2012-01-01 08:00:00'));
/* Errors */
SELECT tgeometryinst(geometry 'Polygon empty', timestamptz '2000-01-01');
SELECT tgeometryinst(geometry 'Polyhedralsurface Z empty', timestamptz '2000-01-01');

-------------------------------------------------------------------------------

SELECT asewkt(tgeometryi(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(1 0, 2 0, 1 1, 1 0)'::geometry), '2012-01-01 08:10:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryi(ARRAY[
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))'::geometry, '2012-01-01 08:00:00'),
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))'::geometry, '2012-01-01 08:10:00'),
tgeometryinst('Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)),((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))'::geometry, '2012-01-01 08:20:00')
]));

/* Errors */
SELECT asewkt(tgeometryi(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 1 1, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryi(ARRAY[
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))'::geometry, '2012-01-01 08:00:00'),
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)),((0 0 0,0 0 1,0 1 0,0 0 0)))'::geometry, '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryi(ARRAY[
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))'::geometry, '2012-01-01 08:00:00'),
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 0 1,0 1 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))'::geometry, '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryi(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0 0, 1 0 0, 0 1 0, 0 0 0)'::geometry), '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryi(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))'::geometry, '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryi(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 2 0, 0 2, 0 0)'::geometry), '2012-01-01 08:10:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryi(ARRAY[
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))'::geometry, '2012-01-01 08:00:00'),
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 0 2,0 2 0,0 0 0)),((0 0 0,0 2 0,2 0 0,0 0 0)),((0 0 0,2 0 0,0 0 2,0 0 0)),((2 0 0,0 2 0,0 0 2,2 0 0)))'::geometry, '2012-01-01 08:10:00'),
tgeometryinst('Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))'::geometry, '2012-01-01 08:20:00')
]));

-------------------------------------------------------------------------------
