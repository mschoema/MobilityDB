/*****************************************************************************
 *
 * tgeo_boxops.c
 *    Bounding box operators for temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "tgeo_boxops.h"

#include "tpoint_boxops.h"
#include "tgeo_transform.h"

/*****************************************************************************
 * Functions computing the bounding box at the creation of a temporal point
 *****************************************************************************/

/**
 * Set the spatiotemporal box from the array of temporal instant point values
 *
 * @param[out] box Spatiotemporal box
 * @param[in] instants Temporal instant values
 * @param[in] count Number of elements in the array
 * @note Temporal instant values do not have a precomputed bounding box
 */
void
tgeoinstarr_to_stbox(STBOX *box, TInstant **instants, int count)
{
  tpointinst_make_stbox(box, instants[0]);
  for (int i = 1; i < count; i++)
  {
    STBOX box1;
    memset(&box1, 0, sizeof(STBOX));
    TInstant *geom_inst = tgeoinst_rtransform_to_geometry(instants[i], instants[0]);
    tpointinst_make_stbox(&box1, geom_inst);
    pfree(geom_inst);
    stbox_expand(box, &box1);
  }
}

/*****************************************************************************/
