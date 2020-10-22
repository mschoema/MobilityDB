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
char *
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
 * Output a temporal geo in Well-Known Text (WKT) format
 * (dispatch function)
 */
static char *
tgeo_as_text_internal1(const Temporal *temp)
{
  char *result;
  ensure_valid_tempsubtype(temp->subtype);
  if (temp->subtype == INSTANT)
    result = tinstant_to_string((TInstant *)temp, &geo_wkt_out);
  else if (temp->subtype == INSTANTSET)
    result = tinstantset_to_string((TInstantSet *)temp, &geo_wkt_out);
  else if (temp->subtype == SEQUENCE)
    result = tsequence_to_string((TSequence *)temp, false, &geo_wkt_out);
  else /* temp->subtype == SEQUENCESET */
    result = tsequenceset_to_string((TSequenceSet *)temp, &geo_wkt_out);
  return result;
}

/**
 * Output a temporal geo in Well-Known Text (WKT) format
 */
static text *
tgeo_as_text_internal(const Temporal *temp)
{
  char *str = tgeo_as_text_internal1(temp);
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
  text *result = tgeo_as_text_internal(temp);
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
  char *str2 = tgeo_as_text_internal1(temp);
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
tgeoarr_as_text1(FunctionCallInfo fcinfo, bool extended)
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
      tgeo_as_text_internal(temparr[i]);
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
  return tgeoarr_as_text1(fcinfo, false);
}

PG_FUNCTION_INFO_V1(tgeoarr_as_ewkt);
/**
 * Output a temporal geo array in Extended Well-Known Text (EWKT) format,
 * that is, in WKT format prefixed with the SRID
 */
PGDLLEXPORT Datum
tgeoarr_as_ewkt(PG_FUNCTION_ARGS)
{
  return tgeoarr_as_text1(fcinfo, true);
}

/*****************************************************************************/
