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
 * @brief General functions for rigid temporal geometries.
 */

#include "geometry/tgeometry.h"

/* C */
#include <assert.h>
/* MEOS */
#include "general/lifting.h"
#include "general/meos_catalog.h"
#include "general/temporal.h"
#include "geometry/tgeometry_spatialfuncs.h"
#include "liblwgeom.h"
#include "meos_internal.h"
#include "geometry/tgeometry_temporaltypes.h"
#include "geometry/tgeometry_out.h"
#include "geometry/tgeometry_utils.h"
#include "point/tpoint_spatialfuncs.h"
#include "pose/tpose_static.h"

/*****************************************************************************/

/**
 * Returns the reference geometry of the temporal value
 */
Datum
tgeometry_geom(const Temporal *temp)
{
  Datum result;
  assert(temptype_subtype(temp->subtype));
  if (temp->subtype == TINSTANT)
    result = tgeometryinst_geom((const TInstant *) temp);
  else if (temp->subtype == TSEQUENCE)
    result = tgeometry_seq_geom((const TSequence *) temp);
  else /* temp->subtype == TSEQUENCESET */
    result = tgeometry_seqset_geom((const TSequenceSet *) temp);
  return result;
}

/*****************************************************************************
 * Input/output functions
 *****************************************************************************/

/**
 * Output a rigid temporal geometry in Well-Known Text (WKT) format
 */
char *
tgeometry_out(const Temporal *temp, int maxdd)
{
  return tgeometry_as_text(temp, maxdd);
}

/*****************************************************************************
 * Cast functions
 *****************************************************************************/

Temporal *
tgeometry_to_tgeompoint(const Temporal *temp)
{
  /* We only need to fill these parameters for tfunc_temporal */
  LiftedFunctionInfo lfinfo;
  memset(&lfinfo, 0, sizeof(LiftedFunctionInfo));
  lfinfo.func = (varfunc) &datum_pose_geom;
  lfinfo.numparam = 0;
  lfinfo.args = true;
  lfinfo.argtype[0] = temptype_basetype(temp->temptype);
  lfinfo.restype = T_TGEOMPOINT;
  lfinfo.tpfunc_base = NULL;
  lfinfo.tpfunc = NULL;
  Temporal *result = tfunc_temporal(temp, &lfinfo);
  return result;
}

/*****************************************************************************
 * Accessor functions
 *****************************************************************************/

/**
 * @ingroup libmeos_tgeometry_accessor
 * @brief Return the start instant of a temporal value.
 * @sqlfunc startInstant
 * @pymeosfunc startInstant
 */
TInstant *
tgeometry_start_instant(const Temporal *temp)
{
  const TInstant *inst = temporal_start_instant(temp);
  TInstant *result = tgeometryinst_make1(tgeometry_geom(temp),
    tinstant_value(inst), inst->temptype, inst->t);
  return result;
}

/**
 * @ingroup libmeos_tgeometry_accessor
 * @brief Return the end instant of a temporal value.
 * @note This function is used for validity testing.
 * @sqlfunc endInstant
 * @pymeosfunc endInstant
 */
TInstant *
tgeometry_end_instant(const Temporal *temp)
{
  const TInstant *inst = temporal_end_instant(temp);
  TInstant *result = tgeometryinst_make1(tgeometry_geom(temp),
    tinstant_value(inst), inst->temptype, inst->t);
  return result;
}

/**
 * @ingroup libmeos_tgeometry_accessor
 * @brief Return the n-th instant of a temporal value.
 * @note n is assumed 1-based
 * @sqlfunc instantN
 * @pymeosfunc instantN
 */
TInstant *
tgeometry_instant_n(const Temporal *temp, int n)
{
  const TInstant *inst = temporal_instant_n(temp, n);
  TInstant *result = (inst == NULL) ? NULL : tgeometryinst_make1(
    tgeometry_geom(temp), tinstant_value(inst), inst->temptype, inst->t);
  return result;
}

/**
 * @ingroup libmeos_tgeometry_accessor
 * @brief Return the array of instants of a temporal value.
 * @sqlfunc instants
 * @pymeosfunc instants
 */
TInstant **
tgeometry_instants(const Temporal *temp, int *count)
{
  Datum geom = tgeometry_geom(temp);
  const TInstant **instants = temporal_instants(temp, count);
  TInstant **result = palloc(sizeof(TInstant *) * (*count));
  for (int i = 0; i < *count; ++i)
    result[i] = tgeometryinst_make1(geom, tinstant_value(instants[i]),
      instants[i]->temptype, instants[i]->t);
  return result;
}

/**
 * @ingroup libmeos_tgeometry_accessor
 * @brief Return the start sequence of a temporal sequence (set).
 * @sqlfunc startSequence
 */
TSequence *
tgeometry_start_sequence(const Temporal *temp)
{
  ensure_continuous(temp);
  TSequence *result;
  if (temp->subtype == TSEQUENCE)
    result = tsequence_copy((TSequence *) temp);
  else /* temp->subtype == TSEQUENCESET */
  {
    const TSequenceSet *ss = (const TSequenceSet *) temp;
    result = tgeometry_seqset_seq_n(ss, 0);
  }
  return result;
}

/**
 * @ingroup libmeos_tgeometry_accessor
 * @brief Return the end sequence of a temporal sequence (set).
 * @sqlfunc endSequence
 */
TSequence *
tgeometry_end_sequence(const Temporal *temp)
{
  ensure_continuous(temp);
  TSequence *result;
  if (temp->subtype == TSEQUENCE)
    result = tsequence_copy((TSequence *) temp);
  else /* temp->subtype == TSEQUENCESET */
  {
    const TSequenceSet *ss = (const TSequenceSet *) temp;
    result = tgeometry_seqset_seq_n(ss, ss->count - 1);
  }
  return result;
}

/**
 * @ingroup libmeos_tgeometry_accessor
 * @brief Return the n-th sequence of a temporal sequence (set).
 * @note n is assumed to be 1-based.
 * @sqlfunc sequenceN
 */
TSequence *
tgeometry_sequence_n(const Temporal *temp, int i)
{
  ensure_continuous(temp);
  TSequence *result = NULL;
  if (temp->subtype == TSEQUENCE)
  {
    if (i == 1)
      result = tsequence_copy((TSequence *) temp);
  }
  else /* temp->subtype == TSEQUENCESET */
  {
    const TSequenceSet *ss = (const TSequenceSet *) temp;
    if (i >= 1 && i <= ss->count)
      result = tgeometry_seqset_seq_n(ss, i - 1);
  }
  return result;
}

/**
 * @ingroup libmeos_tgeometry_accessor
 * @brief Return the array of sequences of a temporal sequence (set).
 * @sqlfunc sequences
 */
TSequence **
tgeometry_sequences(const Temporal *temp, int *count)
{
  TSequence **result;
  assert(temptype_subtype(temp->subtype));
  if (temp->subtype == TINSTANT)
    result = tgeometryinst_sequences((TInstant *) temp, count);
  else if (temp->subtype == TSEQUENCE)
    result = tgeometry_seq_sequences((TSequence *) temp, count);
  else /* temp->subtype == TSEQUENCE */
    result = tgeometry_seqset_sequences((TSequenceSet *) temp, count);
  return result;
}

/**
 * @ingroup libmeos_tgeometry_accessor
 * @brief Return the array of segments of a temporal value.
 * @sqlfunc segments
 */
TSequence **
tgeometry_segments(const Temporal *temp, int *count)
{
  TSequence **result;
  assert(temptype_subtype(temp->subtype));
  if (temp->subtype == TINSTANT)
    result = tgeometryinst_sequences((TInstant *) temp, count);
  else if (temp->subtype == TSEQUENCE)
    result = tgeometry_seq_segments((TSequence *) temp, count);
  else /* temp->subtype == TSEQUENCESET */
    result = tgeometry_seqset_segments((TSequenceSet *) temp, count);
  return result;
}

/*****************************************************************************
 * Restriction Functions
 *****************************************************************************/

/**
 * @ingroup libmeos_internal_temporal_restrict
 * @brief Return the base value of a temporal value at the timestamp
 * @sqlfunc valueAtTimestamp
 * @pymeosfunc valueAtTimestamp
 */
bool
tgeometry_value_at_timestamp(const Temporal *temp, TimestampTz t, bool strict,
  Datum *result)
{
  Datum pose_datum;
  bool found = temporal_value_at_timestamp(temp, t, strict, &pose_datum);
  if (found)
  {
    /* Apply pose to reference geometry */
    GSERIALIZED *gs = DatumGetGserializedP(tgeometry_geom(temp));
    GSERIALIZED *result_gs;
    Pose *pose = DatumGetPoseP(pose_datum);
    LWGEOM *geom = lwgeom_from_gserialized(gs);
    LWGEOM *result_geom = lwgeom_clone_deep(geom);
    lwgeom_apply_pose(result_geom, pose);
    if (result_geom->bbox)
      lwgeom_refresh_bbox(result_geom);
    lwgeom_free(geom);
    result_gs = geo_serialize(result_geom);
    lwgeom_free(result_geom);
    *result = PointerGetDatum(result_gs);
  }
  return found;
}

/*****************************************************************************/
