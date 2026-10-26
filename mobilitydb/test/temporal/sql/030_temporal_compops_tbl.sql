-------------------------------------------------------------------------------
-- Ever/always comparison functions
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_tbool WHERE temp ?= startValue(temp);
SELECT COUNT(*) FROM tbl_tint WHERE temp ?= startValue(temp);
SELECT COUNT(*) FROM tbl_tfloat WHERE temp ?= startValue(temp);
SELECT COUNT(*) FROM tbl_ttext WHERE temp ?= startValue(temp);

SELECT COUNT(*) FROM tbl_tbool WHERE startValue(temp) ?= temp;
SELECT COUNT(*) FROM tbl_tint WHERE startValue(temp) ?= temp;
SELECT COUNT(*) FROM tbl_tfloat WHERE startValue(temp) ?= temp;
SELECT COUNT(*) FROM tbl_ttext WHERE startValue(temp) ?= temp;

SELECT COUNT(*) FROM tbl_tbool WHERE temp %= true;
SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp %= i;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp %= f;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp %= t;

SELECT COUNT(*) FROM tbl_tbool WHERE true %= temp;
SELECT COUNT(*) FROM tbl_int, tbl_tint WHERE i %= temp;
SELECT COUNT(*) FROM tbl_float, tbl_tfloat WHERE f %= temp;
SELECT COUNT(*) FROM tbl_text, tbl_ttext WHERE t %= temp;

SELECT COUNT(*) FROM tbl_tbool WHERE temp ?<> startValue(temp);
SELECT COUNT(*) FROM tbl_tint WHERE temp ?<> startValue(temp);
SELECT COUNT(*) FROM tbl_tfloat WHERE temp ?<> startValue(temp);
SELECT COUNT(*) FROM tbl_ttext WHERE temp ?<> startValue(temp);

SELECT COUNT(*) FROM tbl_tbool WHERE startValue(temp) ?<> temp;
SELECT COUNT(*) FROM tbl_tint WHERE startValue(temp) ?<> temp;
SELECT COUNT(*) FROM tbl_tfloat WHERE startValue(temp) ?<> temp;
SELECT COUNT(*) FROM tbl_ttext WHERE startValue(temp) ?<> temp;

SELECT COUNT(*) FROM tbl_tbool WHERE temp %<> true;
SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp %<> i;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp %<> f;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp %<> t;

SELECT COUNT(*) FROM tbl_tbool WHERE true %<> temp;
SELECT COUNT(*) FROM tbl_int, tbl_tint WHERE i %<> temp;
SELECT COUNT(*) FROM tbl_float, tbl_tfloat WHERE f %<> temp;
SELECT COUNT(*) FROM tbl_text, tbl_ttext WHERE t %<> temp;

SELECT COUNT(*) FROM tbl_tint WHERE temp ?< startValue(temp);
SELECT COUNT(*) FROM tbl_tfloat WHERE temp ?< startValue(temp);
SELECT COUNT(*) FROM tbl_ttext WHERE temp ?< startValue(temp);

SELECT COUNT(*) FROM tbl_tint WHERE startValue(temp) ?< temp;
SELECT COUNT(*) FROM tbl_tfloat WHERE startValue(temp) ?< temp;
SELECT COUNT(*) FROM tbl_ttext WHERE startValue(temp) ?< temp;

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp %< i;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp %< f;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp %< t;

SELECT COUNT(*) FROM tbl_int, tbl_tint WHERE i %< temp;
SELECT COUNT(*) FROM tbl_float, tbl_tfloat WHERE f %< temp;
SELECT COUNT(*) FROM tbl_text, tbl_ttext WHERE t %< temp;

SELECT COUNT(*) FROM tbl_tint WHERE temp ?<= startValue(temp);
SELECT COUNT(*) FROM tbl_tfloat WHERE temp ?<= startValue(temp);
SELECT COUNT(*) FROM tbl_ttext WHERE temp ?<= startValue(temp);

SELECT COUNT(*) FROM tbl_tint WHERE startValue(temp) ?<= temp;
SELECT COUNT(*) FROM tbl_tfloat WHERE startValue(temp) ?<= temp;
SELECT COUNT(*) FROM tbl_ttext WHERE startValue(temp) ?<= temp;

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp %<= i;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp %<= f;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp %<= t;

SELECT COUNT(*) FROM tbl_int, tbl_tint WHERE i %<= temp;
SELECT COUNT(*) FROM tbl_float, tbl_tfloat WHERE f %<= temp;
SELECT COUNT(*) FROM tbl_text, tbl_ttext WHERE t %<= temp;

SELECT COUNT(*) FROM tbl_tint WHERE temp ?> startValue(temp);
SELECT COUNT(*) FROM tbl_tfloat WHERE temp ?> startValue(temp);
SELECT COUNT(*) FROM tbl_ttext WHERE temp ?> startValue(temp);

SELECT COUNT(*) FROM tbl_tint WHERE startValue(temp) ?> temp;
SELECT COUNT(*) FROM tbl_tfloat WHERE startValue(temp) ?> temp;
SELECT COUNT(*) FROM tbl_ttext WHERE startValue(temp) ?> temp;

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp %> i;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp %> f;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp %> t;

SELECT COUNT(*) FROM tbl_int, tbl_tint WHERE i %> temp;
SELECT COUNT(*) FROM tbl_float, tbl_tfloat WHERE f %> temp;
SELECT COUNT(*) FROM tbl_text, tbl_ttext WHERE t %> temp;

SELECT COUNT(*) FROM tbl_tint WHERE temp ?>= startValue(temp);
SELECT COUNT(*) FROM tbl_tfloat WHERE temp ?>= startValue(temp);
SELECT COUNT(*) FROM tbl_ttext WHERE temp ?>= startValue(temp);

SELECT COUNT(*) FROM tbl_tint WHERE startValue(temp) ?>= temp;
SELECT COUNT(*) FROM tbl_tfloat WHERE startValue(temp) ?>= temp;
SELECT COUNT(*) FROM tbl_ttext WHERE startValue(temp) ?>= temp;

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp %>= i;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp %>= f;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp %>= t;

SELECT COUNT(*) FROM tbl_int, tbl_tint WHERE i %>= temp;
SELECT COUNT(*) FROM tbl_float, tbl_tfloat WHERE temp %>= temp;
SELECT COUNT(*) FROM tbl_text, tbl_ttext WHERE temp %>= temp;

-------------------------------------------------------------------------------

-- RESTRICTION SELECTIVITY
-- Test index support function

CREATE INDEX tbl_tbool_big_rtree_030_temporal_compops_idx ON tbl_tbool_big USING gist(temp);
CREATE INDEX tbl_tint_big_rtree_030_temporal_compops_idx ON tbl_tint_big USING gist(temp);
CREATE INDEX tbl_tfloat_big_rtree_030_temporal_compops_idx ON tbl_tfloat_big USING gist(temp);
CREATE INDEX tbl_ttext_rtree_030_temporal_compops_idx ON tbl_ttext_big USING gist(temp);

-- EXPLAIN ANALYZE
SELECT COUNT(*) FROM tbl_tint_big WHERE temp ?= 1;
SELECT COUNT(*) FROM tbl_tfloat_big WHERE temp ?= 1.5;
SELECT COUNT(*) FROM tbl_ttext_big WHERE temp ?= text 'AAA';

SELECT COUNT(*) FROM tbl_tint_big WHERE temp %= 1;
SELECT COUNT(*) FROM tbl_tfloat_big WHERE temp %= 1.5;
SELECT COUNT(*) FROM tbl_ttext_big WHERE temp %= text 'AAA';

DROP INDEX tbl_tbool_big_rtree_030_temporal_compops_idx;
DROP INDEX tbl_tint_big_rtree_030_temporal_compops_idx;
DROP INDEX tbl_tfloat_big_rtree_030_temporal_compops_idx;
DROP INDEX tbl_ttext_rtree_030_temporal_compops_idx;

-------------------------------------------------------------------------------

-- RESTRICTION SELECTIVITY
-- Test index support function

CREATE INDEX tbl_tbool_big_quadtree_030_temporal_compops_idx ON tbl_tbool_big USING spgist(temp);
CREATE INDEX tbl_tint_big_quadtree_030_temporal_compops_idx ON tbl_tint_big USING spgist(temp);
CREATE INDEX tbl_tfloat_big_quadtree_030_temporal_compops_idx ON tbl_tfloat_big USING spgist(temp);
CREATE INDEX tbl_ttext_quadtree_030_temporal_compops_idx ON tbl_ttext_big USING spgist(temp);

-- EXPLAIN ANALYZE
SELECT COUNT(*) FROM tbl_tint_big WHERE temp ?= 1;
SELECT COUNT(*) FROM tbl_tfloat_big WHERE temp ?= 1.5;
SELECT COUNT(*) FROM tbl_tint_big WHERE temp %= 1;
SELECT COUNT(*) FROM tbl_tfloat_big WHERE temp %= 1.5;

DROP INDEX tbl_tbool_big_quadtree_030_temporal_compops_idx;
DROP INDEX tbl_tint_big_quadtree_030_temporal_compops_idx;
DROP INDEX tbl_tfloat_big_quadtree_030_temporal_compops_idx;
DROP INDEX tbl_ttext_quadtree_030_temporal_compops_idx;

-------------------------------------------------------------------------------
-- Ever comparisons
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_bool t1, tbl_tbool t2 WHERE t1.b ?= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_bool t2 WHERE t1.temp ?= t2.b IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_tbool t2 WHERE t1.temp ?= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_bool t1, tbl_tbool t2 WHERE t1.b ?<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_bool t2 WHERE t1.temp ?<> t2.b IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_tbool t2 WHERE t1.temp ?<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_int t1, tbl_tint t2 WHERE t1.i ?= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint t1, tbl_int t2 WHERE t1.temp ?= t2.i IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp ?= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_int t1, tbl_tint t2 WHERE t1.i ?<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint t1, tbl_int t2 WHERE t1.temp ?<> t2.i IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp ?<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_float t1, tbl_tfloat t2 WHERE t1.f ?= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_float t2 WHERE t1.temp ?= t2.f IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp ?= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_float t1, tbl_tfloat t2 WHERE t1.f ?<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_float t2 WHERE t1.temp ?<> t2.f IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp ?<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_text t1, tbl_ttext t2 WHERE t1.t ?= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_text t2 WHERE t1.temp ?= t2.t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp ?= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_text t1, tbl_ttext t2 WHERE t1.t ?<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_text t2 WHERE t1.temp ?<> t2.t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp ?<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Always comparisons
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_bool t1, tbl_tbool t2 WHERE t1.b %= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_bool t2 WHERE t1.temp %= t2.b IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_tbool t2 WHERE t1.temp %= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_bool t1, tbl_tbool t2 WHERE t1.b %<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_bool t2 WHERE t1.temp %<> t2.b IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_tbool t2 WHERE t1.temp %<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_int t1, tbl_tint t2 WHERE t1.i %= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint t1, tbl_int t2 WHERE t1.temp %= t2.i IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp %= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_int t1, tbl_tint t2 WHERE t1.i %<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint t1, tbl_int t2 WHERE t1.temp %<> t2.i IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp %<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_float t1, tbl_tfloat t2 WHERE t1.f %= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_float t2 WHERE t1.temp %= t2.f IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp %= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_float t1, tbl_tfloat t2 WHERE t1.f %<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_float t2 WHERE t1.temp %<> t2.f IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp %<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_text t1, tbl_ttext t2 WHERE t1.t %= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_text t2 WHERE t1.temp %= t2.t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp %= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_text t1, tbl_ttext t2 WHERE t1.t %<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_text t2 WHERE t1.temp %<> t2.t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp %<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Temporal eq
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_tbool WHERE true #= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool WHERE temp #= true IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_tbool t2 WHERE t1.temp #= t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE i #= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp #= i IS NOT NULL;

SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE f #= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp #= f IS NOT NULL;


SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp #= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp #= t2.temp IS NOT NULL;

/* Roundoff errors */
SELECT DISTINCT (temp #= temp) = (temp #= temp + 1e-16) FROM tbl_tfloat WHERE temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE t #= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp #= t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp #= t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Temporal ne
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_tbool WHERE true #<> temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool WHERE temp #<> true IS NOT NULL;
SELECT COUNT(*) FROM tbl_tbool t1, tbl_tbool t2 WHERE t1.temp #<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE i #<> temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp #<> i IS NOT NULL;

SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE f #<> temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp #<> f IS NOT NULL;

SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp #<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp #<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE t #<> temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp #<> t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp #<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Temporal lt
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE i #< temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp #< i IS NOT NULL;

SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE f #< temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp #< f IS NOT NULL;

SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp #< t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp #< t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE t #< temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp #< t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp #< t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Temporal gt
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE i #> temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp #> i IS NOT NULL;

SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE f #> temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp #> f IS NOT NULL;

SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp #> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp #> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE t #> temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp #> t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp #> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Temporal le
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE i #<= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp #<= i IS NOT NULL;

SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE f #<= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp #<= f IS NOT NULL;

SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp #<= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp #<= t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE t #<= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp #<= t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp #<= t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Temporal ge
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE i #>= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tint, tbl_int WHERE temp #>= i IS NOT NULL;

SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE f #>= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat, tbl_float WHERE temp #>= f IS NOT NULL;

SELECT COUNT(*) FROM tbl_tint t1, tbl_tint t2 WHERE t1.temp #>= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloat t1, tbl_tfloat t2 WHERE t1.temp #>= t2.temp IS NOT NULL;

-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE t #>= temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext, tbl_text WHERE temp #>= t IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttext t1, tbl_ttext t2 WHERE t1.temp #>= t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
