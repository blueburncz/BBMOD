function __cmi_triangle_get_priority(triangle, collider, mask = collider[CM.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns -1 if the shape is too far away
		Returns the square of the distance between the shape and the given point
	*/
	if (mask != 0 && (mask & CM_TRIANGLE_GROUP) == 0){return -1;}
	
	var height = collider[CM.H];
	if (height == 0)
	{
		return __cmi_triangle_get_priority_sphere(triangle, collider);
	}
	
	//Read collider array
	var radius = collider[CM.R] * CM_FIRST_PASS_RADIUS;
	
	//Do an AABB-check
	var t;
	var X = collider[CM.X];
	var xup = collider[CM.XUP];
	var v1x = CM_TRIANGLE_X1;
	var v2x = CM_TRIANGLE_X2;
	var v3x = CM_TRIANGLE_X3;
	t = X + ((xup < 0) ? xup * height : 0) - radius;
	if (t > v1x && t > v2x && t > v3x){return -1;}
	t = X + ((xup > 0) ? xup * height : 0) + radius;
	if (t < v1x && t < v2x && t < v3x){return -1;}
	
	var Y = collider[CM.Y];
	var yup = collider[CM.YUP];
	var v1y = CM_TRIANGLE_Y1;
	var v2y = CM_TRIANGLE_Y2;
	var v3y = CM_TRIANGLE_Y3;
	t = Y + ((yup < 0) ? yup * height : 0) - radius;
	if (t > v1y && t > v2y && t > v3y){return -1;}
	t = Y + ((yup > 0) ? yup * height : 0) + radius;
	if (t < v1y && t < v2y && t < v3y){return -1;}
	
	var Z = collider[CM.Z];
	var zup = collider[CM.ZUP];
	var v1z = CM_TRIANGLE_Z1;
	var v2z = CM_TRIANGLE_Z2;
	var v3z = CM_TRIANGLE_Z3
	t = Z + ((zup < 0) ? zup * height : 0) - radius;
	if (t > v1z && t > v2z && t > v3z){return -1;}
	t = Z + ((zup > 0) ? zup * height : 0) + radius;
	if (t < v1z && t < v2z && t < v3z){return -1;}
	
	var nx  = CM_TRIANGLE_NX;
	var ny  = CM_TRIANGLE_NY;
	var nz  = CM_TRIANGLE_NZ;
	CM_TRIANGLE_GET_CAPSULE_REF;
	var tx = refX - v1x;
	var ty = refY - v1y;
	var tz = refZ - v1z;
	
	//Early exit if the triangle is too far away
	var D = dot_product_3d(tx, ty, tz, nx, ny, nz);
	if (abs(D) > radius){return -1;}
	
	//Check first edge
	var e = e0, ex = e00, ey = e01, ez = e02;
	if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
	{	//Check second edge
		tx = refX - v2x; ty = refY - v2y; tz = refZ - v2z;
		e = e1; ex = e10; ey = e11; ez = e12;
		if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
		{	//Check third edge
			tx = refX - v3x; ty = refY - v3y; tz = refZ - v3z;
			e = e2; ex = e20; ey = e21; ez = e22;
			if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
			{
				return D * D;
			}
		}
	}
	var d = clamp(dot_product_3d(ex, ey, ez, tx, ty, tz) / e, 0, 1);
	var a = ex * d - tx;
	var b = ey * d - ty;
	var c = ez * d - tz;
	return dot_product_3d(a, b, c, a, b, c);
}