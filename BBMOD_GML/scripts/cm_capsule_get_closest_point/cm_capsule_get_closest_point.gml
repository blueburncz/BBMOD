function cm_capsule_get_closest_point(capsule, x, y, z)
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.getClosestPoint
	*/
	static ret = array_create(3);
	var cx = CM_CAPSULE_DX;
	var cy = CM_CAPSULE_DY;
	var cz = CM_CAPSULE_DZ;
	var d = dot_product_3d(x - CM_CAPSULE_X1, y - CM_CAPSULE_Y1, z - CM_CAPSULE_Z1, cx, cy, cz) / dot_product_3d(cx, cy, cz, cx, cy, cz);
	d = clamp(d, 0, 1);
	var tx = lerp(CM_CAPSULE_X1, CM_CAPSULE_X2, d);
	var ty = lerp(CM_CAPSULE_Y1, CM_CAPSULE_Y2, d);
	var tz = lerp(CM_CAPSULE_Z1, CM_CAPSULE_Z2, d);
	var dx = x - tx;
	var dy = y - ty;
	var dz = z - tz;
	var d = point_distance_3d(0, 0, 0, dx, dy, dz);
	if (d > 0)
	{
		var r = CM_CAPSULE_R / d;
		ret[@ 0] = tx + dx * r;
		ret[@ 1] = ty + dy * r;
		ret[@ 2] = tz + dz * r;
		return ret;
	}
	ret[@ 0] = tx + CM_CAPSULE_R;
	ret[@ 1] = ty;
	ret[@ 2] = tz;
	return ret;
}