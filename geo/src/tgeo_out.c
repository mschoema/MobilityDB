/*****************************************************************************
 *
 * tgeo_out.c
 *    Output of temporal geometries in WKT and EWKT format
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "tgeo_out.h"

#include <float.h>
#include <utils/builtins.h>

#include "temporaltypes.h"
#include "tempcache.h"
#include "temporal_util.h"
#include "tpoint_out.h"
#include "tpoint_spatialfuncs.h"
#include "rtransform.h"

/******************************************************************************
 * Output as WKT and EWKT format
 ******************************************************************************/

/*
 * Output a moving geometry in Well-Known Text (WKT) and Extended Well-Known Text
 * (EWKT) format.
 * The Oid argument is not used but is needed since the second argument of
 * the functions temporal*_to_string is of type char *(*value_out)(Oid, Datum)
 */
static char *
geo_wkt_out(Oid type, Datum value)
{
  char *result;
  if (tgeo_base_type(type))
    result = wkt_out(type, value);
  else if (type == type_oid(T_RTRANSFORM2D))
  {
    RTransform2D *rt = DatumGetRTransform2D(value);
    result = psprintf("RTransform2D(%.*g, %.*g, %.*g)",
      DBL_DIG, rt->theta,
      DBL_DIG, rt->translation.a,
      DBL_DIG, rt->translation.b);
  }
  else if (type == type_oid(T_RTRANSFORM3D))
  {
    RTransform3D *rt = DatumGetRTransform3D(value);
    result = psprintf("RTransform3D(%.*g, %.*g, %.*g, %.*g, %.*g, %.*g, %.*g)",
      DBL_DIG, rt->quat.W,
      DBL_DIG, rt->quat.X,
      DBL_DIG, rt->quat.Y,
      DBL_DIG, rt->quat.Z,
      DBL_DIG, rt->translation.a,
      DBL_DIG, rt->translation.b,
      DBL_DIG, rt->translation.c);
  }
  return result;
}

/**
 * Returns the string representation of the temporal geometry
 *
 * @param[in] ti Temporal value
 * @param[in] value_out Function called to output the base value depending on
 * its Oid
 */
static char*
tgeoi_to_string(const TInstantSet *ti, char *(*value_out)(Oid, Datum))
{
  char** strings = palloc(sizeof(char *) * ti->count);
  size_t outlen = 0;

  for (int i = 0; i < ti->count; i++)
  {
    bool copy;
    TInstant *inst = tinstantset_standalone_inst_n(ti, i, &copy);
    strings[i] = tinstant_to_string(inst, value_out);
    outlen += strlen(strings[i]) + 2;
    if (copy)
      pfree(inst);
  }
  return stringarr_to_string(strings, ti->count, outlen, "", '{', '}');
}

/**
 * Returns the string representation of the temporal geometry
 *
 * @param[in] seq Temporal value
 * @param[in] component True when the output string is a component of
 * a temporal sequence set value and thus no interpolation string
 * at the begining of the string should be output
 * @param[in] value_out Function called to output the base value
 * depending on its Oid
 */
static char *
tgeoseq_to_string(const TSequence *seq, bool component,
  char *(*value_out)(Oid, Datum))
{
  char **strings = palloc(sizeof(char *) * seq->count);
  size_t outlen = 0;
  char prefix[20];
  if (! component && MOBDB_FLAGS_GET_CONTINUOUS(seq->flags) &&
    !MOBDB_FLAGS_GET_LINEAR(seq->flags))
    sprintf(prefix, "Interp=Stepwise;");
  else
    prefix[0] = '\0';
  for (int i = 0; i < seq->count; i++)
  {
    bool copy;
    TInstant *inst = tsequence_standalone_inst_n(seq, i, &copy);
    strings[i] = tinstant_to_string(inst, value_out);
    outlen += strlen(strings[i]) + 2;
    if (copy)
      pfree(inst);
  }
  char open = seq->period.lower_inc ? (char) '[' : (char) '(';
  char close = seq->period.upper_inc ? (char) ']' : (char) ')';
  return stringarr_to_string(strings, seq->count, outlen, prefix,
    open, close);
}

/**
 * Returns the string representation of the temporal geometry
 *
 * @param[in] ts Temporal value
 * @param[in] value_out Function called to output the base value
 * depending on its Oid
 */
static char *
tgeos_to_string(const TSequenceSet *ts, char *(*value_out)(Oid, Datum))
{
  char **strings = palloc(sizeof(char *) * ts->count);
  size_t outlen = 0;
  char prefix[20];
  if (MOBDB_FLAGS_GET_CONTINUOUS(ts->flags) &&
    ! MOBDB_FLAGS_GET_LINEAR(ts->flags))
    sprintf(prefix, "Interp=Stepwise;");
  else
    prefix[0] = '\0';
  for (int i = 0; i < ts->count; i++)
  {
    const TSequence *seq = tsequenceset_seq_n(ts, i);
    strings[i] = tgeoseq_to_string(seq, true, value_out);
    outlen += strlen(strings[i]) + 2;
  }
  return stringarr_to_string(strings, ts->count, outlen, prefix, '{', '}');
}

/**
 * Output a temporal geo in Well-Known Text (WKT) format
 * (dispatch function)
 */
static char *
tgeo_as_text_internal1(const Temporal *temp, bool asTransform)
{
  char *result;
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT)
    result = tinstant_to_string((TInstant *)temp, &geo_wkt_out);
  else if (temp->subtype == INSTANTSET)
    result = asTransform ?
      tinstantset_to_string((TInstantSet *)temp, &geo_wkt_out) :
      tgeoi_to_string((TInstantSet *)temp, &geo_wkt_out);
  else if (temp->subtype == SEQUENCE)
    result = asTransform ?
      tsequence_to_string((TSequence *)temp, false, &geo_wkt_out) :
      tgeoseq_to_string((TSequence *)temp, false, &geo_wkt_out);
  else /* temp->subtype == SEQUENCESET */
    result = asTransform ?
      tsequenceset_to_string((TSequenceSet *)temp, &geo_wkt_out) :
      tgeos_to_string((TSequenceSet *)temp, &geo_wkt_out);
  return result;
}

/**
 * Output a temporal geo in Well-Known Text (WKT) format
 */
static text *
tgeo_as_text_internal(const Temporal *temp, bool asTransform)
{
  char *str = tgeo_as_text_internal1(temp, asTransform);
  text *result = cstring_to_text(str);
  pfree(str);
  return result;
}

PG_FUNCTION_INFO_V1(tgeo_as_text);
/**
 * Output a temporal geo in Well-Known Text (WKT) format
 */
PGDLLEXPORT Datum
tgeo_as_text(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL(0);
  text *result = tgeo_as_text_internal(temp, false);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_TEXT_P(result);
}

PG_FUNCTION_INFO_V1(tgeo_as_transform);
/**
 * Output a temporal geo in Transformation format
 */
PGDLLEXPORT Datum
tgeo_as_transform(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL(0);
  text *result = tgeo_as_text_internal(temp, true);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_TEXT_P(result);
}

/**
 * Output a temporal geo in Extended Well-Known Text (EWKT) format,
 * that is, in WKT format prefixed with the SRID (dispatch function)
 */
static text *
tgeo_as_ewkt_internal(const Temporal *temp)
{
  int srid = tpoint_srid_internal(temp);
  char str1[20];
  if (srid > 0)
    sprintf(str1, "SRID=%d%c", srid,
      MOBDB_FLAGS_GET_LINEAR(temp->flags) ? ';' : ',');
  else
    str1[0] = '\0';
  char *str2 = tgeo_as_text_internal1(temp, false);
  char *str = (char *) palloc(strlen(str1) + strlen(str2) + 1);
  strcpy(str, str1);
  strcat(str, str2);
  text *result = cstring_to_text(str);
  pfree(str2); pfree(str);
  return result;
}

PG_FUNCTION_INFO_V1(tgeo_as_ewkt);
/**
 * Output a temporal geo in Extended Well-Known Text (EWKT) format,
 * that is, in WKT format prefixed with the SRID
 */
PGDLLEXPORT Datum
tgeo_as_ewkt(PG_FUNCTION_ARGS)
{
  Temporal *temp = PG_GETARG_TEMPORAL(0);
  text *result = tgeo_as_ewkt_internal(temp);
  PG_FREE_IF_COPY(temp, 0);
  PG_RETURN_TEXT_P(result);
}

/*****************************************************************************/

/**
 * Output a temporal geo array in Well-Known Text (WKT) or
 * Extended Well-Known Text (EWKT) format
 */
Datum
tgeoarr_as_text1(FunctionCallInfo fcinfo, bool extended, bool asTransform)
{
  ArrayType *array = PG_GETARG_ARRAYTYPE_P(0);
  /* Return NULL on empty array */
  int count = ArrayGetNItems(ARR_NDIM(array), ARR_DIMS(array));
  if (count == 0)
  {
    PG_FREE_IF_COPY(array, 0);
    PG_RETURN_NULL();
  }

  Temporal **temparr = temporalarr_extract(array, &count);
  text **textarr = palloc(sizeof(text *) * count);
  for (int i = 0; i < count; i++)
    textarr[i] = extended ? tgeo_as_ewkt_internal(temparr[i]) :
      tgeo_as_text_internal(temparr[i], asTransform);
  ArrayType *result = textarr_to_array(textarr, count);

  pfree_array((void **) textarr, count);
  pfree(temparr);
  PG_FREE_IF_COPY(array, 0);
  PG_RETURN_ARRAYTYPE_P(result);
}

PG_FUNCTION_INFO_V1(tgeoarr_as_text);
/**
 * Output a temporal geo array in Well-Known Text (WKT) format
 */
PGDLLEXPORT Datum
tgeoarr_as_text(PG_FUNCTION_ARGS)
{
  return tgeoarr_as_text1(fcinfo, false, false);
}

PG_FUNCTION_INFO_V1(tgeoarr_as_transform);
/**
 * Output a temporal geo array in Transformation format
 */
PGDLLEXPORT Datum
tgeoarr_as_transform(PG_FUNCTION_ARGS)
{
  return tgeoarr_as_text1(fcinfo, false, true);
}

PG_FUNCTION_INFO_V1(tgeoarr_as_ewkt);
/**
 * Output a temporal geo array in Extended Well-Known Text (EWKT) format,
 * that is, in WKT format prefixed with the SRID
 */
PGDLLEXPORT Datum
tgeoarr_as_ewkt(PG_FUNCTION_ARGS)
{
  return tgeoarr_as_text1(fcinfo, true, false);
}

/*****************************************************************************/
