-------------------------------------------------------------------------------
-- Temporal equal
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_geometry t1, tbl_trgeometry2d t2 WHERE ST_SetSRID(t1.g, 5676) #= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_trgeometry2d t1, tbl_geometry t2 WHERE t1.temp #= ST_SetSRID(t2.g, 5676) IS NOT NULL;
SELECT COUNT(*) FROM tbl_trgeometry2d t1, tbl_trgeometry2d t2 WHERE t1.temp #= t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Temporal not equal
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_geometry t1, tbl_trgeometry2d t2 WHERE ST_SetSRID(t1.g, 5676) #<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_trgeometry2d t1, tbl_geometry t2 WHERE t1.temp #<> ST_SetSRID(t2.g, 5676) IS NOT NULL;
SELECT COUNT(*) FROM tbl_trgeometry2d t1, tbl_trgeometry2d t2 WHERE t1.temp #<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
