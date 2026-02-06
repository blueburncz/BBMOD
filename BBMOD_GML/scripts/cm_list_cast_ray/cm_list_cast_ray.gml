function cm_list_cast_ray(list, ray, mask = ray[CM_RAY.MASK])
{
	var rayCastHasBeenDone = CM_RAYMAP[CM_RECURSION];
	if (rayCastHasBeenDone < 0)
	{
		rayCastHasBeenDone = ds_map_create();
		CM_RAYMAP[CM_RECURSION] = rayCastHasBeenDone;
	}
	
	var num = CM_LIST_SIZE;
	++ CM_RECURSION;
	for (var i = CM_LIST.NUM; i < num; i ++)
	{
		var object = list[i];
		if (!is_undefined(rayCastHasBeenDone[? object])) continue;
		
		CM_CAST_RAY(object, ray, mask);
		rayCastHasBeenDone[? object] = true;
	}
	-- CM_RECURSION;
	ds_map_clear(rayCastHasBeenDone);
	return ray;
}