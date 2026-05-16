function __cmi_disk_get_priority(disk, collider, mask = collider[CM.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns -1 if the shape is too far away
		Returns the square of the distance between the shape and the given point
	*/
	if (mask != 0 && (mask & CM_DISK_GROUP) == 0){return -1;}
	
	//Read collider array
	var ref = __cmi_disk_get_capsule_ref(disk, collider);
	var maxR = collider[CM.R] * CM_FIRST_PASS_RADIUS;
	
	var p = __cmi_get_diskcoord(CM_DISK_X, CM_DISK_Y, CM_DISK_Z, CM_DISK_NX, CM_DISK_NY, CM_DISK_NZ, CM_DISK_BIGRADIUS, ref[0], ref[1], ref[2]);
	var dx = ref[0] - p[0];
	var dy = ref[1] - p[1];
	var dz = ref[2] - p[2];
	var d = max(point_distance_3d(dx, dy, dz, 0, 0, 0) - CM_DISK_SMALLRADIUS, 0);
	if (d > maxR){return -1;}
	return d * d;
}