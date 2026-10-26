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

CREATE TABLE tbl_geodstbox (
    k integer,
    b stbox
);
\set filename :srcdir '/mobilitydb/test/h3/data/tbl_geodstbox.data'
COPY tbl_geodstbox (k, b) FROM :'filename';

CREATE TABLE tbl_h3index (
    k integer,
    h3 h3index
);
\set filename :srcdir '/mobilitydb/test/h3/data/tbl_h3index.data'
COPY tbl_h3index (k, h3) FROM :'filename';

CREATE TABLE tbl_h3indexset (
    k integer,
    s h3indexset
);
\set filename :srcdir '/mobilitydb/test/h3/data/tbl_h3indexset.data'
COPY tbl_h3indexset (k, s) FROM :'filename';

CREATE TABLE tbl_th3index (
    k integer,
    temp th3index
);
\set filename :srcdir '/mobilitydb/test/h3/data/tbl_th3index.data'
COPY tbl_th3index (k, temp) FROM :'filename';

CREATE TABLE tbl_th3index_big (
    k integer,
    temp th3index
);
\set filename :srcdir '/mobilitydb/test/h3/data/tbl_th3index_big.data'
COPY tbl_th3index_big (k, temp) FROM :'filename';

CREATE TABLE tbl_th3index_discseq (
    k integer,
    ti th3index
);
\set filename :srcdir '/mobilitydb/test/h3/data/tbl_th3index_discseq.data'
COPY tbl_th3index_discseq (k, ti) FROM :'filename';

CREATE TABLE tbl_th3index_inst (
    k integer,
    inst th3index
);
\set filename :srcdir '/mobilitydb/test/h3/data/tbl_th3index_inst.data'
COPY tbl_th3index_inst (k, inst) FROM :'filename';

CREATE TABLE tbl_th3index_seq (
    k integer,
    seq th3index
);
\set filename :srcdir '/mobilitydb/test/h3/data/tbl_th3index_seq.data'
COPY tbl_th3index_seq (k, seq) FROM :'filename';

CREATE TABLE tbl_th3index_seqset (
    k integer,
    ss th3index
);
\set filename :srcdir '/mobilitydb/test/h3/data/tbl_th3index_seqset.data'
COPY tbl_th3index_seqset (k, ss) FROM :'filename';

ANALYZE tbl_geodstbox, tbl_h3index, tbl_h3indexset, tbl_th3index, tbl_th3index_big, tbl_th3index_discseq, tbl_th3index_inst, tbl_th3index_seq, tbl_th3index_seqset;
