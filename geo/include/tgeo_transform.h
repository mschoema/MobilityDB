/*****************************************************************************
 *
 * tgeo_transform.h
 *    Transformation (encoder/decoder) functions for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#ifndef __TGEO_TRANSFORM_H__
#define __TGEO_TRANSFORM_H__

#include <postgres.h>
#include <catalog/pg_type.h>

#include "tgeo.h"

/*****************************************************************************
 * Encoding functions
 *****************************************************************************/

extern TInstant *tgeoinst_region_to_rtransform(const TInstant *inst, const TInstant *ref_region);

extern TInstant **tgeo_instarr_to_rtransform(TInstant **instants, int count);

/*****************************************************************************
 * Decoding functions
 *****************************************************************************/

extern TInstant *tgeoinst_rtransform_to_geometry(const TInstant *inst, const TInstant *ref_region);

/*****************************************************************************
 * Other transformation functions
 *****************************************************************************/

extern TInstant *tgeoinst_rtransform_combine(const TInstant *inst, const TInstant *ref_rtransform);

/*****************************************************************************/

#endif /* __TGEO_TRANSFORM_H__ */
