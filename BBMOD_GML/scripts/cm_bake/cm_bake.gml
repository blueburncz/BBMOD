/*
	This function lets you bake a shape into a vertex buffer. Useful for debugging.
*/
function cm_bake(object, matrix = matrix_build_identity(), mask = 0, hrep = 1, vrep = 1, color = -1, alpha = 1)
{
	var vbuff = vertex_create_buffer();
	cm_vbuff_begin(vbuff);
	cm_vbuff_bake(object, vbuff, matrix, mask, hrep, vrep, color, alpha);
	cm_vbuff_end(vbuff);
	return vbuff;
}