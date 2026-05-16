function cm_spatialhash_debug_draw(spatialhash, tex = -1, color = -1, alpha = 1, mask = 0)
{
	static region = cm_list();
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
	cm_list_debug_draw(region, tex, color, alpha, mask);
}