/*
	This function displaces the collider out of the give shape.
*/

function cm_list_displace(list, collider, mask = collider[CM.MASK])
{
	if (CM_RECURSION == 0)
	{
		//Only reset the collider for the first recursive call
		__cmi_collider_reset(collider);
		collider[@ CM.REGION] = list;
	}
		
	//Exit the script if we've reached the recursion limit
	if (CM_RECURSION >= CM_MAX_RECURSIONS) return false;
	
	//Get info from the collider
	var precision = collider[CM.PRECISION];
	var collisions = collider[CM.COLLISIONS];
		
	//Each recursive layer needs a separate priority structure for sorting collision shapes
	var P = CM_PRIORITY[CM_RECURSION];
	if (P < 0 && precision > 0)
	{	
		//We need a separate ds_priority for each recursive level, otherwise they'll mess with each other
		P = ds_priority_create();
		CM_PRIORITY[CM_RECURSION] = P;
	}
		
	//If we're doing fast collision checking, the collisions are done on a first-come-first-serve basis. 
	//Fast collisions will also not save anything to the delta matrix queue
	++ CM_RECURSION;
	for (var i = CM_LIST.NUM; i < list[CM_LIST.SIZE]; ++i)
	{
		var object = list[i];
		
		if (precision == 0)
		{
			if (CM_DISPLACE(object, collider, mask))
			{
				array_push(collisions, object);
			}
		}
		else
		{
			var pri = CM_GET_PRIORITY(object, collider, mask);
			if (pri >= 0)
			{
				ds_priority_add(P, object, pri);
			}
		}
	}
	-- CM_RECURSION;
	if (precision == 0) return collider[CM.COLLISION];
	
	var colNum = ds_priority_size(P);
	
	if (colNum == 0) return collider[CM.COLLISION];
	
	if (colNum == 1)
	{
		var object = ds_priority_delete_min(P);
		++ CM_RECURSION;
		if (CM_DISPLACE(object, collider, mask))
		{
			array_push(collisions, object);
		}
		-- CM_RECURSION;
		return collider[CM.COLLISION];
	}
	
	var colOrder = array_create(colNum);
	var i = colNum;
	repeat (colNum)
	{
		colOrder[--i] = ds_priority_delete_min(P);
	}
	var rep = 0;
	++ CM_RECURSION;
	repeat (precision)
	{
		var i = colNum;
		var col = 0;
		repeat (colNum)
		{
			//Second pass, collide with the nearby shapes, starting with the closest one
			var object = colOrder[--i];
			if (CM_DISPLACE(object, collider, mask))
			{
				++col;
				if (rep == 0)
				{
					array_push(collisions, object);
				}
			}
		}
		++ rep;
		if (col <= 1){break;}
	}
	-- CM_RECURSION;
		
	return collider[CM.COLLISION];
}