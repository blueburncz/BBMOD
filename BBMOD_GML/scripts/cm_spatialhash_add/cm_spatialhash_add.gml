function cm_spatialhash_add(spatialhash, object)
{
	//If the object is an object list (which is what's created when loading a mesh), add each element individually
	if (object[CM_TYPE] == CM_OBJECTS.LIST)
	{
		for (var i = CM_LIST.NUM; i < object[CM_LIST.SIZE]; ++ i)
		{
			if (!is_array(object[i])){continue;}
			cm_spatialhash_add(spatialhash, object[i]);
		}
		return object;
	}
	var map = CM_SPATIALHASH_MAP;
	var rsize = CM_SPATIALHASH_REGIONSIZE;
	var aabb = cm_get_aabb(object);
	var x0 = floor(aabb[0] / rsize);
	var y0 = floor(aabb[1] / rsize);
	var z0 = floor(aabb[2] / rsize);
	var x1 = floor(aabb[3] / rsize);
	var y1 = floor(aabb[4] / rsize);
	var z1 = floor(aabb[5] / rsize);
	for (var xx = x0; xx <= x1; ++xx)
	{
		for (var yy = y0; yy <= y1; ++yy)
		{
			for (var zz = z0; zz <= z1; ++zz)
			{
				//if (!cm_intersects_cube(object, rsize * .5, (xx + .5) * rsize, (yy + .5) * rsize, (zz + .5) * rsize)) continue;
				var key = __cmi_spatialhash_get_key(xx, yy, zz);
				var region = map[$ key];
				if (is_undefined(region))
				{
					region = cm_list();
					map[$ key] = region;
				}
				if (array_contains(region, object)) continue;
				cm_list_add(region, object);
			}
		}
	}
	__cmi_spatialhash_update_aabb(spatialhash, object);
	return object;
}