function __cmi_triangle_displace_sphere(triangle, collider, mask = collider[CM.MASK])
{
	/*
		This is a slightly more optimized version of the displace function, which removes some of the calculations needed for
		colliding with a capsule when the capsule's height is zero. It also offsets the reading of the triangle array to
		later in the function when it's needed instead of up front, potentially skipping several array reads when colliding
		with a mesh.
	*/
	//Read collider array
	var X = collider[CM.X];
	var Y = collider[CM.Y];
	var Z = collider[CM.Z];
	var radius = collider[CM.R];
	
	//Read triangle array
	var v1x = CM_TRIANGLE_X1;
	var v1y = CM_TRIANGLE_Y1;
	var v1z = CM_TRIANGLE_Z1;
	var nx  = CM_TRIANGLE_NX;
	var ny  = CM_TRIANGLE_NY;
	var nz  = CM_TRIANGLE_NZ;
	
	//Check triangle plane for a potential early exit
	var tx = X - v1x, ty = Y - v1y, tz = Z - v1z;
	var D = dot_product_3d(tx, ty, tz, nx, ny, nz);
	if (abs(D) > radius) return false;
	
	var v2x = CM_TRIANGLE_X2;
	var v2y = CM_TRIANGLE_Y2;
	var v2z = CM_TRIANGLE_Z2;
	var ex = v2x - v1x, ey = v2y - v1y, ez = v2z - v1z;
	
	var type = CM_TRIANGLE_TYPE;
	if (type == CM_OBJECTS.SMDSTRIANGLE || type == CM_OBJECTS.SMSSTRIANGLE)
	{
		//Check first edge
		var n1, n2, n3;
		n1 = CM_TRIANGLE_N1;
		n2 = CM_TRIANGLE_N2;
		var w1 = dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz);
		if (w1 > 0)
		{	
			//Check second edge
			var v3x = CM_TRIANGLE_X3;
			var v3y = CM_TRIANGLE_Y3;
			var v3z = CM_TRIANGLE_Z3;
			n1 = CM_TRIANGLE_N2;
			n2 = CM_TRIANGLE_N3;
			tx = X - v2x; ty = Y - v2y; tz = Z - v2z;
			ex = v3x - v2x; ey = v3y - v2y; ez = v3z - v2z;
			var w2 = dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz);
			if (w2 > 0)
			{	
				//Check third edge
				n1 = CM_TRIANGLE_N3;
				n2 = CM_TRIANGLE_N1;
				tx = X - v2x; ty = Y - v2y; tz = Z - v2z;
				ex = v3x - v2x; ey = v3y - v2y; ez = v3z - v2z;
				var w3 = dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz);
				if (w3 > 0)
				{
					var sum = w1 + w2 + w3;
					w1 = w1 / sum;
					w2 = w2 / sum;
					w3 = w3 / sum;
					n3 = CM_TRIANGLE_N2;
					var smoothnx = dot_product_3d(n1[0], n2[0], n3[0], w1, w2, w3);
					var smoothny = dot_product_3d(n1[1], n2[1], n3[1], w1, w2, w3);
					var smoothnz = dot_product_3d(n1[2], n2[2], n3[2], w1, w2, w3);
				
					var s = (radius - D) / dot_product_3d(nx, ny, nz, smoothnx, smoothny, smoothnz);
					return __cmi_collider_displace(collider, smoothnx * s, smoothny * s, smoothnz * s);
				}
			}
		}
		var a = clamp(dot_product_3d(ex, ey, ez, tx, ty, tz) / dot_product_3d(ex, ey, ez, ex, ey, ez), 0, 1);
		var d = point_distance_3d(tx, ty, tz, ex * a, ey * a, ez * a);
		if (d == 0 || d >= radius) return false;
		var smoothnx = lerp(n1[0], n2[0], a);
		var smoothny = lerp(n1[1], n2[1], a);
		var smoothnz = lerp(n1[2], n2[2], a);
		var s = (radius - d) / dot_product_3d(nx, ny, nz, smoothnx, smoothny, smoothnz);
		return __cmi_collider_displace(collider, smoothnx * s, smoothny * s, smoothnz * s);
	}
	else
	{
		//Check first edge
		if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
		{	
			//Check second edge
			var v3x = CM_TRIANGLE_X3;
			var v3y = CM_TRIANGLE_Y3;
			var v3z = CM_TRIANGLE_Z3;
			tx = X - v2x; ty = Y - v2y; tz = Z - v2z;
			ex = v3x - v2x; ey = v3y - v2y; ez = v3z - v2z;
			if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
			{	
				//Check third edge
				tx = X - v3x; ty = Y - v3y; tz = Z - v3z;
				ex = v1x - v3x; ey = v1y - v3y; ez = v1z - v3z;
				if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
				{
					var singlesided = (type == CM_OBJECTS.FLSSTRIANGLE || type == CM_OBJECTS.SMSSTRIANGLE);
					var s = (D == 0) ? radius : (singlesided ? radius - D : sign(D) * (radius - abs(D)));
					return __cmi_collider_displace(collider, nx * s, ny * s, nz * s);
				}
			}
		}
		var a = clamp(dot_product_3d(ex, ey, ez, tx, ty, tz) / dot_product_3d(ex, ey, ez, ex, ey, ez), 0, 1);
		nx = tx - ex * a; 
		ny = ty - ey * a;
		nz = tz - ez * a;
		var d = point_distance_3d(0, 0, 0, nx, ny, nz);
		if (d == 0 || d >= radius) return false;
		d = radius / d - 1;
		return __cmi_collider_displace(collider, nx * d, ny * d, nz * d);
	}
}