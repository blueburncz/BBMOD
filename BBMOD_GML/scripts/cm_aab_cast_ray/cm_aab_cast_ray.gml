function cm_aab_cast_ray(aab, ray, mask = ray[CM_RAY.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.castRay
	*/
	if (mask != 0 && (mask & CM_AAB_GROUP) == 0){return ray;}
	
	var cx = CM_AAB_X;
	var cy = CM_AAB_Y;
	var cz = CM_AAB_Z;
	var halfX = CM_AAB_HALFX;
	var halfY = CM_AAB_HALFY;
	var halfZ = CM_AAB_HALFZ;
	
	var x1 = (ray[CM_RAY.X1] - cx) / halfX;
	var y1 = (ray[CM_RAY.Y1] - cy) / halfY;
	var z1 = (ray[CM_RAY.Z1] - cz) / halfZ;
	var x2 = (ray[CM_RAY.X2] - cx) / halfX;
	var y2 = (ray[CM_RAY.Y2] - cy) / halfY;
	var z2 = (ray[CM_RAY.Z2] - cz) / halfZ;
	var T = ray[CM_RAY.T];
		
	var t, nx, ny, nz;
	if (x2 != x1 && abs(x1) > 1)
	{
		var s = sign(x1 - x2);
		t = (s - x1) / (x2 - x1);
		if (t >= 0 && t <= T)
		{
			var itsY = lerp(y1, y2, t);
			var itsZ = lerp(z1, z2, t);
			if (abs(itsY) <= 1 && abs(itsZ) <= 1)
			{
				ray[@ CM_RAY.T] = t;
				ray[@ CM_RAY.HIT] = true;
				ray[@ CM_RAY.X] = cx + s * halfX;
				ray[@ CM_RAY.Y] = cy + itsY * halfY;
				ray[@ CM_RAY.Z] = cz + itsZ * halfZ;
				ray[@ CM_RAY.NX] = sign(x1);
				ray[@ CM_RAY.NY] = 0;
				ray[@ CM_RAY.NZ] = 0;
				ray[@ CM_RAY.OBJECT] = aab;
				return ray;
			}
		}
	}
	if (y2 != y1 && abs(y1) > 1)
	{
		var s = sign(y1 - y2);
		t = (s - y1) / (y2 - y1);
		if (t >= 0 && t <= T)
		{
			var itsX = lerp(x1, x2, t);
			var itsZ = lerp(z1, z2, t);
			if (abs(itsX) <= 1 && abs(itsZ) <= 1)
			{
				ray[@ CM_RAY.T] = t;
				ray[@ CM_RAY.HIT] = true;
				ray[@ CM_RAY.X] = cx + itsX * halfX;
				ray[@ CM_RAY.Y] = cy + s * halfY;
				ray[@ CM_RAY.Z] = cz + itsZ * halfZ;
				ray[@ CM_RAY.NX] = 0;
				ray[@ CM_RAY.NY] = sign(y1);
				ray[@ CM_RAY.NZ] = 0;
				ray[@ CM_RAY.OBJECT] = aab;
				return ray;
			}
		}
	}
	if (z2 != z1 && abs(z1) > 1)
	{
		var s = sign(z1 - z2);
		t = (s - z1) / (z2 - z1);
		if (t >= 0 && t <= T)
		{
			var itsX = lerp(x1, x2, t);
			var itsY = lerp(y1, y2, t);
			if (abs(itsX) <= 1 && abs(itsY) <= 1)
			{
				ray[@ CM_RAY.T] = t;
				ray[@ CM_RAY.HIT] = true;
				ray[@ CM_RAY.X] = cx + itsX * halfX;
				ray[@ CM_RAY.Y] = cy + itsY * halfY;
				ray[@ CM_RAY.Z] = cz + s * halfZ;
				ray[@ CM_RAY.NX] = 0;
				ray[@ CM_RAY.NY] = 0;
				ray[@ CM_RAY.NZ] = sign(z1);
				ray[@ CM_RAY.OBJECT] = aab;
				return ray;
			}
		}
	}
	return ray;
}