function cm_octree_debug_string(octree)
{
	static leaves = 0;
	static calldepth = 0;
	if (calldepth == 0)
	{
		leaves = 0;
	}
	
	if (CM_OCTREE_SUBDIVIDED)
	{
		++ calldepth;
		var i = CM_OCTREE.CHILD1;
		repeat 8
		{
			var child = octree[i++];
			if (!is_array(child)) continue;
			cm_octree_debug_string(child);
		}
		-- calldepth;
	}
	else
	{
		++leaves;
	}
	
	return $"[Octree: Min region size: {CM_OCTREE_REGIONSIZE}, Max objects: {CM_OCTREE_MAXOBJECTS}, Leaf regions: {leaves}, AABB: {CM_OCTREE_AABB}";
}