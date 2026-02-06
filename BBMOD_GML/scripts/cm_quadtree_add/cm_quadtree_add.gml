function cm_quadtree_add(quadtree, object)
{
	//If the object is an object list, add each element individually
	if (object[CM_TYPE] == CM_OBJECTS.LIST)
	{
		var num = object[CM_LIST.SIZE] - CM_LIST.NUM;
		for (var i = CM_LIST.NUM; i < num; ++i)
		{
			cm_quadtree_add(quadtree, object[i]);
		}
		return object;
	}
	
	//Get info from the quadtree
	var quad_size = CM_QUADTREE_SIZE;
	var quad_aabb = CM_QUADTREE_AABB;
	var isroot = CM_QUADTREE_ISROOT;
	var maxobjects = CM_QUADTREE_MAXOBJECTS;
	var objectlist = CM_QUADTREE_OBJECTLIST;
	var issubdivided = CM_QUADTREE_SUBDIVIDED;
	var minregionsize = CM_QUADTREE_REGIONSIZE;
	var contentnum = objectlist[CM_LIST.SIZE] - CM_LIST.NUM;
	var obj_aabb = cm_get_aabb(object);
	
	//If the object is entirely outside the quadtree, and this is not the root (ie. can't be expanded), exit the function.
	if (!isroot && (obj_aabb[0] > quad_aabb[3] || obj_aabb[1] > quad_aabb[4] || obj_aabb[3] < quad_aabb[0] || obj_aabb[4] < quad_aabb[1]))
	{
		return false;
	}
	
	//If this quadtree has not been subdivided yet.
	if (!issubdivided)
	{	
		//If this region contains too many objects, and is large enough to subdivide, subdivide it.
		if (contentnum >= maxobjects && quad_size > minregionsize)
		{
			CM_QUADTREE_SUBDIVIDED = true;
			CM_QUADTREE_OBJECTLIST = cm_list();
			cm_quadtree_add(quadtree, objectlist);
			return cm_quadtree_add(quadtree, object);
		}
		
		//If this quadtree is the root quadtree, we can expand it to encapsulate the new object.
		if (isroot)
		{	
			//If this is the first object added to the quadtree, move the AABB as well.
			if (contentnum == 0)
			{	
				var obj_size = max(obj_aabb[3] - obj_aabb[0], obj_aabb[4] - obj_aabb[1]);
				quad_size = minregionsize * power(2, ceil(log2(obj_size / minregionsize)));
				quad_aabb[@ 0] = obj_aabb[0];
				quad_aabb[@ 1] = obj_aabb[1];
				quad_aabb[@ 2] = obj_aabb[2];
				quad_aabb[@ 3] = obj_aabb[0] + quad_size;
				quad_aabb[@ 4] = obj_aabb[1] + quad_size;
				quad_aabb[@ 5] = obj_aabb[5];
				CM_QUADTREE_SIZE = quad_size;
			}
			else
			{
				//This is not the first object added to this quadtree. Just expand it.
				var x1 = min(obj_aabb[0], quad_aabb[0]);
				var y1 = min(obj_aabb[1], quad_aabb[1]);
				var z1 = min(obj_aabb[2], quad_aabb[2]);
				var x2 = max(obj_aabb[3], quad_aabb[3]);
				var y2 = max(obj_aabb[4], quad_aabb[4]);
				var z2 = max(obj_aabb[5], quad_aabb[5]);
				var obj_size = max(x2 - x1, y2 - y1);
				quad_size = minregionsize * power(2, ceil(log2(obj_size / minregionsize)));
				quad_aabb[@ 0] = x1;
				quad_aabb[@ 1] = y1;
				quad_aabb[@ 2] = z1;
				quad_aabb[@ 3] = x1 + quad_size;
				quad_aabb[@ 4] = y1 + quad_size;
				quad_aabb[@ 5] = z2;
				CM_QUADTREE_SIZE = quad_size;
			}
		}
		return cm_list_add(objectlist, object);
	}
	
	//Create region variables
	var x1 = (obj_aabb[0] - quad_aabb[0]);
	var y1 = (obj_aabb[1] - quad_aabb[1]);
	var x2 = (obj_aabb[3] - quad_aabb[0]);
	var y2 = (obj_aabb[4] - quad_aabb[1]);
	
	//If the object's border is outside the quadtree, and the quadtree has no parent, expand the quadtree outwards.
	if (isroot && (x1 < 0 || y1 < 0 || x2 > quad_size || y2 > quad_size))
	{
		cm_debug_message($"cm_quadtree_add: Object added outside the edge of the quadtree. Expanding to size {quad_size * 2}");
		
		//Copy all the contents of this quadtree over to a child quadtree.
		var child = cm_quadtree(minregionsize, maxobjects);
		child[@ CM_QUADTREE.SIZE] = quad_size;
		child[@ CM_QUADTREE.ISROOT] = false;
		child[@ CM_QUADTREE.SUBDIVIDED] = true;
		array_copy(child[CM_QUADTREE.AABB], 0, quad_aabb, 0, 6);
		array_copy(child[CM_QUADTREE.OBJECTLIST], 0, objectlist, 0, objectlist[CM_LIST.SIZE]);
		for (var i = 0; i < 4; ++i)
		{
			child[@  CM_QUADTREE.CHILD1 + i] = quadtree[CM_QUADTREE.CHILD1 + i];
			quadtree[@ CM_QUADTREE.CHILD1 + i] = undefined;
		}
		
		//Add the new child quadtree to this quadtree
		var xx = (x1 < 0);
		var yy = (y1 < 0);
		quadtree[@ CM_QUADTREE.CHILD1 + xx + 2 * yy] = child;
		
		//Expand the quadtree
		if (xx) quad_aabb[@ 0] -= quad_size;
		else    quad_aabb[@ 3] += quad_size;
		if (yy) quad_aabb[@ 1] -= quad_size;
		else    quad_aabb[@ 4] += quad_size;
		CM_QUADTREE_SIZE = 2 * quad_size;
		
		//Try again
		return cm_quadtree_add(quadtree, object);
	}
	
	//Add the object to this quadtree's object list
	cm_list_add(objectlist, object);
	
	//Loop through all the regions this object touches
	var rsize = quad_size / 2;
	x1 = (x1 > rsize);
	y1 = (y1 > rsize);
	x2 = (x2 > rsize);
	y2 = (y2 > rsize);
	for (var xx = x1; xx <= x2; ++xx)
	{
		for (var yy = y1; yy <= y2; ++yy)
		{
			//Don't add the object if it doesn't intersect with the region
			//if (!cm_intersects_cube(object, rsize, quad_aabb[0] + rsize * (.5+xx), quad_aabb[1] + rsize * (.5+yy), quad_aabb[2] + rsize * (.5+zz))) continue;
				
			//Find the index of this child. If it does not exist, create it.
			var ind = CM_QUADTREE.CHILD1 + xx + 2 * yy;
			var child = quadtree[ind];
			if (!is_array(child))
			{
				child = cm_quadtree(minregionsize, maxobjects);
				child[@ CM_QUADTREE.SIZE] = rsize;
				child[@ CM_QUADTREE.ISROOT] = false;
				var child_aabb = child[CM_QUADTREE.AABB];
				child_aabb[@ 0] = quad_aabb[0] + xx * rsize;
				child_aabb[@ 1] = quad_aabb[1] + yy * rsize;
				child_aabb[@ 2] = quad_aabb[2];
				child_aabb[@ 3] = quad_aabb[0] + xx * rsize + rsize;
				child_aabb[@ 4] = quad_aabb[1] + yy * rsize + rsize;
				child_aabb[@ 5] = quad_aabb[5];
				child[@ CM_QUADTREE.AABB] = child_aabb;
					
				quadtree[@ ind] = child;
			}
				
			//Add the object to the child
			cm_quadtree_add(child, object);
		}
	}
	return object;
}