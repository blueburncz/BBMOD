// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function __cmi_quadtree_prune(quadtree)
{
	var children = 0;
	var onlychild = 0;
	var i = CM_QUADTREE.CHILD1;
	repeat 4
	{
		var child = quadtree[i++];
		if (!is_array(child)) continue;
		++ children;
		onlychild = child;
	}
	
	//If this quadtree has no children, unsubdivide it
	if (children == 0)
	{
		CM_QUADTREE_SUBDIVIDED = false;
		for (var i = 0; i < 8; ++i)
		{
			quadtree[@ CM_QUADTREE.CHILD1 + i] = undefined;
		}
	}
	//If this quadtree contains just one region, see if it can be unsubdivided
	if (children == 1)
	{
		if (CM_QUADTREE_ISROOT)
		{
			array_copy(quadtree, 0, onlychild, 0, CM_QUADTREE.NUM);
			CM_QUADTREE_ISROOT = true;
			__cmi_quadtree_prune(quadtree);
		}
		else if (onlychild[CM_QUADTREE.SUBDIVIDED] == false)
		{
			CM_QUADTREE_SUBDIVIDED = false;
			for (var i = 0; i < 4; ++i)
			{
				quadtree[@ CM_QUADTREE.CHILD1 + i] = undefined;
			}
		}
	}
}