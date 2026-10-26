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

CREATE TABLE tbl_posechain (
    k integer,
    pc posechain
);
\set filename :srcdir '/mobilitydb/test/posechain/data/tbl_posechain.data'
COPY tbl_posechain (k, pc) FROM :'filename';

CREATE TABLE tbl_posechain2d (
    k integer,
    pc posechain
);
\set filename :srcdir '/mobilitydb/test/posechain/data/tbl_posechain2d.data'
COPY tbl_posechain2d (k, pc) FROM :'filename';

CREATE TABLE tbl_posechain3d (
    k integer,
    pc posechain
);
\set filename :srcdir '/mobilitydb/test/posechain/data/tbl_posechain3d.data'
COPY tbl_posechain3d (k, pc) FROM :'filename';

CREATE TABLE tbl_tposechain (
    k integer,
    temp tposechain
);
\set filename :srcdir '/mobilitydb/test/posechain/data/tbl_tposechain.data'
COPY tbl_tposechain (k, temp) FROM :'filename';

CREATE TABLE tbl_tposechain2d_discseq (
    k integer,
    temp tposechain
);
\set filename :srcdir '/mobilitydb/test/posechain/data/tbl_tposechain2d_discseq.data'
COPY tbl_tposechain2d_discseq (k, temp) FROM :'filename';

CREATE TABLE tbl_tposechain2d_inst (
    k integer,
    temp tposechain
);
\set filename :srcdir '/mobilitydb/test/posechain/data/tbl_tposechain2d_inst.data'
COPY tbl_tposechain2d_inst (k, temp) FROM :'filename';

CREATE TABLE tbl_tposechain2d_seq (
    k integer,
    temp tposechain
);
\set filename :srcdir '/mobilitydb/test/posechain/data/tbl_tposechain2d_seq.data'
COPY tbl_tposechain2d_seq (k, temp) FROM :'filename';

CREATE TABLE tbl_tposechain2d_seqset (
    k integer,
    temp tposechain
);
\set filename :srcdir '/mobilitydb/test/posechain/data/tbl_tposechain2d_seqset.data'
COPY tbl_tposechain2d_seqset (k, temp) FROM :'filename';

-- Launch the ANALYZE deamon to avoid that it is launched during the tests
ANALYZE;
