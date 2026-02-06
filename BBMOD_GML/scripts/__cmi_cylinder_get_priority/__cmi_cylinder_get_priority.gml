function __cmi_cylinder_get_priority(cylinder, collider, mask = collider[CM.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns -1 if the shape is too far away
		Returns the square of the distance between the shape and the given point
	*/
	if (mask != 0 && (mask & CM_CYLINDER_GROUP) == 0){return -1;}
	
	//Read collider array
	var ref = __cmi_cylinder_get_capsule_ref(cylinder, collider);
	var maxR = collider[CM.R] * CM_FIRST_PASS_RADIUS;
	
	var x1 = CM_CYLINDER_X1;
	var y1 = CM_CYLINDER_Y1;
	var z1 = CM_CYLINDER_Z1;
	var x2 = CM_CYLINDER_X2;
	var y2 = CM_CYLINDER_Y2;
	var z2 = CM_CYLINDER_Z2;
	var cx = CM_CYLINDER_DX;
	var cy = CM_CYLINDER_DY;
	var cz = CM_CYLINDER_DZ;
	var R  = CM_CYLINDER_R;
	var c = dot_product_3d(cx, cy, cz, cx, cy, cz);
	var D = clamp(dot_product_3d(ref[0] - x1, ref[1] - y1, ref[2] - z1, cx, cy, cz) / c, 0, 1);
	var tx = lerp(x1, x2, D);
	var ty = lerp(y1, y2, D);
	var tz = lerp(z1, z2, D);
	var dx = ref[0] - tx;
	var dy = ref[1] - ty;
	var dz = ref[2] - tz;
	if (D <= 0 || D >= 1)
	{
		var dp = dot_product_3d(dx, dy, dz, cx, cy, cz) / c;
		dx -= cx * dp;
		dy -= cy * dp;
		dz -= cz * dp;
		var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
		if (d > R)
		{
			var _d = R / d;
			dx *= _d;
			dy *= _d;
			dz *= _d;
		}
		dx = ref[0] - tx - dx;
		dy = ref[1] - ty - dy;
		dz = ref[2] - tz - dz;
		var d = dot_product_3d(dx, dy, dz, dx, dy, dz);
		if (d > maxR * maxR) return -1;
		return d;
	}
	var d = max(point_distance_3d(dx, dy, dz, 0, 0, 0) - R, 0);
	if (d > maxR) return -1;
	return d * d;
}