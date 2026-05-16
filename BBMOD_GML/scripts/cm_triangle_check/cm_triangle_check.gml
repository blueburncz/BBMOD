/*
	This function displaces the collider out of the give shape.
*/

function cm_triangle_check(triangle, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_TRIANGLE_GROUP) == 0){return false;}
	var height = collider[CM.H];
	if (height == 0)
	{
		return __cmi_triangle_check_sphere(triangle, collider, mask);
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
				return true;
			}
		}
	}
	var a = clamp(dot_product_3d(ex, ey, ez, tx, ty, tz) / e, 0, 1);
	if point_distance_3d(tx, ty, tz, ex * a, ey * a, ez * a) <= radius
	{
		return true;
	}
	return false;
}