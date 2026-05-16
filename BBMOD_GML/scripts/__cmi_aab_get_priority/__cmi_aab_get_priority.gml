function __cmi_aab_get_priority(aab, collider, mask = collider[CM.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns -1 if the shape is too far away
		Returns the square of the distance between the shape and the given point
	*/
	if (mask != 0 && (mask & CM_AAB_GROUP) == 0){return -1;}
	
	//Read collider array
	var X = collider[CM.X];
	var Y = collider[CM.Y];
	var Z = collider[CM.Z];
	var radius = collider[CM.R];
	var height = collider[CM.H];
	
	var cx = CM_AAB_X;
	var cy = CM_AAB_Y;
	var cz = CM_AAB_Z;
	var halfX = CM_AAB_HALFX;
	var halfY = CM_AAB_HALFY;
	var halfZ = CM_AAB_HALFZ;
	
	if (height == 0)
	{
		var maxR = radius * CM_FIRST_PASS_RADIUS;
		
		//Find normalized block space position
		var bx = (X - cx) / halfX;
		var by = (Y - cy) / halfY;
		var bz = (Z - cz) / halfZ;
		if (max(abs(bx), abs(by), abs(bz)) <= 1) return 0; //0 is the highest possible priority
	
		//Nearest point on the cube in normalized block space
		var px = cx + clamp(bx, -1, 1) * halfX;
		var py = cy + clamp(by, -1, 1) * halfY;
		var pz = cz + clamp(bz, -1, 1) * halfZ;
		var d = point_distance_3d(X, Y, Z, px, py, pz);
		if (d > maxR) return -1; //The sphere is  too far away
		return d * d;
	}
	
	var xup = collider[CM.XUP];
	var yup = collider[CM.YUP];
	var zup = collider[CM.ZUP];
	var maxR = height * .25 + radius * CM_FIRST_PASS_RADIUS;
		
	//Check middle of capsule
	var bx = (X + xup * .5 - cx) / halfX;
	var by = (Y + yup * .5 - cy) / halfY;
	var bz = (Z + zup * .5 - cz) / halfZ;
	if (max(abs(bx), abs(by), abs(bz)) <= 1) return 0; //0 is the highest possible priority
	
	//Nearest point on the cube in normalized block space
	var px = cx + clamp(bx, -1, 1) * halfX;
	var py = cy + clamp(by, -1, 1) * halfY;
	var pz = cz + clamp(bz, -1, 1) * halfZ;
	var d = clamp(dot_product_3d(px - X, py - Y, pz - Z, xup, yup, zup), 0, height);
	var distSqr = CM_SQR(X + xup * d - px, Y + yup * d - py, Z + zup * d - pz);
	if (distSqr >= maxR * maxR) return -1;
	return distSqr;
}