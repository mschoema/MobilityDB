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
 * @brief Output of rigid temporal geometries in WKT and EWKT format.
 */

#include "geometry/tgeometry_out.h"

/* MEOS */
#include <meos.h>
#include <meos_internal.h>
#include "general/type_util.h"
#include "point/tpoint_out.h"
#include "geometry/tgeometry.h"

/*****************************************************************************
 * Output in WKT and EWKT format
 *****************************************************************************/

/**
 * @ingroup libmeos_temporal_inout
 * @brief Return the Well-Known Text (WKT) representation of a temporal point.
 * @sqlfunc asText()
 */
char *
tgeometry_as_text(const Temporal *temp, int maxdd)
{
  char *geom = wkt_out(tgeometry_geom(temp), 0, maxdd);
  char *rest = temporal_out(temp, maxdd);
  char *result = palloc(strlen(geom) + strlen(rest) + 2);
  sprintf(result, "%s;%s", geom, rest);
  pfree(geom);
  pfree(rest);
  return result;
}

/**
 * @ingroup libmeos_temporal_inout
 * @brief Return the Extended Well-Known Text (EWKT) representation a temporal
 * point.
 * @sqlfunc asEWKT()
 */
char *
tgeometry_as_ewkt(const Temporal *temp, int maxdd)
{
  char *geom = ewkt_out(tgeometry_geom(temp), 0, maxdd);
  char *rest = temporal_out(temp, maxdd);
  char *result = palloc(strlen(geom) + strlen(rest) + 2);
  sprintf(result, "%s;%s", geom, rest);
  pfree(geom);
  pfree(rest);
  return result;
}

/*****************************************************************************/
