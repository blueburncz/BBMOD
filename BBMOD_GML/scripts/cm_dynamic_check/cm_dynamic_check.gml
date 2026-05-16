/*
	This function displaces the collider out of the give shape.
*/

function cm_dynamic_check(dynamic, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_DYNAMIC_GROUP) == 0){return false;}
	if (CM_RECURSION >= CM_MAX_RECURSIONS){return false;}
	if (CM_RECURSION == 0){__cmi_collider_reset(collider);}
	
	var M = CM_DYNAMIC_M;
	var I = CM_DYNAMIC_I;
	var slope = collider[CM.SLOPE]; //This value is set to 1 in cm_displace if this is the object the collider is standing on
		
	//Transform the capsule to the local space of this dynamic
	var tempR = collider[CM.R];
	var tempH = collider[CM.H];
	cm_collider_transform(collider, I, CM_DYNAMIC_SCALE);
	
	//Make the capsule avoid this object
	++ CM_RECURSION;
	var check = cm_check(CM_DYNAMIC_OBJECT, collider, mask);
	-- CM_RECURSION;
	
	//Transform the collider back to world space
	cm_collider_transform(collider, M, 1 / CM_DYNAMIC_SCALE);
	collider[@ CM.R] = tempR;
	collider[@ CM.H] = tempH;
	
	if (check)
	{
		array_push(collider[CM.COLLISIONS], CM_DYNAMIC_OBJECT);
	}
		
	//Return whether or not there was a collision
	return check;
} 