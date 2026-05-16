function cm_aab_get_closest_point(aab, x, y, z)
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.getClosestPoint
	*/
	static ret = array_create(3);
	var cx = CM_AAB_X;
	var cy = CM_AAB_Y;
	var cz = CM_AAB_Z;
	var halfX = CM_AAB_HALFX;
	var halfY = CM_AAB_HALFY;
	var halfZ = CM_AAB_HALFZ;
		
	//Find normalized block space position
	var bx = (x - cx) / halfX;
	var by = (y - cy) / halfY;
	var bz = (z - cz) / halfZ;
	var b = max(abs(bx), abs(by), abs(bz));
		
	//If the center of the sphere is inside the cube, normalize the largest axis
	if (b <= 1)
	{
		if (b == abs(bx))
		{
			bx = sign(bx);
		}
		else if (b == abs(by))
		{
			by = sign(by);
		}
		else
		{
			bz = sign(bz);
		}
		ret[@ 0] = cx + bx * halfX;
		ret[@ 1] = cy + by * halfY;
		ret[@ 2] = cz + bz * halfZ;
		ret[@ 6] = 0;
	}
	else
	{	//Nearest point on the cube in normalized block space
		bx = clamp(bx, -1, 1);
		by = clamp(by, -1, 1);
		bz = clamp(bz, -1, 1);
		ret[@ 0] = cx + bx * halfX;
		ret[@ 1] = cy + by * halfY;
		ret[@ 2] = cz + bz * halfZ;
	}
	return ret;
}