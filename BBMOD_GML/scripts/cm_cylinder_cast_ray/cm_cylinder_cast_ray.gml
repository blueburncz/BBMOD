function cm_cylinder_cast_ray(cylinder, ray, mask = ray[CM_RAY.MASK])
{
	/*
		Source:
		Inigo Quilez, 2016
		https://www.shadertoy.com/view/4lcSRn
	*/
	if (mask != 0 && (mask & CM_CYLINDER_GROUP) == 0){return ray;}
	
	var x1 = CM_CYLINDER_X1;
	var y1 = CM_CYLINDER_Y1;
	var z1 = CM_CYLINDER_Z1;
	var x2 = CM_CYLINDER_X2;
	var y2 = CM_CYLINDER_Y2;
	var z2 = CM_CYLINDER_Z2;
	var R  = CM_CYLINDER_R;
	var rox = ray[CM_RAY.X1];
	var roy = ray[CM_RAY.Y1];
	var roz = ray[CM_RAY.Z1];
	var rdx = ray[CM_RAY.X2] - rox;
	var rdy = ray[CM_RAY.Y2] - roy;
	var rdz = ray[CM_RAY.Z2] - roz;
	var bax = x2 - x1;
	var bay = y2 - y1;
	var baz = z2 - z1;
	var oax = rox - x1;
	var oay = roy - y1;
	var oaz = roz - z1;
	var baba = dot_product_3d(bax, bay, baz, bax, bay, baz);
	var bard = dot_product_3d(bax, bay, baz, rdx, rdy, rdz);
	var baoa = dot_product_3d(bax, bay, baz, oax, oay, oaz);
	var rdrd = dot_product_3d(rdx, rdy, rdz, rdx, rdy, rdz);
	var rdoa = dot_product_3d(rdx, rdy, rdz, oax, oay, oaz);
	var oaoa = dot_product_3d(oax, oay, oaz, oax, oay, oaz);
	var a = baba * rdrd - bard * bard;
	var b = baba * rdoa - baoa * bard;
	var c = baba * oaoa - baoa * baoa - R * R * baba;
	var h = b * b - a * c;
	
	if (h < 0) return ray;
	
	h = sqrt(h);
	var t = - (b + h) / a;
	var l = baoa + t * bard;
	if (t >= 0 && t <= ray[CM_RAY.T] && l > 0 && l < baba)
	{
		//Body
		var itsX = rox + rdx * t;
		var itsY = roy + rdy * t;
		var itsZ = roz + rdz * t;
		var n = clamp(dot_product_3d(itsX - x1, itsY - y1, itsZ - z1, bax, bay, baz) / baba, 0, 1);
	
		ray[@ CM_RAY.T] = t;
		ray[@ CM_RAY.HIT] = true;
		ray[@ CM_RAY.X] = itsX;
		ray[@ CM_RAY.Y] = itsY;
		ray[@ CM_RAY.Z] = itsZ;
		ray[@ CM_RAY.NX] = (oax + t * rdx - bax * l / baba) / R;
		ray[@ CM_RAY.NY] = (oay + t * rdy - bay * l / baba) / R;
		ray[@ CM_RAY.NZ] = (oaz + t * rdz - baz * l / baba) / R;
		ray[@ CM_RAY.OBJECT] = cylinder;
	}
	else
	{
		//Caps
		t = (((l < 0) ? 0 : baba) - baoa) / bard;
		if (t >= 0 && t <= ray[CM_RAY.T] && abs(b + a * t) < h)
		{
			var ba = sign(l) / sqrt(baba);
			ray[@ CM_RAY.T] = t;
			ray[@ CM_RAY.HIT] = true;
			ray[@ CM_RAY.X] = rox + rdx * t;
			ray[@ CM_RAY.Y] = roy + rdy * t;
			ray[@ CM_RAY.Z] = roz + rdz * t;
			ray[@ CM_RAY.NX] = bax * ba;
			ray[@ CM_RAY.NY] = bay * ba;
			ray[@ CM_RAY.NZ] = baz * ba;
			ray[@ CM_RAY.OBJECT] = cylinder;
		}
	}

	return ray;
}