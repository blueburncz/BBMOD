function cm_torus_get_closest_point(torus, x, y, z)
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.getClosestPoint
	*/
	static ret = array_create(3);
	var cx = CM_TORUS_X;
	var cy = CM_TORUS_Y;
	var cz = CM_TORUS_Z;
	var nx = CM_TORUS_NX;
	var ny = CM_TORUS_NY;
	var nz = CM_TORUS_NZ;
	var r  = CM_TORUS_SMALLRADIUS;
	var R  = CM_TORUS_BIGRADIUS;
	
	var rx = x - cx;
	var ry = y - cy;
	var rz = z - cz;
	var dp = dot_product_3d(rx, ry, rz, nx, ny, nz);
	rx -= nx * dp;
	ry -= ny * dp;
	rz -= nz * dp;
	var l = point_distance_3d(0, 0, 0, rx, ry, rz);
	if (l == 0){return [x, y, z];}
	var _d = R / l;
	var px = cx + rx * _d;
	var py = cy + ry * _d;
	var pz = cz + rz * _d;
	
	var dx = x - px;
	var dy = y - py;
	var dz = z - pz;
	var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
	if (d > 0)
	{
		var _r = r / d;
		ret[@ 0] = px + dx * _r;
		ret[@ 1] = py + dy * _r;
		ret[@ 2] = pz + dz * _r;
		return ret;
	}
	ret[@ 0] = x;
	ret[@ 1] = y;
	ret[@ 2] = z;
	return ret;
}