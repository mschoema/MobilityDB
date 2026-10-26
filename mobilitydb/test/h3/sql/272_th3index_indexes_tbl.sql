-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

DROP INDEX IF EXISTS tbl_th3index_big_rtree_idx;
DROP INDEX IF EXISTS tbl_th3index_big_quadtree_idx;
DROP INDEX IF EXISTS tbl_th3index_big_kdtree_idx;

-----------------------------------------------------------------------------

DROP TABLE IF EXISTS test_th3index_idx;
CREATE TEMP TABLE test_th3index_idx(
  op char(3),
  leftarg text,
  rightarg text,
  no_idx BIGINT,
  rtree_idx BIGINT,
  quadtree_idx BIGINT,
  kdtree_idx BIGINT
);

-----------------------------------------------------------------------------
-- Counts with no index

INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '&&', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b && temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '@>', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b @> temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '<@', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <@ temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '~=', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b ~= temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '&&', 'tstzspan', 'th3index', COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t && temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '<@', 'tstzspan', 'th3index', COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t <@ temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '<<', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b << temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '>>', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b >> temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '<<|', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <<| temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '|>>', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b |>> temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '<<#', 'tstzspan', 'th3index', COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t <<# temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '#>>', 'tstzspan', 'th3index', COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t #>> temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '<<#', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <<# temp;
INSERT INTO test_th3index_idx(op, leftarg, rightarg, no_idx)
SELECT '#>>', 'stbox', 'th3index', COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b #>> temp;

-----------------------------------------------------------------------------

CREATE INDEX tbl_th3index_big_rtree_idx ON tbl_th3index_big USING GIST(temp);
-----------------------------------------------------------------------------

UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b && temp )
WHERE op = '&&' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b @> temp )
WHERE op = '@>' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <@ temp )
WHERE op = '<@' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b ~= temp )
WHERE op = '~=' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t && temp )
WHERE op = '&&' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t <@ temp )
WHERE op = '<@' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b << temp )
WHERE op = '<<' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b >> temp )
WHERE op = '>>' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <<| temp )
WHERE op = '<<|' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b |>> temp )
WHERE op = '|>>' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t <<# temp )
WHERE op = '<<#' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t #>> temp )
WHERE op = '#>>' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <<# temp )
WHERE op = '<<#' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET rtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b #>> temp )
WHERE op = '#>>' AND leftarg = 'stbox' AND rightarg = 'th3index';

-----------------------------------------------------------------------------

DROP INDEX tbl_th3index_big_rtree_idx;
CREATE INDEX tbl_th3index_big_quadtree_idx ON tbl_th3index_big USING SPGIST(temp);
-----------------------------------------------------------------------------

UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b && temp )
WHERE op = '&&' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b @> temp )
WHERE op = '@>' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <@ temp )
WHERE op = '<@' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b ~= temp )
WHERE op = '~=' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t && temp )
WHERE op = '&&' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t <@ temp )
WHERE op = '<@' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b << temp )
WHERE op = '<<' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b >> temp )
WHERE op = '>>' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <<| temp )
WHERE op = '<<|' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b |>> temp )
WHERE op = '|>>' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t <<# temp )
WHERE op = '<<#' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t #>> temp )
WHERE op = '#>>' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <<# temp )
WHERE op = '<<#' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET quadtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b #>> temp )
WHERE op = '#>>' AND leftarg = 'stbox' AND rightarg = 'th3index';

-----------------------------------------------------------------------------

DROP INDEX tbl_th3index_big_quadtree_idx;
CREATE INDEX tbl_th3index_big_kdtree_idx ON tbl_th3index_big USING SPGIST(temp th3index_kdtree_ops);
-----------------------------------------------------------------------------

UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b && temp )
WHERE op = '&&' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b @> temp )
WHERE op = '@>' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <@ temp )
WHERE op = '<@' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b ~= temp )
WHERE op = '~=' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t && temp )
WHERE op = '&&' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t <@ temp )
WHERE op = '<@' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b << temp )
WHERE op = '<<' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b >> temp )
WHERE op = '>>' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <<| temp )
WHERE op = '<<|' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b |>> temp )
WHERE op = '|>>' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t <<# temp )
WHERE op = '<<#' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_tstzspan, tbl_th3index_big WHERE t #>> temp )
WHERE op = '#>>' AND leftarg = 'tstzspan' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b <<# temp )
WHERE op = '<<#' AND leftarg = 'stbox' AND rightarg = 'th3index';
UPDATE test_th3index_idx
SET kdtree_idx = ( SELECT COUNT(*) FROM tbl_geodstbox, tbl_th3index_big WHERE b #>> temp )
WHERE op = '#>>' AND leftarg = 'stbox' AND rightarg = 'th3index';

-----------------------------------------------------------------------------

DROP INDEX tbl_th3index_big_kdtree_idx;

-----------------------------------------------------------------------------

SELECT * FROM test_th3index_idx
WHERE no_idx <> rtree_idx OR no_idx <> quadtree_idx OR
  no_idx <> kdtree_idx OR no_idx IS NULL OR rtree_idx IS NULL OR
  quadtree_idx IS NULL OR kdtree_idx IS NULL
ORDER BY op, leftarg, rightarg;

-----------------------------------------------------------------------------

DROP TABLE test_th3index_idx;

-----------------------------------------------------------------------------
