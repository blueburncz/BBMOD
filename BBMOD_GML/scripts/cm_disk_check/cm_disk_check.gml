/*
	This function displaces the collider out of the give shape.
*/

function cm_disk_check(disk, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_DISK_GROUP) == 0){return false;}
	
	var ref = __cmi_disk_get_capsule_ref(disk, collider);
	var p = __cmi_get_diskcoord(CM_DISK_X, CM_DISK_Y, CM_DISK_Z, CM_DISK_NX, CM_DISK_NY, CM_DISK_NZ, CM_DISK_BIGRADIUS, ref[0], ref[1], ref[2]);
	if (point_distance_3d(ref[0], ref[1], ref[2], p[0], p[1], p[2]) >= CM_DISK_SMALLRADIUS + collider[CM.R]) return false;
	
	return true;
}