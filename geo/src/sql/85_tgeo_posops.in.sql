/*****************************************************************************
 *
 * tgeo_relposops.sql
 *    Relative position operators for 4D (2D/3D spatial value + 1D time value)
 *    temporal geometries
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

/* geometry op tgeometry */

CREATE FUNCTION temporal_left(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'left_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overleft(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overleft_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_right(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'right_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overright(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overright_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_below(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'below_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overbelow(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overbelow_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_above(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'above_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overabove(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overabove_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_front(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'front_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overfront(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overfront_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_back(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'back_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overback(geometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overback_geom_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR << (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_left,
  COMMUTATOR = >>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &< (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overleft,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR >> (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_right,
  COMMUTATOR = <<,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &> (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overright,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <<| (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_below,
  COMMUTATOR = |>>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &<| (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overbelow,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |>> (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_above,
  COMMUTATOR = <<|,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |&> (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overabove,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <</ (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_front,
  COMMUTATOR = />>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &</ (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overfront,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR />> (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_back,
  COMMUTATOR = <</,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR /&> (
  LEFTARG = geometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overback,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);

/******************************************************************************/

/* stbox op tgeometry */

CREATE FUNCTION temporal_left(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'left_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overleft(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overleft_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_right(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'right_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overright(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overright_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_below(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'below_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overbelow(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overbelow_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_above(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'above_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overabove(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overabove_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_front(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'front_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overfront(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overfront_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_back(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'back_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overback(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overback_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_before(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'before_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overbefore(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overbefore_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_after(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'after_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overafter(stbox, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overafter_stbox_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR << (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_left,
  COMMUTATOR = >>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &< (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overleft,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR >> (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_right,
  COMMUTATOR = <<,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &> (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overright,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <<| (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_below,
  COMMUTATOR = |>>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &<| (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overbelow,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |>> (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_above,
  COMMUTATOR = <<|,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |&> (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overabove,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <</ (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_front,
  COMMUTATOR = />>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &</ (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overfront,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR />> (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_back,
  COMMUTATOR = <</,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR /&> (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overback,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <<# (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_before,
  COMMUTATOR = #>>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &<# (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overbefore,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR #>> (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_after,
  COMMUTATOR = <<#,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR #&> (
  LEFTARG = stbox, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overafter,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);

/*****************************************************************************/

 /* tgeometry op geometry */

CREATE FUNCTION temporal_left(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'left_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overleft(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overleft_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_right(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'right_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overright(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overright_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_below(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'below_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overbelow(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overbelow_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_above(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'above_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overabove(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overabove_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_front(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'front_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overfront(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overfront_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_back(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'back_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overback(tgeometry, geometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overback_tpoint_geom'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR << (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_left,
  COMMUTATOR = >>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &< (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_overleft,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR >> (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_right,
  COMMUTATOR = <<,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &> (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_overright,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <<| (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_below,
  COMMUTATOR = |>>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &<| (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_overbelow,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |>> (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_above,
  COMMUTATOR = <<|,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |&> (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_overabove,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <</ (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_front,
  COMMUTATOR = />>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &</ (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_overfront,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR />> (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_back,
  COMMUTATOR = <</,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR /&> (
  LEFTARG = tgeometry, RIGHTARG = geometry,
  PROCEDURE = temporal_overback,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);

/*****************************************************************************/

/* tgeometry op stbox */

CREATE FUNCTION temporal_left(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'left_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overleft(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overleft_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_right(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'right_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overright(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overright_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_below(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'below_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overbelow(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overbelow_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_above(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'above_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overabove(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overabove_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_front(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'front_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overfront(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overfront_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_back(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'back_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overback(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overback_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_before(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'before_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overbefore(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overbefore_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_after(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'after_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overafter(tgeometry, stbox)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overafter_tpoint_stbox'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR << (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_left,
  COMMUTATOR = >>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &< (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_overleft,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR >> (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_right,
  COMMUTATOR = <<,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &> (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_overright,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <<| (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_below,
  COMMUTATOR = |>>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &<| (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_overbelow,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |>> (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_above,
  COMMUTATOR = <<|,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |&> (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_overabove,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <</ (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_front,
  COMMUTATOR = />>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &</ (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_overfront,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR />> (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_back,
  COMMUTATOR = <</,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR /&> (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_overback,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <<# (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_before,
  COMMUTATOR = #>>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &<# (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_overbefore,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR #>> (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_after,
  COMMUTATOR = <<#,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR #&> (
  LEFTARG = tgeometry, RIGHTARG = stbox,
  PROCEDURE = temporal_overafter,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);

/*****************************************************************************/

/* tgeometry op tgeometry */

CREATE FUNCTION temporal_left(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'left_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overleft(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overleft_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_right(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'right_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overright(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overright_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_below(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'below_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overbelow(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overbelow_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_above(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'above_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overabove(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overabove_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_front(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'front_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overfront(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overfront_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_back(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'back_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overback(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overback_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_before(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'before_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overbefore(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overbefore_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_after(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'after_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE FUNCTION temporal_overafter(tgeometry, tgeometry)
  RETURNS boolean
  AS 'MODULE_PATHNAME', 'overafter_tpoint_tpoint'
  LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR << (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_left,
  COMMUTATOR = >>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &< (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overleft,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR >> (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_right,
  COMMUTATOR = <<,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &> (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overright,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <<| (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_below,
  COMMUTATOR = |>>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &<| (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overbelow,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |>> (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_above,
  COMMUTATOR = <<|,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR |&> (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overabove,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <</ (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_front,
  COMMUTATOR = />>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &</ (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overfront,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR />> (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_back,
  COMMUTATOR = <</,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR /&> (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overback,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR <<# (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_before,
  COMMUTATOR = #>>,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR &<# (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overbefore,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR #>> (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_after,
  COMMUTATOR = <<#,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);
CREATE OPERATOR #&> (
  LEFTARG = tgeometry, RIGHTARG = tgeometry,
  PROCEDURE = temporal_overafter,
  RESTRICT = tpoint_sel, JOIN = tpoint_joinsel
);

/*****************************************************************************/
