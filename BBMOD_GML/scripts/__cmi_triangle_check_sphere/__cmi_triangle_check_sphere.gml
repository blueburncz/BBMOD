function __cmi_triangle_check_sphere(triangle, collider, mask = collider[CM.MASK])
{
	/*
		This is a slightly more optimized version of the displace function, which removes some of the calculations needed for
		colliding with a capsule when the capsule's height is zero. It also offsets the reading of the triangle array to
		later in the function when it's needed instead of up front, potentially skipping several array reads when colliding
		with a mesh.
	*/
	//Read collider array
	var X = collider[CM.X];
	var Y = collider[CM.Y];
	var Z = collider[CM.Z];
	var radius = collider[CM.R];
	
	//Read triangle array
	var v1x = CM_TRIANGLE_X1;
	var v1y = CM_TRIANGLE_Y1;
	var v1z = CM_TRIANGLE_Z1;
	var nx  = CM_TRIANGLE_NX;
	var ny  = CM_TRIANGLE_NY;
	var nz  = CM_TRIANGLE_NZ;
	
	//Check triangle plane for a potential early exit
	var tx = X - v1x, ty = Y - v1y, tz = Z - v1z;
	var D = dot_product_3d(tx, ty, tz, nx, ny, nz);
	if (abs(D) > radius) return false;
	
	var v2x = CM_TRIANGLE_X2;
	var v2y = CM_TRIANGLE_Y2;
	var v2z = CM_TRIANGLE_Z2;
	var ex = v2x - v1x, ey = v2y - v1y, ez = v2z - v1z;
	
	//Check first edge
	if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
	{	
		//Check second edge
		var v3x = CM_TRIANGLE_X3;
		var v3y = CM_TRIANGLE_Y3;
		var v3z = CM_TRIANGLE_Z3;
		tx = X - v2x; ty = Y - v2y; tz = Z - v2z;
		ex = v3x - v2x; ey = v3y - v2y; ez = v3z - v2z;
		if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
		{	
			//Check third edge
			tx = X - v3x; ty = Y - v3y; tz = Z - v3z;
			ex = v1x - v3x; ey = v1y - v3y; ez = v1z - v3z;
			if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
			{
				return true;
			}
		}
	}
	var a = clamp(dot_product_3d(ex, ey, ez, tx, ty, tz) / dot_product_3d(ex, ey, ez, ex, ey, ez), 0, 1);
	if point_distance_3d(tx, ty, tz, ex * a, ey * a, ez * a) <= radius
	{
		return true;
	}
	return false;
}