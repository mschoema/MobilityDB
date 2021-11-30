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
 * @file pose_parser.c
 * Functions for parsing static network types.
 */

#include "pose/pose_parser.h"

#include "general/temporal_parser.h"
#include "pose/pose.h"

/*****************************************************************************/

/**
 * Parse a pose value from the buffer
 */
pose *
pose_parse(char **str)
{
  bool hasZ = false;

  p_whitespace(str);

  if (strncasecmp(*str,"POSE",4) != 0)
    ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
      errmsg("Could not parse pose value: %s", *str)));

  *str += 4;
  p_whitespace(str);

  if (strncasecmp(*str,"Z",1) == 0)
  {
    hasZ = true;
    *str += 1;
  }

  p_whitespace(str);

  int delim = 0;
  while ((*str)[delim] != ')' && (*str)[delim] != '\0')
    delim++;
  if ((*str)[delim] == '\0')
    ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
      errmsg("Could not parse pose value: %s", *str)));

  pose *result;
  if (!hasZ)
  {
    double x, y, theta;
    if (sscanf(*str, "( %lf , %lf , %lf )", &x, &y, &theta) != 3)
      ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
          errmsg("Could not parse pose value: %s", *str)));
    result = pose_make_2d(x, y, theta);
  }
  else
  {
    double x, y, z, W, X, Y, Z;
    if (sscanf(*str, "( %lf , %lf , %lf , %lf , %lf , %lf , %lf )", &x, &y, &z, &W, &X, &Y, &Z) != 7)
      ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
          errmsg("Could not parse pose value: %s", *str)));
    result = pose_make_3d(x, y, z, W, X, Y, Z);
  }

  *str += delim + 1;

  return result;
}

/*****************************************************************************/
