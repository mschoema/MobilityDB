-------------------------------------------------------------------------------
-- Ever comparisons
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_cbuffer t1, tbl_tcbuffer t2 WHERE t1.cb ?= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_cbuffer t2 WHERE t1.temp ?= t2.cb IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_tcbuffer t2 WHERE t1.temp ?= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_cbuffer t1, tbl_tcbuffer t2 WHERE t1.cb ?<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_cbuffer t2 WHERE t1.temp ?<> t2.cb IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_tcbuffer t2 WHERE t1.temp ?<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Always comparisons
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_cbuffer t1, tbl_tcbuffer t2 WHERE t1.cb %= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_cbuffer t2 WHERE t1.temp %= t2.cb IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_tcbuffer t2 WHERE t1.temp %= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_cbuffer t1, tbl_tcbuffer t2 WHERE t1.cb %<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_cbuffer t2 WHERE t1.temp %<> t2.cb IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_tcbuffer t2 WHERE t1.temp %<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
-- Temporal comparisons
-------------------------------------------------------------------------------

SELECT COUNT(*) FROM tbl_cbuffer t1, tbl_tcbuffer t2 WHERE t1.cb #= t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_cbuffer t2 WHERE t1.temp #= t2.cb IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_tcbuffer t2 WHERE t1.temp #= t2.temp IS NOT NULL;

SELECT COUNT(*) FROM tbl_cbuffer t1, tbl_tcbuffer t2 WHERE t1.cb #<> t2.temp IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_cbuffer t2 WHERE t1.temp #<> t2.cb IS NOT NULL;
SELECT COUNT(*) FROM tbl_tcbuffer t1, tbl_tcbuffer t2 WHERE t1.temp #<> t2.temp IS NOT NULL;

-------------------------------------------------------------------------------
