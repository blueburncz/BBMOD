/*
	This function displaces the collider out of the give shape.
*/

function cm_capsule_displace(capsule, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_CAPSULE_GROUP) == 0){return false;}
	
	var ref = __cmi_capsule_get_capsule_ref(capsule, collider);
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
	var dx = ref[0] - tx;
	var dy = ref[1] - ty;
	var dz = ref[2] - tz;
	var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
	var r = CM_CAPSULE_R + collider[CM.R];
	if (d == 0 || d >= r) return false;
	d = r / d - 1;
	return __cmi_collider_displace(collider, dx * d, dy * d, dz * d);
}