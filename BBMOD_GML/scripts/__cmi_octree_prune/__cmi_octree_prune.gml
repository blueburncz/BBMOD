// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function __cmi_octree_prune(octree)
{
	var children = 0;
	var onlychild = 0;
	var i = CM_OCTREE.CHILD1;
	repeat 8
	{
		var child = octree[i++];
		if (!is_array(child)) continue;
		++ children;
		onlychild = child;
	}
	
	//If this octree has no children, unsubdivide it
	if (children == 0)
	{
		CM_OCTREE_SUBDIVIDED = false;
		for (var i = 0; i < 8; ++i)
		{
			octree[@ CM_OCTREE.CHILD1 + i] = undefined;
		}
	}
	//If this octree contains just one region, see if it can be unsubdivided
	if (children == 1)
	{
		if (CM_OCTREE_ISROOT)
		{
			array_copy(octree, 0, onlychild, 0, CM_OCTREE.NUM);
			CM_OCTREE_ISROOT = true;
			__cmi_octree_prune(octree);
		}
		else if (onlychild[CM_OCTREE.SUBDIVIDED] == false)
		{
			CM_OCTREE_SUBDIVIDED = false;
			for (var i = 0; i < 8; ++i)
			{
				octree[@ CM_OCTREE.CHILD1 + i] = undefined;
			}
		}
	}
}