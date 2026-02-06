function cm_quadtree_get_region(quadtree, AABB)
{
	static calldepth = 0;
	static regions = array_create(CM_TREE_MAXDEPTH);
	var region = regions[calldepth];
	if (!is_array(region))
	{
		region = cm_list();
		regions[calldepth] = region;
	}
	region[CM_LIST.SIZE] = CM_LIST.NUM;
	
	//If the AABB is outside the quadtree, exit early
	var quad_aabb = CM_QUADTREE_AABB;
	if (quad_aabb[0] > AABB[3] || quad_aabb[3] < AABB[0] || quad_aabb[1] > AABB[4] || quad_aabb[4] < AABB[1])
	{
		region[CM_LIST.SIZE] = CM_LIST.NUM;
		return region;
	}
	
	//If the quadtree is entirely inside the AABB, return all objects in this quadtree
	var issubdivided = CM_QUADTREE_SUBDIVIDED;
	if (!issubdivided || (quad_aabb[0] >= AABB[0] && quad_aabb[1] >= AABB[1] && quad_aabb[3] <= AABB[3] && quad_aabb[4] <= AABB[4]))
	{
		return CM_QUADTREE_OBJECTLIST;
	}
	
	++ calldepth;
	var rsize = CM_QUADTREE_SIZE / 2;
	var x1 = (AABB[0] - quad_aabb[0] > rsize);
	var y1 = (AABB[1] - quad_aabb[1] > rsize);
	var x2 = (AABB[3] - quad_aabb[0] > rsize);
	var y2 = (AABB[4] - quad_aabb[1] > rsize);
	for (var xx = x1; xx <= x2; ++xx)
	{
		for (var yy = y1; yy <= y2; ++yy)
		{
			var child = quadtree[CM_QUADTREE.CHILD1 + xx + 2 * yy];
			if (is_array(child))
			{
				cm_list_add(region, cm_octree_get_region(child, AABB));
			}
		}
	}
	if (-- calldepth == 0)
	{
		region[CM_LIST.SIZE] = array_unique_ext(region, 0, region[CM_LIST.SIZE]);
	}
	return region;
}