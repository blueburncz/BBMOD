function cm_capsule_get_aabb(capsule)
{
	/*
			Returns the AABB of the shape as an array with six values
	*/
	var R = CM_CAPSULE_R;
	return [min(CM_CAPSULE_X1, CM_CAPSULE_X2) - R,
			min(CM_CAPSULE_Y1, CM_CAPSULE_Y2) - R,
			min(CM_CAPSULE_Z1, CM_CAPSULE_Z2) - R,
			max(CM_CAPSULE_X1, CM_CAPSULE_X2) + R,
			max(CM_CAPSULE_Y1, CM_CAPSULE_Y2) + R,
			max(CM_CAPSULE_Z1, CM_CAPSULE_Z2) + R];
}