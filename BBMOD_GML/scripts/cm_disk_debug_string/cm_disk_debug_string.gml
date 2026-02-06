function cm_disk_debug_string(disk)
{
	return $"[Disk: Group: {CM_DISK_GROUP}, Pos: [{CM_DISK_X}, {CM_DISK_Y}, {CM_DISK_Z}], N: [{CM_DISK_NX}, {CM_DISK_NY}, {CM_DISK_NZ}], R: {CM_DISK_BIGRADIUS}, r: {CM_DISK_SMALLRADIUS}]";
}