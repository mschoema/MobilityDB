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
 * @brief Functions for parsing rigid temporal geometries.
 */

#include "geometry/tgeometry_parser.h"

/* MEOS */
#include <meos.h>
#include <meos_internal.h>
#include "general/type_parser.h"
#include "general/type_util.h"
#include "point/tpoint_spatialfuncs.h"
#include "geometry/tgeometry_temporaltypes.h"

/*****************************************************************************/

/**
 * @brief Parse a rigid temporal instant geometry from the buffer.
 * @param[in] str Input string
 * @param[in] temptype Temporal type
 * @param[in] end Set to true when reading a single instant to ensure there is
 * no moreinput after the sequence
 * @param[in] make Set to false for the first pass to do not create the instant
 * @param[in] geom the reference geometry
 */
static TInstant *
tgeometryinst_parse(const char **str, meosType temptype, bool end, bool make,
  Datum geom)
{
  p_whitespace(str);
  meosType basetype = temptype_basetype(temptype);
  /* The next two instructions will throw an exception if they fail */
  Datum value = temporal_basetype_parse(str, basetype);
  TimestampTz t = timestamp_parse(str);
  if ((end && ! ensure_end_input(str, "temporal geometry")) || ! make)
  {
    pfree(DatumGetPointer(value));
    return NULL;
  }
  TInstant *result = tgeometryinst_make(geom, value, temptype, t);
  pfree(DatumGetPointer(value));
  return result;
}

/**
 * @brief Parse a rigid temporal discrete sequence geometry from the buffer.
 * @param[in] str Input string
 * @param[in] temptype Temporal type
 * @param[in] geom the reference geometry
 */
static TSequence *
tgeometry_discseq_parse(const char **str, meosType temptype, Datum geom)
{
  const char *type_str = "temporal geometry";
  p_whitespace(str);
  /* We are sure to find an opening brace because that was the condition
   * to call this function in the dispatch function tgeometry_parse */
  p_obrace(str);

  /* First parsing */
  const char *bak = *str;
  tgeometryinst_parse(str, temptype, false, false, geom);
  int count = 1;
  while (p_comma(str))
  {
    count++;
    tgeometryinst_parse(str, temptype, false, false, geom);
  }
  if (! ensure_cbrace(str, type_str) || ! ensure_end_input(str, type_str))
    return NULL;

  /* Second parsing */
  *str = bak;
  TInstant **instants = palloc(sizeof(TInstant *) * count);
  for (int i = 0; i < count; i++)
  {
    p_comma(str);
    instants[i] = tgeometryinst_parse(str, temptype, false, true, geom);
  }
  p_cbrace(str);
  return tgeometry_seq_make_free(geom, instants, count, true, true,
    DISCRETE, NORMALIZE_NO);
}

/**
 * @brief Parse a rigid temporal sequence geometry from the buffer.
 * @param[in] str Input string
 * @param[in] temptype Temporal type
 * @param[in] interp Interpolation
 * @param[in] end Set to true when reading a single instant to ensure there is
 * no moreinput after the sequence
 * @param[in] make Set to false for the first pass to do not create the instant
 * @param[in] geom the reference geometry
*/
static TSequence *
tgeometry_seq_parse(const char **str, meosType temptype, interpType interp,
  bool end, bool make, Datum geom)
{
  p_whitespace(str);
  bool lower_inc = false, upper_inc = false;
  /* We are sure to find an opening bracket or parenthesis because that was the
   * condition to call this function in the dispatch function tgeometry_parse */
  if (p_obracket(str))
    lower_inc = true;
  else if (p_oparen(str))
    lower_inc = false;

  /* First parsing */
  const char *bak = *str;
  tgeometryinst_parse(str, temptype, false, false, geom);
  int count = 1;
  while (p_comma(str))
  {
    count++;
    tgeometryinst_parse(str, temptype, false, false, geom);
  }
  if (p_cbracket(str))
    upper_inc = true;
  else if (p_cparen(str))
    upper_inc = false;
  else
  {
    meos_error(ERROR, MEOS_ERR_TEXT_INPUT,
      "Could not parse temporal geometry value: Missing closing bracket/parenthesis");
    return NULL;
  }
  /* Ensure there is no more input */
  if ((end && ! ensure_end_input(str, "temporal geometry")) || ! make)
    return NULL;

  /* Second parsing */
  *str = bak;
  TInstant **instants = palloc(sizeof(TInstant *) * count);
  for (int i = 0; i < count; i++)
  {
    p_comma(str);
    instants[i] = tgeometryinst_parse(str, temptype, false, true, geom);
  }
  p_cbracket(str);
  p_cparen(str);
  return tgeometry_seq_make_free(geom, instants, count,
    lower_inc, upper_inc, interp, NORMALIZE);
}

/**
 * @brief Parse a rigid temporal sequence set geometry from the buffer.
 * @param[in] str Input string
 * @param[in] temptype Temporal type
 * @param[in] interp Interpolation
 * @param[in] geom the reference geometry
 */
static TSequenceSet *
tgeometry_seqset_parse(const char **str, meosType temptype, interpType interp,
  Datum geom)
{
  const char *type_str = "temporal geometry";
  p_whitespace(str);
  /* We are sure to find an opening brace because that was the condition
   * to call this function in the dispatch function tpoint_parse */
  p_obrace(str);

  /* First parsing */
  const char *bak = *str;
  tgeometry_seq_parse(str, temptype, interp, false, false, geom);
  int count = 1;
  while (p_comma(str))
  {
    count++;
    tgeometry_seq_parse(str, temptype, interp, false, false, geom);
  }
  if (! ensure_cbrace(str, type_str) || ! ensure_end_input(str, type_str))
    return NULL;

  /* Second parsing */
  *str = bak;
  TSequence **sequences = palloc(sizeof(TSequence *) * count);
  for (int i = 0; i < count; i++)
  {
    p_comma(str);
    sequences[i] = tgeometry_seq_parse(str, temptype, interp, false, true,
      geom);
  }
  p_cbrace(str);
  return tgeometry_seqset_make_free(geom, sequences, count, NORMALIZE);
}

/**
 * @brief Parse a rigid temporal geometry value from the buffer.
 * @param[in] str Input string
 * @param[in] temptype Temporal type
 */
Temporal *
tgeometry_parse(const char **str, meosType temptype)
{
  int tgeometry_srid = 0;
  p_whitespace(str);

  /* Starts with "SRID=". The SRID specification must be gobbled for all
   * types. We cannot use the atoi() function
   * because this requires a string terminated by '\0' and we cannot
   * modify the string in case it must be passed to the tgeometryinst_parse
   * function. */
  if (strncasecmp(*str, "SRID=", 5) == 0)
  {
    /* Move str to the start of the number part */
    *str += 5;
    int delim = 0;
    tgeometry_srid = 0;
    /* Delimiter will be either ',' or ';' depending on whether interpolation
       is given after */
    while ((*str)[delim] != ',' && (*str)[delim] != ';' && (*str)[delim] != '\0')
    {
      tgeometry_srid = tgeometry_srid * 10 + (*str)[delim] - '0';
      delim++;
    }
    /* Set str to the start of the rigid temporal geometry */
    *str += delim + 1;
  }

  interpType interp = temptype_continuous(temptype) ? LINEAR : STEP;
  /* Starts with "Interp=Step" */
  if (strncasecmp(*str, "Interp=Step;", 12) == 0)
  {
    /* Move str after the semicolon */
    *str += 12;
    interp = STEP;
  }

  /* Parse de refence geometry */
  p_whitespace(str);
  int delim = 0;
  while ((*str)[delim] != ';' && (*str)[delim] != '\0')
    delim++;
  if ((*str)[delim] == '\0')
  {
    meos_error(ERROR, MEOS_ERR_TEXT_INPUT,
      "Could not parse element value");
    return NULL;
  }
  char *str1 = palloc(sizeof(char) * (delim + 1));
  strncpy(str1, *str, delim);
  str1[delim] = '\0';
  Datum geom = basetype_in(str1, T_GEOMETRY, false);
  pfree(str1);
  /* since there's an ; here, let's take it with us */
  *str += delim + 1;

  GSERIALIZED *gs = DatumGetGserializedP(geom);
  ensure_not_empty(gs);
  ensure_has_not_M_gs(gs);
  /* If one of the SRID of the rigid temporal geometry and of the geometry
   * is SRID_UNKNOWN and the other not, copy the SRID */
  int geo_srid = gserialized_get_srid(gs);
  if (tgeometry_srid == SRID_UNKNOWN && geo_srid != SRID_UNKNOWN)
    tgeometry_srid = geo_srid;
  else if (tgeometry_srid != SRID_UNKNOWN && geo_srid == SRID_UNKNOWN)
    gserialized_set_srid(gs, tgeometry_srid);
  /* If the SRID of the rigid temporal geometry and of the geometry do not match */
  else if (tgeometry_srid != SRID_UNKNOWN && geo_srid != SRID_UNKNOWN &&
    tgeometry_srid != geo_srid)
  {
    meos_error(ERROR, MEOS_ERR_TEXT_INPUT,
      "Geometry SRID (%d) does not match temporal type SRID (%d)",
      geo_srid, tgeometry_srid);
    pfree(gs);
    return NULL;
  }

  p_whitespace(str);
  Temporal *result = NULL; /* keep compiler quiet */
  /* Determine the type of the rigid temporal geometry */
  if (**str != '{' && **str != '[' && **str != '(')
  {
    result = (Temporal *) tgeometryinst_parse(str, temptype, true, true, geom);
  }
  else if (**str == '[' || **str == '(')
    result = (Temporal *) tgeometry_seq_parse(str, temptype, interp,
      true, true, geom);
  else if (**str == '{')
  {
    const char *bak = *str;
    p_obrace(str);
    p_whitespace(str);
    if (**str == '[' || **str == '(')
    {
      *str = bak;
      result = (Temporal *) tgeometry_seqset_parse(str, temptype, interp, geom);
    }
    else
    {
      *str = bak;
      result = (Temporal *) tgeometry_discseq_parse(str, temptype, geom);
    }
  }
  pfree(gs);
  return result;
}

/*****************************************************************************/
