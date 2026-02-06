/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_octree_debug_bake(octree, vbuff, matrix, mask = 0, hrep = 1, vrep = 1, color = -1, alpha = 1)
{
	cm_list_debug_bake(CM_OCTREE_OBJECTLIST, vbuff, matrix, mask, hrep, vrep, color, alpha);
}