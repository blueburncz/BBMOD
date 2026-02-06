function cm_quadtree_remove(quadtree, object)
{
	var oct_aabb = CM_QUADTREE_AABB;
	var obj_aabb = cm_get_aabb(object);
	
	//Exit conditions
	if (obj_aabb[0] > oct_aabb[3] || obj_aabb[1] > oct_aabb[4] || obj_aabb[3] < oct_aabb[0] || obj_aabb[4] < oct_aabb[1]) return false;
	if (!cm_list_remove(CM_QUADTREE_OBJECTLIST, object)) return false;
	if (!CM_QUADTREE_SUBDIVIDED) return false;
	
	var rsize = CM_QUADTREE_SIZE / 2;
	var x1 = (obj_aabb[0] - oct_aabb[0] > rsize);
	var y1 = (obj_aabb[1] - oct_aabb[1] > rsize);
	var x2 = (obj_aabb[3] - oct_aabb[0] > rsize);
	var y2 = (obj_aabb[4] - oct_aabb[1] > rsize);
	for (var xx = x1; xx <= x2; ++xx)
	{
		for (var yy = y1; yy <= y2; ++yy)
		{
			var ind = CM_QUADTREE.CHILD1 + xx + 2 * yy;
			var child = quadtree[ind];
			if (!is_array(child)) continue;
				
			//Remove the object from the child
			cm_quadtree_remove(child, object);
				
			//If the child is empty, remove it from this quadtree
			if (child[CM_QUADTREE.OBJECTLIST][CM_LIST.SIZE] <= CM_LIST.NUM)
			{
				quadtree[@ ind] = undefined;
				continue;
			}
		}
	}
	
	__cmi_quadtree_prune(quadtree);
}