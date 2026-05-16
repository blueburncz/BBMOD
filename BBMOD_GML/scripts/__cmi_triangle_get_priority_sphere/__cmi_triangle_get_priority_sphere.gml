function __cmi_triangle_get_priority_sphere(triangle, collider, mask = collider[CM.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns -1 if the shape is too far away
		Returns the square of the distance between the shape and the given point
	*/
	if (mask != 0 && (mask & CM_TRIANGLE_GROUP) == 0){return -1;}
	
	//Read collider array
	var X = collider[CM.X];
	var Y = collider[CM.Y];
	var Z = collider[CM.Z];
	var maxR = collider[CM.R] * CM_FIRST_PASS_RADIUS;
	
	//Check triangle plane for a potential early exit
	var nx  = CM_TRIANGLE_NX;
	var ny  = CM_TRIANGLE_NY;
	var nz  = CM_TRIANGLE_NZ;
	var v1x = CM_TRIANGLE_X1;
	var v1y = CM_TRIANGLE_Y1;
	var v1z = CM_TRIANGLE_Z1;
	var tx = X - v1x;
	var ty = Y - v1y;
	var tz = Z - v1z;
	
	//Early exit if the triangle is too far away
	var D = dot_product_3d(tx, ty, tz, nx, ny, nz);
	if (abs(D) > maxR){return -1;}
	
	//Check first edge
	var v2x = CM_TRIANGLE_X2;
	var v2y = CM_TRIANGLE_Y2;
	var v2z = CM_TRIANGLE_Z2;
	var ex = v2x - v1x, ey = v2y - v1y, ez = v2z - v1z;
	if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
	{	//Check second edge
		var v3x = CM_TRIANGLE_X3;
		var v3y = CM_TRIANGLE_Y3;
		var v3z = CM_TRIANGLE_Z3;
		tx = X - v2x; ty = Y - v2y; tz = Z - v2z;
		ex = v3x - v2x; ey = v3y - v2y; ez = v3z - v2z;
		if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
		{	//Check third edge
			tx = X - v3x; ty = Y - v3y; tz = Z - v3z;
			ex = v1x - v3x; ey = v1y - v3y; ez = v1z - v3z;
			if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
			{
				return D*D;
			}
		}
	}
	var d = clamp(dot_product_3d(ex, ey, ez, tx, ty, tz) / dot_product_3d(ex, ey, ez, ex, ey, ez), 0, 1);
	var a = ex * d - tx;
	var b = ey * d - ty;
	var c = ez * d - tz;
	return dot_product_3d(a, b, c, a, b, c);
}