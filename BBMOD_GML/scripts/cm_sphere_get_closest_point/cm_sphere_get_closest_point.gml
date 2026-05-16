function cm_sphere_get_closest_point(sphere, x, y, z)
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.getClosestPoint
	*/
	static ret = array_create(3);
	var dx = x - CM_SPHERE_X;
	var dy = y - CM_SPHERE_Y;
	var dz = z - CM_SPHERE_Z;
	var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
	if (d > 0)
	{
		var _d = CM_SPHERE_R / d;
		ret[@ 0] = CM_SPHERE_X + dx * d;
		ret[@ 1] = CM_SPHERE_Y + dy * d;
		ret[@ 2] = CM_SPHERE_Z + dz * d;
		return ret;
	}
	ret[@ 0] = CM_SPHERE_X + CM_SPHERE_R;
	ret[@ 1] = CM_SPHERE_Y;
	ret[@ 2] = CM_SPHERE_Z;
	return ret;
}