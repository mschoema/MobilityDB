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

-- The network first, since the input of a network point reads the route
-- of the point in it
CREATE TABLE ways (
    gid bigint NOT NULL,
    the_geom geometry,
    length double precision
);
\set filename :srcdir '/mobilitydb/test/npoint/data/ways.data'
COPY ways (gid, the_geom, length) FROM :'filename';

ALTER TABLE ONLY ways
    ADD CONSTRAINT ways_pkey PRIMARY KEY (gid);

CREATE TABLE tbl_npoint (
    k integer PRIMARY KEY,
    np npoint
);
\set filename :srcdir '/mobilitydb/test/npoint/data/tbl_npoint.data'
COPY tbl_npoint (k, np) FROM :'filename';

CREATE TABLE tbl_nsegment (
    k integer PRIMARY KEY,
    ns nsegment
);
\set filename :srcdir '/mobilitydb/test/npoint/data/tbl_nsegment.data'
COPY tbl_nsegment (k, ns) FROM :'filename';

CREATE TABLE tbl_npointset (
    k integer PRIMARY KEY,
    n npointset
);
\set filename :srcdir '/mobilitydb/test/npoint/data/tbl_npointset.data'
COPY tbl_npointset (k, n) FROM :'filename';

CREATE TABLE tbl_tnpoint (
    k integer PRIMARY KEY,
    temp tnpoint
);
\set filename :srcdir '/mobilitydb/test/npoint/data/tbl_tnpoint.data'
COPY tbl_tnpoint (k, temp) FROM :'filename';

CREATE TABLE tbl_tnpoint_big (
    k integer PRIMARY KEY,
    temp tnpoint
);
\set filename :srcdir '/mobilitydb/test/npoint/data/tbl_tnpoint_big.data'
COPY tbl_tnpoint_big (k, temp) FROM :'filename';

CREATE TABLE tbl_tnpoint_discseq (
    k integer PRIMARY KEY,
    ti tnpoint(Sequence)
);
\set filename :srcdir '/mobilitydb/test/npoint/data/tbl_tnpoint_discseq.data'
COPY tbl_tnpoint_discseq (k, ti) FROM :'filename';

CREATE TABLE tbl_tnpoint_inst (
    k integer PRIMARY KEY,
    inst tnpoint(Instant)
);
\set filename :srcdir '/mobilitydb/test/npoint/data/tbl_tnpoint_inst.data'
COPY tbl_tnpoint_inst (k, inst) FROM :'filename';

CREATE TABLE tbl_tnpoint_seqset (
    k integer PRIMARY KEY,
    ss tnpoint(SequenceSet)
);
\set filename :srcdir '/mobilitydb/test/npoint/data/tbl_tnpoint_seqset.data'
COPY tbl_tnpoint_seqset (k, ss) FROM :'filename';

CREATE TABLE tbl_tnpoint_seq (
    k integer PRIMARY KEY,
    seq tnpoint(Sequence)
);
\set filename :srcdir '/mobilitydb/test/npoint/data/tbl_tnpoint_seq.data'
COPY tbl_tnpoint_seq (k, seq) FROM :'filename';

-- Launch the ANALYZE deamon to avoid that it is launched during the tests
ANALYZE;
