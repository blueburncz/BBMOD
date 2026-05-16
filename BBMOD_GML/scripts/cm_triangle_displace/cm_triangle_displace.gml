/*
	This function displaces the collider out of the give shape.
*/

function cm_triangle_displace(triangle, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_TRIANGLE_GROUP) == 0){return false;}
	var height = collider[CM.H];
	if (height == 0)
	{
		return __cmi_triangle_displace_sphere(triangle, collider, mask);
	}
	
	var radius = collider[CM.R];
	
	//Do an AABB-check
	var t;
	var X = collider[CM.X];
	var xup = collider[CM.XUP];
	var v1x = CM_TRIANGLE_X1;
	var v2x = CM_TRIANGLE_X2;
	var v3x = CM_TRIANGLE_X3;
	t = X + ((xup < 0) ? xup * height : 0) - radius;
	if (t > v1x && t > v2x && t > v3x){return false;}
	t = X + ((xup > 0) ? xup * height : 0) + radius;
	if (t < v1x && t < v2x && t < v3x){return false;}
	
	var Y = collider[CM.Y];
	var yup = collider[CM.YUP];
	var v1y = CM_TRIANGLE_Y1;
	var v2y = CM_TRIANGLE_Y2;
	var v3y = CM_TRIANGLE_Y3;
	t = Y + ((yup < 0) ? yup * height : 0) - radius;
	if (t > v1y && t > v2y && t > v3y){return false;}
	t = Y + ((yup > 0) ? yup * height : 0) + radius;
	if (t < v1y && t < v2y && t < v3y){return false;}
	
	var Z = collider[CM.Z];
	var zup = collider[CM.ZUP];
	var v1z = CM_TRIANGLE_Z1;
	var v2z = CM_TRIANGLE_Z2;
	var v3z = CM_TRIANGLE_Z3
	t = Z + ((zup < 0) ? zup * height : 0) - radius;
	if (t > v1z && t > v2z && t > v3z){return false;}
	t = Z + ((zup > 0) ? zup * height : 0) + radius;
	if (t < v1z && t < v2z && t < v3z){return false;}

	var nx  = CM_TRIANGLE_NX;
	var ny  = CM_TRIANGLE_NY;
	var nz  = CM_TRIANGLE_NZ;
	CM_TRIANGLE_GET_CAPSULE_REF;
	
	//Check triangle plane for a potential early exit
	var tx = refX - v1x, ty = refY - v1y, tz = refZ - v1z;
	var D = dot_product_3d(tx, ty, tz, nx, ny, nz);
	if (abs(D) > radius) return false;
	
	var type = CM_TRIANGLE_TYPE;
	if (D > 0 && (type == CM_OBJECTS.SMDSTRIANGLE || type == CM_OBJECTS.SMSSTRIANGLE))
	{
		//Check first edge
		var n1, n2, n3;
		n1 = CM_TRIANGLE_N1;
		n2 = CM_TRIANGLE_N2;
		var e = e0, ex = e00, ey = e01, ez = e02;
		var w1 = dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz);
		if (w1 > 0)
		{	
			//Check second edge
			n1 = CM_TRIANGLE_N2;
			n2 = CM_TRIANGLE_N3;
			tx = refX - v2x; ty = refY - v2y; tz = refZ - v2z;
			e = e1; ex = e10; ey = e11; ez = e12;
			var w2 = dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz);
			if (w2 > 0)
			{	
				//Check third edge
				n1 = CM_TRIANGLE_N3;
				n2 = CM_TRIANGLE_N1;
				tx = refX - v3x; ty = refY - v3y; tz = refZ - v3z;
				e = e2; ex = e20; ey = e21; ez = e22;
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
		var a = clamp(dot_product_3d(ex, ey, ez, tx, ty, tz) / e, 0, 1);
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
		var e = e0, ex = e00, ey = e01, ez = e02;
		if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
		{	
			//Check second edge
			tx = refX - v2x; ty = refY - v2y; tz = refZ - v2z;
			e = e1; ex = e10; ey = e11; ez = e12;
			if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
			{	
				//Check third edge
				tx = refX - v3x; ty = refY - v3y; tz = refZ - v3z;
				e = e2; ex = e20; ey = e21; ez = e22;
				if (dot_product_3d(tz * ey - ty * ez, tx * ez - tz * ex, ty * ex - tx * ey, nx, ny, nz) > 0)
				{
					var s;
					if (D == 0)
					{
						s = (dp > 0) ? radius + pd / dp : radius + (height - pd) / dp;
					}
					else
					{
						var singlesided = (type == CM_OBJECTS.FLSSTRIANGLE || type == CM_OBJECTS.SMSSTRIANGLE);
						s = singlesided ? radius - D : sign(D) * (radius - abs(D));
					}
					return __cmi_collider_displace(collider, nx * s, ny * s, nz * s);
				}
			}
		}
		var a = clamp(dot_product_3d(ex, ey, ez, tx, ty, tz) / e, 0, 1);
		nx = tx - ex * a; 
		ny = ty - ey * a;
		nz = tz - ez * a;
		d = point_distance_3d(0, 0, 0, nx, ny, nz);
		if (d == 0 || d >= radius) return false;
		d = radius / d - 1;
		return __cmi_collider_displace(collider, nx * d, ny * d, nz * d);
	}
}