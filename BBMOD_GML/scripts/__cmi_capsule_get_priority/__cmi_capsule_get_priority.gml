function __cmi_capsule_get_priority(capsule, collider, mask = collider[CM.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns -1 if the shape is too far away
		Returns the square of the distance between the shape and the given point
	*/
	if (mask != 0 && (mask & CM_CAPSULE_GROUP) == 0){return -1;}
	
	//Read collider array
	var ref = __cmi_capsule_get_capsule_ref(capsule, collider);
	var maxR = collider[CM.R] * CM_FIRST_PASS_RADIUS;
	var x1 = CM_CAPSULE_X1;
	var y1 = CM_CAPSULE_Y1;
	var z1 = CM_CAPSULE_Z1;
	var x2 = CM_CAPSULE_X2;
	var y2 = CM_CAPSULE_Y2;
	var z2 = CM_CAPSULE_Z2;
	var cx = x2 - x1;
	var cy = y2 - y1;
	var cz = z2 - z1;
	var D = dot_product_3d(ref[0] - x1, ref[1] - y1, ref[2] - z1, cx, cy, cz) / dot_product_3d(cx, cy, cz, cx, cy, cz);
	D = clamp(D, 0, 1);
	var tx = lerp(x1, x2, D);
	var ty = lerp(y1, y2, D);
	var tz = lerp(z1, z2, D);
	var d = point_distance_3d(ref[0], ref[1], ref[2], tx, ty, tz) - CM_CAPSULE_R;
	if (d > maxR) return -1;
	return sqr(max(d, 0));
}