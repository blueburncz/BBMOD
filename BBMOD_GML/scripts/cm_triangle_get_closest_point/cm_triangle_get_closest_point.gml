function cm_triangle_get_closest_point(triangle, x, y, z)
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.getClosestPoint
	*/
	static ret = array_create(3);
		
	//Check first edge
	var nx = CM_TRIANGLE_NX;
	var ny = CM_TRIANGLE_NY;
	var nz = CM_TRIANGLE_NZ;
	var v1x = CM_TRIANGLE_X1;
	var v1y = CM_TRIANGLE_Y1;
	var v1z = CM_TRIANGLE_Z1;
	var v2x = CM_TRIANGLE_X2;
	var v2y = CM_TRIANGLE_Y2;
	var v2z = CM_TRIANGLE_Z2;
	var t0 = x - v1x;
	var t1 = y - v1y;
	var t2 = z - v1z;
	var u0 = v2x - v1x;
	var u1 = v2y - v1y;
	var u2 = v2z - v1z;
	if (dot_product_3d(t2 * u1 - t1 * u2, t0 * u2 - t2 * u0, t1 * u0 - t0 * u1, nx, ny, nz) < 0)
	{
		var a = clamp(dot_product_3d(u0, u1, u2, t0, t1, t2) / dot_product_3d(u0, u1, u2, u0, u1, u2), 0, 1);
		ret[0] = v1x + u0 * a;
		ret[1] = v1y + u1 * a;
		ret[2] = v1z + u2 * a;
		return ret;
	}
	else
	{
		//Check second edge
		var v3x = CM_TRIANGLE_X3;
		var v3y = CM_TRIANGLE_Y3;
		var v3z = CM_TRIANGLE_Z3;
		var t0 = x - v2x;
		var t1 = y - v2y;
		var t2 = z - v2z;
		var u0 = v3x - v2x;
		var u1 = v3y - v2y;
		var u2 = v3z - v2z;
		if (dot_product_3d(t2 * u1 - t1 * u2, t0 * u2 - t2 * u0, t1 * u0 - t0 * u1, nx, ny, nz) < 0)
		{
			var a = clamp(dot_product_3d(u0, u1, u2, t0, t1, t2) / dot_product_3d(u0, u1, u2, u0, u1, u2), 0, 1);
			ret[0] = v2x + u0 * a;
			ret[1] = v2y + u1 * a;
			ret[2] = v2z + u2 * a;
			return ret;
		}
		else
		{
			//Check third edge
			var t0 = x - v3x;
			var t1 = y - v3y;
			var t2 = z - v3z;
			var u0 = v1x - v3x;
			var u1 = v1y - v3y;
			var u2 = v1z - v3z;
			if (dot_product_3d(t2 * u1 - t1 * u2, t0 * u2 - t2 * u0, t1 * u0 - t0 * u1, nx, ny, nz) < 0)
			{
				var a = clamp(dot_product_3d(u0, u1, u2, t0, t1, t2) / dot_product_3d(u0, u1, u2, u0, u1, u2), 0, 1);
				ret[0] = v3x + u0 * a;
				ret[1] = v3y + u1 * a;
				ret[2] = v3z + u2 * a;
				return ret;
			}
		}
	}
	var D =  dot_product_3d(t0, t1, t2, nx, ny, nz);
	ret[0] = x - nx * D;
	ret[1] = y - ny * D;
	ret[2] = z - nz * D;
	return ret;
}