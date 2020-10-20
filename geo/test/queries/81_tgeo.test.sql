-------------------------------------------------------------------------------
-- Input/output functions
-------------------------------------------------------------------------------

-- Temporal instant

SELECT tgeometry 'Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2012-01-01 08:00:00';
SELECT tgeometry 'Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)), ((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2012-01-01 08:00:00';
SELECT tgeometry '  Polygon((0 0, 2 0, 2 2, 0 2, 0 0))@2012-01-01 08:00:00  ';
SELECT tgeometry '  Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)), ((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2012-01-01 08:00:00  ';
/* Errors */
SELECT tgeometry 'TRUE@2012-01-01 08:00:00';
SELECT tgeometry 'Polygon empty@2000-01-01 00:00:00+01';
SELECT tgeometry 'Polyhedralsurface Z empty@2012-01-01 08:00:00';
SELECT tgeometry 'Polygon((0 0, 1 0, 1 1, 0 1, 0 0))@2000-01-01 00:00:00+01 ,';
SELECT tgeometry 'Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)), ((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))@2012-01-01 08:00:00 ,';

-------------------------------------------------------------------------------
-- Constructor functions
-------------------------------------------------------------------------------

SELECT tgeometryinst(ST_MakePolygon('LineString(0 0, 1 0, 0 1, 0 0)'::geometry), '2012-01-01 08:00:00');
SELECT tgeometryinst('Polyhedralsurface Z (((0 0 0, 0 0 1, 0 1 0, 0 0 0)),((0 0 0, 0 1 0, 1 0 0, 0 0 0)), ((0 0 0, 1 0 0, 0 0 1, 0 0 0)),((1 0 0, 0 1 0, 0 0 1, 1 0 0)))'::geometry, '2012-01-01 08:00:00');
SELECT tgeometryinst(NULL, '2012-01-01 08:00:00');
/* Errors */
SELECT tgeometryinst(geometry 'Polygon empty', timestamptz '2000-01-01');
SELECT tgeometryinst(geometry 'Polyhedralsurface Z empty', timestamptz '2000-01-01');
