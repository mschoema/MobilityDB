/*****************************************************************************
 *
 * rtransform.sql
 *    2D and 3D Rigidbody Transformation types.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

CREATE TYPE rtransform2d;
CREATE TYPE rtransform3d;

/******************************************************************************
 * Input/Output
 ******************************************************************************/

CREATE FUNCTION rtransform2d_in(cstring)
    RETURNS rtransform2d
    AS 'MODULE_PATHNAME', 'rtransform_in_2d'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION rtransform2d_out(rtransform2d)
    RETURNS cstring
    AS 'MODULE_PATHNAME', 'rtransform_out_2d'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE rtransform2d (
    internallength = 24,
    input = rtransform2d_in,
    output = rtransform2d_out,
    alignment = double
);

/******************************************************************************/

CREATE FUNCTION rtransform3d_in(cstring)
    RETURNS rtransform3d
    AS 'MODULE_PATHNAME', 'rtransform_in_3d'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION rtransform3d_out(rtransform3d)
    RETURNS cstring
    AS 'MODULE_PATHNAME', 'rtransform_out_3d'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE rtransform3d (
    internallength = 56,
    input = rtransform3d_in,
    output = rtransform3d_out,
    alignment = double
);

/******************************************************************************/
