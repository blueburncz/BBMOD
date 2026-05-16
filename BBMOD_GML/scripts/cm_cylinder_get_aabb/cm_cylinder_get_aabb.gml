function cm_cylinder_get_aabb(cylinder)
{
	/*
			Returns the AABB of the shape as an array with six values
	*/
	var R = CM_CYLINDER_R;
	return [min(CM_CYLINDER_X1, CM_CYLINDER_X2) - R,
			min(CM_CYLINDER_Y1, CM_CYLINDER_Y2) - R,
			min(CM_CYLINDER_Z1, CM_CYLINDER_Z2) - R,
			max(CM_CYLINDER_X1, CM_CYLINDER_X2) + R,
			max(CM_CYLINDER_Y1, CM_CYLINDER_Y2) + R,
			max(CM_CYLINDER_Z1, CM_CYLINDER_Z2) + R];
}