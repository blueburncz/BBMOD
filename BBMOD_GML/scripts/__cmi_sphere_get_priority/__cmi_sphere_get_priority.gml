function __cmi_sphere_get_priority(sphere, collider, mask = collider[CM.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns -1 if the shape is too far away
		Returns the square of the distance between the shape and the given point
	*/
	if (mask != 0 && (mask & CM_SPHERE_GROUP) == 0){return -1;}
	
	//Read collider array
	var ref = __cmi_sphere_get_capsule_ref(sphere, collider);
	var maxR = collider[CM.R] * CM_FIRST_PASS_RADIUS;
	var d = point_distance_3d(ref[0], ref[1], ref[2], CM_SPHERE_X, CM_SPHERE_Y, CM_SPHERE_Z);
	if (d > CM_SPHERE_R + maxR) return -1;
	return sqr(max(d - CM_SPHERE_R, 0));
}