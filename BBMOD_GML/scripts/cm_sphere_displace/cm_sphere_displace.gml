/*
	This function displaces the collider out of the give shape.
*/

function cm_sphere_displace(sphere, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_SPHERE_GROUP) == 0){return false;}
	
	var ref = __cmi_sphere_get_capsule_ref(sphere, collider);
	var dx = ref[0] - CM_SPHERE_X;
	var dy = ref[1] - CM_SPHERE_Y;
	var dz = ref[2] - CM_SPHERE_Z;
	var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
	var r = CM_SPHERE_R + collider[CM.R];
	if (d == 0 || d >= r){return false;}
	d = r / d - 1;
	return __cmi_collider_displace(collider, dx * d, dy * d, dz * d);
}