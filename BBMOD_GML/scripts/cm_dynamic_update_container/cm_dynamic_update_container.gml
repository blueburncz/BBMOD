// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_dynamic_update_container(dynamic, container)
{
	var AABB = CM_DYNAMIC_AABB;
	var pAABB = CM_DYNAMIC_AABBPREV;
	
	var containerType = container[CM_TYPE];
	if (containerType == CM_OBJECTS.SPATIALHASH)
	{
		var rsize = container[CM_SPATIALHASH.REGIONSIZE];
		if (floor(pAABB[0] / rsize) != floor(AABB[0] / rsize) ||
			floor(pAABB[1] / rsize) != floor(AABB[1] / rsize) ||
			floor(pAABB[2] / rsize) != floor(AABB[2] / rsize) ||
			floor(pAABB[3] / rsize) != floor(AABB[3] / rsize) ||
			floor(pAABB[4] / rsize) != floor(AABB[4] / rsize) ||
			floor(pAABB[5] / rsize) != floor(AABB[5] / rsize))
		{
			CM_DYNAMIC_AABB = pAABB;
			cm_spatialhash_remove(container, dynamic);
			CM_DYNAMIC_AABB = AABB;
			cm_spatialhash_add(container, dynamic);
		}
		return true;
	}
	if (containerType == CM_OBJECTS.QUADTREE)
	{
		var qAABB = container[CM_QUADTREE.AABB];
		var rsize = container[CM_QUADTREE.REGIONSIZE];
		if (floor((pAABB[0] - qAABB[0]) / rsize) != floor((AABB[0] - qAABB[0]) / rsize) ||
			floor((pAABB[1] - qAABB[1]) / rsize) != floor((AABB[1] - qAABB[1]) / rsize) ||
			floor((pAABB[3] - qAABB[0]) / rsize) != floor((AABB[3] - qAABB[0]) / rsize) ||
			floor((pAABB[4] - qAABB[1]) / rsize) != floor((AABB[4] - qAABB[1]) / rsize))
		{
			CM_DYNAMIC_AABB = pAABB;
			cm_octree_remove(container, dynamic);
			CM_DYNAMIC_AABB = AABB;
			cm_octree_add(container, dynamic);
		}
		return true;
	}
	if (containerType == CM_OBJECTS.OCTREE)
	{
		var oAABB = container[CM_OCTREE.AABB];
		var rsize = container[CM_OCTREE.REGIONSIZE];
		if (floor((pAABB[0] - oAABB[0]) / rsize) != floor((AABB[0] - oAABB[0]) / rsize) ||
			floor((pAABB[1] - oAABB[1]) / rsize) != floor((AABB[1] - oAABB[1]) / rsize) ||
			floor((pAABB[2] - oAABB[2]) / rsize) != floor((AABB[2] - oAABB[2]) / rsize) ||
			floor((pAABB[3] - oAABB[0]) / rsize) != floor((AABB[3] - oAABB[0]) / rsize) ||
			floor((pAABB[4] - oAABB[1]) / rsize) != floor((AABB[4] - oAABB[1]) / rsize) ||
			floor((pAABB[5] - oAABB[2]) / rsize) != floor((AABB[5] - oAABB[2]) / rsize))
		{
			CM_DYNAMIC_AABB = pAABB;
			cm_octree_remove(container, dynamic);
			CM_DYNAMIC_AABB = AABB;
			cm_octree_add(container, dynamic);
		}
		return true;
	}
	return false;
}