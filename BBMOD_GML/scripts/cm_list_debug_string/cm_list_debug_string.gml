function cm_list_debug_string(list)
{
	var str = $"[Object list: Number: {CM_LIST_SIZE}, Contents:";
	for (var i = CM_LIST.NUM; i < list[CM_LIST.SIZE]; ++i)
	{
		var object = list[i++];
		str += "\n    " + CM_DEBUG_STRING(list[i++]);
	}
	return str + "]";
}