/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 * Copyright (c) 2016-2023, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2023, PostGIS contributors
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without a written
 * agreement is hereby granted, provided that the above copyright notice and
 * this paragraph and the following two paragraphs appear in all copies.
 *
 * IN NO EVENT SHALL UNIVERSITE LIBRE DE BRUXELLES BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
 * LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF UNIVERSITE LIBRE DE BRUXELLES HAS BEEN ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * UNIVERSITE LIBRE DE BRUXELLES SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON
 * AN "AS IS" BASIS, AND UNIVERSITE LIBRE DE BRUXELLES HAS NO OBLIGATIONS TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 
 *
 *****************************************************************************/

/**
 * @brief Spatial functions for rigid temporal geometries.
 */

#include "geometry/tgeometry_spatialfuncs.h"

/* C */
#include <assert.h>
/* PostGIS */
#include <liblwgeom.h>
/* MEOS */
#include "meos_internal.h"
#include "general/temporal.h"
#include "point/tpoint_spatialfuncs.h"
#include "geometry/tgeometry_inst.h"

/*****************************************************************************/

/**
 * Returns the SRID of a rigid temporal instant geometry
 */
int
tgeometryinst_srid(const TInstant *inst)
{
  GSERIALIZED *gs = DatumGetGserializedP(tgeometryinst_geom(inst));
  return gserialized_get_srid(gs);
}

/**
 * Returns the SRID of a rigid temporal geometry (dispatch function)
 */
int
tgeometry_srid(const Temporal *temp)
{
  int result;
  assert(temptype_subtype(temp->subtype));
  if (temp->subtype == TINSTANT)
    result = tgeometryinst_srid((TInstant *) temp);
  else if (temp->subtype == TSEQUENCE)
    result = tpointseq_srid((TSequence *) temp);
  else /* temp->subtype == TSEQUENCESET */
    result = tpointseqset_srid((TSequenceSet *) temp);
  return result;
}

/*****************************************************************************/
