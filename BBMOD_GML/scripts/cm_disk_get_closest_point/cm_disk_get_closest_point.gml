function cm_disk_get_closest_point(disk, x, y, z)
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.getClosestPoint
	*/
	gml_pragma("forceinline");
	static ret = array_create(3);
	var cx = CM_DISK_X;
	var cy = CM_DISK_Y;
	var cz = CM_DISK_Z;
	var nx = CM_DISK_NX;
	var ny = CM_DISK_NY;
	var nz = CM_DISK_NZ;
	var r  = CM_DISK_SMALLRADIUS;
	var R  = CM_DISK_BIGRADIUS;
	var p = __cmi_get_diskcoord(cx, cy, cz, nx, ny, nz, R, x, y, z);
	var dx = x - p[0];
	var dy = y - p[1];
	var dz = z - p[2];
	var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
	if (d > 0)
	{
		var _r = r / d;
		ret[@ 0] = p[0] + dx * _r;
		ret[@ 1] = p[1] + dy * _r;
		ret[@ 2] = p[2] + dz * _r;
		return ret;
	}
	ret[@ 0] = x;
	ret[@ 1] = y;
	ret[@ 2] = z;
	return ret;
}