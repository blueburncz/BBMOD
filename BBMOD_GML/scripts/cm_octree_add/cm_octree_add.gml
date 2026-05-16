function cm_octree_add(octree, object)
{
	//If the object is an object list, add each element individually
	if (object[CM_TYPE] == CM_OBJECTS.LIST)
	{
		var num = array_length(object);
		for (var i = CM_LIST.NUM; i < object[CM_LIST.SIZE]; ++i)
		{
			cm_octree_add(octree, object[i]);
		}
		return object;
	}
	
	//Get info from the octree
	var oct_size = CM_OCTREE_SIZE;
	var oct_aabb = CM_OCTREE_AABB;
	var isroot = CM_OCTREE_ISROOT;
	var maxobjects = CM_OCTREE_MAXOBJECTS;
	var objectlist = CM_OCTREE_OBJECTLIST;
	var issubdivided = CM_OCTREE_SUBDIVIDED;
	var minregionsize = CM_OCTREE_REGIONSIZE;
	var contentnum = objectlist[CM_LIST.SIZE] - CM_LIST.NUM;
	var obj_aabb = cm_get_aabb(object);
	
	//If the object is entirely outside the octree, and this is not the root (ie. can't be expanded), exit the function.
	if (!isroot && (obj_aabb[0] > oct_aabb[3] || obj_aabb[1] > oct_aabb[4] || obj_aabb[2] > oct_aabb[5] || obj_aabb[3] < oct_aabb[0] || obj_aabb[4] < oct_aabb[1] || obj_aabb[5] < oct_aabb[2]))
	{
		return false;
	}
	
	//If this octree has not been subdivided yet.
	if (!issubdivided)
	{	
		//If this region contains too many objects, and is large enough to subdivide, subdivide it.
		if (contentnum >= maxobjects && oct_size > minregionsize)
		{
			cm_debug_message($"cm_octree_add: More than the maximum {maxobjects} has been added to the root octree. Subdiving...");
			
			//Make sure the size is a power of two times the minimum region size
			oct_size = minregionsize * power(2, ceil(log2(oct_size / minregionsize)));
			oct_aabb[@ 3] = oct_aabb[@ 0] + oct_size;
			oct_aabb[@ 4] = oct_aabb[@ 1] + oct_size;
			oct_aabb[@ 5] = oct_aabb[@ 2] + oct_size;
			CM_OCTREE_SIZE = oct_size;
			CM_OCTREE_SUBDIVIDED = true;
			CM_OCTREE_OBJECTLIST = cm_list();
			cm_octree_add(octree, objectlist);
			return cm_octree_add(octree, object);
		}
		
		//If this octree is the root octree, we can expand it to encapsulate the new object.
		if (isroot)
		{	
			//If this is the first object added to the octree, move the AABB as well.
			if (contentnum == 0)
			{	
				oct_size = max(obj_aabb[3] - obj_aabb[0], obj_aabb[4] - obj_aabb[1], obj_aabb[5] - obj_aabb[2]);
				oct_aabb[@ 0] = obj_aabb[0];
				oct_aabb[@ 1] = obj_aabb[1];
				oct_aabb[@ 2] = obj_aabb[2];
				oct_aabb[@ 3] = obj_aabb[0] + oct_size;
				oct_aabb[@ 4] = obj_aabb[1] + oct_size;
				oct_aabb[@ 5] = obj_aabb[2] + oct_size;
				CM_OCTREE_SIZE = oct_size;
			}
			else
			{
				//This is not the first object added to this octree. Just expand it.
				var x1 = min(obj_aabb[0], oct_aabb[0]);
				var y1 = min(obj_aabb[1], oct_aabb[1]);
				var z1 = min(obj_aabb[2], oct_aabb[2]);
				var x2 = max(obj_aabb[3], oct_aabb[3]);
				var y2 = max(obj_aabb[4], oct_aabb[4]);
				var z2 = max(obj_aabb[5], oct_aabb[5]);
				oct_size = max(x2 - x1, y2 - y1, z2 - z1);
				oct_aabb[@ 0] = x1;
				oct_aabb[@ 1] = y1;
				oct_aabb[@ 2] = z1;
				oct_aabb[@ 3] = x1 + oct_size;
				oct_aabb[@ 4] = y1 + oct_size;
				oct_aabb[@ 5] = z1 + oct_size;
				CM_OCTREE_SIZE = oct_size;
			}
		}
		return cm_list_add(objectlist, object);
	}
	
	//Create region variables
	var x1 = (obj_aabb[0] - oct_aabb[0]);
	var y1 = (obj_aabb[1] - oct_aabb[1]);
	var z1 = (obj_aabb[2] - oct_aabb[2]);
	var x2 = (obj_aabb[3] - oct_aabb[0]);
	var y2 = (obj_aabb[4] - oct_aabb[1]);
	var z2 = (obj_aabb[5] - oct_aabb[2]);
	
	//If the object's border is outside the octree, and the octree has no parent, expand the octree outwards.
	if (isroot && (x1 < 0 || y1 < 0 || z1 < 0 || x2 > oct_size || y2 > oct_size || z2 > oct_size))
	{
		cm_debug_message($"cm_octree_add: Object added outside the edge of the octree. Expanding to size {oct_size * 2}");
		
		//Make sure the size is a power of two times the minimum region size
		oct_size = minregionsize * power(2, ceil(log2(oct_size / minregionsize)));
		oct_aabb[@ 3] = oct_aabb[@ 0] + oct_size;
		oct_aabb[@ 4] = oct_aabb[@ 1] + oct_size;
		oct_aabb[@ 5] = oct_aabb[@ 2] + oct_size;
		
		//Copy all the contents of this octree over to a child octree.
		var child = cm_octree(minregionsize, maxobjects);
		child[@ CM_OCTREE.SIZE] = oct_size;
		child[@ CM_OCTREE.ISROOT] = false;
		child[@ CM_OCTREE.SUBDIVIDED] = true;
		array_copy(child[CM_OCTREE.AABB], 0, oct_aabb, 0, 6);
		array_copy(child[CM_OCTREE.OBJECTLIST], 0, objectlist, 0, objectlist[CM_LIST.SIZE]);
		for (var i = 0; i < 8; ++i)
		{
			child[@  CM_OCTREE.CHILD1 + i] = octree[CM_OCTREE.CHILD1 + i];
			octree[@ CM_OCTREE.CHILD1 + i] = undefined;
		}
		
		//Add the new child octree to this octree
		var xx = (x1 < 0);
		var yy = (y1 < 0);
		var zz = (z1 < 0);
		octree[@ CM_OCTREE.CHILD1 + xx + 2 * yy + 4 * zz] = child;
		
		//Expand the octree
		if (xx) oct_aabb[@ 0] -= oct_size; else oct_aabb[@ 3] += oct_size;
		if (yy) oct_aabb[@ 1] -= oct_size; else oct_aabb[@ 4] += oct_size;
		if (zz) oct_aabb[@ 2] -= oct_size; else oct_aabb[@ 5] += oct_size;
		CM_OCTREE_SIZE = 2 * oct_size;
		
		//Try again
		return cm_octree_add(octree, object);
	}
	
	//Add the object to this octree's object list
	cm_list_add(objectlist, object);
	
	//Loop through all the regions this object touches
	var rsize = oct_size / 2;
	x1 = (x1 > rsize);
	y1 = (y1 > rsize);
	z1 = (z1 > rsize);
	x2 = (x2 > rsize);
	y2 = (y2 > rsize);
	z2 = (z2 > rsize);
	for (var xx = x1; xx <= x2; ++xx)
	{
		for (var yy = y1; yy <= y2; ++yy)
		{
			for (var zz = z1; zz <= z2; ++zz)
			{
				//Don't add the object if it doesn't intersect with the region
				if (!cm_intersects_cube(object, rsize, oct_aabb[0] + rsize * (.5+xx), oct_aabb[1] + rsize * (.5+yy), oct_aabb[2] + rsize * (.5+zz))) continue;
				
				//Find the index of this child. If it does not exist, create it.
				var ind = CM_OCTREE.CHILD1 + xx + 2 * yy + 4 * zz;
				var child = octree[ind];
				if (!is_array(child))
				{
					child = cm_octree(minregionsize, maxobjects);
					child[@ CM_OCTREE.SIZE] = rsize;
					child[@ CM_OCTREE.ISROOT] = false;
					var child_aabb = child[CM_OCTREE.AABB];
					child_aabb[@ 0] = oct_aabb[0] + xx * rsize;
					child_aabb[@ 1] = oct_aabb[1] + yy * rsize;
					child_aabb[@ 2] = oct_aabb[2] + zz * rsize;
					child_aabb[@ 3] = oct_aabb[0] + xx * rsize + rsize;
					child_aabb[@ 4] = oct_aabb[1] + yy * rsize + rsize;
					child_aabb[@ 5] = oct_aabb[2] + zz * rsize + rsize;
					child[@ CM_OCTREE.AABB] = child_aabb;
					
					octree[@ ind] = child;
				}
				
				//Add the object to the child
				cm_octree_add(child, object);
			}
		}
	}
	return object;
}