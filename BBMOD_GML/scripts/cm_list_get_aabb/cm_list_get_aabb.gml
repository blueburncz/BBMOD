function cm_list_get_aabb(list)
{
	var AABB = array_create(6, 0);
	for (var i = CM_LIST.NUM; i < list[CM_LIST.SIZE]; ++i)
	{
		var aabb = cm_get_aabb(list[i]);
		if (i == CM_LIST.NUM)
		{
			AABB = aabb;
		}
		else
		{
			AABB[0] = min(AABB[0], aabb[0]);
			AABB[1] = min(AABB[1], aabb[1]);
			AABB[2] = min(AABB[2], aabb[2]);
			AABB[3] = max(AABB[3], aabb[3]);
			AABB[4] = max(AABB[4], aabb[4]);
			AABB[5] = max(AABB[5], aabb[5]);
		}
	}
	return AABB;
}