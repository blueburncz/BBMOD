function __cmi_get_diskcoord(cx, cy, cz, nx, ny, nz, R, x, y, z)
{
	gml_pragma("forceinline");
	static ret = array_create(3);
	var dx = x - cx;
	var dy = y - cy;
	var dz = z - cz;
	var dp = dot_product_3d(dx, dy, dz, nx, ny, nz);
	dx -= nx * dp;
	dy -= ny * dp;
	dz -= nz * dp;
	var l = point_distance_3d(0, 0, 0, dx, dy, dz);
	if (l <= R)
	{
		ret[0] = cx + dx;
		ret[1] = cy + dy;
		ret[2] = cz + dz;
		return ret;
	}
	var _d = R / l;
	ret[0] = cx + dx * _d;
	ret[1] = cy + dy * _d;
	ret[2] = cz + dz * _d;
	return ret;
}