/*****************************************************************************
 *
 * tgeo_parser.c
 *    Functions for parsing temporal geometries.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "tgeo_parser.h"

#include "temporaltypes.h"
#include "oidcache.h"
#include "temporal_parser.h"
#include "tgeo.h"
#include "tpoint_spatialfuncs.h"
#include "tgeo_spatialfuncs.h"

/*****************************************************************************/

/**
 * Parse a temporal geometry value of instant duration from the buffer
 *
 * @param[in] str Input string
 * @param[in] basetype Oid of the base type
 * @param[in] end Set to true when reading a single instant to ensure there is
 * no moreinput after the sequence
 * @param[in] make Set to false for the first pass to do not create the instant
 * @param[in] tpoint_srid SRID of the temporal geometry
 */
static TInstant *
tgeoinst_parse(char **str, Oid basetype, bool end, bool make, int *tgeo_srid)
{
  p_whitespace(str);
  /* The next instruction will throw an exception if it fails */
  Datum geo = basetype_parse(str, basetype);
  GSERIALIZED *gs = (GSERIALIZED *)PG_DETOAST_DATUM(geo);
  int geo_srid = gserialized_get_srid(gs);
  ensure_geo_type(gs);
  ensure_non_empty(gs);
  ensure_has_not_M_gs(gs);
  if (*tgeo_srid != SRID_UNKNOWN && geo_srid != SRID_UNKNOWN && *tgeo_srid != geo_srid)
    ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
      errmsg("Geometry SRID (%d) does not match temporal type SRID (%d)",
      geo_srid, *tgeo_srid)));
  if (basetype == type_oid(T_GEOMETRY))
  {
    if (*tgeo_srid != SRID_UNKNOWN && geo_srid == SRID_UNKNOWN)
      gserialized_set_srid(gs, *tgeo_srid);
    if (*tgeo_srid == SRID_UNKNOWN && geo_srid != SRID_UNKNOWN)
      *tgeo_srid = geo_srid;
  }
  else                                  // GEOGRAPHY
  {
    ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
      errmsg("Only geometry types accepted")));
  }
  /* The next instruction will throw an exception if it fails */
  TimestampTz t = timestamp_parse(str);
  ensure_end_input(str, end);
  TInstant *result = make ?
  tinstant_make(PointerGetDatum(gs), t, basetype) : NULL;
  pfree(gs);
  return result;
}

/**
 * Parse a temporal geometry value of instant set duration from the buffer
 *
 * @param[in] str Input string
 * @param[in] basetype Oid of the base type
 * @param[in] tpoint_srid SRID of the temporal geometry
 */
static TInstantSet *
tgeoinstset_parse(char **str, Oid basetype, int *tgeo_srid)
{
  p_whitespace(str);
  /* We are sure to find an opening brace because that was the condition
   * to call this function in the dispatch function tpoint_parse */
  p_obrace(str);

  /* First parsing */
  char *bak = *str;
  tgeoinst_parse(str, basetype, false, false, tgeo_srid);
  int count = 1;
  while (p_comma(str))
  {
    count++;
    tgeoinst_parse(str, basetype, false, false, tgeo_srid);
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
    instants[i] = tgeoinst_parse(str, basetype, false, true, tgeo_srid);
  }
  p_cbrace(str);
  return tinstantset_make_free(instants, count);
}

/**
 * Parse a temporal geometry value of sequence duration from the buffer
 *
 * @param[in] str Input string
 * @param[in] basetype Oid of the base type
 * @param[in] linear Set to true when the sequence set has linear interpolation
 * @param[in] end Set to true when reading a single instant to ensure there is
 * no moreinput after the sequence
 * @param[in] make Set to false for the first pass to do not create the instant
 * @param[in] tpoint_srid SRID of the temporal geometry
*/
static TSequence *
tgeoseq_parse(char **str, Oid basetype, bool linear, bool end, bool make, int *tgeo_srid)
{
  p_whitespace(str);
  bool lower_inc = false, upper_inc = false;
  /* We are sure to find an opening bracket or parenthesis because that was
   * the condition to call this function in the dispatch function tpoint_parse */
  if (p_obracket(str))
    lower_inc = true;
  else if (p_oparen(str))
    lower_inc = false;

  /* First parsing */
  char *bak = *str;
  tgeoinst_parse(str, basetype, false, false, tgeo_srid);
  int count = 1;
  while (p_comma(str))
  {
    count++;
    tgeoinst_parse(str, basetype, false, false, tgeo_srid);
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
    instants[i] = tgeoinst_parse(str, basetype, false, true, tgeo_srid);
  }

  p_cbracket(str);
  p_cparen(str);

  return tsequence_make_free(instants, count, lower_inc, upper_inc,
    linear, NORMALIZE);
}

/**
 * Parse a temporal geometry value of sequence set duration from the buffer
 *
 * @param[in] str Input string
 * @param[in] basetype Oid of the base type
 * @param[in] linear Set to true when the sequence set has linear interpolation
 * @param[in] tpoint_srid SRID of the temporal geometry
 */
static TSequenceSet *
tgeoseqset_parse(char **str, Oid basetype, bool linear, int *tgeo_srid)
{
  p_whitespace(str);
  /* We are sure to find an opening brace because that was the condition
   * to call this function in the dispatch function tpoint_parse */
  p_obrace(str);

  /* First parsing */
  char *bak = *str;
  tgeoseq_parse(str, basetype, linear, false, false, tgeo_srid);
  int count = 1;
  while (p_comma(str))
  {
    count++;
    tgeoseq_parse(str, basetype, linear, false, false, tgeo_srid);
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
    sequences[i] = tgeoseq_parse(str, basetype, linear, false, true, tgeo_srid);
  }
  p_cbrace(str);
  return tsequenceset_make_free(sequences, count, NORMALIZE);
}

Temporal *
tgeo_parse(char **str, Oid basetype)
{
  int tgeo_srid = 0;
  p_whitespace(str);

  /* Starts with "SRID=". The SRID specification must be gobbled for all
   * durations excepted TInstant. We cannot use the atoi() function
   * because this requires a string terminated by '\0' and we cannot
   * modify the string in case it must be passed to the tgeoinst_parse
   * function. */
  char *bak = *str;
  if (strncasecmp(*str,"SRID=",5) == 0)
  {
    /* Move str to the start of the numeric part */
    *str += 5;
    int delim = 0;
    tgeo_srid = 0;
    /* Delimiter will be either ',' or ';' depending on whether interpolation
       is given after */
    while ((*str)[delim] != ',' && (*str)[delim] != ';' && (*str)[delim] != '\0')
    {
      tgeo_srid = tgeo_srid * 10 + (*str)[delim] - '0';
      delim++;
    }
    /* Set str to the start of the temporal geo */
    *str += delim + 1;
  }
  /* We cannot ensure that the SRID is geodetic for geography since
   * the srid_is_latlong function is not exported by PostGIS
  if (basetype == type_oid(T_GEOGRAPHY))
    srid_is_latlong(fcinfo, tgeo_srid);
   */

  bool linear = linear_interpolation(basetype);
  /* Starts with "Interp=Stepwise" */
  if (strncasecmp(*str,"Interp=Stepwise;",16) == 0)
  {
    /* Move str after the semicolon */
    *str += 16;
    linear = false;
  }
  Temporal *result = NULL; /* keep compiler quiet */
  /* Determine the type of the temporal geo */
  if (**str != '{' && **str != '[' && **str != '(')
  {
    /* Pass the SRID specification */
    *str = bak;
    result = (Temporal *)tgeoinst_parse(str, basetype, true, true, &tgeo_srid);
  }
  else if (**str == '[' || **str == '(')
    result = (Temporal *)tgeoseq_parse(str, basetype, linear, true, true, &tgeo_srid);
  else if (**str == '{')
  {
    bak = *str;
    p_obrace(str);
    p_whitespace(str);
    if (**str == '[' || **str == '(')
    {
      *str = bak;
      result = (Temporal *)tgeoseqset_parse(str, basetype, linear, &tgeo_srid);
    }
    else
    {
      *str = bak;
      result = (Temporal *)tgeoinstset_parse(str, basetype, &tgeo_srid);
    }
  }
  return result;
}

/*****************************************************************************/
