-------------------------------------------------------------------------------
-- Temporal equal
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_npoint t1, tbl_tnpoint t2 WHERE t1.np #= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tnpoint t1, tbl_npoint t2 WHERE t1.temp #= t2.np IS NOT NULL;
SELECT COUNT(*) FROM tbl_tnpoint t1, tbl_tnpoint t2 WHERE t1.temp #= t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Temporal not equal
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_npoint t1, tbl_tnpoint t2 WHERE t1.np #<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tnpoint t1, tbl_npoint t2 WHERE t1.temp #<> t2.np IS NOT NULL;
SELECT COUNT(*) FROM tbl_tnpoint t1, tbl_tnpoint t2 WHERE t1.temp #<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
