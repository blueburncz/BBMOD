/*
	This function displaces the collider out of the give shape.
*/

function cm_box_displace(box, collider, mask = collider[CM.MASK])
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
	var b = max(abs(bx), abs(by), abs(bz));
	var nx, ny, nz;
	//If the center of the sphere is inside the cube, normalize the largest axis
	if (b <= 1)
	{
		if (b == abs(bx))
		{
			bx = sign(bx);
			var n = point_distance_3d(0, 0, 0, M[0], M[1], M[2]);
			nx = M[0] / n;
			ny = M[1] / n;
			nz = M[2] / n;
		}
		else if (b == abs(by))
		{
			by = sign(by);
			var n = point_distance_3d(0, 0, 0, M[4], M[5], M[6]);
			nx = M[4] / n;
			ny = M[5] / n;
			nz = M[6] / n;
		}
		else
		{
			bz = sign(bz);
			var n = point_distance_3d(0, 0, 0, M[8], M[9], M[10]);
			nx = M[8] / n;
			ny = M[9] / n;
			nz = M[10] / n;
		}
		var p = matrix_transform_vertex(M, bx, by, bz);
		var d = radius - dot_product_3d(refX - p[0], refY - p[1], refZ - p[2], nx, ny, nz);
		return __cmi_collider_displace(collider, nx * d, ny * d, nz * d);
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
	var d = point_distance_3d(dx, dy, dz, 0, 0, 0);
	if (d == 0 || d > radius){return false;}
	d = (radius - d) / d;
	return __cmi_collider_displace(collider, dx * d, dy * d, dz * d);
}