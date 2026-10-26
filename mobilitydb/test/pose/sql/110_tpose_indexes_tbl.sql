-- Index correctness tests for tpose on tbl_tpose2d (100 rows, SRID 5676).
-- Modeled on mobilitydb/test/cbuffer/sql/166_tcbuffer_indexes_tbl.
DROP INDEX IF EXISTS tbl_tpose2d_rtree_idx;
DROP INDEX IF EXISTS tbl_tpose2d_quadtree_idx;
DROP INDEX IF EXISTS tbl_tpose2d_kdtree_idx;

-------------------------------------------------------------------------------
-- 1. rtree (GIST)
-------------------------------------------------------------------------------

CREATE INDEX tbl_tpose2d_rtree_idx ON tbl_tpose2d USING GIST(temp);

SELECT COUNT(*) FROM tbl_tpose2d WHERE temp <<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp &<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp #>> tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp #&> tstzspan '[2001-01-01, 2001-02-01]';

SELECT COUNT(*) FROM tbl_tpose2d WHERE temp < tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp <= tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp > tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp >= tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';

SELECT COUNT(*) FROM tbl_tpose2d WHERE temp && tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp @> tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp <@ tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp ~= tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp -|- tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';

SELECT COUNT(*) FROM tbl_tpose2d WHERE temp << tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp &< tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp >> tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp &> tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp <<| tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp &<| tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp |>> tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp |&> tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';

-------------------------------------------------------------------------------
-- 2. quadtree (SPGIST default)
-------------------------------------------------------------------------------

DROP INDEX IF EXISTS tbl_tpose2d_rtree_idx;

CREATE INDEX tbl_tpose2d_quadtree_idx ON tbl_tpose2d USING SPGIST(temp);

SELECT COUNT(*) FROM tbl_tpose2d WHERE temp <<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp &<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp #>> tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp #&> tstzspan '[2001-01-01, 2001-02-01]';

SELECT COUNT(*) FROM tbl_tpose2d WHERE temp && tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp @> tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp <@ tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp ~= tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp -|- tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';

-------------------------------------------------------------------------------
-- 3. kdtree (SPGIST tpose_kdtree_ops)
-------------------------------------------------------------------------------

DROP INDEX IF EXISTS tbl_tpose2d_quadtree_idx;

CREATE INDEX tbl_tpose2d_kdtree_idx ON tbl_tpose2d USING SPGIST(temp tpose_kdtree_ops);

SELECT COUNT(*) FROM tbl_tpose2d WHERE temp && tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp @> tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp <@ tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';
SELECT COUNT(*) FROM tbl_tpose2d WHERE temp ~= tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]';

-------------------------------------------------------------------------------
-- 4. KNN ordered-search via |=| (rtree + quadtree, on tbl_tpose2d)
-------------------------------------------------------------------------------

DROP INDEX IF EXISTS tbl_tpose2d_kdtree_idx;

CREATE INDEX tbl_tpose2d_rtree_idx ON tbl_tpose2d USING GIST(temp);

WITH test AS (
  SELECT temp |=| tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-06-01, Pose(Point(50 50), 0.5)@2001-07-01]' AS distance
  FROM tbl_tpose2d ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| pose 'SRID=3812;Pose(Point(25 25), 0.3)' AS distance
  FROM tbl_tpose2d ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| geometry 'SRID=3812;Point(25 25)' AS distance
  FROM tbl_tpose2d ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| stbox 'SRID=3812;STBOX XT(((0,0),(50,50)),[2001-06-01, 2001-07-01])' AS distance
  FROM tbl_tpose2d ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;

DROP INDEX tbl_tpose2d_rtree_idx;

CREATE INDEX tbl_tpose2d_quadtree_idx ON tbl_tpose2d USING SPGIST(temp);

WITH test AS (
  SELECT temp |=| tpose 'SRID=3812;[Pose(Point(0 0), 0.1)@2001-06-01, Pose(Point(50 50), 0.5)@2001-07-01]' AS distance
  FROM tbl_tpose2d ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| pose 'SRID=3812;Pose(Point(25 25), 0.3)' AS distance
  FROM tbl_tpose2d ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| geometry 'SRID=3812;Point(25 25)' AS distance
  FROM tbl_tpose2d ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;
WITH test AS (
  SELECT temp |=| stbox 'SRID=3812;STBOX XT(((0,0),(50,50)),[2001-06-01, 2001-07-01])' AS distance
  FROM tbl_tpose2d ORDER BY 1 LIMIT 3 )
SELECT round(distance, 6) FROM test;

DROP INDEX tbl_tpose2d_quadtree_idx;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 5. Z-axis position operators on tbl_tpose3d
-------------------------------------------------------------------------------
DROP INDEX IF EXISTS tbl_tpose3d_rtree_idx;
DROP INDEX IF EXISTS tbl_tpose3d_quadtree_idx;
DROP INDEX IF EXISTS tbl_tpose3d_kdtree_idx;

DROP TABLE IF EXISTS test_zaxis;
CREATE TEMP TABLE test_zaxis(
  op TEXT,
  no_idx BIGINT,
  rtree_idx BIGINT,
  quadtree_idx BIGINT,
  kdtree_idx BIGINT
);

INSERT INTO test_zaxis(op, no_idx)
SELECT '<</', COUNT(*) FROM tbl_tpose3d WHERE temp <</ stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))';
INSERT INTO test_zaxis(op, no_idx)
SELECT '&</', COUNT(*) FROM tbl_tpose3d WHERE temp &</ stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))';
INSERT INTO test_zaxis(op, no_idx)
SELECT '/>>', COUNT(*) FROM tbl_tpose3d WHERE temp />> stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))';
INSERT INTO test_zaxis(op, no_idx)
SELECT '/&>', COUNT(*) FROM tbl_tpose3d WHERE temp /&> stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))';

CREATE INDEX tbl_tpose3d_rtree_idx ON tbl_tpose3d USING GIST(temp);

UPDATE test_zaxis
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp <</ stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '<</';
UPDATE test_zaxis
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp &</ stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '&</';
UPDATE test_zaxis
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp />> stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/>>';
UPDATE test_zaxis
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp /&> stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/&>';

DROP INDEX tbl_tpose3d_rtree_idx;

CREATE INDEX tbl_tpose3d_quadtree_idx ON tbl_tpose3d USING SPGIST(temp);

UPDATE test_zaxis
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp <</ stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '<</';
UPDATE test_zaxis
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp &</ stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '&</';
UPDATE test_zaxis
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp />> stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/>>';
UPDATE test_zaxis
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp /&> stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/&>';

DROP INDEX tbl_tpose3d_quadtree_idx;

CREATE INDEX tbl_tpose3d_kdtree_idx ON tbl_tpose3d USING SPGIST(temp tpose_kdtree_ops);

UPDATE test_zaxis
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp <</ stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '<</';
UPDATE test_zaxis
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp &</ stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '&</';
UPDATE test_zaxis
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp />> stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/>>';
UPDATE test_zaxis
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_tpose3d WHERE temp /&> stbox 'SRID=3812;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/&>';

DROP INDEX tbl_tpose3d_kdtree_idx;

-- the operators that match at least one row: a mismatch test over
-- predicates that match nothing would hold vacuously
SELECT count(*) FILTER (WHERE no_idx > 0) AS matching, count(*) AS ops
FROM test_zaxis;

SELECT * FROM test_zaxis
WHERE no_idx <> rtree_idx OR no_idx <> quadtree_idx OR no_idx <> kdtree_idx OR
  no_idx IS NULL OR rtree_idx IS NULL OR quadtree_idx IS NULL OR kdtree_idx IS NULL
ORDER BY op;

DROP TABLE test_zaxis;

-------------------------------------------------------------------------------
