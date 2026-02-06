function __cmi_capsule_get_capsule_ref(capsule, collider)
{	
	/*
		A supplementary function, not meant to be used by itself.
		Returns the nearest point along the given capsule to the shape.
	*/
	//If the collider has 0 height, this is a sphere
	static ret = array_create(3);
	var height = collider[CM.H];
	if (collider[CM.H] == 0)
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
	
	static ret = array_create(3);
	var cx = CM_CAPSULE_DX;
	var cy = CM_CAPSULE_DY;
	var cz = CM_CAPSULE_DZ;
	var dx = X - CM_CAPSULE_X1;
	var dy = Y - CM_CAPSULE_Y1;
	var dz = Z - CM_CAPSULE_Z1;
	var H = dot_product_3d(cx, cy, cz, cx, cy, cz);
	var upDp = dot_product_3d(cx, cy, cz, xup, yup, zup);
		
	//If the capsules are parallel, finding the nearest point is trivial
	if (upDp * upDp == H)
	{
		var t = - dot_product_3d(dx, dy, dz, xup, yup, zup);
		t = clamp(t, 0, height);
		ret[0] = X + xup * t;
		ret[1] = Y + yup * t;
		ret[2] = Z + zup * t;
		return ret;
	}
		
	//Find the nearest point between the central axis of each capsule. Source: http://geomalgorithms.com/a07-_distance.html
	var w1 = dot_product_3d(dx, dy, dz, cx, cy, cz);
	var w2 = dot_product_3d(dx, dy, dz, xup, yup, zup);
	var s = clamp((w1 - w2 * upDp) / (H - upDp * upDp), 0, 1);
	var t = dot_product_3d(cx * s - dx, cy * s - dy, cz * s - dz, xup, yup, zup);
	t = clamp(t, 0, height);
	ret[0] = X + xup * t;
	ret[1] = Y + yup * t;
	ret[2] = Z + zup * t;
	return ret;
}