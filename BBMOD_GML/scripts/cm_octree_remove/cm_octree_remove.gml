function cm_octree_remove(octree, object)
{
	var oct_aabb = CM_OCTREE_AABB;
	var obj_aabb = cm_get_aabb(object);
	
	//Exit conditions
	if (obj_aabb[0] > oct_aabb[3] || obj_aabb[1] > oct_aabb[4] || obj_aabb[2] > oct_aabb[5] || obj_aabb[3] < oct_aabb[0] || obj_aabb[4] < oct_aabb[1] || obj_aabb[5] < oct_aabb[2]) return false;
	if (!cm_list_remove(CM_OCTREE_OBJECTLIST, object)) return false;
	if (!CM_OCTREE_SUBDIVIDED) return false;
	
	var rsize = CM_OCTREE_SIZE / 2;
	var x1 = (obj_aabb[0] - oct_aabb[0] > rsize);
	var y1 = (obj_aabb[1] - oct_aabb[1] > rsize);
	var z1 = (obj_aabb[2] - oct_aabb[2] > rsize);
	var x2 = (obj_aabb[3] - oct_aabb[0] > rsize);
	var y2 = (obj_aabb[4] - oct_aabb[1] > rsize);
	var z2 = (obj_aabb[5] - oct_aabb[2] > rsize);
	for (var xx = x1; xx <= x2; ++xx)
	{
		for (var yy = y1; yy <= y2; ++yy)
		{
			for (var zz = z1; zz <= z2; ++zz)
			{
				var ind = CM_OCTREE.CHILD1 + xx + 2 * yy + 4 * zz;
				var child = octree[ind];
				if (!is_array(child)) continue;
				
				//Remove the object from the child
				cm_octree_remove(child, object);
				
				//If the child is empty, remove it from this octree
				if (child[CM_OCTREE.OBJECTLIST][CM_LIST.SIZE] == CM_LIST.NUM)
				{
					octree[@ ind] = undefined;
					continue;
				}
			}
		}
	}
	
	__cmi_octree_prune(octree);
}