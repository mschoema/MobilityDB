/*****************************************************************************
 *
 * tgeo_out.h
 *    Output of temporal geometries in WKT and EWKT format
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __TGEO_OUT_H__
#define __TGEO_OUT_H__

#include <postgres.h>
#include <fmgr.h>
#include <catalog/pg_type.h>

/******************************************************************************
 * Output as region
 ******************************************************************************/

extern Datum tgeo_as_text(PG_FUNCTION_ARGS);
extern Datum tgeo_as_ewkt(PG_FUNCTION_ARGS);
extern Datum tgeoarr_as_text(PG_FUNCTION_ARGS);
extern Datum tgeoarr_as_ewkt(PG_FUNCTION_ARGS);

/*****************************************************************************/

#endif /* __TGEO_OUT_H__ */
