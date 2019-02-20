﻿/******************************************************************************/

SELECT COUNT(*) FROM tbl_tboolinst WHERE tbooli(inst) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tboolinst WHERE tboolseq(inst) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tboolinst WHERE tbools(inst) IS NOT NULL;

SELECT COUNT(*) FROM tbl_tintinst WHERE tinti(inst) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tintinst WHERE tintseq(inst) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tintinst WHERE tints(inst) IS NOT NULL;

SELECT COUNT(*) FROM tbl_tfloatinst WHERE tfloati(inst) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloatinst WHERE tfloatseq(inst) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloatinst WHERE tfloats(inst) IS NOT NULL;

SELECT COUNT(*) FROM tbl_ttextinst WHERE ttexti(inst) IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttextinst WHERE ttextseq(inst) IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttextinst WHERE ttexts(inst) IS NOT NULL;

/******************************************************************************/

SELECT COUNT(*) FROM tbl_tboolseq WHERE tbools(seq) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tintseq WHERE tints(seq) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tfloatseq WHERE tfloats(seq) IS NOT NULL;
SELECT COUNT(*) FROM tbl_ttextseq WHERE ttexts(seq) IS NOT NULL;

/******************************************************************************/

SELECT COUNT(*) FROM tbl_tintinst WHERE tfloat(inst) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tinti WHERE tfloat(ti) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tintseq WHERE tfloat(seq) IS NOT NULL;
SELECT COUNT(*) FROM tbl_tints WHERE tfloat(ts) IS NOT NULL;

/******************************************************************************/