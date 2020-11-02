/*****************************************************************************
 *
 * tgeo_gist.c
 *    R-tree GiST index for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2020, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

CREATE FUNCTION gist_tgeometry_consistent(internal, tgeometry, smallint, oid, internal)
  RETURNS bool
  AS 'MODULE_PATHNAME', 'stbox_gist_consistent'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR CLASS gist_tgeometry_ops
  DEFAULT FOR TYPE tgeometry USING gist AS
  STORAGE stbox,
  -- strictly left
  OPERATOR  1    << (tgeometry, geometry),
  OPERATOR  1    << (tgeometry, stbox),
  OPERATOR  1    << (tgeometry, tgeometry),
  -- overlaps or left
  OPERATOR  2    &< (tgeometry, geometry),
  OPERATOR  2    &< (tgeometry, stbox),
  OPERATOR  2    &< (tgeometry, tgeometry),
  -- overlaps
  OPERATOR  3    && (tgeometry, geometry),
  OPERATOR  3    && (tgeometry, stbox),
  OPERATOR  3    && (tgeometry, tgeometry),
  -- overlaps or right
  OPERATOR  4    &> (tgeometry, geometry),
  OPERATOR  4    &> (tgeometry, stbox),
  OPERATOR  4    &> (tgeometry, tgeometry),
    -- strictly right
  OPERATOR  5    >> (tgeometry, geometry),
  OPERATOR  5    >> (tgeometry, stbox),
  OPERATOR  5    >> (tgeometry, tgeometry),
    -- same
  OPERATOR  6    ~= (tgeometry, geometry),
  OPERATOR  6    ~= (tgeometry, stbox),
  OPERATOR  6    ~= (tgeometry, tgeometry),
  -- contains
  OPERATOR  7    @> (tgeometry, geometry),
  OPERATOR  7    @> (tgeometry, stbox),
  OPERATOR  7    @> (tgeometry, tgeometry),
  -- contained by
  OPERATOR  8    <@ (tgeometry, geometry),
  OPERATOR  8    <@ (tgeometry, stbox),
  OPERATOR  8    <@ (tgeometry, tgeometry),
  -- overlaps or below
  OPERATOR  9    &<| (tgeometry, geometry),
  OPERATOR  9    &<| (tgeometry, stbox),
  OPERATOR  9    &<| (tgeometry, tgeometry),
  -- strictly below
  OPERATOR  10    <<| (tgeometry, geometry),
  OPERATOR  10    <<| (tgeometry, stbox),
  OPERATOR  10    <<| (tgeometry, tgeometry),
  -- strictly above
  OPERATOR  11    |>> (tgeometry, geometry),
  OPERATOR  11    |>> (tgeometry, stbox),
  OPERATOR  11    |>> (tgeometry, tgeometry),
  -- overlaps or above
  OPERATOR  12    |&> (tgeometry, geometry),
  OPERATOR  12    |&> (tgeometry, stbox),
  OPERATOR  12    |&> (tgeometry, tgeometry),
  -- adjacent
  OPERATOR  17    -|- (tgeometry, geometry),
  OPERATOR  17    -|- (tgeometry, stbox),
  OPERATOR  17    -|- (tgeometry, tgeometry),
  -- overlaps or before
  OPERATOR  28    &<# (tgeometry, stbox),
  OPERATOR  28    &<# (tgeometry, tgeometry),
  -- strictly before
  OPERATOR  29    <<# (tgeometry, stbox),
  OPERATOR  29    <<# (tgeometry, tgeometry),
  -- strictly after
  OPERATOR  30    #>> (tgeometry, stbox),
  OPERATOR  30    #>> (tgeometry, tgeometry),
  -- overlaps or after
  OPERATOR  31    #&> (tgeometry, stbox),
  OPERATOR  31    #&> (tgeometry, tgeometry),
  -- overlaps or front
  OPERATOR  32    &</ (tgeometry, geometry),
  OPERATOR  32    &</ (tgeometry, stbox),
  OPERATOR  32    &</ (tgeometry, tgeometry),
  -- strictly front
  OPERATOR  33    <</ (tgeometry, geometry),
  OPERATOR  33    <</ (tgeometry, stbox),
  OPERATOR  33    <</ (tgeometry, tgeometry),
  -- strictly back
  OPERATOR  34    />> (tgeometry, geometry),
  OPERATOR  34    />> (tgeometry, stbox),
  OPERATOR  34    />> (tgeometry, tgeometry),
  -- overlaps or back
  OPERATOR  35    /&> (tgeometry, geometry),
  OPERATOR  35    /&> (tgeometry, stbox),
  OPERATOR  35    /&> (tgeometry, tgeometry),
  -- functions
  FUNCTION  1  gist_tgeometry_consistent(internal, tgeometry, smallint, oid, internal),
  FUNCTION  2  stbox_gist_union(internal, internal),
  FUNCTION  3  tpoint_gist_compress(internal),
#if MOBDB_PGSQL_VERSION < 110000
  FUNCTION  4  tpoint_gist_decompress(internal),
#endif
  FUNCTION  5  stbox_gist_penalty(internal, internal, internal),
  FUNCTION  6  stbox_gist_picksplit(internal, internal),
  FUNCTION  7  stbox_gist_same(stbox, stbox, internal),
  FUNCTION  8  stbox_gist_distance(internal, stbox, smallint, oid, internal);

/******************************************************************************/
