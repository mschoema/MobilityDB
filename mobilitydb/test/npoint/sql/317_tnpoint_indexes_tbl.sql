-- Index correctness tests for tnpoint on tbl_tnpoint_big (1 000 rows).
-- Modeled on mobilitydb/test/cbuffer/sql/166_tcbuffer_indexes_tbl.
DROP INDEX IF EXISTS tbl_tnpoint_big_rtree_idx;
DROP INDEX IF EXISTS tbl_tnpoint_big_quadtree_idx;
DROP INDEX IF EXISTS tbl_tnpoint_big_kdtree_idx;

-------------------------------------------------------------------------------
-- 1. rtree (GIST)
-------------------------------------------------------------------------------

CREATE INDEX tbl_tnpoint_big_rtree_idx ON tbl_tnpoint_big USING GIST(temp);

SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp #>> tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp #&> tstzspan '[2001-01-01, 2001-02-01]';

SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp < tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <= tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp > tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp >= tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';

SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp && tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp @> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <@ tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp ~= tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp -|- tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';

SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp << tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &< tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp >> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <<| tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &<| tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp |>> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp |&> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <<# tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &<# tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp #>> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp #&> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';

-------------------------------------------------------------------------------
-- 2. quadtree (SPGIST default)
-------------------------------------------------------------------------------

DROP INDEX IF EXISTS tbl_tnpoint_big_rtree_idx;

CREATE INDEX tbl_tnpoint_big_quadtree_idx ON tbl_tnpoint_big USING SPGIST(temp);

SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp #>> tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp #&> tstzspan '[2001-01-01, 2001-02-01]';

SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp && tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp @> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <@ tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp ~= tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp -|- tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';

SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp << tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &< tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp >> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <<| tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &<| tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp |>> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp |&> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';

-------------------------------------------------------------------------------
-- 3. kdtree (SPGIST tnpoint_kdtree_ops)
-------------------------------------------------------------------------------

DROP INDEX IF EXISTS tbl_tnpoint_big_quadtree_idx;

CREATE INDEX tbl_tnpoint_big_kdtree_idx ON tbl_tnpoint_big USING SPGIST(temp tnpoint_kdtree_ops);

SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp &<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp #>> tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp #&> tstzspan '[2001-01-01, 2001-02-01]';

SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp && tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp @> tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp <@ tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp ~= tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tnpoint_big WHERE temp -|- tnpoint '[Npoint(1, 0.2)@2001-01-01, Npoint(1, 0.5)@2001-12-31]';

-------------------------------------------------------------------------------
-- 4. KNN ordered-search via |=| (rtree + quadtree, on tbl_tnpoint)
-------------------------------------------------------------------------------

DROP INDEX IF EXISTS tbl_tnpoint_big_kdtree_idx;
DROP INDEX IF EXISTS tbl_tnpoint_rtree_317_tnpoint_indexes_idx;
CREATE INDEX tbl_tnpoint_rtree_317_tnpoint_indexes_idx ON tbl_tnpoint USING GIST(temp);

WITH test AS (
  SELECT temp |=| tnpoint '[Npoint(1, 0.2)@2001-06-01, Npoint(1, 0.5)@2001-07-01]' AS distance
  FROM tbl_tnpoint ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| npoint 'Npoint(1, 0.4)' AS distance
  FROM tbl_tnpoint ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| stbox 'SRID=5676;STBOX XT(((0,0),(50,50)),[2001-06-01, 2001-07-01])' AS distance
  FROM tbl_tnpoint ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;

DROP INDEX tbl_tnpoint_rtree_317_tnpoint_indexes_idx;

DROP INDEX IF EXISTS tbl_tnpoint_quadtree_317_tnpoint_indexes_idx;
CREATE INDEX tbl_tnpoint_quadtree_317_tnpoint_indexes_idx ON tbl_tnpoint USING SPGIST(temp);

WITH test AS (
  SELECT temp |=| tnpoint '[Npoint(1, 0.2)@2001-06-01, Npoint(1, 0.5)@2001-07-01]' AS distance
  FROM tbl_tnpoint ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| npoint 'Npoint(1, 0.4)' AS distance
  FROM tbl_tnpoint ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| stbox 'SRID=5676;STBOX XT(((0,0),(50,50)),[2001-06-01, 2001-07-01])' AS distance
  FROM tbl_tnpoint ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;

DROP INDEX tbl_tnpoint_quadtree_317_tnpoint_indexes_idx;

-------------------------------------------------------------------------------
-- Coverage of all the same and order by logic in SP-GiST indexes

CREATE TEMP TABLE tbl_tnpoint_big_allthesame AS
  SELECT k, tnpoint(npoint 'Npoint(1, 0.5)', t) AS temp
  FROM tbl_tstzspan_big;
CREATE INDEX tbl_tnpoint_big_allthesame_quadtree_idx ON tbl_tnpoint_big_allthesame USING SPGIST(temp);
ANALYZE tbl_tnpoint_big_allthesame;

-- EXPLAIN ANALYZE

DROP TABLE tbl_tnpoint_big_allthesame;

-------------------------------------------------------------------------------
