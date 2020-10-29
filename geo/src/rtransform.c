/*****************************************************************************
 *
 * rtransform.c
 *    Functions for 2D and 3D Rigidbody Transformations.
 *
 * Portions Copyright (c) 2019, Maxime Schoemans, Esteban Zimanyi,
 *    Universite Libre de Bruxelles
 * Portions Copyright (c) 1996-2019, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *****************************************************************************/

#include "rtransform.h"

#include <assert.h>
#include <libpq/pqformat.h>
#include <executor/spi.h>
#include <liblwgeom.h>
#include <math.h>
#include <float.h>

#include "temporaltypes.h"
#include "tempcache.h"
#include "doublen.h"
#include "lwgeom_utils.h"
#include "quaternion.h"
#include "tgeo_parser.h"
#include "tgeo_spatialfuncs.h"
#include "tpoint_spatialfuncs.h"

/*****************************************************************************
 * Input/Output functions for RTransform2D and RTransform3D
 *****************************************************************************/

PG_FUNCTION_INFO_V1(rtransform_in_2d);
/**
 * Input function for 2D rtransform values (stub only)
 */
PGDLLEXPORT Datum
rtransform_in_2d(PG_FUNCTION_ARGS)
{
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("function rtransform_in_2d not implemented")));
  PG_RETURN_POINTER(NULL);
}

PG_FUNCTION_INFO_V1(rtransform_out_2d);
/**
 * Output function for 2D rtransform values (stub only)
 */
PGDLLEXPORT Datum
rtransform_out_2d(PG_FUNCTION_ARGS)
{
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("function rtransform_out_2d not implemented")));
  PG_RETURN_POINTER(NULL);
}

PG_FUNCTION_INFO_V1(rtransform_in_3d);
/**
 * Input function for 3D rtransform values (stub only)
 */
PGDLLEXPORT Datum
rtransform_in_3d(PG_FUNCTION_ARGS)
{
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("function rtransform_in_3d not implemented")));
  PG_RETURN_POINTER(NULL);
}

PG_FUNCTION_INFO_V1(rtransform_out_3d);
/**
 * Output function for 3D rtransform values (stub only)
 */
PGDLLEXPORT Datum
rtransform_out_3d(PG_FUNCTION_ARGS)
{
  ereport(ERROR,(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
    errmsg("function rtransform_out_3d not implemented")));
  PG_RETURN_POINTER(NULL);
}

/*****************************************************************************
 * Constructor functions
 *****************************************************************************/

RTransform2D *
rtransform_make_2d(double theta, double2 translation)
{
    if (theta < -M_PI || theta > M_PI)
        ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Rotation theta must be in ]-pi, pi]. Recieved: %f", theta)));

    /* If we want a unique representation for theta */
    if (theta == -M_PI)
        theta = M_PI;

    RTransform2D *result = (RTransform2D *)palloc(sizeof(RTransform2D));
    result->theta = theta;
    result->translation = translation;
    return result;
}

RTransform3D *
rtransform_make_3d(Quaternion quat, double3 translation)
{
    if (fabs(quaternion_norm(quat) - 1)  > EPSILON)
        ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Rotation quaternion must be of unit norm. Recieved: %f", quaternion_norm(quat))));

    /* If we want a unique representation for the quaternion */
    if (quat.W < 0.0)
        quat = quaternion_negate(quat);

    RTransform3D *result = (RTransform3D *)palloc(sizeof(RTransform3D));
    result->quat = quat;
    result->translation = translation;
    return result;
}

Datum
rtransform_zero_datum(Oid basetypid)
{
  Datum result;
  if (basetypid == type_oid(T_RTRANSFORM2D))
  {
    RTransform2D *rt = rtransform_make_2d(0, (double2) {0, 0});
    result = RTransform2DGetDatum(rt);
  }
  else if (basetypid == type_oid(T_RTRANSFORM3D))
  {
    RTransform3D *rt = rtransform_make_3d((Quaternion) {1, 0, 0, 0}, (double3) {0, 0, 0});
    result = RTransform3DGetDatum(rt);
  }
  return result;
}

/*****************************************************************************
 * Comparison functions
 *****************************************************************************/

bool
rtransform_eq_datum(const Datum rt1_datum, const Datum rt2_datum, Oid basetypid)
{
  bool result;
  if (basetypid == type_oid(T_RTRANSFORM2D))
  {
    RTransform2D *rt1 = DatumGetRTransform2D(rt1_datum);
    RTransform2D *rt2 = DatumGetRTransform2D(rt2_datum);
    result = (rt1->theta == rt2->theta && double2_eq(&rt1->translation, &rt2->translation));
  }
  else if (basetypid == type_oid(T_RTRANSFORM3D))
  {
    RTransform3D *rt1 = DatumGetRTransform3D(rt1_datum);
    RTransform3D *rt2 = DatumGetRTransform3D(rt2_datum);
    result = (quaternion_eq(rt1->quat, rt2->quat) && double3_eq(&rt1->translation, &rt2->translation));
  }
  return result;
}

/*****************************************************************************
 * Apply functions
 *****************************************************************************/

static void
rtransform_apply_2d(const RTransform2D *rt, LWGEOM *geom, LWPOINT *centroid)
{
  if (centroid)
  {
    double x = lwpoint_get_x(centroid);
    double y = lwpoint_get_y(centroid);

    double a = cos(rt->theta);
    double b = sin(rt->theta);

    /* Translate to have centroid at (0,0) */
    lwgeom_translate_2d(geom, -x, -y);
    /* Apply tranform */
    lwgeom_rotate_2d(geom, a, -b, b, a);
    /* Translate back */
    lwgeom_translate_2d(geom, x, y);
  }

  double dx = rt->translation.a;
  double dy = rt->translation.b;
  lwgeom_translate_2d(geom, dx, dy);
  return;
}

static void
rtransform_apply_3d(const RTransform3D *rt, LWGEOM *geom, LWPOINT *centroid)
{
  if (centroid)
  {
    double x = lwpoint_get_x(centroid);
    double y = lwpoint_get_y(centroid);
    double z = lwpoint_get_z(centroid);

    double a = rt->quat.W*rt->quat.W + rt->quat.X*rt->quat.X
    - rt->quat.Y*rt->quat.Y - rt->quat.Z*rt->quat.Z;
    double b = 2*rt->quat.X*rt->quat.Y - 2*rt->quat.W*rt->quat.Z;
    double c = 2*rt->quat.X*rt->quat.Z + 2*rt->quat.W*rt->quat.Y;
    double d = 2*rt->quat.X*rt->quat.Y + 2*rt->quat.W*rt->quat.Z;
    double e = rt->quat.W*rt->quat.W - rt->quat.X*rt->quat.X
    + rt->quat.Y*rt->quat.Y - rt->quat.Z*rt->quat.Z;
    double f = 2*rt->quat.Y*rt->quat.Z - 2*rt->quat.W*rt->quat.X;
    double g = 2*rt->quat.X*rt->quat.Z - 2*rt->quat.W*rt->quat.Y;
    double h = 2*rt->quat.Y*rt->quat.Z + 2*rt->quat.W*rt->quat.X;
    double i = rt->quat.W*rt->quat.W - rt->quat.X*rt->quat.X
    - rt->quat.Y*rt->quat.Y + rt->quat.Z*rt->quat.Z;

    /* Translate to have centroid at (0,0) */
    lwgeom_translate_3d(geom, -x, -y, -z);
    /* Apply tranform */
    lwgeom_rotate_3d(geom, a, b, c, d, e, f, g, h, i);
    /* Translate back */
    lwgeom_translate_3d(geom, x, y , z);
  }

  double dx = rt->translation.a;
  double dy = rt->translation.b;
  double dz = rt->translation.c;
  lwgeom_translate_3d(geom, dx, dy, dz);
  return;
}

Datum
rtransform_apply_datum(const Datum rt_datum, const Datum geom_datum, Oid basetypid)
{
  GSERIALIZED *gs = (GSERIALIZED *) DatumGetPointer(geom_datum);
  LWGEOM *geom = lwgeom_from_gserialized(gs);
  LWGEOM *result_geom = lwgeom_clone_deep(geom);
  LWPOINT *centroid;
  if (basetypid == type_oid(T_RTRANSFORM2D))
  {
    RTransform2D *rt = DatumGetRTransform2D(rt_datum);
    centroid = lwgeom_as_lwpoint(lwgeom_centroid(geom));
    rtransform_apply_2d(rt, result_geom, centroid);
  }
  else if (basetypid == type_oid(T_RTRANSFORM3D))
  {
    RTransform3D *rt = DatumGetRTransform3D(rt_datum);
    centroid = lwpsurface_centroid((LWPSURFACE *) result_geom);
    rtransform_apply_3d(rt, result_geom, centroid);
  }
  if (result_geom->bbox)
    lwgeom_refresh_bbox(result_geom);
  lwgeom_free(geom);
  lwpoint_free(centroid);
  GSERIALIZED *result_gs = geo_serialize(result_geom);
  lwgeom_free(result_geom);
  Datum result = PointerGetDatum(result_gs);
  return result;
}

Datum
rtransform_apply_point_datum(const Datum rt_datum, const Datum point_datum, const Datum centroid_datum, Oid valuetypid)
{
  GSERIALIZED *gs = (GSERIALIZED *) DatumGetPointer(point_datum);
  LWGEOM *point = lwgeom_from_gserialized(gs);
  GSERIALIZED *centroid_gs = (GSERIALIZED *) DatumGetPointer(centroid_datum);
  LWPOINT *centroid = NULL;
  if (centroid_gs)
    centroid = (LWPOINT *) lwgeom_from_gserialized(centroid_gs);
  LWGEOM *result_point = lwgeom_clone_deep(point);
  if (valuetypid == type_oid(T_RTRANSFORM2D))
  {
    RTransform2D *rt = DatumGetRTransform2D(rt_datum);
    rtransform_apply_2d(rt, result_point, centroid);
  }
  else if (valuetypid == type_oid(T_RTRANSFORM3D))
  {
    RTransform3D *rt = DatumGetRTransform3D(rt_datum);
    rtransform_apply_3d(rt, result_point, centroid);
  }
  if (result_point->bbox)
    lwgeom_refresh_bbox(result_point);
  lwgeom_free(point);
  if (centroid)
    lwpoint_free(centroid);
  GSERIALIZED *result_gs = geo_serialize(result_point);
  lwgeom_free(result_point);
  Datum result = PointerGetDatum(result_gs);
  return result;
}

/*****************************************************************************
 * Compute functions
 *****************************************************************************/

static RTransform2D *
rtransform_compute_2d(const LWPOLY *poly1, const LWPOLY *poly2)
{
  LWPOINT *centroid_1 = lwpoly_centroid(poly1);
  double cx = lwpoint_get_x(centroid_1);
  double cy = lwpoint_get_y(centroid_1);

  POINTARRAY *point_arr_1 = poly1->rings[0];
  POINTARRAY *point_arr_2 = poly2->rings[0];

  POINT2D p11 = getPoint2d(point_arr_1, 0);
  POINT2D p12 = getPoint2d(point_arr_1, 1);
  POINT2D p21 = getPoint2d(point_arr_2, 0);
  POINT2D p22 = getPoint2d(point_arr_2, 1);

  double x1 = p11.x - cx, y1 = p11.y - cy;
  double x2 = p12.x - cx, y2 = p12.y - cy;
  double x1_ = p21.x - cx, y1_ = p21.y - cy;
  double x2_ = p22.x - cx, y2_ = p22.y - cy;
  double a, b, c, d;

  /* Compute affine tranformation from poly1 to poly2 */
  a = ((x1_ - x2_)*(x1 - x2) + (y1_ - y2_)*(y1 - y2))/((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2));
  b = ((y1_ - y2_)*(x1 - x2) - (x1_ - x2_)*(y1 - y2))/((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2));
  c = x1_ - a*x1 + b*y1;
  d = y1_ - a*y1 - b*x1;

  double theta = atan2(b, a);

  return rtransform_make_2d(theta, (double2) {c, d});
}

static double
rtransform_compute_angle_3d(double3 e, double3 p1, double3 p2)
{
  double3 p1_e = vec3_normalize(vec3_diff(p1, vec3_mult(e, vec3_dot(p1, e))));
  double3 p2_e = vec3_normalize(vec3_diff(p2, vec3_mult(e, vec3_dot(p2, e))));
  double dot = fmin(fmax(vec3_dot(p1_e, p2_e), -1.0), 1.0); // clip to [-1, 1] for acos
  double theta = acos(dot);
  if (vec3_dot(e, vec3_cross(p1_e, p2_e)) < 0.0)
    theta = -theta;
  return theta;
}

static RTransform3D *
rtransform_compute_3d(const LWPSURFACE *psurface1, const LWPSURFACE *psurface2)
{
  LWPOINT *centroid_1 = lwpsurface_centroid(psurface1);
  LWPOINT *centroid_2 = lwpsurface_centroid(psurface2);
  double cx1 = lwpoint_get_x(centroid_1); double cx2 = lwpoint_get_x(centroid_2);
  double cy1 = lwpoint_get_y(centroid_1); double cy2 = lwpoint_get_y(centroid_2);
  double cz1 = lwpoint_get_z(centroid_1); double cz2 = lwpoint_get_z(centroid_2);

  double dx = cx2 - cx1;
  double dy = cy2 - cy1;
  double dz = cz2 - cz1;

  POINTARRAY *point_arr_1 = psurface1->geoms[0]->rings[0];
  POINTARRAY *point_arr_2 = psurface2->geoms[0]->rings[0];

  POINT3DZ p11 = getPoint3dz(point_arr_1, 0);
  POINT3DZ p12 = getPoint3dz(point_arr_1, 1);
  POINT3DZ p21 = getPoint3dz(point_arr_2, 0);
  POINT3DZ p22 = getPoint3dz(point_arr_2, 1);
  if (fabs(p11.x) < EPSILON && fabs(p11.y) < EPSILON && fabs(p11.z) < EPSILON)
  {
    p11 = getPoint3dz(point_arr_1, 2);
    p21 = getPoint3dz(point_arr_2, 2);
  }
  else if (fabs(p12.x) < EPSILON && fabs(p12.y) < EPSILON && fabs(p12.z) < EPSILON)
  {
    p12 = getPoint3dz(point_arr_1, 2);
    p22 = getPoint3dz(point_arr_2, 2);
  }

  double3 P = (double3) {p11.x - cx1, p11.y - cy1, p11.z - cz1};
  double3 R = (double3) {p12.x - cx1, p12.y - cy1, p12.z - cz1};
  double3 P_ = (double3) {p21.x - cx2, p21.y - cy2, p21.z - cz2};
  double3 R_ = (double3) {p22.x - cx2, p22.y - cy2, p22.z - cz2};

  double3 PP_ = vec3_diff(P_, P);
  double3 RR_ = vec3_diff(R_, R);
  double3 PR = vec3_diff(R, P);

  double Pnorm = vec3_norm(PP_);
  double Rnorm = vec3_norm(RR_);

  double3 e;
  double theta;
  if (Pnorm < EPSILON && Rnorm < EPSILON) // No rotation
    return rtransform_make_3d(
      (Quaternion) {1, 0, 0, 0},
      (double3) {dx, dy, dz}
    );
  else if (Pnorm < EPSILON) // Rotation around P
  {
    e = vec3_normalize(P);
    theta = rtransform_compute_angle_3d(e, R, R_);
  }
  else if (Rnorm < EPSILON) // Rotation around R
  {
    e = vec3_normalize(R);
    theta = rtransform_compute_angle_3d(e, P, P_);
  }
  else
  {
    double dot = vec3_dot(PP_, RR_);
    if (fabs(dot - Pnorm*Rnorm) < EPSILON) // Same direction
      e = vec3_normalize(vec3_cross(PP_, vec3_cross(PR, PP_)));
    else if (fabs(dot + Pnorm*Rnorm) < EPSILON) // Opposite direction
      e = vec3_normalize(vec3_cross(PR, PP_));
    else // General case
      e = vec3_normalize(vec3_cross(PP_, RR_));
    theta = rtransform_compute_angle_3d(e, P, P_);
  }
  Quaternion quat = quaternion_from_axis_angle(e, theta);
  return rtransform_make_3d(quat, (double3) {dx, dy, dz});
}

Datum
rtransform_compute_datum(const Datum geom1_datum, const Datum geom2_datum, Oid basetypid)
{
  GSERIALIZED *gs1 = (GSERIALIZED *) DatumGetPointer(geom1_datum);
  GSERIALIZED *gs2 = (GSERIALIZED *) DatumGetPointer(geom2_datum);
  Datum result;
  if (basetypid == type_oid(T_RTRANSFORM2D))
  {
    LWPOLY *poly1 = (LWPOLY *) lwgeom_from_gserialized(gs1);
    LWPOLY *poly2 = (LWPOLY *) lwgeom_from_gserialized(gs2);
    RTransform2D *rt = rtransform_compute_2d(poly1, poly2);
    result = RTransform2DGetDatum(rt);
    lwpoly_free(poly1);
    lwpoly_free(poly2);
  }
  else if (basetypid == type_oid(T_RTRANSFORM3D))
  {
    LWPSURFACE *psurface1 = (LWPSURFACE *) lwgeom_from_gserialized(gs1);
    LWPSURFACE *psurface2 = (LWPSURFACE *) lwgeom_from_gserialized(gs2);
    RTransform3D *rt = rtransform_compute_3d(psurface1, psurface2);
    result = RTransform3DGetDatum(rt);
    lwpsurface_free(psurface1);
    lwpsurface_free(psurface2);
  }
  Datum geom2_datum_computed = rtransform_apply_datum(result, geom1_datum, basetypid);
  ensure_rigid_body(geom2_datum, geom2_datum_computed);
  pfree((void *) geom2_datum_computed);
  return result;
}

/*****************************************************************************
 * Combine functions
 *****************************************************************************/

static RTransform2D *
rtransform_combine_2d(const RTransform2D *rt1, const RTransform2D *rt2)
{
  double theta = rt1->theta + rt2->theta;
  if (theta > M_PI)
    theta = theta - 2*M_PI;
  if (theta <= -M_PI)
    theta = theta + 2*M_PI;
  double dx = rt1->translation.a + rt2->translation.a;
  double dy = rt1->translation.b + rt2->translation.b;
  return rtransform_make_2d(theta, (double2) {dx, dy});
}

static RTransform3D *
rtransform_combine_3d(const RTransform3D *rt1, const RTransform3D *rt2)
{
  Quaternion quat = quaternion_multiply(rt2->quat, rt1->quat); // Apply rt1 before rt2
  quat = quaternion_normalize(quat);
  double dx = rt1->translation.a + rt2->translation.a;
  double dy = rt1->translation.b + rt2->translation.b;
  double dz = rt1->translation.c + rt2->translation.c;
  return rtransform_make_3d(quat, (double3) {dx, dy, dz});
}

Datum
rtransform_combine_datum(const Datum rt1_datum, const Datum rt2_datum, Oid basetypid)
{
  Datum result;
  if (basetypid == type_oid(T_RTRANSFORM2D))
  {
    RTransform2D *rt1 = DatumGetRTransform2D(rt1_datum);
    RTransform2D *rt2 = DatumGetRTransform2D(rt2_datum);
    RTransform2D *rt = rtransform_combine_2d(rt1, rt2);
    result = RTransform2DGetDatum(rt);
  }
  else if (basetypid == type_oid(T_RTRANSFORM3D))
  {
    RTransform3D *rt1 = DatumGetRTransform3D(rt1_datum);
    RTransform3D *rt2 = DatumGetRTransform3D(rt2_datum);
    RTransform3D *rt = rtransform_combine_3d(rt1, rt2);
    result = RTransform3DGetDatum(rt);
  }
  return result;
}

/*****************************************************************************
 * Interpolate functions
 *****************************************************************************/

static RTransform2D *
rtransform_interpolate_2d(const RTransform2D *rt1, const RTransform2D *rt2,
  double ratio)
{
  /* If fabs(theta_delta) == M_PI: Always turn counter-clockwise */
  double theta;
  double theta_delta = rt2->theta - rt1->theta;
  if (fabs(theta_delta) < EPSILON)
      theta = rt1->theta;
  else if (theta_delta > 0 && fabs(theta_delta) <= M_PI)
      theta = rt1->theta + theta_delta*ratio;
  else if (theta_delta > 0 && fabs(theta_delta) > M_PI)
      theta = rt2->theta + (2*M_PI - theta_delta)*(1 - ratio);
  else if (theta_delta < 0 && fabs(theta_delta) < M_PI)
      theta = rt1->theta + theta_delta*ratio;
  else /* (theta_delta < 0 && fabs(theta_delta) >= M_PI) */
      theta = rt1->theta + (2*M_PI + theta_delta)*ratio;

  if (theta > M_PI)
      theta = theta - 2*M_PI;

  double dx = rt1->translation.a * (1 - ratio) + rt2->translation.a * ratio;
  double dy = rt1->translation.b * (1 - ratio) + rt2->translation.b * ratio;
  return rtransform_make_2d(theta, (double2) {dx, dy});
}

static RTransform3D *
rtransform_interpolate_3d(const RTransform3D *rt1, const RTransform3D *rt2,
  double ratio)
{
  Quaternion quat = quaternion_slerp(rt1->quat, rt2->quat, ratio);
  double dx = rt1->translation.a * (1 - ratio) + rt2->translation.a * ratio;
  double dy = rt1->translation.b * (1 - ratio) + rt2->translation.b * ratio;
  double dz = rt1->translation.c * (1 - ratio) + rt2->translation.c * ratio;
  return rtransform_make_3d(quat, (double3) {dx, dy, dz});
}

Datum
rtransform_interpolate_datum(const Datum rt1_datum, const Datum rt2_datum,
  double ratio, Oid basetypid)
{
  assert(0 < ratio && ratio < 1);
  Datum result;
  if (basetypid == type_oid(T_RTRANSFORM2D))
  {
    RTransform2D *rt1 = DatumGetRTransform2D(rt1_datum);
    RTransform2D *rt2 = DatumGetRTransform2D(rt2_datum);
    RTransform2D *rt = rtransform_interpolate_2d(rt1, rt2, ratio);
    result = RTransform2DGetDatum(rt);
  }
  else if (basetypid == type_oid(T_RTRANSFORM3D))
  {
    RTransform3D *rt1 = DatumGetRTransform3D(rt1_datum);
    RTransform3D *rt2 = DatumGetRTransform3D(rt2_datum);
    RTransform3D *rt = rtransform_interpolate_3d(rt1, rt2, ratio);
    result = RTransform3DGetDatum(rt);
  }
  return result;
}

/*****************************************************************************
 * Invert functions
 *****************************************************************************/

static RTransform2D *
rtransform_invert_2d(const RTransform2D *rt)
{
  double theta = - rt->theta;
  if (theta == -M_PI)
      theta = M_PI;
  double dx = - rt->translation.a;
  double dy = - rt->translation.b;
  return rtransform_make_2d(theta, (double2) {dx, dy});
}

static RTransform3D *
rtransform_invert_3d(const RTransform3D *rt)
{
  Quaternion quat = quaternion_invert(rt->quat);
  double dx = - rt->translation.a;
  double dy = - rt->translation.b;
  double dz = - rt->translation.c;
  return rtransform_make_3d(quat, (double3) {dx, dy, dz});
}

Datum
rtransform_invert_datum(const Datum rt_datum, Oid valuetypid)
{
  Datum result;
  if (valuetypid == type_oid(T_RTRANSFORM2D))
  {
    RTransform2D *rt = DatumGetRTransform2D(rt_datum);
    RTransform2D *rt_inverse = rtransform_invert_2d(rt);
    result = RTransform2DGetDatum(rt_inverse);
  }
  else if (valuetypid == type_oid(T_RTRANSFORM3D))
  {
    RTransform3D *rt = DatumGetRTransform3D(rt_datum);
    RTransform3D *rt_inverse = rtransform_invert_3d(rt);
    result = RTransform3DGetDatum(rt_inverse);
  }
  return result;
}

/*****************************************************************************/
