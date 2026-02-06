/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_dynamic_debug_bake(dynamic, vbuff, matrix, hrep = 1, vrep = 1, color = -1, alpha = 1)
{
	if (CM_RECURSION >= CM_MAX_RECURSIONS) return false;
	if (CM_DYNAMIC_MOVING) return false; //Don't bake moving objects
	
	++ CM_RECURSION;
	cm_vbuff_bake(CM_DYNAMIC_OBJECT, vbuff, matrix_multiply(CM_DYNAMIC_M, matrix), hrep, vrep, color, alpha);
	-- CM_RECURSION;
}