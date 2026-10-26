-------------------------------------------------------------------------------
--
-- This MobilityDB code is provided under The PostgreSQL License.
-- Copyright (c) 2016-2026, Université libre de Bruxelles and MobilityDB
-- contributors
--
-- MobilityDB includes portions of PostGIS version 3 source code released
-- under the GNU General Public License (GPLv2 or later).
-- Copyright (c) 2001-2026, PostGIS contributors
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

\getenv srcdir MOBILITYDB_SOURCE_DIR

CREATE TABLE tbl_cbuffer (
    k integer PRIMARY KEY,
    cb cbuffer
);
\set filename :srcdir '/mobilitydb/test/cbuffer/data/tbl_cbuffer.data'
COPY tbl_cbuffer (k, cb) FROM :'filename';

CREATE TABLE tbl_cbufferset (
    k integer PRIMARY KEY,
    s cbufferset
);
\set filename :srcdir '/mobilitydb/test/cbuffer/data/tbl_cbufferset.data'
COPY tbl_cbufferset (k, s) FROM :'filename';

CREATE TABLE tbl_tcbuffer (
    k integer PRIMARY KEY,
    temp tcbuffer
);
\set filename :srcdir '/mobilitydb/test/cbuffer/data/tbl_tcbuffer.data'
COPY tbl_tcbuffer (k, temp) FROM :'filename';

CREATE TABLE tbl_tcbuffer_big (
    k integer PRIMARY KEY,
    temp tcbuffer
);
\set filename :srcdir '/mobilitydb/test/cbuffer/data/tbl_tcbuffer_big.data'
COPY tbl_tcbuffer_big (k, temp) FROM :'filename';

CREATE TABLE tbl_tcbuffer_discseq (
    k integer PRIMARY KEY,
    ti tcbuffer(Sequence)
);
\set filename :srcdir '/mobilitydb/test/cbuffer/data/tbl_tcbuffer_discseq.data'
COPY tbl_tcbuffer_discseq (k, ti) FROM :'filename';

CREATE TABLE tbl_tcbuffer_inst (
    k integer PRIMARY KEY,
    inst tcbuffer(Instant)
);
\set filename :srcdir '/mobilitydb/test/cbuffer/data/tbl_tcbuffer_inst.data'
COPY tbl_tcbuffer_inst (k, inst) FROM :'filename';

CREATE TABLE tbl_tcbuffer_seqset (
    k integer PRIMARY KEY,
    ss tcbuffer(SequenceSet)
);
\set filename :srcdir '/mobilitydb/test/cbuffer/data/tbl_tcbuffer_seqset.data'
COPY tbl_tcbuffer_seqset (k, ss) FROM :'filename';

CREATE TABLE tbl_tcbuffer_seq (
    k integer PRIMARY KEY,
    seq tcbuffer(Sequence)
);
\set filename :srcdir '/mobilitydb/test/cbuffer/data/tbl_tcbuffer_seq.data'
COPY tbl_tcbuffer_seq (k, seq) FROM :'filename';

-- Launch the ANALYZE deamon to avoid that it is launched during the tests
ANALYZE;
