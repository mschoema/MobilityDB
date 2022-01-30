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

#include "geometry/tgeometry_inst.h"

#include <utils/builtins.h>
#include <utils/timestamp.h>

#include "general/temporaltypes.h"
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
  if (!MOBDB_FLAGS_GET_GEOM(inst->flags))
    ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
      errmsg("Cannot access geometry from tgeometry instant")));
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

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometryinstset_geom(const TInstantSet *ti)
{
  return PointerGetDatum(
    /* start of data */
    ((char *)ti) + double_pad(sizeof(TInstantSet)) + ti->bboxsize +
      (ti->count + 1) * sizeof(size_t) +
      /* offset */
      (tinstantset_offsets_ptr(ti))[ti->count]);
}

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometryseq_geom(const TSequence *seq)
{
  return PointerGetDatum(
    /* start of data */
    ((char *)seq) + double_pad(sizeof(TSequence)) + seq->bboxsize +
      (seq->count + 1) * sizeof(size_t) +
      /* offset */
      (tsequence_offsets_ptr(seq))[seq->count]);
}

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometryseqset_geom(const TSequenceSet *ts)
{
  return PointerGetDatum(
    /* start of data */
    ((char *)ts) + double_pad(sizeof(TSequenceSet)) + ts->bboxsize +
      (ts->count + 1) * sizeof(size_t) +
      /* offset */
      (tsequenceset_offsets_ptr(ts))[ts->count]);
}

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometry_geom(const Temporal *temp)
{
  Datum result;
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT)
    result = tgeometryinst_geom((const TInstant *) temp);
  else if (temp->subtype == INSTANTSET)
    result = tgeometryinstset_geom((const TInstantSet *) temp);
  else if (temp->subtype == SEQUENCE)
    result = tgeometryseq_geom((const TSequence *) temp);
  else /* temp->subtype == SEQUENCESET */
    result = tgeometryseqset_geom((const TSequenceSet *) temp);
  return result;
}

/*****************************************************************************/

/**
 * Returns the size of the tgeometryinst without reference geometry
 */
size_t
tgeometryinst_elem_varsize(const TInstant *inst)
{
  Datum *value = tinstant_value_ptr(inst);
  return double_pad(sizeof(TInstant)) + double_pad(VARSIZE(value));
}

/**
 * Set the size of the tgeometryinst without reference geometry
 */
void
tgeometryinst_set_elem(TInstant *inst)
{
  SET_VARSIZE(inst, tgeometryinst_elem_varsize(inst));
  MOBDB_FLAGS_SET_GEOM(inst->flags, NO_GEOM);
  return;
}

/**
 * Returns the size of the tgeometryseq without reference geometry
 */
size_t
tgeometryseq_elem_varsize(const TSequence *seq)
{
  void *geom = DatumGetPointer(tgeometryseq_geom(seq));
  return VARSIZE(seq) - double_pad(VARSIZE(geom));
}

/**
 * Set the size of the tgeometryseq without reference geometry
 */
void
tgeometryseq_set_elem(TSequence *seq)
{
  SET_VARSIZE(seq, tgeometryseq_elem_varsize(seq));
  MOBDB_FLAGS_SET_GEOM(seq->flags, NO_GEOM);
  return;
}

/*****************************************************************************/

/**
 * Ensure the validity of the arguments when creating a temporal value
 */
static void
tgeometryinst_make_valid(Datum value, Datum geom)
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
tgeometryinst_make1(Datum value,
  TimestampTz t, Oid basetypid, bool hasgeom, Datum geom)
{
  size_t value_offset = double_pad(sizeof(TInstant));
  size_t size = value_offset;
  /* Create the temporal value */
  TInstant *result;

  void *value_from = DatumGetPointer(value);
  size_t value_size = double_pad(VARSIZE(value_from));
  void *geom_from;
  size_t geom_size = 0;
  if (hasgeom)
  {
    geom_from = DatumGetPointer(geom);
    geom_size = double_pad(VARSIZE(geom_from));
  }

  size += value_size + geom_size;
  result = palloc0(size);
  void *value_to = ((char *) result) + value_offset;
  memcpy(value_to, value_from, value_size);
  if (hasgeom)
  {
    void *geom_to = ((char *) result) + value_offset + value_size;
    memcpy(geom_to, geom_from, geom_size);
  }

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
  MOBDB_FLAGS_SET_GEOM(result->flags, hasgeom);
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
tgeometryinst_make(Datum value,
  TimestampTz t, Oid basetypid, bool hasgeom, Datum geom)
{
  if (hasgeom)
    tgeometryinst_make_valid(value, geom);
  return tgeometryinst_make1(value, t, basetypid, hasgeom, geom);
}

/*****************************************************************************/
