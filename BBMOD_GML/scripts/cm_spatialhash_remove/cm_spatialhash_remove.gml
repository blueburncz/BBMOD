function cm_spatialhash_remove(spatialhash, object)
{
	var map = CM_SPATIALHASH_MAP;
	var regionsize = CM_SPATIALHASH_REGIONSIZE;
	var AABB = cm_get_aabb(object);
	var x0 = floor(AABB[0] / regionsize);
	var y0 = floor(AABB[1] / regionsize);
	var z0 = floor(AABB[2] / regionsize);
	var x1 = floor(AABB[3] / regionsize);
	var y1 = floor(AABB[4] / regionsize);
	var z1 = floor(AABB[5] / regionsize);
	for (var xx = x0; xx <= x1; ++xx)
	{
		for (var yy = y0; yy <= y1; ++yy)
		{
			for (var zz = z0; zz <= z1; ++zz)
			{
				var key = __cmi_spatialhash_get_key(xx, yy, zz);
				var region = map[$ key];
				if (is_undefined(region)) continue;
				
				cm_list_remove(region, object);
				if (region[CM_LIST.SIZE] <= CM_LIST.NUM)
				{
					struct_remove(map, key);
				}
			}
		}
	}
}