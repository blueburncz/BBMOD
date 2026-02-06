function cm_capsule_cast_ray(capsule, ray, mask = ray[CM_RAY.MASK])
{
	/*
		Source:
		Inigo Quilez, 2016
		https://www.shadertoy.com/view/Xt3SzX
	*/
	if (mask != 0 && (mask & CM_CAPSULE_GROUP) == 0){return ray;}
	
	var x1 = CM_CAPSULE_X1;
	var y1 = CM_CAPSULE_Y1;
	var z1 = CM_CAPSULE_Z1;
	var x2 = CM_CAPSULE_X2;
	var y2 = CM_CAPSULE_Y2;
	var z2 = CM_CAPSULE_Z2;
	var R  = CM_CAPSULE_R;
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
	var i = baoa + t * bard;
	if (i <= 0 || i >= baba)
	{
		//caps
		var ocx = (i <= 0) ? oax : rox - x2;
		var ocy = (i <= 0) ? oay : roy - y2;
		var ocz = (i <= 0) ? oaz : roz - z2;
		b = dot_product_3d(rdx, rdy, rdz, ocx, ocy, ocz);
		c = dot_product_3d(ocx, ocy, ocz, ocx, ocy, ocz) - R * R;
		h = b * b - rdrd * c;
		if (h < 0) return ray;
		t = (- b - sqrt(h)) / rdrd;
	}
	if (t < 0 || t > ray[CM_RAY.T]){return ray;}
	
	var itsX = rox + rdx * t;
	var itsY = roy + rdy * t;
	var itsZ = roz + rdz * t;
	var n = clamp(dot_product_3d(itsX - x1, itsY - y1, itsZ - z1, bax, bay, baz) / baba, 0, 1);
	
	ray[@ CM_RAY.T] = t;
	ray[@ CM_RAY.HIT] = true;
	ray[@ CM_RAY.X] = itsX;
	ray[@ CM_RAY.Y] = itsY;
	ray[@ CM_RAY.Z] = itsZ;
	ray[@ CM_RAY.NX] = (itsX - lerp(x1, x2, n)) / R;
	ray[@ CM_RAY.NY] = (itsY - lerp(y1, y2, n)) / R;
	ray[@ CM_RAY.NZ] = (itsZ - lerp(z1, z2, n)) / R;
	ray[@ CM_RAY.OBJECT] = capsule;
	return ray;
}