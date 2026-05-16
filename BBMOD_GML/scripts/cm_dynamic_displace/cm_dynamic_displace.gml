/*
	This function displaces the collider out of the give shape.
*/

function cm_dynamic_displace(dynamic, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_DYNAMIC_GROUP) == 0){return false;}
	if (CM_RECURSION >= CM_MAX_RECURSIONS){return false;}
	
	var M = CM_DYNAMIC_M;
	var I = CM_DYNAMIC_I;
	var slope = collider[CM.SLOPE]; //This value is set to 1 in cm_displace if this is the object the collider is standing on
		
	//Transform the capsule to the local space of this dynamic
	var tempR = collider[CM.R];
	var tempH = collider[CM.H];
	cm_collider_transform(collider, I, CM_DYNAMIC_SCALE);
	
	//Make the capsule avoid this object
	++ CM_RECURSION;
	var col = cm_displace(CM_DYNAMIC_OBJECT, collider, mask);
	-- CM_RECURSION;
	
	//Transform the collider back to world space
	cm_collider_transform(collider, M, 1 / CM_DYNAMIC_SCALE);
	collider[@ CM.R] = tempR;
	collider[@ CM.H] = tempH;
	
	if (col && slope < 1 && collider[CM.SLOPE] == 1)
	{
		var transformations = collider[CM.TRANSFORMATIONS];
		if (CM_DYNAMIC_MOVING)
		{
			//This object is moving. Save its current world matrix and the inverse of the previous 
			//world matrix so that figuring out the delta matrix later is as easy as a matrix multiplication
			array_push(transformations, M);
			array_push(transformations, CM_DYNAMIC_P);
		}
		//If the transformation queue is empty, this is the first dynamic to be added. 
		//If it's static as well, there's no point in adding it to the transformation queue
		else if (array_length(transformations) > 0)
		{
			//If the dynamic is not marked as "moving", save the current inverse matrix to the transformation 
			//queue so that no transformation is done. It will then only transform the preceding transformations
			//into its own frame of reference
			array_push(transformations, M);
			array_push(transformations, I);
		}
	}
		
	//Return whether or not there was a collision
	return col;
} 