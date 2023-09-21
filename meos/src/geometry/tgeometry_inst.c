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
 * @brief Functions for rigid temporal instant geometries.
 */

#include "geometry/tgeometry_inst.h"

/* MEOS */
#include "meos_internal.h"
#include "general/temporaltypes.h"
#include "general/type_util.h"
#include "general/tinstant.h"
#include "point/tpoint_spatialfuncs.h"
#include "pose/tpose_static.h"
#include "geometry/tgeometry_temporaltypes.h"

/*****************************************************************************
 * General functions
 *****************************************************************************/

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometryinst_geom(const TInstant *inst)
{
  if (!MEOS_FLAGS_GET_GEOM(inst->flags))
    elog(ERROR, "Cannot access geometry from tgeometry instant");
  size_t value_size = DOUBLE_PAD(VARSIZE(&inst->value));
  return PointerGetDatum((char *)&inst->value + value_size);
}

/*****************************************************************************/

/**
 * Returns the size of the tgeometry instant without reference geometry
 */
size_t
tgeometryinst_elem_varsize(const TInstant *inst)
{
  size_t size = VARSIZE(inst);
  if (MEOS_FLAGS_GET_GEOM(inst->flags))
    size -= DOUBLE_PAD(VARSIZE(tgeometryinst_geom(inst)));
  return size;
}

/**
 * Set the size of the tgeometry instant without reference geometry
 */
void
tgeometryinst_set_elem(TInstant *inst)
{
  if (MEOS_FLAGS_GET_GEOM(inst->flags))
  {
    SET_VARSIZE(inst, tgeometryinst_elem_varsize(inst));
    MEOS_FLAGS_SET_GEOM(inst->flags, NO_GEOM);
  }
  return;
}

/*****************************************************************************/

/**
 * Ensure the validity of the arguments when creating a temporal value
 */
static void
tgeometryinst_make_valid(Datum geom, Datum value)
{
  const GSERIALIZED *gs = DatumGetGserializedP(geom);
  const Pose *pose = DatumGetPoseP(value);
  ensure_not_empty(gs);
  ensure_has_not_M_gs(gs);
  int geomtype = gserialized_get_type(gs);
  bool hasZ = MEOS_FLAGS_GET_Z(pose->flags);
  if (geomtype != POLYGONTYPE && geomtype != POLYHEDRALSURFACETYPE)
    elog(ERROR, "Only polygon or polyhedral surface geometries accepted");
  if ((geomtype == POLYGONTYPE && hasZ)
    || (geomtype == POLYHEDRALSURFACETYPE && !hasZ))
    elog(ERROR, "Dimension of geometry and pose must correspond.");
  return;
}

/**
 * Creating a temporal value from its arguments
 * @pre The validity of the arguments has been tested before
 */
TInstant *
tgeometryinst_make1(Datum geom, Datum value, meosType temptype, TimestampTz t)
{
  size_t value_offset = sizeof(TInstant) - sizeof(Datum);
  size_t size = value_offset;
  /* Create the temporal instant */
  void *value_from = DatumGetPointer(value);
  size_t value_size = DOUBLE_PAD(VARSIZE(value_from));
  void *geom_from = DatumGetPointer(geom);
  size_t geom_size = DOUBLE_PAD(VARSIZE(geom_from));
  size += value_size + geom_size;
  TInstant *result = palloc0(size);
  void *value_to = ((char *) result) + value_offset;
  memcpy(value_to, value_from, value_size);
  void *geom_to = ((char *) result) + value_offset + value_size;
  memcpy(geom_to, geom_from, geom_size);

  /* Initialize fixed-size values */
  result->temptype = temptype;
  result->subtype = TINSTANT;
  result->t = t;
  SET_VARSIZE(result, size);
  MEOS_FLAGS_SET_BYVAL(result->flags, false);
  MEOS_FLAGS_SET_CONTINUOUS(result->flags, true);
  // MEOS_FLAGS_SET_INTERP(result->flags, DISCRETE);
  MEOS_FLAGS_SET_X(result->flags, true);
  MEOS_FLAGS_SET_T(result->flags, true);
  const Pose *pose = DatumGetPoseP(value);
  MEOS_FLAGS_SET_Z(result->flags, MEOS_FLAGS_GET_Z(pose->flags));
  MEOS_FLAGS_SET_GEODETIC(result->flags, false);
  MEOS_FLAGS_SET_GEOM(result->flags, WITH_GEOM);
  return result;
}

/**
 * Construct a temporal geometry instant value from the arguments
 *
 * The memory structure of a temporal geometry instant value is as follows
 * @code
 * -----------------------------
 * ( TInstant )_X | ( Geom )_X |
 * -----------------------------
 * @endcode
 * where the attribute `value` of type `Datum` in the TInstant struct
 * stores the base value (pose). The `_X` are unused bytes added for double padding.
 *
 * @param geom Reference geometry
 * @param value Base value (Pose)
 * @param temptype Base type
 * @param t Timestamp
 */
TInstant *
tgeometryinst_make(Datum geom, Datum value, meosType temptype, TimestampTz t)
{
  tgeometryinst_make_valid(geom, value);
  return tgeometryinst_make1(geom, value, temptype, t);
}

/*****************************************************************************
 * Transformation functions
 *****************************************************************************/

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal sequence transformed into a temporal instant.
 */
TInstant *
tgeometry_tseq_to_tinst(const TSequence *seq)
{
  if (seq->count != 1)
    elog(ERROR, "Cannot transform input to a temporal instant");

  return tgeometry_seq_inst_n(seq, 0);
}

/**
 * @ingroup libmeos_internal_temporal_transf
 * @brief Return a temporal sequence set transformed into a temporal instant.
 */
TInstant *
tgeometry_tseqset_to_tinst(const TSequenceSet *ts)
{
  const TSequence *seq = TSEQUENCESET_SEQ_N(ts, 0);
  if (ts->count != 1 || seq->count != 1)
    elog(ERROR, "Cannot transform input to a temporal instant");

   return tgeometry_seq_inst_n(seq, 0);
}


/*****************************************************************************
 * Accessor functions
 *****************************************************************************/

/**
 * @ingroup libmeos_internal_tgeometry_accessor
 * @brief Return the singleton array of sequences of a temporal instant.
 * @post The output parameter @p count is equal to 1
 * @sqlfunc sequences()
 */
TSequence **
tgeometryinst_sequences(const TInstant *inst, int *count)
{
  TSequence **result = palloc(sizeof(TSequence *));
  result[0] = tgeometry_tinst_to_tseq(inst,
    MEOS_FLAGS_GET_CONTINUOUS(inst->flags) ? LINEAR : STEP);
  *count = 1;
  return result;
}

/*****************************************************************************/
