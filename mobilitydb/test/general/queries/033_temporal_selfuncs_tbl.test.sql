-------------------------------------------------------------------------------
--
-- This MobilityDB code is provided under The PostgreSQL License.
-- Copyright (c) 2016-2025, Université libre de Bruxelles and MobilityDB
-- contributors
--
-- MobilityDB includes portions of PostGIS version 3 source code released
-- under the GNU General Public License (GPLv2 or later).
-- Copyright (c) 2001-2025, PostGIS contributors
--
-- Permission to use, copy, modify, and distribute this software and its
-- documentation for any purpose, without fee, and without a written
-- agreement is hereby granted, provided that the above copyright notice and
-- this paragraph and the following two paragraphs appear in all copies.
--
-- IN NO EVENT SHALL UNIVERSITE LIBRE DE BRUXELLES BE LIABLE TO ANY PARTY FOR
-- DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
-- LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
-- EVEN IF UNIVERSITE LIBRE DE BRUXELLES HAS BEEN ADVISED OF THE POSSIBILITY
-- OF SUCH DAMAGE.
--
-- UNIVERSITE LIBRE DE BRUXELLES SPECIFICALLY DISCLAIMS ANY WARRANTIES,
-- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
-- AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON
-- AN "AS IS" BASIS, AND UNIVERSITE LIBRE DE BRUXELLES HAS NO OBLIGATIONS TO
-- PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
--
-------------------------------------------------------------------------------

--SELECT st_makepoint(0.0,0.0);
--SELECT bbox_statistics_validate();
--VACUUM ANALYSE tbl_tintinst;
--VACUUM ANALYSE tbl_tfloatinst;
--VACUUM ANALYSE tbl_tgeompointinst;
--VACUUM ANALYSE tbl_tinti;
--VACUUM ANALYSE tbl_tfloati;
--VACUUM ANALYSE tbl_tgeompointi;
--VACUUM ANALYSE tbl_tintseq;
--VACUUM ANALYSE tbl_tfloatseq;
--VACUUM ANALYSE tbl_tgeompointseq;
--VACUUM ANALYSE tbl_tints;
--VACUUM ANALYSE tbl_tfloats;
--VACUUM ANALYSE tbl_tgeompoints;
--SELECT * FROM execution_stats WHERE PlanRows::text NOT like '%nan' AND abs(PlanRows::text::int - ActualRows::text::int)>10
-- 91/251
-- 80/251
-- 825/2510
-- STATISTICS COLLECTION FUNCTIONS
--SELECT * FROM execution_stats WHERE PlanRows::text = '-nan'
CREATE FUNCTION bbox_statistics_validate()
RETURNS XML AS $$
DECLARE
  Query CHAR(5);
  PlanRows XML;
  ActualRows XML;
  QFilter  XML;
  RowsRemovedbyFilter XML;
  J XML;
  StartTime TIMESTAMP;
  RandTimestamp TIMESTAMPTZ;
  RandTstzspan tstzspan;
  RandTstzset tstzset;
  RandTstzspanset tstzspanset;

  Randtintinst tint(Instant);
  Randtinti tint(Sequence);
  Randtintseq tint(Sequence);
  Randtints tint(SequenceSet);

  Randtfloatinst tfloat(Instant);
  Randtfloati tfloat(Sequence);
  Randtfloatseq tfloat(Sequence);
  Randtfloats tfloat(SequenceSet);

  Randtgeompointinst tgeompoint(Instant, Point);
  Randtgeompointi tgeompoint(Sequence, Point);
  Randtgeompointseq tgeompoint(Sequence, Point);
  Randtgeompoints tgeompoint(SequenceSet, Point);

  Randint INT;
  Randfloat FLOAT;
  Randgeompoint geometry;

  k INT;
BEGIN
DROP TABLE IF EXISTS execution_stats;
CREATE TABLE IF NOT EXISTS execution_stats
(Query CHAR(5),
StartTime TIMESTAMP,
QFilter XML,
PlanRows XML,
ActualRows XML,
RowsRemovedByFilter XML,
J XML);


TRUNCATE TABLE execution_stats;

SET log_error_verbosity TO terse;
k:= 0;

-----------------------------------------------
---- OPERATOR &&-------------------------------
-----------------------------------------------
--Q1
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q2
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q3
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q4
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q5
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q6
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q7
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q8
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q9
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q10
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q11
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q12
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q13
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q14
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q15
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q16
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q17
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q18
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q19
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q20
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q21
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q22
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q23
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q24
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q25
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q26
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q27
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q28
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q29
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q30
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q31
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q32
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q33
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q34
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q35
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q36
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q37
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q38
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q39
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss && RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q40
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q41
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q42
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss && RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q43
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q44
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q45
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss && RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q46
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q47
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q48
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss && RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR @>-------------------------------
-----------------------------------------------

--Q49
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q50
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q51
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q52
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst @> RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q53
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q54
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q55
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q56
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q57
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q58
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q59
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q60
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q61
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q62
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q63
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q64
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti @> RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q65
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q66
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q67
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q68
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q69
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q70
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q71
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q72
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q73
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q74
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q75
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q76
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq @> RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q77
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q78
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q79
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q80
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q81
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q82
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q83
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q84
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q85
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q86
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q87
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q88
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss @> RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q89
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q90
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss @> RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q91
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q92
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q93
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss @> RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q94
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q95
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q96
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss @> RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR <@-------------------------------
-----------------------------------------------
--Q97
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q98
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q99
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q100
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst <@ RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q101
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q102
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q103
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q104
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q105
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q106
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q107
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q108
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q109
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q110
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q111
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q112
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti <@ RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q113
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q114
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q115
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q116
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q117
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q118
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q119
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q120
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q121
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q122
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q123
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q124
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq <@ RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q125
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q126
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q127
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q128
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q129
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q130
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q131
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q132
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q133
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q134
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q135
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q136
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss <@ RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q137
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q138
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss <@ RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q139
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q140
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q141
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss <@ RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q142
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q143
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q144
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss <@ RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR ~=-------------------------------
-----------------------------------------------
--Q145
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q146
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q147
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q148
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst ~= RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q149
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q150
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q151
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q152
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q153
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q154
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q155
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q156
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q157
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q158
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q159
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q160
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti ~= RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q161
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q162
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q163
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q164
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q165
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q166
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q167
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q168
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q169
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q170
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q171
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q172
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq ~= RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q173
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q174
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q175
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q176
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q177
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q178
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintseq
  WHERE seq ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q179
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatseq
  WHERE seq ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q180
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointseq
  WHERE seq ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q181
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q182
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q183
k:= k+1;
FOR i IN 1..10 LOOP
  RandTimestamp:= random_timestamptz('2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q184
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss ~= RandTstzset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q185
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q186
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzset:= random_tstzset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss ~= RandTimestamp
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q187
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q188
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q189
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspan:= random_tstzspan('2000-10-01', '2002-1-31', 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss ~= RandTstzspan
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q190
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tints
  WHERE ss ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q191
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloats
  WHERE ss ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q192
k:= k+1;
FOR i IN 1..10 LOOP
  RandTstzspanset:= random_tstzspanset('2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompoints
  WHERE ss ~= RandTstzspanset
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR &&-------------------------------
-----------------------------------------------
--Q193
k:= k+1;
FOR i IN 1..10 LOOP
  Randtintinst:= random_tint_inst(-10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst && Randtintinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q194
k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloatinst:= random_tfloat_inst(-10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst && Randtfloatinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q195
k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointinst:= random_tgeompoint_inst(-10, 120, -10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst && Randtgeompointinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR @>-------------------------------
-----------------------------------------------
--Q196
k:= k+1;
FOR i IN 1..10 LOOP
  Randtintinst:= random_tint_inst(-10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst @> Randtintinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q197
k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloatinst:= random_tfloat_inst(-10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst @> Randtfloatinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q198
k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointinst:= random_tgeompoint_inst(-10, 120, -10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst @> Randtgeompointinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR <@-------------------------------
-----------------------------------------------

--Q199
k:= k+1;
FOR i IN 1..10 LOOP
  Randtintinst:= random_tint_inst(-10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst <@ Randtintinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q200
k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloatinst:= random_tfloat_inst(-10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst <@ Randtfloatinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q201
k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointinst:= random_tgeompoint_inst(-10, 120, -10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst <@ Randtgeompointinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR ~=-------------------------------
-----------------------------------------------

--Q202
k:= k+1;
FOR i IN 1..10 LOOP
  Randtintinst:= random_tint_inst(-10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst ~= Randtintinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q203
k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloatinst:= random_tfloat_inst(-10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst ~= Randtfloatinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q204
k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointinst:= random_tgeompoint_inst(-10, 120, -10, 120, '2000-10-01', '2002-1-31');
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointinst
  WHERE inst ~= Randtgeompointinst
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR &&-------------------------------
-----------------------------------------------

--Q205
k:= k+1;
FOR i IN 1..10 LOOP
  Randtinti:= random_tint_discseq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst && Randtinti
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q206
k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloati:= random_tfloat__discseq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst && Randtfloati
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q207
k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointi:= random_tgeompoint_discseq(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti && Randtgeompointi
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR @>-------------------------------
-----------------------------------------------

--Q208
k:= k+1;
FOR i IN 1..10 LOOP
  Randtinti:= random_tint_discseq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti @> Randtinti
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q209
k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloati:= random_tfloat_discseq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti @> Randtfloati
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--Q210
k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointi:= random_tgeompoint_discseq(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti @> Randtgeompointi
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR <@-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtinti:= random_tint_discseq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti <@ Randtinti
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloati:= random_tfloat_discseq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti <@ Randtfloati
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointi:= random_tgeompoint_discseq(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti <@ Randtgeompointi
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR ~=-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtinti:= random_tint_discseq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti ~= Randtinti
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloati:= random_tfloat_discseq(-10, 120, '2000-10-01', '2002-1-31',10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti ~= Randtfloati
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointi:= random_tgeompoint_discseq(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti ~= Randtgeompointi
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR &&-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtintseq:= random_tint_seq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst && Randtintseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloatseq:= random_tfloat_seq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst && Randtfloatseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

--k:= k+1;
--FOR i IN 1..10 LOOP
--  Randtgeompointseq:= random_tgeompoint_seq(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10);
--  EXPLAIN (ANALYZE, FORMAT XML)
--  SELECT *
--  FROM tbl_tgeompointi
--  WHERE ti && Randtgeompointseq
--  INTO J;
--
--  StartTime := clock_timestamp();
--  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
--  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
--  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
--  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
--
--  Query:= 'Q' || k;
--  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, NULL);
--END LOOP;


-----------------------------------------------
---- OPERATOR @>-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtintseq:= random_tint_seq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti @> Randtintseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloatseq:= random_tfloat_seq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti @> Randtfloatseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointseq:= random_tgeompoint_seq(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti @> Randtgeompointseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR <@-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtintseq:= random_tint_seq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti <@ Randtintseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloatseq:= random_tfloat_seq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti <@ Randtfloatseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointseq:= random_tgeompoint_seq(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti <@ Randtgeompointseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR ~=-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtintseq:= random_tint_seq(-10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti ~= Randtintseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloatseq:= random_tfloat_seq(-10, 120, '2000-10-01', '2002-1-31',10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti ~= Randtfloatseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompointseq:= random_tgeompoint_seq(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti ~= Randtgeompointseq
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR &&-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtints:= random_tint_seqset(-10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst && Randtints
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloats:= random_tfloat_seqset(-10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst && Randtfloats
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompoints:= random_tgeompoint_seqset(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti && Randtgeompoints
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR @>-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtints:= random_tint_seqset(-10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti @> Randtints
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloats:= random_tfloat_seqset(-10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti @> Randtfloats
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompoints:= random_tgeompoint_seqset(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti @> Randtgeompoints
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR <@-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtints:= random_tint_seqset(-10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti <@ Randtints
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloats:= random_tfloat_seqset(-10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti <@ Randtfloats
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompoints:= random_tgeompoint_seqset(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti <@ Randtgeompoints
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR ~=-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randtints:= random_tint_seqset(-10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti ~= Randtints
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtfloats:= random_tfloat_seqset(-10, 120, '2000-10-01', '2002-1-31',10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti ~= Randtfloats
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randtgeompoints:= random_tgeompoint_seqset(-10, 120, -10, 120, '2000-10-01', '2002-1-31', 10, 10, 10);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti ~= Randtgeompoints
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR &&-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randint:= random_int(-10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tintinst
  WHERE inst && Randint
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randfloat:= random_float(-10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloatinst
  WHERE inst && Randfloat
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randgeompoint:= random_geompoint(-10, 120, -10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti && Randgeompoint
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR @>-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randint:= random_int(-10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti @> Randint
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randfloat:= random_float(-10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti @> Randfloat
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randgeompoint:= random_geompoint(-10, 120, -10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti @> Randgeompoint
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR <@-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randint:= random_int(-10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti <@ Randint
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randfloat:= random_float(-10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti <@ Randfloat
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randgeompoint:= random_geompoint(-10, 120, -10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti <@ Randgeompoint
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

-----------------------------------------------
---- OPERATOR ~=-------------------------------
-----------------------------------------------

k:= k+1;
FOR i IN 1..10 LOOP
  Randint:= random_int(-10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tinti
  WHERE ti ~= Randint
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randfloat:= random_float(-10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tfloati
  WHERE ti ~= Randfloat
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

k:= k+1;
FOR i IN 1..10 LOOP
  Randgeompoint:= random_geompoint(-10, 120, -10, 120);
  EXPLAIN (ANALYZE, FORMAT XML)
  SELECT *
  FROM tbl_tgeompointi
  WHERE ti ~= Randgeompoint
  INTO J;

  StartTime := clock_timestamp();
  PlanRows:= (xpath('/n:explain/n:Query/n:Plan/n:Plan-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  ActualRows:=  (xpath('/n:explain/n:Query/n:Plan/n:Actual-Rows/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  QFilter:=  (xpath('/n:explain/n:Query/n:Plan/n:Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];
  RowsRemovedbyFilter:= (xpath('/n:explain/n:Query/n:Plan/n:Rows-Removed-by-Filter/text()', j, '{{n,http://www.postgresql.org/2009/explain}}'))[1];

  Query:= 'Q' || k;
  INSERT INTO execution_stats VALUES (Query, StartTime, QFilter, PlanRows, ActualRows, RowsRemovedByFilter, J);
END LOOP;

RETURN 'THE END';
END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------------------
