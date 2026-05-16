function __cmi_dynamic_get_priority(dynamic, collider, mask)
{
	if (CM_RECURSION >= CM_MAX_RECURSIONS){return -1;}
	
	var M = CM_DYNAMIC_M;
	var I = CM_DYNAMIC_I;
	var scale = CM_DYNAMIC_SCALE;
		
	//Transform the capsule to the local space of this dynamic
	var tempR = collider[CM.R];
	var tempH = collider[CM.H];
	cm_collider_transform(collider, I, scale);
	
	//Get the local priority of this object
	++ CM_RECURSION;
	var priority = cm_get_priority(CM_DYNAMIC_OBJECT, collider, mask);
	-- CM_RECURSION;
	
	//Transform the collider back to world space
	cm_collider_transform(collider, M, 1 / scale);
	collider[CM.R] = tempR;
	collider[CM.H] = tempH;
	
	return priority / (scale * scale);
}