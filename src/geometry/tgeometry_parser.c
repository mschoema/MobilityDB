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
 * @file tgeometry_parser.c
 * Functions for parsing rigid temporal geometries.
 */

#include "geometry/tgeometry_parser.h"

#include <utils/builtins.h>
#include <utils/timestamp.h>

#include "general/temporaltypes.h"
#include "general/tempcache.h"
#include "general/temporal_util.h"
#include "general/temporal_parser.h"

#include "point/tpoint_spatialfuncs.h"

#include "geometry/tgeometry_inst.h"

/*****************************************************************************/

/**
 * Parse a rigid temporal geometry value of instant type from the buffer
 *
 * @param[in] str Input string
 * @param[in] basetype Oid of the base type
 * @param[in] end Set to true when reading a single instant to ensure there is
 * no moreinput after the sequence
 * @param[in] make Set to false for the first pass to do not create the instant
 * @param[in] geom the reference geometry
 */
static TInstant *
tgeometryinst_parse(char **str, Oid basetype, bool end, bool make, Datum geom)
{
  p_whitespace(str);
  /* The next two instructions will throw an exception if they fail */
  Datum value = basetype_parse(str, basetype);
  TimestampTz t = timestamp_parse(str);
  ensure_end_input(str, end);
  if (! make)
    return NULL;
  return tgeometryinst_make(value, t, basetype, WITH_GEOM, geom);
}

/**
 * Parse a rigid temporal geometry value of instant set type from the buffer
 *
 * @param[in] str Input string
 * @param[in] basetype Oid of the base type
 * @param[in] geom the reference geometry
 */
static TInstantSet *
tgeometryinstset_parse(char **str, Oid basetype, Datum geom)
{
  p_whitespace(str);
  /* We are sure to find an opening brace because that was the condition
   * to call this function in the dispatch function tgeometry_parse */
  p_obrace(str);

  /* First parsing */
  char *bak = *str;
  tgeometryinst_parse(str, basetype, false, false, geom);
  int count = 1;
  while (p_comma(str))
  {
    count++;
    tgeometryinst_parse(str, basetype, false, false, geom);
  }
  if (!p_cbrace(str))
    ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
      errmsg("Could not parse temporal value")));
  ensure_end_input(str, true);

  /* Second parsing */
  *str = bak;
  TInstant **instants = palloc(sizeof(TInstant *) * count);
  for (int i = 0; i < count; i++)
  {
    p_comma(str);
    instants[i] = tgeometryinst_parse(str, basetype, false, true, geom);
  }
  p_cbrace(str);
  return tinstantset_make_free(instants, count, MERGE_NO);
}

/**
 * Parse a rigid temporal geometry value of sequence type from the buffer
 *
 * @param[in] str Input string
 * @param[in] basetype Oid of the base type
 * @param[in] linear Set to true when the sequence set has linear interpolation
 * @param[in] end Set to true when reading a single instant to ensure there is
 * no moreinput after the sequence
 * @param[in] make Set to false for the first pass to do not create the instant
 * @param[in] geom the reference geometry
*/
static TSequence *
tgeometryseq_parse(char **str, Oid basetype, bool linear, bool end, bool make, Datum geom)
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
  char *bak = *str;
  tgeometryinst_parse(str, basetype, false, false, geom);
  int count = 1;
  while (p_comma(str))
  {
    count++;
    tgeometryinst_parse(str, basetype, false, false, geom);
  }
  if (p_cbracket(str))
    upper_inc = true;
  else if (p_cparen(str))
    upper_inc = false;
  else
    ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
      errmsg("Could not parse temporal value")));
  ensure_end_input(str, end);
  if (! make)
    return NULL;

  /* Second parsing */
  *str = bak;
  TInstant **instants = palloc(sizeof(TInstant *) * count);
  for (int i = 0; i < count; i++)
  {
    p_comma(str);
    instants[i] = tgeometryinst_parse(str, basetype, false, true, geom);
  }
  p_cbracket(str);
  p_cparen(str);
  return tsequence_make_free(instants, count, lower_inc, upper_inc,
    linear, NORMALIZE);
}

/**
 * Parse a temporal geometry value of sequence set type from the buffer
 *
 * @param[in] str Input string
 * @param[in] basetype Oid of the base type
 * @param[in] linear Set to true when the sequence set has linear interpolation
 * @param[in] geom the reference geometry
 */
static TSequenceSet *
tgeometryseqset_parse(char **str, Oid basetype, bool linear, Datum geom)
{
  p_whitespace(str);
  /* We are sure to find an opening brace because that was the condition
   * to call this function in the dispatch function tpoint_parse */
  p_obrace(str);

  /* First parsing */
  char *bak = *str;
  tgeometryseq_parse(str, basetype, linear, false, false, geom);
  int count = 1;
  while (p_comma(str))
  {
    count++;
    tgeometryseq_parse(str, basetype, linear, false, false, geom);
  }
  if (!p_cbrace(str))
    ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
      errmsg("Could not parse temporal value")));
  ensure_end_input(str, true);

  /* Second parsing */
  *str = bak;
  TSequence **sequences = palloc(sizeof(TSequence *) * count);
  for (int i = 0; i < count; i++)
  {
    p_comma(str);
    sequences[i] = tgeometryseq_parse(str, basetype, linear, false, true,
      geom);
  }
  p_cbrace(str);
  return tsequenceset_make_free(sequences, count, NORMALIZE);
}

/**
 * Parse a rigid temporal geometry value from the buffer (dispatch function)
 *
 * @param[in] str Input string
 * @param[in] basetype Oid of the base type
 */
Temporal *
tgeometry_parse(char **str, Oid basetype)
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

  bool linear = base_type_continuous(basetype);
  /* Starts with "Interp=Stepwise" */
  if (strncasecmp(*str, "Interp=Stepwise;", 16) == 0)
  {
    /* Move str after the semicolon */
    *str += 16;
    linear = false;
  }

  p_whitespace(str);
  int delim = 0;
  while ((*str)[delim] != ';' && (*str)[delim] != '\0')
    delim++;
  if ((*str)[delim] == '\0')
    ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
      errmsg("Could not parse element value")));
  (*str)[delim] = '\0';
  Datum geom = call_input(type_oid(T_GEOMETRY), *str);
  (*str)[delim] = ';';
  /* since we know there's an ; here, let's take it with us */
  *str += delim + 1;

  GSERIALIZED *gs = (GSERIALIZED *)PG_DETOAST_DATUM(geom);
  ensure_non_empty(gs);
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
    ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
      errmsg("Geometry SRID (%d) does not match temporal type SRID (%d)",
      geo_srid, tgeometry_srid)));
  geom = PointerGetDatum(gs);

  p_whitespace(str);
  Temporal *result = NULL; /* keep compiler quiet */
  /* Determine the type of the rigid temporal geometry */
  if (**str != '{' && **str != '[' && **str != '(')
  {
    result = (Temporal *) tgeometryinst_parse(str, basetype, true, true, geom);
  }
  else if (**str == '[' || **str == '(')
    result = (Temporal *) tgeometryseq_parse(str, basetype, linear,
      true, true, geom);
  else if (**str == '{')
  {
    char *bak = *str;
    p_obrace(str);
    p_whitespace(str);
    if (**str == '[' || **str == '(')
    {
      *str = bak;
      result = (Temporal *) tgeometryseqset_parse(str, basetype, linear, geom);
    }
    else
    {
      *str = bak;
      result = (Temporal *) tgeometryinstset_parse(str, basetype, geom);
    }
  }
  pfree(gs);
  return result;
}

/*****************************************************************************/
