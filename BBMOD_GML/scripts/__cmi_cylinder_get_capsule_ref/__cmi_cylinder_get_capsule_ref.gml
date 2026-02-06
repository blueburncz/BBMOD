function __cmi_cylinder_get_capsule_ref(cylinder, collider)
{	
	/*
		A supplementary function, not meant to be used by itself.
		Returns the nearest point along the given cylinder to the shape.
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
	
	//Read cylinder array
	var cx = CM_CYLINDER_DX;
	var cy = CM_CYLINDER_DY;
	var cz = CM_CYLINDER_DZ;
	var dx = X - CM_CYLINDER_X1;
	var dy = Y - CM_CYLINDER_Y1;
	var dz = Z - CM_CYLINDER_Z1;
	var H = dot_product_3d(cx, cy, cz, cx, cy, cz);
	var upDp = dot_product_3d(cx, cy, cz, xup, yup, zup);
		
	//If the cylinders are parallel, finding the nearest point is trivial
	if (abs(upDp * upDp - H) < 0.0001)
	{
		var t = - dot_product_3d(dx, dy, dz, xup, yup, zup);
		t = clamp(t, 0, height);
		ret[0] = X + xup * t;
		ret[1] = Y + yup * t;
		ret[2] = Z + zup * t;
		return ret;
	}
		
	//Find the nearest point between the central axis of each cylinder. Source: http://geomalgorithms.com/a07-_distance.html
	var w1 = dot_product_3d(dx, dy, dz, cx, cy, cz);
	var w2 = dot_product_3d(dx, dy, dz, xup, yup, zup);
	var s = (w1 - w2 * upDp) / (H - upDp * upDp);
	if (s > 0 && s < 1)
	{
		var t = dot_product_3d(cx * s - dx, cy * s - dy, cz * s - dz, xup, yup, zup);
		t = clamp(t, 0, height);
		ret[0] = X + xup * t;
		ret[1] = Y + yup * t;
		ret[2] = Z + zup * t;
		return ret;
	}
		
	//If the given point is outside either end of the cylinder, find the nearest point to the terminal plane instead
	s = clamp(s, 0, 1);
	var traceX = lerp(CM_CYLINDER_X1, CM_CYLINDER_X2, s);
	var traceY = lerp(CM_CYLINDER_Y1, CM_CYLINDER_Y2, s);
	var traceZ = lerp(CM_CYLINDER_Z1, CM_CYLINDER_Z2, s);
	if (upDp != 0)
	{
		var trace = dot_product_3d(traceX - X, traceY - Y, traceZ - Z, cx, cy, cz) / upDp;
		traceX = X + xup * trace;
		traceY = Y + yup * trace;
		traceZ = Z + zup * trace;
		var p = cm_cylinder_get_closest_point(cylinder, traceX, traceY, traceZ);
		var d = dot_product_3d(p[0] - X, p[1] - Y, p[2] - Z, xup, yup, zup);
	}
	else
	{
		var d = dot_product_3d(traceX - X, traceY - Y, traceZ - Z, xup, yup, zup);
	}
	var t = clamp(d, 0, height);
	ret[0] = X + xup * t;
	ret[1] = Y + yup * t;
	ret[2] = Z + zup * t;
	return ret;
}