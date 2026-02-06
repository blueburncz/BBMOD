function cm_ray_constrain(ray, aabb) 
{
	//Returns how far along the ray there was an intersection with the given AABB as a single value
		
	///////////////////////////////////////////////////////////////////
	//Convert from world coordinates to local coordinates
	var sx = (aabb[3] - aabb[0]) * .5;
	var sy = (aabb[4] - aabb[1]) * .5;
	var sz = (aabb[5] - aabb[2]) * .5;
	var mx = (aabb[3] + aabb[0]) * .5;
	var my = (aabb[4] + aabb[1]) * .5;
	var mz = (aabb[5] + aabb[2]) * .5;
	var x1 = (ray[CM_RAY.X1] - mx) / sx;
	var y1 = (ray[CM_RAY.Y1] - my) / sy;
	var z1 = (ray[CM_RAY.Z1] - mz) / sz;
		
	if (abs(x1) < 1 && abs(y1) < 1 && abs(z1) < 1)
	{
		//The ray starts inside the bounding box, and we can end the algorithm here
		return 0;
	}
	
	var x2 = (ray[CM_RAY.X2] - mx) / sx;
	var y2 = (ray[CM_RAY.Y2] - my) / sy;
	var z2 = (ray[CM_RAY.Z2] - mz) / sz;
	
	///////////////////////////////////////////////////////////////////
	//Check X dimension
	var d = x1 - x2;
	if (d != 0)
	{
		var t = (x1 - sign(d)) / d;
		if (t >= 0 && t <= 1)
		{
			if (abs(lerp(y1, y2, t)) <= 1 && abs(lerp(z1, z2, t)) <= 1)
			{
				return t;
			}
		}
	}
	///////////////////////////////////////////////////////////////////
	//Check Y dimension
	var d = y1 - y2;
	if (d != 0)
	{
		var t = (y1 - sign(d)) / d;
		if (t >= 0 && t <= 1)
		{
			if (abs(lerp(x1, x2, t)) <= 1 && abs(lerp(z1, z2, t)) <= 1)
			{
				return t;
			}
		}
	}
	///////////////////////////////////////////////////////////////////
	//Check Z dimension
	var d = z1 - z2;
	if (d != 0)
	{
		var t = (z1 - sign(d)) / d;
		if (t >= 0 && t <= 1)
		{
			if (abs(lerp(x1, x2, t)) <= 1 && abs(lerp(y1, y2, t)) <= 1)
			{
				return t;
			}
		}
	}

	///////////////////////////////////////////////////////////////////
	//There was no intersection. Return 1, which represents the end of the ray.
	return 1;
}