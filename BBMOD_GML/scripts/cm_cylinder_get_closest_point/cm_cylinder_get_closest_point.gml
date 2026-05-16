
function cm_cylinder_get_closest_point(cylinder, x, y, z)
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.getClosestPoint
	*/
	static ret = array_create(3);
	var dx = CM_CYLINDER_X1 - x;
	var dy = CM_CYLINDER_Y1 - y;
	var dz = CM_CYLINDER_Z1 - z;
	var cx = CM_CYLINDER_DX;
	var cy = CM_CYLINDER_DY;
	var cz = CM_CYLINDER_DZ;
	var c = dot_product_3d(cx, cy, cz, cx, cy, cz);
	var d = dot_product_3d(dx, dy, dz, cx, cy, cz) / c;
	d = clamp(d, 0, 1);
	var tx = lerp(CM_CYLINDER_X1, CM_CYLINDER_X2, d);
	var ty = lerp(CM_CYLINDER_Y1, CM_CYLINDER_Y2, d);
	var tz = lerp(CM_CYLINDER_Z1, CM_CYLINDER_Z2, d);
	var dx = x - tx;
	var dy = y - ty;
	var dz = z - tz;
	var dp = dot_product_3d(dx, dy, dz, cx, cy, cz) / c;
	dx -= cx * dp;
	dy -= cy * dp;
	dz -= cz * dp;
	var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
	if (d > 0)
	{
		var r = CM_CYLINDER_R / d;
		if (r < 1)
		{
			dx *= r;
			dy *= r;
			dz *= r;
		}
		ret[@ 0] = tx + dx;
		ret[@ 1] = ty + dy;
		ret[@ 2] = tz + dz;
		return ret;
	}
	ret[@ 0] = tx + CM_CYLINDER_R;
	ret[@ 1] = ty;
	ret[@ 2] = tz;
	return ret;
}