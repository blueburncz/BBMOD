function __cmi_box_get_priority(box, collider, mask = collider[CM.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns -1 if the shape is too far away
		Returns the square of the distance between the shape and the given point
	*/
	if (mask != 0 && (mask & CM_BOX_GROUP) == 0){return -1;}
	
	var M = CM_BOX_M;
	var I = CM_BOX_I;
	//Read collider array
	var X = collider[CM.X];
	var Y = collider[CM.Y];
	var Z = collider[CM.Z];
	var radius = collider[CM.R];
	var height = collider[CM.H];
	
	if (height == 0)
	{
		var maxR = radius * CM_FIRST_PASS_RADIUS;
		
		//Find normalized block space position
		var b = matrix_transform_vertex(I, X, Y, Z);
		if (max(abs(b[0]), abs(b[1]), abs(b[2])) <= 1) return 0; //0 is the highest possible priority
	
		//Nearest point on the cube in normalized block space
		var p = matrix_transform_vertex(M, clamp(b[0], -1, 1), clamp(b[1], -1, 1), clamp(b[2], -1, 1));
		var d = point_distance_3d(X, Y, Z, p[0], p[1], p[2]);
		if (d > maxR) return -1; //The sphere is  too far away
		return d * d;
	}
	
	var xup = collider[CM.XUP];
	var yup = collider[CM.YUP];
	var zup = collider[CM.ZUP];
	var maxR = height * .25 + radius * CM_FIRST_PASS_RADIUS;
		
	//Check middle of capsule
	var b = matrix_transform_vertex(I, X + xup * height * .5, Y + yup * height * .5, Z + zup * height * .5);
	if (max(abs(b[0]), abs(b[1]), abs(b[2])) <= 1) return 0; //0 is the highest possible priority
	
	var p = matrix_transform_vertex(M, clamp(b[0], -1, 1), clamp(b[1], -1, 1), clamp(b[2], -1, 1));
	var d = clamp(dot_product_3d(p[0] - X, p[1] - Y, p[2] - Z, xup, yup, zup), 0, height);
	var distSqr = CM_SQR(X + xup * d - p[0], Y + yup * d - p[1], Z + zup * d - p[2]);
	if (distSqr >= maxR * maxR) return -1;
	return distSqr;
}