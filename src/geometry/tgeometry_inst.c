/*****************************************************************************
 *
 * This MobilityDB code is provided under The PostgreSQL License.
 *
 * Copyright (c) 2016-2021, Université libre de Bruxelles and MobilityDB
 * contributors
 *
 * MobilityDB includes portions of PostGIS version 3 source code released
 * under the GNU General Public License (GPLv2 or later).
 * Copyright (c) 2001-2021, PostGIS contributors
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
 * @file tpoint.c
 * Basic functions for temporal points.
 */

#include "geometry/tgeometry.h"

#include <utils/builtins.h>
#include <utils/timestamp.h>

#include "general/temporal.h"
#include "general/temporal_util.h"
#include "general/tinstant.h"

#include "point/tpoint_spatialfuncs.h"

#include "pose/pose.h"

/*****************************************************************************
 * General functions
 *****************************************************************************/

/**
 * Returns a pointer to the base geometry of the temporal instant geometry value
 */
Datum *
tgeometryinst_geom_ptr(const TInstant *inst)
{
  Datum *value = tinstant_value_ptr(inst);
  size_t value_size = double_pad(VARSIZE(value));
  if MOBDB_FLAGS_GET_GEOMBYVAL(inst->flags)
    return (Datum *)((char *)value + value_size);
  else
    return *(Datum **)((char *)value + value_size);
}

/**
 * Returns the base geometry of the temporal instant geometry value
 */
Datum
tgeometryinst_geom(const TInstant *inst)
{
  Datum *geom = tgeometryinst_geom_ptr(inst);
  return PointerGetDatum(geom);
}

/**
 * Returns a copy of the base geometry of the temporal instant geometry value
 */
Datum
tgeometryinst_geom_copy(const TInstant *inst)
{
  Datum *geom = tgeometryinst_geom_ptr(inst);
  size_t geom_size = VARSIZE(geom);
  void *result = palloc0(geom_size);
  memcpy(result, geom, geom_size);
  return PointerGetDatum(result);
}

/**
 * Returns the size of the tgeometryinst based on how the geometry is stored
 */
size_t
tgeometryinst_varsize(const TInstant *inst, bool geombyval)
{
  if (MOBDB_FLAGS_GET_GEOMBYVAL(inst->flags) == geombyval)
    return VARSIZE(inst);
  Datum *value = tinstant_value_ptr(inst);
  size_t result = double_pad(sizeof(TInstant)) + double_pad(VARSIZE(value));
  if (geombyval)
  {
    Datum *geom = tgeometryinst_geom_ptr(inst);
    result += double_pad(VARSIZE(geom));
  }
  else
    result += double_pad(sizeof(Datum));
  return result;
}

/**
 * Ensure the validity of the arguments when creating a temporal value
 */
static void
tgeometryinst_make_valid(Datum geom, Datum value)
{
  GSERIALIZED *gs = (GSERIALIZED *)PG_DETOAST_DATUM(geom);
  pose *p = DatumGetPose(value);
  ensure_non_empty(gs);
  ensure_has_not_M_gs(gs);
  if (gserialized_get_type(gs) != POLYGONTYPE &&
    gserialized_get_type(gs) != POLYHEDRALSURFACETYPE)
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Only polygon or polyhedral surface geometries accepted")));
  if ((gserialized_get_type(gs) == POLYGONTYPE &&
      MOBDB_FLAGS_GET_Z(p->flags)) ||
    (gserialized_get_type(gs) == POLYHEDRALSURFACETYPE &&
      !MOBDB_FLAGS_GET_Z(p->flags)))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Dimension of geometry and pose must correspond.")));
  return;
}

/**
 * Creating a temporal value from its arguments
 * @pre The validity of the arguments has been tested before
 */
TInstant *
tgeometryinst_make1(Datum geom, Datum value,
  TimestampTz t, Oid basetypid, bool geombyval)
{
  size_t value_offset = double_pad(sizeof(TInstant));
  size_t size = value_offset;
  /* Create the temporal value */
  TInstant *result;

  size_t value_size;
  void *value_from;
  value_from = DatumGetPointer(value);
  value_size = double_pad(VARSIZE(value_from));

  size_t geom_size;
  void *geom_from;
  if (geombyval)
  {
    geom_from = DatumGetPointer(geom);
    geom_size = double_pad(VARSIZE(geom_from));
  }
  else
  {
    geom_from = &geom;
    geom_size = double_pad(sizeof(Datum));
  }

  size += value_size + geom_size;
  result = palloc0(size);
  void *value_to = ((char *) result) + value_offset;
  memcpy(value_to, value_from, value_size);
  void *geom_to = ((char *) result) + value_offset + value_size;
  memcpy(geom_to, geom_from, geom_size);

  /* Initialize fixed-size values */
  result->subtype = INSTANT;
  result->basetypid = basetypid;
  result->t = t;
  SET_VARSIZE(result, size);
  MOBDB_FLAGS_SET_BYVAL(result->flags, false);
  MOBDB_FLAGS_SET_CONTINUOUS(result->flags, true);
  MOBDB_FLAGS_SET_LINEAR(result->flags, true);
  MOBDB_FLAGS_SET_X(result->flags, true);
  pose *p = DatumGetPose(value);
  MOBDB_FLAGS_SET_Z(result->flags, MOBDB_FLAGS_GET_Z(p->flags));
  MOBDB_FLAGS_SET_T(result->flags, true);
  MOBDB_FLAGS_SET_GEODETIC(result->flags, false);
  MOBDB_FLAGS_SET_GEOMBYVAL(result->flags, geombyval);
  return result;
}

/**
 * Construct a temporal instant geometry value from the arguments
 *
 * The memory structure of a temporal instant geometry value is as follows
 * @code
 * ------------------------------------------
 * ( TInstant )_X | ( Value )_X | ( Geom )_X
 * ------------------------------------------
 * @endcode
 * where the `_X` are unused bytes added for double padding.
 *
 * @param geom Base geometry
 * @param value Base value
 * @param t Timestamp
 * @param basetypid Oid of the base type
 */
TInstant *
tgeometryinst_make(Datum geom, Datum value,
  TimestampTz t, Oid basetypid, bool geombyval)
{
  tgeometryinst_make_valid(geom, value);
  return tgeometryinst_make1(geom, value, t, basetypid, geombyval);
}

/**
 * Set the pointer to the geometry of the temporal instant value
 */
void
tgeometryinst_set_geom(TInstant *inst, Datum geom, bool geombyval)
{
  Datum *value = tinstant_value_ptr(inst);
  size_t size1 = double_pad(sizeof(TInstant)) + double_pad(VARSIZE(value));
  void *geom_to = tgeometryinst_geom_ptr(inst);
  size_t geom_size;
  void *geom_from;
  if (geombyval)
  {
    geom_from = DatumGetPointer(geom);
    geom_size = double_pad(VARSIZE(geom_from));
  }
  else
  {
    geom_from = &geom;
    geom_size = double_pad(sizeof(Datum));
  }
  memcpy(geom_to, geom_from, geom_size);
  SET_VARSIZE(inst, size1 + geom_size);
  MOBDB_FLAGS_SET_GEOMBYVAL(inst->flags, geombyval);
  return;
}


/**
 * Returns a copy of the temporal instant value
 * on how the geometry is stored
 */
TInstant *
tgeometryinst_copy(const TInstant *inst, bool geombyval)
{
  if (MOBDB_FLAGS_GET_GEOMBYVAL(inst->flags) == geombyval)
    return tinstant_copy(inst);
  return tgeometryinst_make1(tgeometryinst_geom(inst),
    tinstant_value(inst), inst->t, inst->basetypid, geombyval);
}

/*****************************************************************************/
