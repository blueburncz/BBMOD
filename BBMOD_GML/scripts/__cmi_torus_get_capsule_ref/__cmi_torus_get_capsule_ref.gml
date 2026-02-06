function __cmi_torus_get_capsule_ref(torus, collider)
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
	
	//Read torus array
	var cx = CM_TORUS_X;
	var cy = CM_TORUS_Y;
	var cz = CM_TORUS_Z;
	var nx = CM_TORUS_NX;
	var ny = CM_TORUS_NY;
	var nz = CM_TORUS_NZ;
	var r  = CM_TORUS_SMALLRADIUS;
	var R  = CM_TORUS_BIGRADIUS;
	
	var d = dot_product_3d(xup, yup, zup, nx, ny, nz);
	if (d != 0)
	{
		var d = dot_product_3d(cx - X, cy - Y, cz - Z, nx, ny, nz) / d;
		var rx = X + xup * d - cx;
		var ry = Y + yup * d - cy;
		var rz = Z + zup * d - cz;
		var dp = dot_product_3d(rx, ry, rz, nx, ny, nz);
		rx -= nx * dp;
		ry -= ny * dp;
		rz -= nz * dp;
		var l = point_distance_3d(0, 0, 0, rx, ry, rz);
		if (l == 0){return ret;}
		var _d = R / l;
		d = dot_product_3d(cx + rx * _d - X, cy + ry * _d - Y, cz + rz * _d - Z, xup, yup, zup);
	}
	else
	{
		d = dot_product_3d(cx - X, cy - Y, cz - Z, xup, yup, zup);
	}
	d = clamp(d, 0, height);
	ret[0] = X + xup * d;
	ret[1] = Y + yup * d;
	ret[2] = Z + zup * d;
	return ret;
}