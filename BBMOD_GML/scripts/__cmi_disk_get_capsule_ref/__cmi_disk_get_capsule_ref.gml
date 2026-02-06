function __cmi_disk_get_capsule_ref(disk, collider)
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
	
	//Read disk array
	var cx = CM_DISK_X;
	var cy = CM_DISK_Y;
	var cz = CM_DISK_Z;
	var nx = CM_DISK_NX;
	var ny = CM_DISK_NY;
	var nz = CM_DISK_NZ;
	var r  = CM_DISK_SMALLRADIUS;
	var R  = CM_DISK_BIGRADIUS;
	
	var d = dot_product_3d(xup, yup, zup, nx, ny, nz);
	if (d != 0)
	{
		var d = dot_product_3d(cx - X, cy - Y, cz - Z, nx, ny, nz) / d;
		var p = __cmi_get_diskcoord(cx, cy, cz, nx, ny, nz, R, X + xup * d, Y + yup * d, Z + zup * d);
		d = dot_product_3d(p[0] - X, p[1] - Y, p[2] - Z, xup, yup, zup);
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