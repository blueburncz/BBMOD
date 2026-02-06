/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_quadtree_debug_bake(quadtree, vbuff, matrix, mask = 0, hrep = 1, vrep = 1, color = -1, alpha = 1)
{
	cm_list_debug_bake(CM_QUADTREE_OBJECTLIST, vbuff, matrix, mask, hrep, vrep, color, alpha);
}