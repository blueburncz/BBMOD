function cm_list_debug_draw_wireframe(list, tex = -1, color = c_teal, alpha = 1, mask = 0)
{
	for (var i = CM_LIST.NUM; i < list[CM_LIST.SIZE]; ++i)
	{
		cm_debug_draw_wireframe(list[i], tex, color, alpha, mask);
	}
}