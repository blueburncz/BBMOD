function cm_sphere_get_aabb(sphere)
{
	/*
			Returns the AABB of the shape as an array with six values
	*/
	var R = CM_SPHERE_R;
	return [CM_SPHERE_X - R,
			CM_SPHERE_Y - R,
			CM_SPHERE_Z - R,
			CM_SPHERE_X + R,
			CM_SPHERE_Y + R,
			CM_SPHERE_Z + R];
}