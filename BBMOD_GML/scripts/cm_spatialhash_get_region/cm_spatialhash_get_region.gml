function cm_spatialhash_get_region(spatialhash, AABB)
{
	static region = cm_list();
	var map = CM_SPATIALHASH_MAP;
	var aabb = CM_SPATIALHASH_AABB;
	if (is_undefined(aabb))
	{
		region[CM_LIST.SIZE] = CM_LIST.NUM;
		return region;
	}
	var regionsize = CM_SPATIALHASH_REGIONSIZE;
	var x0 = floor(max(AABB[0], aabb[0]) / regionsize);
	var y0 = floor(max(AABB[1], aabb[1]) / regionsize);
	var z0 = floor(max(AABB[2], aabb[2]) / regionsize);
	var x1 = floor(min(AABB[3], aabb[3]) / regionsize);
	var y1 = floor(min(AABB[4], aabb[4]) / regionsize);
	var z1 = floor(min(AABB[5], aabb[5]) / regionsize);
	for (var xx = x0; xx <= x1; ++xx)
	{
		for (var yy = y0; yy <= y1; ++yy)
		{
			for (var zz = z0; zz <= z1; ++zz)
			{
				var key = __cmi_spatialhash_get_key(xx, yy, zz);
				var list = map[$ key];
				if (is_array(list))
				{
					cm_list_add(region, list);
				}
			}
		}
	}
	region[CM_LIST.SIZE] = array_unique_ext(region, 0, region[CM_LIST.SIZE]);
	return region;
}