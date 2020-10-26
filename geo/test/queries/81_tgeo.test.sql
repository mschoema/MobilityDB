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

-- Temporal sequence

SELECT asText(tgeometry ' [ Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00 , Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 08:05:00 , Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00 ] ');
SELECT asText(tgeometry ' [ Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2001-01-01 08:00:00 , Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 08:05:00 , Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2001-01-01 08:06:00 ] ');
SELECT asText(tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 08:05:00,Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00]');
SELECT asText(tgeometry '[Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2001-01-01 08:00:00,Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 08:05:00,Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2001-01-01 08:06:00]');
SELECT asText(tgeometry '[Polyhedralsurface Z (((-1 -1 -1,-1 -1 1,-1 1 1,-1 1 -1,-1 -1 -1)),((-1 -1 -1,-1 1 -1,1 1 -1,1 -1 -1,-1 -1 -1)),((-1 -1 -1,1 -1 -1,1 -1 1,-1 -1 1,-1 -1 -1)),((1 1 -1,1 1 1,1 -1 1,1 -1 -1,1 1 -1)),((-1 1 -1,-1 1 1,1 1 1,1 1 -1,-1 1 -1)),((-1 -1 1,1 -1 1,1 1 1,-1 1 1,-1 -1 1)))@2001-01-01 08:00:00,POLYHEDRALSURFACE Z (((-1 0 -1.41421356237309,-1 -1.41421356237309 0,-1 0 1.41421356237309,-1 1.41421356237309 0,-1 0 -1.41421356237309)),((-1 0 -1.41421356237309,-1 1.41421356237309 0,1 1.41421356237309 0,1 0 -1.41421356237309,-1 0 -1.41421356237309)),((-1 0 -1.41421356237309,1 0 -1.41421356237309,1 -1.41421356237309 0,-1 -1.41421356237309 0,-1 0 -1.41421356237309)),((1 1.41421356237309 0,1 0 1.41421356237309,1 -1.41421356237309 0,1 0 -1.41421356237309,1 1.41421356237309 0)),((-1 1.41421356237309 0,-1 0 1.41421356237309,1 0 1.41421356237309,1 1.41421356237309 0,-1 1.41421356237309 0)),((-1 -1.41421356237309 0,1 -1.41421356237309 0,1 0 1.41421356237309,-1 0 1.41421356237309,-1 -1.41421356237309 0)))@2001-01-01 08:05:00,Polyhedralsurface(((-1 1 -1,-1 -1 -1,-1 -1 1,-1 1 1,-1 1 -1)),((-1 1 -1,-1 1 1,1 1 1,1 1 -1,-1 1 -1)),((-1 1 -1,1 1 -1,1 -1 -1,-1 -1 -1,-1 1 -1)),((1 1 1,1 -1 1,1 -1 -1,1 1 -1,1 1 1)),((-1 1 1,-1 -1 1,1 -1 1,1 1 1,-1 1 1)),((-1 -1 -1,1 -1 -1,1 -1 1,-1 -1 1,-1 -1 -1)))@2001-01-01 08:10:00]');
/* Errors */
SELECT asText(tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((0 0, 2 0, 2 2, 0 2, 0 0))@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00]');
SELECT asText(tgeometry '[Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2001-01-01 08:00:00,Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 08:05:00,Polyhedralsurface Z (((0 0 0,0 0 2,0 2 0,0 0 0)),((0 0 0,0 2 0,2 0 0,0 0 0)),((0 0 0,2 0 0,0 0 2,0 0 0)),((2 0 0,0 2 0,0 0 2,2 0 0)))@2001-01-01 08:06:00]');
SELECT asText(tgeometry '[Polygon((0 0 0, 1 0 0, 1 1 0, 0 1 0, 0 0 0))@2001-01-01, Polygon((0 0 0, 2 0 0, 2 2 0, 0 2 0, 0 0 0))@2001-01-02, Polygon((0 0 0, 3 0 0, 3 3 0, 0 3 0, 0 0 0))@2001-01-03]');
SELECT tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon empty@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00]';
SELECT tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((0 0 0, 2 0 0, 2 2 0, 0 2 0, 0 0 0))@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00]';
SELECT tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((0 0, 2 0, 2 2, 0 2, 0 0))@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00}';
SELECT tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((0 0, 2 0, 2 2, 0 2, 0 0))@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00] xxx';

-------------------------------------------------------------------------------

-- Temporal sequence set

SELECT asText(tgeometry '  { [ Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00 , Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 08:05:00 , Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00 ],
 [ Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 09:00:00 , Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 09:05:00 , Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 09:06:00 ] } ');
SELECT asText(tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 08:05:00,Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00],
 [Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 09:00:00,Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 09:05:00,Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 09:06:00]}');
SELECT asText(tgeometry '{[Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2001-01-01 08:00:00,Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 08:05:00,Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2001-01-01 08:06:00],
 [Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2001-01-01 09:00:00,Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))@2001-01-01 09:05:00,Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 09:06:00]}');

/* Errors */
SELECT asText(tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00,Polygon((0 0, 2 0, 2 2, 0 2, 0 0))@2001-01-01 08:05:00,Polygon((0 0, 3 0, 3 3, 0 3, 0 0))@2001-01-01 08:06:00],
 [Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 09:00:00,Polygon((0 0, 2 0, 2 2, 0 2, 0 0))@2001-01-01 09:05:00,Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 09:06:00]}');
SELECT asText(tgeometry '{[Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2001-01-01 08:00:00,Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2001-01-01 08:05:00,Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2001-01-01 08:06:00],
 [Polyhedralsurface Z (((0 0 0,0 0 2,0 2 0,0 0 0)),((0 0 0,0 2 0,2 0 0,0 0 0)),((0 0 0,2 0 0,0 0 2,0 0 0)),((2 0 0,0 2 0,0 0 2,2 0 0)))@2001-01-01 09:00:00,Polyhedralsurface Z (((0 0 0,0 0 2,0 2 0,0 0 0)),((0 0 0,0 2 0,2 0 0,0 0 0)),((0 0 0,2 0 0,0 0 2,0 0 0)),((2 0 0,0 2 0,0 0 2,2 0 0)))@2001-01-01 09:05:00]}');
SELECT tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00, Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 08:05:00, Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00],
 [Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 09:00:00, Polygon empty@2001-01-01 09:05:00, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 09:06:00]}';
SELECT tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00],[Polygon((0 0 0, 1 0 0, 1 1 0, 0 1 0, 0 0 0))@2001-01-01 08:05:00,Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00]}';
SELECT tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00],[Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 08:05:00,Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00]';
SELECT tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2001-01-01 08:00:00],[Polygon((1 0, 1 1, 0 1, 0 0, 1 0))@2001-01-01 08:05:00,Polygon((1 1, 0 1, 0 0, 1 0, 1 1))@2001-01-01 08:06:00]} xxx';


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

SELECT asewkt(tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(1 0, 2 0, 1 1, 1 0)'::geometry), '2012-01-01 08:10:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:00:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))', '2012-01-01 08:10:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))', '2012-01-01 08:20:00')
]));

/* Errors */
SELECT asewkt(tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 1 1, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:00:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))', '2012-01-01 08:10:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))', '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:00:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))', '2012-01-01 08:10:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)),((1 0 0,1 0 1,1 1 0,1 0 0)))', '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0 0, 1 0 0, 0 1 0, 0 0 0)'::geometry), '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 2 0, 0 2, 0 0)'::geometry), '2012-01-01 08:10:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]));
SELECT asewkt(tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:00:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 2,0 2 0,0 0 0)),((0 0 0,0 2 0,2 0 0,0 0 0)),((0 0 0,2 0 0,0 0 2,0 0 0)),((2 0 0,0 2 0,0 0 2,2 0 0)))', '2012-01-01 08:10:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))', '2012-01-01 08:20:00')
]));

-------------------------------------------------------------------------------

SELECT asewkt(tgeometrys(ARRAY[
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(1 0, 2 0, 1 1, 1 0)'::geometry), '2012-01-01 08:10:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]),
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 09:00:00'),
tgeometryinst(ST_MakePolygon('LineString(1 0, 2 0, 1 1, 1 0)'::geometry), '2012-01-01 09:10:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 09:20:00')
])]));
SELECT asewkt(tgeometrys(ARRAY[
tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:00:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))', '2012-01-01 08:10:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:20:00')
]),
tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 09:00:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))', '2012-01-01 09:10:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 09:20:00')
])]));
SELECT asewkt(tgeometrys(ARRAY[
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(1 0, 2 0, 1 1, 1 0)'::geometry), '2012-01-01 08:10:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]),
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00'),
tgeometryinst(ST_MakePolygon('LineString(1 0, 2 0, 1 1, 1 0)'::geometry), '2012-01-01 08:30:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:40:00')
], FALSE, TRUE)]));
SELECT asewkt(tgeometrys(ARRAY[
tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:00:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))', '2012-01-01 08:10:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:20:00')
]),
tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:20:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))', '2012-01-01 08:30:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:40:00')
], FALSE, TRUE)]));

/* Errors */
SELECT asewkt(tgeometrys(ARRAY[
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 1 1, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]),
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 09:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 1 1, 0 1, 0 0)'::geometry), '2012-01-01 09:20:00')
])]));
SELECT asewkt(tgeometrys(ARRAY[
tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:00:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))', '2012-01-01 08:10:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))', '2012-01-01 08:20:00')
]),
tgeometryseq(ARRAY[
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,1 0 1,0 0 1,0 0 0)),((1 1 0,1 1 1,1 0 1,1 0 0,1 1 0)),((0 1 0,0 1 1,1 1 1,1 1 0,0 1 0)),((0 0 1,1 0 1,1 1 1,0 1 1,0 0 1)))', '2012-01-01 09:00:00'),
tgeometryinst(geometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,1 0 1,0 0 1,0 0 0)),((1 1 0,1 1 1,1 0 1,1 0 0,1 1 0)),((0 1 0,0 1 1,1 1 1,1 1 0,0 1 0)),((0 0 1,1 0 1,1 1 1,0 1 1,0 0 1)))', '2012-01-01 09:10:00')
])]));
SELECT asewkt(tgeometrys(ARRAY[
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0 0, 1 0 0, 0 1 0, 0 0 0)'::geometry), '2012-01-01 08:20:00')
]),
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 09:00:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0 0, 1 0 0, 0 1 0, 0 0 0)'::geometry), '2012-01-01 09:20:00')
])]));
SELECT asewkt(tgeometrys(ARRAY[
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00'),
tgeometryinst(ST_MakePolygon('LineString(1 0, 2 0, 1 1, 1 0)'::geometry), '2012-01-01 08:10:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:20:00')
]),
tgeometryseq(ARRAY[
tgeometryinst(ST_MakePolygon('LineString(0 0, 2 0, 0 2, 0 0)'::geometry), '2012-01-01 09:00:00'),
tgeometryinst(ST_MakePolygon('LineString(1 0, 3 0, 1 2, 1 0)'::geometry), '2012-01-01 09:10:00'),
tgeometryinst(ST_MakePolygon('LineString(0 0, 2 0, 0 2, 0 0)'::geometry), '2012-01-01 09:20:00')
])]));

-------------------------------------------------------------------------------
-- Transformation functions
-------------------------------------------------------------------------------

SELECT asewkt(tgeometryinst(tgeometry 'Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01'));
SELECT asewkt(tgeometryinst(tgeometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-01'));
SELECT asewkt(tgeometryi(tgeometry 'Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01'));
SELECT asewkt(tgeometryi(tgeometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-01'));
SELECT asewkt(tgeometryi(tgeometry '{Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03}'));
SELECT asewkt(tgeometryi(tgeometry '{Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-01, Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2000-01-02, Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))@2000-01-03}'));
SELECT asewkt(tgeometryseq(tgeometry 'Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01'));
SELECT asewkt(tgeometryseq(tgeometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-01'));
SELECT asewkt(tgeometryseq(tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03]'));
SELECT asewkt(tgeometryseq(tgeometry '[Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-01, Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2000-01-02, Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))@2000-01-03]'));
SELECT asewkt(tgeometrys(tgeometry 'Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01'));
SELECT asewkt(tgeometrys(tgeometry 'Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-01'));
SELECT asewkt(tgeometrys(tgeometry '{Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03}'));
SELECT asewkt(tgeometrys(tgeometry '{Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-01, Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2000-01-02, Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))@2000-01-03}'));
SELECT asewkt(tgeometrys(tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03]'));
SELECT asewkt(tgeometrys(tgeometry '[Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-01, Polyhedralsurface Z (((0 0 0,0 0 -1,0 -1 0,0 0 0)),((0 0 0,0 -1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 -1,0 0 0)),((1 0 0,0 -1 0,0 0 -1,1 0 0)))@2000-01-02, Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))@2000-01-03]'));
SELECT asewkt(tgeometrys(tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03],[Polygon((4 3, 4 4, 3 4, 3 3, 4 3))@2000-01-04, Polygon((4 3, 4 4, 3 4, 3 3, 4 3))@2000-01-05]}'));
SELECT asewkt(tgeometrys(tgeometry '{[Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-01, Polyhedralsurface Z (((0 0 0,0 -1 0,0 0 1,0 0 0)),((0 0 0,0 0 1,1 0 0,0 0 0)),((0 0 0,1 0 0,0 -1 0,0 0 0)),((1 0 0,0 0 1,0 -1 0,1 0 0)))@2000-01-02, Polyhedralsurface Z (((0 0 0,0 0 1,0 1 0,0 0 0)),((0 0 0,0 1 0,1 0 0,0 0 0)),((0 0 0,1 0 0,0 0 1,0 0 0)),((1 0 0,0 1 0,0 0 1,1 0 0)))@2000-01-03],[Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))@2000-01-04, Polyhedralsurface Z (((1 0 0,1 0 1,1 1 0,1 0 0)),((1 0 0,1 1 0,2 0 0,1 0 0)),((1 0 0,2 0 0,1 0 1,1 0 0)),((2 0 0,1 1 0,1 0 1,2 0 0)))@2000-01-05]}'));
/* Errors */
SELECT asewkt(tgeometryinst(tgeometry '{Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03}'));
SELECT asewkt(tgeometryinst(tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03]'));
SELECT asewkt(tgeometryinst(tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03],[Polygon((4 3, 4 4, 3 4, 3 3, 4 3))@2000-01-04, Polygon((4 3, 4 4, 3 4, 3 3, 4 3))@2000-01-05]}'));
SELECT asewkt(tgeometryi(tgeometry '[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03]'));
SELECT asewkt(tgeometryi(tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03],[Polygon((4 3, 4 4, 3 4, 3 3, 4 3))@2000-01-04, Polygon((4 3, 4 4, 3 4, 3 3, 4 3))@2000-01-05]}'));
SELECT asewkt(tgeometryseq(tgeometry '{Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03}'));
SELECT asewkt(tgeometryseq(tgeometry '{[Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01, Polygon((5 5, 6 5, 6 6, 5 6, 5 5))@2000-01-02, Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-03],[Polygon((4 3, 4 4, 3 4, 3 3, 4 3))@2000-01-04, Polygon((4 3, 4 4, 3 4, 3 3, 4 3))@2000-01-05]}'));

-------------------------------------------------------------------------------
