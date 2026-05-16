function cm_quadtree_debug_string(quadtree)
{
	static leaves = 0;
	static calldepth = 0;
	if (calldepth == 0)
	{
		leaves = 0;
	}
	
	if (CM_QUADTREE_SUBDIVIDED)
	{
		++ calldepth;
		var i = CM_QUADTREE.CHILD1;
		repeat 4
		{
			var child = quadtree[i++];
			if (!is_array(child)) continue;
			cm_quadtree_debug_string(child);
		}
		-- calldepth;
	}
	else
	{
		++leaves;
	}
	
	return $"[Octree: Min region size: {CM_QUADTREE_REGIONSIZE}, Max objects: {CM_QUADTREE_MAXOBJECTS}, Leaf regions: {leaves}, AABB: {CM_QUADTREE_AABB}";
}