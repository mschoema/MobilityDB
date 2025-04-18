/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 * Copyright (c) 2016-2025, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2025, PostGIS contributors
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without a written
 * agreement is hereby granted, provided that the above copyright notice and
 * this paragraph and the following two paragraphs appear in all copies.
 *
 * IN NO EVENT SHALL UNIVERSITE LIBRE DE BRUXELLES BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
 * LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF UNIVERSITE LIBRE DE BRUXELLES HAS BEEN ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * UNIVERSITE LIBRE DE BRUXELLES SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON
 * AN "AS IS" BASIS, AND UNIVERSITE LIBRE DE BRUXELLES HAS NO OBLIGATIONS TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 *****************************************************************************/

/*
 * create_test_tables_temporal.sql
 * Function generating a set of test tables for some PostgreSQL data types
 * and for temporal data types.
 *
 * These functions use the random generator for these types that are in the
 * file random_temporal.sql. Refer to that file for the meaning of the
 * parameters used in the function calls of this file.
 */

DROP FUNCTION IF EXISTS create_test_tables_temporal();
CREATE OR REPLACE FUNCTION create_test_tables_temporal(size int DEFAULT 100)
RETURNS text AS $$
DECLARE
  perc int;
BEGIN
perc := size * 0.01;
IF perc < 1 THEN perc := 1; END IF;

-------------------------------------------------------------------------------
-- Base types
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_bool;
CREATE TABLE tbl_bool(k, b) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_bool()
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_int;
CREATE TABLE tbl_int(k, i) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_int(0, 100)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_bigint;
CREATE TABLE tbl_bigint(k, b) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_bigint(0, 100)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_float;
CREATE TABLE tbl_float(k, f) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_float(0, 100)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_text;
CREATE TABLE tbl_text(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_text(10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_date;
CREATE TABLE tbl_date(k, d) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_date('2001-01-01', '2001-12-31')
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_timestamptz;
CREATE TABLE tbl_timestamptz(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_timestamptz('2001-01-01', '2001-12-31')
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_interval;
CREATE TABLE tbl_interval(k, i) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_minutes(1, 100)
FROM generate_series(perc+1, size) AS k;

-------------------------------------------------------------------------------
-- Set types
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_intset;
CREATE TABLE tbl_intset(k, i) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_intset(1, 100, 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_bigintset;
CREATE TABLE tbl_bigintset(k, b) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_bigintset(1, 100, 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_floatset;
CREATE TABLE tbl_floatset(k, f) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_floatset(1, 100, 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_textset;
CREATE TABLE tbl_textset(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_textset(10, 1, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_dateset;
CREATE TABLE tbl_dateset(k, d) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_dateset('2001-01-01', '2001-12-31', 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_tstzset;
CREATE TABLE tbl_tstzset(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tstzset('2001-01-01', '2001-12-31', 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

-------------------------------------------------------------------------------
-- Span types
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_intspan;
CREATE TABLE tbl_intspan(k, i) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_intspan(1, 100, 10, 5)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_bigintspan;
CREATE TABLE tbl_bigintspan(k, b) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_bigintspan(1, 100, 10, 5)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_floatspan;
CREATE TABLE tbl_floatspan(k, f) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_floatspan(1, 100, 10, 5)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_datespan;
CREATE TABLE tbl_datespan(k, d) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_datespan('2001-01-01', '2001-12-31', 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_tstzspan;
CREATE TABLE tbl_tstzspan(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tstzspan('2001-01-01', '2001-12-31', 10)
FROM generate_series(perc+1, size) AS k;

-------------------------------------------------------------------------------
-- Span set types
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_intspanset;
CREATE TABLE tbl_intspanset(k, i) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_intspanset(1, 100, 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_bigintspanset;
CREATE TABLE tbl_bigintspanset(k, b) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_bigintspanset(1, 100, 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_floatspanset;
CREATE TABLE tbl_floatspanset(k, f) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_floatspanset(1, 100, 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_datespanset;
CREATE TABLE tbl_datespanset(k, d) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_datespanset('2001-01-01', '2001-12-31', 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_tstzspanset;
CREATE TABLE tbl_tstzspanset(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tstzspanset('2001-01-01', '2001-12-31', 10, 5, 10)
FROM generate_series(perc+1, size) AS k;

-------------------------------------------------------------------------------
-- Range and multirange types
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_int4range;
CREATE TABLE tbl_int4range(k, i) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_int4range(0, 100, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_float8range;
CREATE TABLE tbl_float8range(k, f) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_float8range(0, 100, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_daterange;
CREATE TABLE tbl_daterange(k, d) AS
/* Add perc NULL values */
SELECT k, NULL AS d
FROM generate_series(1, perc) AS k UNION
SELECT k, random_daterange('2001-01-01', '2001-12-31', 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_tstzrange;
CREATE TABLE tbl_tstzrange(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tstzrange('2001-01-01', '2001-12-31', 10)
FROM generate_series(perc+1, size) AS k;

-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_datemultirange;
CREATE TABLE tbl_datemultirange(k, d) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_datespanset('2001-01-01', '2001-12-31', 10, 5, 10)::datemultirange
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_tstzmultirange;
CREATE TABLE tbl_tstzmultirange(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tstzspanset('2001-01-01', '2001-12-31', 10, 5, 10)::tstzmultirange
FROM generate_series(perc+1, size) AS k;

-------------------------------------------------------------------------------
-- Tbox types
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_tboxint;
CREATE TABLE tbl_tboxint(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tboxint(0, 100, '2001-01-01', '2001-12-31', 10, 10)
FROM generate_series(perc+1, size) AS k;

DROP TABLE IF EXISTS tbl_tboxfloat;
CREATE TABLE tbl_tboxfloat(k, t) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tboxfloat(0, 100, '2001-01-01', '2001-12-31', 10, 10)
FROM generate_series(perc+1, size) AS k;

------------------------------------------------------------------------------
-- Temporal Types
------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_tbool_inst;
CREATE TABLE tbl_tbool_inst(k, inst) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tbool_inst('2001-01-01', '2001-12-31')
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tbool_inst t1
SET inst = (SELECT inst FROM tbl_tbool_inst t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tbool_inst t1
SET inst = (SELECT tbool_inst(random_bool(), getTimestamp(inst))
  FROM tbl_tbool_inst t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);

DROP TABLE IF EXISTS tbl_tint_inst;
CREATE TABLE tbl_tint_inst(k, inst) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tint_inst(0, 100, '2001-01-01', '2001-12-31')
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tint_inst t1
SET inst = (SELECT inst FROM tbl_tint_inst t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tint_inst t1
SET inst = (SELECT tint_inst(random_int(0, 100), getTimestamp(inst))
  FROM tbl_tint_inst t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);

DROP TABLE IF EXISTS tbl_tfloat_inst;
CREATE TABLE tbl_tfloat_inst(k, inst) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tfloat_inst(0, 100, '2001-01-01', '2001-12-31')
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tfloat_inst t1
SET inst = (SELECT inst FROM tbl_tfloat_inst t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tfloat_inst t1
SET inst = (SELECT tfloat_inst(random_float(1, 100), getTimestamp(inst))
  FROM tbl_tfloat_inst t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);

DROP TABLE IF EXISTS tbl_ttext_inst;
CREATE TABLE tbl_ttext_inst(k, inst) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_ttext_inst('2001-01-01', '2001-12-31', 10)
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_ttext_inst t1
SET inst = (SELECT inst FROM tbl_ttext_inst t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_ttext_inst t1
SET inst = (SELECT ttext_inst(random_text(10), getTimestamp(inst))
  FROM tbl_ttext_inst t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);

-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_tbool_discseq;
CREATE TABLE tbl_tbool_discseq(k, ti) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tbool_discseq('2001-01-01', '2001-12-31', 10, 5, 10)
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tbool_discseq t1
SET ti = (SELECT ti FROM tbl_tbool_discseq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tbool_discseq t1
SET ti = (SELECT ~ ti FROM tbl_tbool_discseq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tbool_discseq t1
SET ti = (SELECT shift(ti, endTimestamp(ti)-startTimestamp(ti))
  FROM tbl_tbool_discseq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tbool_discseq t1
SET ti = (SELECT shift(ti, date_trunc('minute',(endTimestamp(ti)-startTimestamp(ti))/2))
  FROM tbl_tbool_discseq t2 WHERE t2.k = t1.k+2)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_tint_discseq;
CREATE TABLE tbl_tint_discseq(k, ti) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tint_discseq(1, 100, '2001-01-01', '2001-12-31', 10, 10, 5, 10)
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tint_discseq t1
SET ti = (SELECT ti FROM tbl_tint_discseq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tint_discseq t1
SET ti = (SELECT ti + random_int(1, 2) FROM tbl_tint_discseq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tint_discseq t1
SET ti = (SELECT shift(ti, endTimestamp(ti)-startTimestamp(ti))
  FROM tbl_tint_discseq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tint_discseq t1
SET ti = (SELECT shift(ti, date_trunc('minute',(endTimestamp(ti)-startTimestamp(ti))/2))
  FROM tbl_tint_discseq t2 WHERE t2.k = t1.k+2)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_tfloat_discseq;
CREATE TABLE tbl_tfloat_discseq(k, ti) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tfloat_discseq(1, 100, '2001-01-01', '2001-12-31', 10, 10, 5, 10)
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tfloat_discseq t1
SET ti = (SELECT ti FROM tbl_tfloat_discseq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tfloat_discseq t1
SET ti = (SELECT ti + random_int(1, 2) FROM tbl_tfloat_discseq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tfloat_discseq t1
SET ti = (SELECT shift(ti, endTimestamp(ti)-startTimestamp(ti))
  FROM tbl_tfloat_discseq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tfloat_discseq t1
SET ti = (SELECT shift(ti, date_trunc('minute',(endTimestamp(ti)-startTimestamp(ti))/2))
  FROM tbl_tfloat_discseq t2 WHERE t2.k = t1.k+2)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_ttext_discseq;
CREATE TABLE tbl_ttext_discseq(k, ti) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_ttext_discseq('2001-01-01', '2001-12-31', 10, 10, 5, 10)
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_ttext_discseq t1
SET ti = (SELECT ti FROM tbl_ttext_discseq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_ttext_discseq t1
SET ti = (SELECT ti || text 'A' FROM tbl_ttext_discseq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_ttext_discseq t1
SET ti = (SELECT shift(ti, endTimestamp(ti)-startTimestamp(ti))
  FROM tbl_ttext_discseq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_ttext_discseq t1
SET ti = (SELECT shift(ti, date_trunc('minute',(endTimestamp(ti)-startTimestamp(ti))/2))
  FROM tbl_ttext_discseq t2 WHERE t2.k = t1.k+2)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_tbool_seq;
CREATE TABLE tbl_tbool_seq(k, seq) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tbool_seq('2001-01-01', '2001-12-31', 10, 5, 10) AS seq
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tbool_seq t1
SET seq = (SELECT seq FROM tbl_tbool_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tbool_seq t1
SET seq = (SELECT ~ seq FROM tbl_tbool_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tbool_seq t1
SET seq = (SELECT shift(seq, duration(seq, true)) FROM tbl_tbool_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tbool_seq t1
SET seq = (SELECT shift(seq, date_trunc('minute', duration(seq, true)/2))
  FROM tbl_tbool_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_tint_seq;
CREATE TABLE tbl_tint_seq(k, seq) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tint_seq(1, 100, '2001-01-01', '2001-12-31', 10, 10, 5, 10) AS seq
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tint_seq t1
SET seq = (SELECT seq FROM tbl_tint_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tint_seq t1
SET seq = (SELECT seq + random_int(1, 2) FROM tbl_tint_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tint_seq t1
SET seq = (SELECT shift(seq, duration(seq, true)) FROM tbl_tint_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tint_seq t1
SET seq = (SELECT shift(seq, date_trunc('minute',duration(seq, true)/2))
  FROM tbl_tint_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_tfloat_seq;
CREATE TABLE tbl_tfloat_seq(k, seq) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tfloat_seq(1, 100, '2001-01-01', '2001-12-31', 10, 10, 5, 10) AS seq
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tfloat_seq t1
SET seq = (SELECT seq FROM tbl_tfloat_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tfloat_seq t1
SET seq = (SELECT seq + random_int(1, 2) FROM tbl_tfloat_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tfloat_seq t1
SET seq = (SELECT shift(seq, duration(seq, true)) FROM tbl_tfloat_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tfloat_seq t1
SET seq = (SELECT shift(seq, date_trunc('minute',duration(seq, true)/2))
  FROM tbl_tfloat_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_ttext_seq;
CREATE TABLE tbl_ttext_seq(k, seq) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_ttext_seq('2001-01-01', '2001-12-31', 10, 10, 5, 10) AS seq
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_ttext_seq t1
SET seq = (SELECT seq FROM tbl_ttext_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_ttext_seq t1
SET seq = (SELECT seq || text 'A' FROM tbl_ttext_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_ttext_seq t1
SET seq = (SELECT shift(seq, duration(seq, true)) FROM tbl_ttext_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_ttext_seq t1
SET seq = (SELECT shift(seq, date_trunc('minute',duration(seq, true)/2))
  FROM tbl_ttext_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_tbool_seqset;
CREATE TABLE tbl_tbool_seqset(k, ts) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tbool_seqset('2001-01-01', '2001-12-31', 10, 5, 10, 5, 10) AS ts
FROM generate_series(perc+1, size) AS k;
/* Add perc duplicates */
UPDATE tbl_tbool_seqset t1
SET ts = (SELECT ts FROM tbl_tbool_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tbool_seqset t1
SET ts = (SELECT ~ ts FROM tbl_tbool_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tbool_seqset t1
SET ts = (SELECT shift(ts, duration(ts, true)) FROM tbl_tbool_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tbool_seqset t1
SET ts = (SELECT shift(ts, date_trunc('minute', duration(ts, true)/2))
  FROM tbl_tbool_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_tint_seqset;
CREATE TABLE tbl_tint_seqset(k, ts) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tint_seqset(1, 100, '2001-01-01', '2001-12-31', 10, 10, 5, 10, 5, 10)
FROM generate_series(perc+1, size) AS k;
/* Add perc duplicates */
UPDATE tbl_tint_seqset t1
SET ts = (SELECT ts FROM tbl_tint_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tint_seqset t1
SET ts = (SELECT ts + random_int(1, 2) FROM tbl_tint_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tint_seqset t1
SET ts = (SELECT shift(ts, duration(ts, true)) FROM tbl_tint_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tint_seqset t1
SET ts = (SELECT shift(ts, date_trunc('minute', duration(ts, true)/2))
  FROM tbl_tint_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_tfloat_seqset;
CREATE TABLE tbl_tfloat_seqset(k, ts) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tfloat_seqset(1, 100, '2001-01-01', '2001-12-31', 10, 10, 5, 10, 5, 10)
FROM generate_series(perc+1, size) AS k;
/* Add perc duplicates */
UPDATE tbl_tfloat_seqset t1
SET ts = (SELECT ts FROM tbl_tfloat_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tfloat_seqset t1
SET ts = (SELECT ts + random_int(1, 2) FROM tbl_tfloat_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tfloat_seqset t1
SET ts = (SELECT shift(ts, duration(ts, true)) FROM tbl_tfloat_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tfloat_seqset t1
SET ts = (SELECT shift(ts, date_trunc('minute', duration(ts, true)/2))
  FROM tbl_tfloat_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_ttext_seqset;
CREATE TABLE tbl_ttext_seqset(k, ts) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_ttext_seqset('2001-01-01', '2001-12-31', 10, 10, 5, 10, 5, 10)
FROM generate_series(perc+1, size) AS k;
/* Add perc duplicates */
UPDATE tbl_ttext_seqset t1
SET ts = (SELECT ts FROM tbl_ttext_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_ttext_seqset t1
SET ts = (SELECT ts || text 'A' FROM tbl_ttext_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_ttext_seqset t1
SET ts = (SELECT shift(ts, duration(ts, true)) FROM tbl_ttext_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_ttext_seqset t1
SET ts = (SELECT shift(ts, date_trunc('minute', duration(ts, true)/2))
  FROM tbl_ttext_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

-------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_tbool;
CREATE TABLE tbl_tbool(k, temp) AS
(SELECT k, inst FROM tbl_tbool_inst order by k limit size / 4) UNION all
(SELECT k + size / 4, ti FROM tbl_tbool_discseq order by k limit size / 4) UNION all
(SELECT k + size / 2, seq FROM tbl_tbool_seq order by k limit size / 4) UNION all
(SELECT k + size / 4 * 3, ts FROM tbl_tbool_seqset order by k limit size / 4);

DROP TABLE IF EXISTS tbl_tint;
CREATE TABLE tbl_tint(k, temp) AS
(SELECT k, inst FROM tbl_tint_inst order by k limit size / 4) UNION all
(SELECT k + size / 4, ti FROM tbl_tint_discseq order by k limit size / 4) UNION all
(SELECT k + size / 2, seq FROM tbl_tint_seq order by k limit size / 4) UNION all
(SELECT k + size / 4 * 3, ts FROM tbl_tint_seqset order by k limit size / 4);

DROP TABLE IF EXISTS tbl_tfloat;
CREATE TABLE tbl_tfloat(k, temp) AS
(SELECT k, inst FROM tbl_tfloat_inst order by k limit size / 4) UNION all
(SELECT k + size / 4, ti FROM tbl_tfloat_discseq order by k limit size / 4) UNION all
(SELECT k + size / 2, seq FROM tbl_tfloat_seq order by k limit size / 4) UNION all
(SELECT k + size / 4 * 3, ts FROM tbl_tfloat_seqset order by k limit size / 4);

DROP TABLE IF EXISTS tbl_ttext;
CREATE TABLE tbl_ttext(k, temp) AS
(SELECT k, inst FROM tbl_ttext_inst order by k limit size / 4) UNION all
(SELECT k + size / 4, ti FROM tbl_ttext_discseq order by k limit size / 4) UNION all
(SELECT k + size / 2, seq FROM tbl_ttext_seq order by k limit size / 4) UNION all
(SELECT k + size / 4 * 3, ts FROM tbl_ttext_seqset order by k limit size / 4);

------------------------------------------------------------------------------
-- Temporal Float Types with Step Interpolation
------------------------------------------------------------------------------

DROP TABLE IF EXISTS tbl_tfloat_step_seq;
CREATE TABLE tbl_tfloat_step_seq(k, seq) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tfloat_seq(1, 100, '2001-01-01', '2001-12-31', 10, 10, 5, 10, linear:=false)
FROM generate_series(perc+1, size) k;
/* Add perc duplicates */
UPDATE tbl_tfloat_step_seq t1
SET seq = (SELECT seq FROM tbl_tfloat_step_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tfloat_step_seq t1
SET seq = (SELECT seq + random_int(1, 2) FROM tbl_tfloat_step_seq t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tfloat_step_seq t1
SET seq = (SELECT shift(seq, duration(seq, true)) FROM tbl_tfloat_step_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tfloat_step_seq t1
SET seq = (SELECT shift(seq, date_trunc('minute',duration(seq, true)/2))
  FROM tbl_tfloat_step_seq t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

DROP TABLE IF EXISTS tbl_tfloat_step_seqset;
CREATE TABLE tbl_tfloat_step_seqset(k, ts) AS
/* Add perc NULL values */
SELECT k, NULL
FROM generate_series(1, perc) AS k UNION
SELECT k, random_tfloat_seqset(1, 100, '2001-01-01', '2001-12-31', 10, 10, 5, 10, 5, 10, linear:=false)
FROM generate_series(perc+1, size) AS k;
/* Add perc duplicates */
UPDATE tbl_tfloat_step_seqset t1
SET ts = (SELECT ts FROM tbl_tfloat_step_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 2*perc, 3*perc) i);
/* Add perc tuples with the same timestamp */
UPDATE tbl_tfloat_step_seqset t1
SET ts = (SELECT ts + random_int(1, 2) FROM tbl_tfloat_step_seqset t2 WHERE t2.k = t1.k+perc)
WHERE k in (SELECT i FROM generate_series(1 + 4*perc, 5*perc) i);
/* Add perc tuples that meet */
UPDATE tbl_tfloat_step_seqset t1
SET ts = (SELECT shift(ts, duration(ts, true)) FROM tbl_tfloat_step_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 6*perc, 7*perc) i);
/* Add perc tuples that overlap */
UPDATE tbl_tfloat_step_seqset t1
SET ts = (SELECT shift(ts, date_trunc('minute', duration(ts, true)/2))
  FROM tbl_tfloat_step_seqset t2 WHERE t2.k = t1.k+perc)
WHERE t1.k in (SELECT i FROM generate_series(1 + 8*perc, 9*perc) i);

-------------------------------------------------------------------------------
RETURN 'The End';
END;
$$ LANGUAGE 'plpgsql';

-- SELECT create_test_tables_temporal(100);

