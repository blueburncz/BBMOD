/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_spatialhash_debug_bake(spatialhash, vbuff, matrix, mask = 0, hrep = 1, vrep = 1, color = -1, alpha = 1)
{
	var region = cm_list();
	var map = CM_SPATIALHASH_MAP;
	var names = struct_get_names(map);
	var size = CM_LIST.NUM;
	var i = 0;
	repeat array_length(names)
	{
		var local = map[$ names[i++]];
		var num = local[CM_LIST.SIZE] - CM_LIST.NUM;
		array_copy(region, size, local, CM_LIST.NUM, num);
		size += num;
	}
	region[CM_LIST.SIZE] = array_unique_ext(region, 0, size);
	cm_list_debug_bake(region, vbuff, matrix, mask, hrep, vrep, color, alpha);
}