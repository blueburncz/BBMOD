function __cmi_sphere_get_capsule_ref(sphere, collider)
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns the nearest point along the given capsule to the shape.
	*/
	//If the collider has 0 height, this is a sphere
	static ret = array_create(3);
	var height = collider[CM.H];
	if (height == 0)
	{
		ret[0] = collider[CM.X];
		ret[1] = collider[CM.Y];
		ret[2] = collider[CM.Z];
		return ret;
	}
	
	//Read collider array
	var X = collider[CM.X];
	var Y = collider[CM.Y];
	var Z = collider[CM.Z];
	var xup = collider[CM.XUP];
	var yup = collider[CM.YUP];
	var zup = collider[CM.ZUP];
	
	var d = clamp(dot_product_3d(CM_SPHERE_X - X, CM_SPHERE_Y - Y, CM_SPHERE_Z - Z, xup, yup, zup), 0, height);
	ret[@ 0] = X + xup * d;
	ret[@ 1] = Y + yup * d;
	ret[@ 2] = Z + zup * d;
	return ret;
}