function cm_disk_get_aabb(disk)
{
	/*
			Returns the AABB of the shape as an array with six values
	*/
	var cx = CM_DISK_X;
	var cy = CM_DISK_Y;
	var cz = CM_DISK_Z;
	var nx = CM_DISK_NX;
	var ny = CM_DISK_NY;
	var nz = CM_DISK_NZ;
	var r  = CM_DISK_SMALLRADIUS;
	var R  = CM_DISK_BIGRADIUS;
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