/*****************************************************************************
 *
 * tgeo_boxops.h
 *    Bounding box operators for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __TGEO_BOXOPS_H__
#define __TGEO_BOXOPS_H__

#include <postgres.h>
#include <catalog/pg_type.h>

#include "temporal.h"
#include "stbox.h"

/** Symbolic constants for temporal geometry bounding box computations */
#define BBOX_ROTATING       true
#define BBOX_ROTATING_NO    false

/*****************************************************************************/

/* Functions computing the bounding box at the creation of the temporal geometry */

extern void tgeoinstarr_to_stbox(STBOX *box, TInstant **inst, int count, bool rotating);

/*****************************************************************************/

#endif /* __TGEO_BOXOPS_H__ */
