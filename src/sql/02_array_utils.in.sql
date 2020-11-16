/*****************************************************************************
 *
 * array_utils.sql
 *    Utility functions for arrays
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

CREATE FUNCTION round(float[], integer DEFAULT 0)
RETURNS numeric[]
LANGUAGE SQL
AS $$
   SELECT array_agg(round(arr::numeric, $2))
   FROM unnest($1) as arr;
$$;

/******************************************************************************/
