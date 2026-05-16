/*
	This function displaces the collider out of the give shape.
*/

function cm_capsule_check(capsule, collider, mask = collider[CM.MASK])
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
	var a = clamp(dot_product_3d(ref[0] - x1, ref[1] - y1, ref[2] - z1, cx, cy, cz) / dot_product_3d(cx, cy, cz, cx, cy, cz), 0, 1);
	var d = point_distance_3d(ref[0], ref[1], ref[2], lerp(x1, x2, a), lerp(y1, y2, a), lerp(z1, z2, a));
	if (d >= CM_CAPSULE_R + collider[CM.R]) return false;
	
	return true;
}