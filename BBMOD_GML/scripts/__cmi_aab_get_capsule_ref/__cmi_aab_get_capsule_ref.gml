function __cmi_aab_get_capsule_ref(aab, collider)
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
	var radius = collider[CM.R];
	var xup = collider[CM.XUP];
	var yup = collider[CM.YUP];
	var zup = collider[CM.ZUP];
	
	var cx = CM_AAB_X;
	var cy = CM_AAB_Y;
	var cz = CM_AAB_Z;
	var halfX = CM_AAB_HALFX;
	var halfY = CM_AAB_HALFY;
	var halfZ = CM_AAB_HALFZ;
		
	//Check bottom of capsule
	var xx = X - cx;
	var yy = Y - cy;
	var zz = Z - cz;
	var px = cx + clamp(xx / halfX, -1, 1) * halfX;
	var py = cy + clamp(yy / halfY, -1, 1) * halfY;
	var pz = cz + clamp(zz / halfZ, -1, 1) * halfZ;
	var d = dot_product_3d(px - X, py - Y, pz - Z, xup, yup, zup);
	d = clamp(d, 0, height);
	var rx1 = X + xup * d;
	var ry1 = Y + yup * d;
	var rz1 = Z + zup * d;
	var d1 = CM_SQR(rx1 - px, ry1 - py, rz1 - pz);
		
	//Check top of capsule
	xx += xup * height;
	yy += yup * height;
	zz += zup * height;
	var px = cx + clamp(xx / halfX, -1, 1) * halfX;
	var py = cy + clamp(yy / halfY, -1, 1) * halfY;
	var pz = cz + clamp(zz / halfZ, -1, 1) * halfZ;
	var d = dot_product_3d(px - X, py - Y, pz - Z, xup, yup, zup);
	d = clamp(d, 0, height);
	var rx2 = X + xup * d;
	var ry2 = Y + yup * d;
	var rz2 = Z + zup * d;
	var d2 = CM_SQR(rx2 - px, ry2 - py, rz2 - pz);
	if (d2 < d1)
	{
		ret[0] = rx2;
		ret[1] = ry2;
		ret[2] = rz2;
		return ret;
	}
	ret[0] = rx1;
	ret[1] = ry1;
	ret[2] = rz1;
	return ret;
}