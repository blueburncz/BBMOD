function cm_octree_cast_ray(octree, ray, mask = ray[CM_RAY.MASK])
{
	var aabb = CM_OCTREE_AABB;
	var rsize = CM_OCTREE_SIZE / 2;
	var subdivided = CM_OCTREE_SUBDIVIDED;
	
	var t = cm_ray_constrain(ray, aabb);
	if (t >= ray[CM_RAY.T])
	{
		return ray;
	}
	
	if (!subdivided)
	{
		return cm_list_cast_ray(CM_OCTREE_OBJECTLIST, ray, mask);
	}
	
	var lox = ray[CM_RAY.X1] - aabb[0];
	var loy = ray[CM_RAY.Y1] - aabb[1];
	var loz = ray[CM_RAY.Z1] - aabb[2];
	var ldx = ray[CM_RAY.X2] - ray[CM_RAY.X1];
	var ldy = ray[CM_RAY.Y2] - ray[CM_RAY.Y1];
	var ldz = ray[CM_RAY.Z2] - ray[CM_RAY.Z1];
	
	//Perform a ray cast against the first region the ray hits
	var rx = (lox + ldx * t > rsize);
	var ry = (loy + ldy * t > rsize);
	var rz = (loz + ldz * t > rsize);
	var child = octree[CM_OCTREE.CHILD1 + rx + 2 * ry + 4 * rz];
	if (is_array(child))
	{
		cm_octree_cast_ray(child, ray, mask);
	}
	
	//Perform a ray cast against subsequent regions in order
	var tx = (ldx == 0) ? 1 : (rsize - lox) / ldx;
	var ty = (ldy == 0) ? 1 : (rsize - loy) / ldy;
	var tz = (ldz == 0) ? 1 : (rsize - loz) / ldz;
	repeat 3
	{
		var m = min(tx, ty, tz);
		if (m >= ray[CM_RAY.T]) return ray;
		if (m == tx)
		{
			if (tx > t)
			{
				rx = !rx;
				t = tx;
			}
			tx = 1;
		}
		else if (m == ty)
		{
			if (ty > t)
			{
				ry = !ry;
				t = ty;
			}
			ty = 1;
		}
		else
		{
			if (tz > t)
			{
				rz = !rz;
				t = tz;
			}
			tz = 1;
		}
		if (m == t)
		{
			if (abs(lox + ldx * t - rsize) <= rsize && abs(loy + ldy * t - rsize) <= rsize && abs(loz + ldz * t - rsize) <= rsize)
			{
				child = octree[CM_OCTREE.CHILD1 + rx + 2 * ry + 4 * rz];
				if (is_array(child))
				{
					cm_octree_cast_ray(child, ray, mask);
				}
			}
		}
	}
	return ray;
}