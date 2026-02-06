function __cmi_spatialhash_update_aabb(spatialhash, object)
{
	var aabb = CM_SPATIALHASH_AABB;
	var map = CM_SPATIALHASH_MAP;
	var num = struct_names_count(map);
	var mm = cm_get_aabb(object);
	if (is_undefined(aabb))
	{
		CM_SPATIALHASH_AABB = array_create(6);
		array_copy(CM_SPATIALHASH_AABB, 0, mm, 0, 6);
		return CM_SPATIALHASH_AABB;
	}
	else
	{
		aabb[@ 0] = min(mm[0], aabb[0]);
		aabb[@ 1] = min(mm[1], aabb[1]);
		aabb[@ 2] = min(mm[2], aabb[2]);
		aabb[@ 3] = max(mm[3], aabb[3]);
		aabb[@ 4] = max(mm[4], aabb[4]);
		aabb[@ 5] = max(mm[5], aabb[5]);
		return aabb;
	}
}