/*
	This function displaces the collider out of the give shape.
*/

function cm_cylinder_check(cylinder, collider, mask = collider[CM.MASK])
{
	if (mask != 0 && (mask & CM_CYLINDER_GROUP) == 0){return false;}
	
	var ref = __cmi_cylinder_get_capsule_ref(cylinder, collider);
	var x1 = CM_CYLINDER_X1;
	var y1 = CM_CYLINDER_Y1;
	var z1 = CM_CYLINDER_Z1;
	var x2 = CM_CYLINDER_X2;
	var y2 = CM_CYLINDER_Y2;
	var z2 = CM_CYLINDER_Z2;
	var cx = x2 - x1;
	var cy = y2 - y1;
	var cz = z2 - z1;
	var dx = ref[0] - x1;
	var dy = ref[1] - y1;
	var dz = ref[2] - z1;
	var c = dot_product_3d(cx, cy, cz, cx, cy, cz);
	var D = clamp(dot_product_3d(dx, dy, dz, cx, cy, cz) / c, 0, 1);
	var tx = lerp(x1, x2, D);
	var ty = lerp(y1, y2, D);
	var tz = lerp(z1, z2, D);
	var dx = ref[0] - tx;
	var dy = ref[1] - ty;
	var dz = ref[2] - tz;
	var R = CM_CYLINDER_R
	var r = R + collider[CM.R];
	if (D <= 0 || D >= 1)
	{
		var dp = dot_product_3d(dx, dy, dz, cx, cy, cz) / c;
		dx -= cx * dp;
		dy -= cy * dp;
		dz -= cz * dp;
		var d = dot_product_3d(dx, dy, dz, dx, dy, dz);
		if (d > R * R)
		{
			var _d = R / sqrt(d);
			dx *= _d;
			dy *= _d;
			dz *= _d;
		}
		dx = ref[0] - tx - dx;
		dy = ref[1] - ty - dy;
		dz = ref[2] - tz - dz;
		r = collider[CM.R];
	}
		
	if (point_distance_3d(dx, dy, dz, 0, 0, 0) >= r) return false;
	
	return true;
}