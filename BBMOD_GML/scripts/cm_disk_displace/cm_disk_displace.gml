/*
	This function displaces the collider out of the give shape.
*/

function cm_disk_displace(disk, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_DISK_GROUP) == 0){return false;}
	
	var ref = __cmi_disk_get_capsule_ref(disk, collider);
	gml_pragma("forceinline");
	var p = __cmi_get_diskcoord(CM_DISK_X, CM_DISK_Y, CM_DISK_Z, CM_DISK_NX, CM_DISK_NY, CM_DISK_NZ, CM_DISK_BIGRADIUS, ref[0], ref[1], ref[2]);
	var dx = ref[0] - p[0];
	var dy = ref[1] - p[1];
	var dz = ref[2] - p[2];
	var _r = CM_DISK_SMALLRADIUS + collider[CM.R];
	var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
	if (d == 0 || d >= _r) return false;
	d = (_r - d) / d;
	return __cmi_collider_displace(collider, dx * d, dy * d, dz * d);
}