-- Index correctness tests for trgeometry on tbl_trgeometry2d (SRID 5676).
-- Modeled on mobilitydb/test/cbuffer/sql/166_tcbuffer_indexes_tbl.
DROP INDEX IF EXISTS tbl_trgeometry2d_rtree_idx;
DROP INDEX IF EXISTS tbl_trgeometry2d_quadtree_idx;
DROP INDEX IF EXISTS tbl_trgeometry2d_kdtree_idx;

-- Reusable trgeometry literal: small triangle Polygon stamped along
-- a 2-instant pose path
\set TRG_LIT 'SRID=5676;Polygon((1 1,2 2,3 1,1 1));[Pose(Point(0 0), 0.1)@2001-01-01, Pose(Point(50 50), 0.5)@2001-12-31]'
\set GEOM_LIT 'SRID=5676;Point(25 25)'
\set BBOX_LIT 'SRID=5676;STBOX XT(((0,0),(50,50)),[2001-01-01, 2001-12-31])'

-------------------------------------------------------------------------------
-- 1. rtree (GIST)
-------------------------------------------------------------------------------

CREATE INDEX tbl_trgeometry2d_rtree_idx ON tbl_trgeometry2d USING GIST(temp);

SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp <<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp &<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp #>> tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp #&> tstzspan '[2001-01-01, 2001-02-01]';

SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp < trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp <= trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp > trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp >= trgeometry :'TRG_LIT';

SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp && trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp @> trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp <@ trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp ~= trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp -|- trgeometry :'TRG_LIT';

SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp << trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp &< trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp >> trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp &> trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp <<| trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp &<| trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp |>> trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp |&> trgeometry :'TRG_LIT';

-------------------------------------------------------------------------------
-- 2. quadtree (SPGIST default)
-------------------------------------------------------------------------------

DROP INDEX IF EXISTS tbl_trgeometry2d_rtree_idx;

CREATE INDEX tbl_trgeometry2d_quadtree_idx ON tbl_trgeometry2d USING SPGIST(temp);

SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp <<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp &<# tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp #>> tstzspan '[2001-01-01, 2001-02-01]';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp #&> tstzspan '[2001-01-01, 2001-02-01]';

SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp && trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp @> trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp <@ trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp ~= trgeometry :'TRG_LIT';

-------------------------------------------------------------------------------
-- 3. kdtree (SPGIST trgeometry_kdtree_ops)
-------------------------------------------------------------------------------

DROP INDEX IF EXISTS tbl_trgeometry2d_quadtree_idx;

CREATE INDEX tbl_trgeometry2d_kdtree_idx ON tbl_trgeometry2d USING SPGIST(temp trgeometry_kdtree_ops);

SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp && trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp @> trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp <@ trgeometry :'TRG_LIT';
SELECT COUNT(*) FROM tbl_trgeometry2d WHERE temp ~= trgeometry :'TRG_LIT';

-------------------------------------------------------------------------------
-- Coverage of all the same and order by logic in SP-GiST indexes

CREATE TEMP TABLE tbl_trgeometry_big_allthesame AS
  SELECT k, trgeometry(geometry 'SRID=5676;Polygon((1 1,2 2,3 1,1 1))',
    tpose(pose 'SRID=5676;Pose(Point(25 25), 0.3)', timeSpan(temp))) AS temp
  FROM tbl_trgeometry2d WHERE temp IS NOT NULL;
CREATE INDEX tbl_trgeometry_big_allthesame_quadtree_idx ON tbl_trgeometry_big_allthesame USING SPGIST(temp);
ANALYZE tbl_trgeometry_big_allthesame;

-- EXPLAIN ANALYZE

DROP TABLE tbl_trgeometry_big_allthesame;

-------------------------------------------------------------------------------
-- 5. Z-axis position operators on tbl_trgeometry3d
-------------------------------------------------------------------------------
DROP INDEX IF EXISTS tbl_trgeometry3d_rtree_idx;
DROP INDEX IF EXISTS tbl_trgeometry3d_quadtree_idx;
DROP INDEX IF EXISTS tbl_trgeometry3d_kdtree_idx;

DROP TABLE IF EXISTS test_zaxis;
CREATE TEMP TABLE test_zaxis(
  op TEXT,
  no_idx BIGINT,
  rtree_idx BIGINT,
  quadtree_idx BIGINT,
  kdtree_idx BIGINT
);

INSERT INTO test_zaxis(op, no_idx)
SELECT '<</', COUNT(*) FROM tbl_trgeometry3d WHERE temp <</ stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))';
INSERT INTO test_zaxis(op, no_idx)
SELECT '&</', COUNT(*) FROM tbl_trgeometry3d WHERE temp &</ stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))';
INSERT INTO test_zaxis(op, no_idx)
SELECT '/>>', COUNT(*) FROM tbl_trgeometry3d WHERE temp />> stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))';
INSERT INTO test_zaxis(op, no_idx)
SELECT '/&>', COUNT(*) FROM tbl_trgeometry3d WHERE temp /&> stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))';

CREATE INDEX tbl_trgeometry3d_rtree_idx ON tbl_trgeometry3d USING GIST(temp);

UPDATE test_zaxis
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp <</ stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '<</';
UPDATE test_zaxis
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp &</ stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '&</';
UPDATE test_zaxis
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp />> stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/>>';
UPDATE test_zaxis
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp /&> stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/&>';

DROP INDEX tbl_trgeometry3d_rtree_idx;

CREATE INDEX tbl_trgeometry3d_quadtree_idx ON tbl_trgeometry3d USING SPGIST(temp);

UPDATE test_zaxis
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp <</ stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '<</';
UPDATE test_zaxis
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp &</ stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '&</';
UPDATE test_zaxis
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp />> stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/>>';
UPDATE test_zaxis
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp /&> stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/&>';

DROP INDEX tbl_trgeometry3d_quadtree_idx;

CREATE INDEX tbl_trgeometry3d_kdtree_idx ON tbl_trgeometry3d USING SPGIST(temp trgeometry_kdtree_ops);

UPDATE test_zaxis
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp <</ stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '<</';
UPDATE test_zaxis
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp &</ stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '&</';
UPDATE test_zaxis
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp />> stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/>>';
UPDATE test_zaxis
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_trgeometry3d WHERE temp /&> stbox 'SRID=5676;STBOX Z((-50,-50,-50),(50,50,50))' )
WHERE op = '/&>';

DROP INDEX tbl_trgeometry3d_kdtree_idx;

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
