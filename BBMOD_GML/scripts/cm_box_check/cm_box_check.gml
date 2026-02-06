/*
	This function displaces the collider out of the give shape.
*/

function cm_box_check(box, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_BOX_GROUP) == 0){return false;}
	
	var M = CM_BOX_M;
	var I = CM_BOX_I;
	var refX, refY, refZ;
	var radius = collider[CM.R];
	var height = collider[CM.H];
	if (height == 0)
	{
		refX = collider[CM.X];
		refY = collider[CM.Y];
		refZ = collider[CM.Z];
	}
	else
	{
		//Read collider array
		var X = collider[CM.X];
		var Y = collider[CM.Y];
		var Z = collider[CM.Z];
		var xup = collider[CM.XUP];
		var yup = collider[CM.YUP];
		var zup = collider[CM.ZUP];
		
		//Check bottom of capsule
		var b = matrix_transform_vertex(I, X, Y, Z);
		var p = matrix_transform_vertex(M, clamp(b[0], -1, 1), clamp(b[1], -1, 1), clamp(b[2], -1, 1));
		var d = dot_product_3d(p[0] - X, p[1] - Y, p[2] - Z, xup, yup, zup);
		d = clamp(d, 0, height);
		refX = X + xup * d;
		refY = Y + yup * d;
		refZ = Z + zup * d;
		var d1 = CM_SQR(refX - p[0], refY - p[1], refZ - p[2]);
		
		//Check top of capsule
		var b = matrix_transform_vertex(I, X + xup * height, Y + yup * height, Z + zup * height);
		var p = matrix_transform_vertex(M, clamp(b[0], -1, 1), clamp(b[1], -1, 1), clamp(b[2], -1, 1));
		var d = dot_product_3d(p[0] - X, p[1] - Y, p[2] - Z, xup, yup, zup);
		d = clamp(d, 0, height);
		var rx2 = X + xup * d;
		var ry2 = Y + yup * d;
		var rz2 = Z + zup * d;
		var d2 = CM_SQR(rx2 - p[0], ry2 - p[1], rz2 - p[2]);
		
		if (d2 < d1)
		{
			refX = rx2;
			refY = ry2;
			refZ = rz2;
		}
	}
	
	//Find normalized block space position
	var p = matrix_transform_vertex(I, refX, refY, refZ);
	var bx = p[0];
	var by = p[1];
	var bz = p[2];
	
	//If the center of the sphere is inside the cube, normalize the largest axis
	if (max(abs(bx), abs(by), abs(bz)) <= 1)
	{
		return true;
	}
	
	//Nearest point on the cube
	var p = matrix_transform_vertex(M, clamp(bx, -1, 1), clamp(by, -1, 1), clamp(bz, -1, 1));
	if (height != 0)
	{
		var d = dot_product_3d(p[0] - X, p[1] - Y, p[2] - Z, xup, yup, zup);
		d = clamp(d, 0, height);
		refX = X + xup * d;
		refY = Y + yup * d;
		refZ = Z + zup * d;
	}
	var dx = refX - p[0];
	var dy = refY - p[1];
	var dz = refZ - p[2];
	var d = point_distance_3d(refX, refY, refZ, p[0], p[1], p[2]);
	if (d > radius) return false;
	
	return true;
}