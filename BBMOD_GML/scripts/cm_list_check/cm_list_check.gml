/*
	This function displaces the collider out of the give shape.
*/

function cm_list_check(list, collider, mask = collider[CM.MASK])
{
	if (CM_RECURSION >= CM_MAX_RECURSIONS)
	{
		//Exit the script if we've reached the recursion limit
		return false;
	}
	
	if (CM_RECURSION == 0)
	{
		//Only reset the collider for the first recursive call
		array_resize(collider[CM.COLLISIONS], 0);
	}
	
	//Get info from the collider
	var collisions = collider[CM.COLLISIONS];
		
	//If we're doing fast collision checking, the collisions are done on a first-come-first-serve basis. 
	//Fast collisions will also not save anything to the delta matrix queue
	++CM_RECURSION;
	for (var i = CM_LIST.NUM; i < list[CM_LIST.SIZE]; ++i)
	{
		var object = list[i];
		if (CM_CHECK(object, collider, mask))
		{
			array_push(collisions, object);
		}
	}
	--CM_RECURSION;
		
	return array_length(collisions);
}