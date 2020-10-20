/*****************************************************************************
 *
 * tgeo.c
 *    Basic functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "tgeo.h"

#include <utils/builtins.h>
#include <utils/timestamp.h>

#include "temporaltypes.h"
#include "oidcache.h"
#include "temporal_util.h"
#include "tgeo_parser.h"

/*****************************************************************************
 * Input function
 *****************************************************************************/

PG_FUNCTION_INFO_V1(tgeo_in);

PGDLLEXPORT Datum
tgeo_in(PG_FUNCTION_ARGS)
{
  char *input = PG_GETARG_CSTRING(0);
  Oid temptypid = PG_GETARG_OID(1);
  Oid valuetypid = temporal_valuetypid(temptypid);
  Temporal *result = tgeo_parse(&input, valuetypid);
  if (result == 0)
    PG_RETURN_NULL();
  PG_RETURN_POINTER(result);
}

/*****************************************************************************
 * Constructor function
 *****************************************************************************/

/* Construct a temporal instant geometry from two arguments */

PG_FUNCTION_INFO_V1(tgeoinst_constructor);

PGDLLEXPORT Datum
tgeoinst_constructor(PG_FUNCTION_ARGS)
{
  GSERIALIZED *gs = PG_GETARG_GSERIALIZED_P(0);
  ensure_geo_type(gs);
  ensure_non_empty(gs);
  ensure_has_not_M_gs(gs);
  TimestampTz t = PG_GETARG_TIMESTAMPTZ(1);
  Oid valuetypid = get_fn_expr_argtype(fcinfo->flinfo, 0);
  Temporal *result = (Temporal *)tinstant_make(PointerGetDatum(gs),
    t, valuetypid);
  PG_FREE_IF_COPY(gs, 0);
  PG_RETURN_POINTER(result);
}

/*****************************************************************************/
