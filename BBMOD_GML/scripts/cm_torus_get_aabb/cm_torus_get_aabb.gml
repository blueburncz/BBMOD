function cm_torus_get_aabb(torus)
{
	/*
			Returns the AABB of the shape as an array with six values
	*/
	var cx = CM_TORUS_X;
	var cy = CM_TORUS_Y;
	var cz = CM_TORUS_Z;
	var nx = CM_TORUS_NX;
	var ny = CM_TORUS_NY;
	var nz = CM_TORUS_NZ;
	var r  = CM_TORUS_SMALLRADIUS;
	var R  = CM_TORUS_BIGRADIUS;
	var sx = r + R * point_distance(0, 0, ny, nz);
	var sy = r + R * point_distance(0, 0, nx, nz);
	var sz = r + R * point_distance(0, 0, nx, ny);
	return [cx - sx,
			cy - sy,
			cz - sz,
			cx + sx,
			cy + sy,
			cz + sz];
}