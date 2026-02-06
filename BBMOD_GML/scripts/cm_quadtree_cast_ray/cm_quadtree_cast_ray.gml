function cm_quadtree_cast_ray(quadtree, ray, mask = ray[CM_RAY.MASK])
{
	var aabb = CM_QUADTREE_AABB;
	var rsize = CM_QUADTREE_SIZE / 2;
	var subdivided = CM_QUADTREE_SUBDIVIDED;
	
	var t = cm_ray_constrain(ray, aabb);
	if (t >= ray[CM_RAY.T])
	{
		return ray;
	}
	
	if (!subdivided)
	{
		return cm_list_cast_ray(CM_QUADTREE_OBJECTLIST, ray);
	}
	
	var lox = ray[CM_RAY.X1] - aabb[0];
	var loy = ray[CM_RAY.Y1] - aabb[1];
	var ldx = ray[CM_RAY.X2] - ray[CM_RAY.X1];
	var ldy = ray[CM_RAY.Y2] - ray[CM_RAY.Y1];
	
	//Perform a ray cast against the first region the ray hits
	var rx = (lox + ldx * t > rsize);
	var ry = (loy + ldy * t > rsize);
	var child = quadtree[CM_QUADTREE.CHILD1 + rx + 2 * ry];
	if (is_array(child))
	{
		cm_quadtree_cast_ray(child, ray);
	}
	
	//Perform a ray cast against subsequent regions in order
	var tx = (ldx == 0) ? 1 : (rsize - lox) / ldx;
	var ty = (ldy == 0) ? 1 : (rsize - loy) / ldy;
	repeat 3
	{
		var m = min(tx, ty);
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
		else
		{
			if (ty > t)
			{
				ry = !ry;
				t = ty;
			}
			ty = 1;
		}
		if (m == t)
		{
			if (abs(lox + ldx * t - rsize) <= rsize && abs(loy + ldy * t - rsize) <= rsize)
			{
				child = quadtree[CM_QUADTREE.CHILD1 + rx + 2 * ry];
				if (is_array(child))
				{
					cm_quadtree_cast_ray(child, ray, mask);
				}
			}
		}
	}
	return ray;
}