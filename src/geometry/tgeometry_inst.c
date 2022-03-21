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
 * @file tgeometry_inst.c
 * Functions for rigid temporal instant geometries.
 */

#include "geometry/tgeometry_inst.h"

#include <utils/builtins.h>
#include <utils/timestamp.h>

#include "general/temporaltypes.h"
#include "general/temporal_util.h"
#include "general/tinstant.h"

#include "point/tpoint_spatialfuncs.h"

#include "pose/pose.h"

#include "geometry/tgeometry.h"

/*****************************************************************************
 * General functions
 *****************************************************************************/

/**
 * Returns a pointer to the base geometry of the temporal instant geometry value
 */
Datum *
tgeometryinst_geom_ptr(const TInstant *inst)
{
  if (!MOBDB_FLAGS_GET_GEOM(inst->flags))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Cannot access geometry from tgeometry instant")));
  Datum *value = tinstant_value_ptr(inst);
  size_t value_size = double_pad(VARSIZE(value));
  return (Datum *)((char *)value + value_size);
}

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometryinst_geom(const TInstant *inst)
{
  Datum *geom = tgeometryinst_geom_ptr(inst);
  return PointerGetDatum(geom);
}

/*****************************************************************************/

/**
 * Returns the size of the tgeometry instant without reference geometry
 */
size_t
tgeometryinst_elem_varsize(const TInstant *inst)
{
  Datum *value = tinstant_value_ptr(inst);
  return double_pad(sizeof(TInstant)) + double_pad(VARSIZE(value));
}

/**
 * Set the size of the tgeometry instant without reference geometry
 */
void
tgeometryinst_set_elem(TInstant *inst)
{
  SET_VARSIZE(inst, tgeometryinst_elem_varsize(inst));
  MOBDB_FLAGS_SET_GEOM(inst->flags, NO_GEOM);
  return;
}

/*****************************************************************************/

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
tgeometryinst_make1(Datum geom, Datum value, TimestampTz t, Oid basetypid)
{
  size_t value_offset = double_pad(sizeof(TInstant));
  size_t size = value_offset;
  /* Create the temporal value */
  TInstant *result;

  void *value_from = DatumGetPointer(value);
  size_t value_size = double_pad(VARSIZE(value_from));
  void *geom_from = DatumGetPointer(geom);
  size_t geom_size = double_pad(VARSIZE(geom_from));

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
  MOBDB_FLAGS_SET_GEOM(result->flags, WITH_GEOM);
  return result;
}

/**
 * Construct a temporal geometry instant value from the arguments
 *
 * The memory structure of a temporal geometry instant value is as follows
 * @code
 * --------------------------------------------
 * ( TInstant )_X | ( Value )_X | ( Geom )_X |
 * --------------------------------------------
 * @endcode
 * where the `_X` are unused bytes added for double padding.
 *
 * @param geom Reference geometry
 * @param value Base value (Pose)
 * @param t Timestamp
 * @param basetypid Oid of the base type
 */
TInstant *
tgeometryinst_make(Datum geom, Datum value, TimestampTz t, Oid basetypid)
{
  tgeometryinst_make_valid(geom, value);
  return tgeometryinst_make1(geom, value, t, basetypid);
}

/*****************************************************************************
 * Transformation functions
 *****************************************************************************/

/**
 * Transform the temporal instant set value into a temporal instant value
 */
TInstant *
tgeometry_instset_to_inst(const TInstantSet *ti)
{
  if (ti->count != 1)
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Cannot transform input to a temporal instant")));
  return tgeometry_instset_inst_n(ti, 0);
}

/**
 * Transform the temporal sequence value into a temporal instant value
 */
TInstant *
tgeometry_seq_to_inst(const TSequence *seq)
{
  if (seq->count != 1)
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Cannot transform input to a temporal instant")));
  return tgeometry_seq_inst_n(seq, 0);
}

/**
 * Transform the temporal sequence set value into a temporal instant value
 */
TInstant *
tgeometry_seqset_to_inst(const TSequenceSet *ts)
{
  const TSequence *seq = tsequenceset_seq_n(ts, 0);
  if (ts->count != 1 || seq->count != 1)
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Cannot transform input to a temporal instant")));

  const TInstant *inst = tsequence_inst_n(seq, 0);
  return tgeometryinst_make1(tgeometry_seqset_geom(ts),
    tinstant_value(inst), inst->t, inst->basetypid);
}


/*****************************************************************************/
