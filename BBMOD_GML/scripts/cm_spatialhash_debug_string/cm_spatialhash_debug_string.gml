function cm_spatialhash_debug_string(spatialhash)
{
	return $"[Spatial hash: Region size: {CM_SPATIALHASH_REGIONSIZE}, Regions: {struct_names_count(CM_SPATIALHASH_MAP)}, AABB: {CM_SPATIALHASH_AABB}]";
}