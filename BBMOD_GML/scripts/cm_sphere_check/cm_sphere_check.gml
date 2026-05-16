/*
	This function displaces the collider out of the give shape.
*/

function cm_sphere_check(sphere, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_SPHERE_GROUP) == 0){return false;}
	
	var ref = __cmi_sphere_get_capsule_ref(sphere, collider);
	var d = point_distance_3d(ref[0], ref[1], ref[2], CM_SPHERE_X, CM_SPHERE_Y, CM_SPHERE_Z);
	if (d >= CM_SPHERE_R + collider[CM.R]) return false;
	
	return true;
}