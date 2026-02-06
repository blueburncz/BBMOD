function cm_spatialhash_cast_ray(spatialhash, ray, mask = ray[CM_RAY.MASK])
{
	var rayCastHasBeenDone = CM_RAYMAP[CM_RECURSION];
	if (rayCastHasBeenDone < 0)
	{
		rayCastHasBeenDone = ds_map_create();
		CM_RAYMAP[CM_RECURSION] = rayCastHasBeenDone;
	}
	var map = CM_SPATIALHASH_MAP;
	var aabb = cm_spatialhash_get_aabb(spatialhash);
	var regionsize = CM_SPATIALHASH_REGIONSIZE;
	var lox = ray[CM_RAY.X1];
	var loy = ray[CM_RAY.Y1];
	var loz = ray[CM_RAY.Z1];
	var ldx = ray[CM_RAY.X2] - lox;
	var ldy = ray[CM_RAY.Y2] - loy;
	var ldz = ray[CM_RAY.Z2] - loz;
	var idx = (ldx == 0) ? 0 : 1 / ldx;
	var idy = (ldy == 0) ? 0 : 1 / ldy;
	var idz = (ldz == 0) ? 0 : 1 / ldz;
	var incx = abs(idx) + (idx == 0);
	var incy = abs(idy) + (idy == 0);
	var incz = abs(idz) + (idz == 0);
	var ox = lox / regionsize;
	var oy = loy / regionsize;
	var oz = loz / regionsize;
	var t = cm_ray_constrain(ray, aabb);
	var _t = t / regionsize;
	var currX = ox + ldx * _t;
	var currY = oy + ldy * _t;
	var currZ = oz + ldz * _t;
	var key = __cmi_spatialhash_get_key(floor(currX), floor(currY), floor(currZ));
	++ CM_RECURSION;
	while (t < 1)
	{
		if (ray[CM_RAY.T] < t) break;
		var region = map[$ key];
		
		var tMaxX = - frac(currX) * idx;
		var tMaxY = - frac(currY) * idy;
		var tMaxZ = - frac(currZ) * idz;
		if (tMaxX <= 0){tMaxX += incx;}
		if (tMaxY <= 0){tMaxY += incy;}
		if (tMaxZ <= 0){tMaxZ += incz;}
		if (tMaxX < tMaxY){
			if (tMaxX < tMaxZ){
				_t += tMaxX;
				currX = round(ox + ldx * _t);
				currY = oy + ldy * _t;
				currZ = oz + ldz * _t;
				key = __cmi_spatialhash_get_key(currX - (ldx < 0), floor(currY), floor(currZ));
			}
			else{
				_t += tMaxZ;
				currX = ox + ldx * _t;
				currY = oy + ldy * _t;
				currZ = round(oz + ldz * _t);
				key = __cmi_spatialhash_get_key(floor(currX), floor(currY), currZ - (ldz < 0));
			}
		}
		else{
			if (tMaxY < tMaxZ){
				_t += tMaxY;
				currX = ox + ldx * _t;
				currY = round(oy + ldy * _t);
				currZ = oz + ldz * _t;
				key = __cmi_spatialhash_get_key(floor(currX), currY - (ldy < 0), floor(currZ));
			}
			else{
				_t += tMaxZ;
				currX = ox + ldx * _t;
				currY = oy + ldy * _t;
				currZ = round(oz + ldz * _t);
				key = __cmi_spatialhash_get_key(floor(currX), floor(currY), currZ - (ldz < 0));
			}
		}
		
		t = min(1, _t * regionsize);
		if (is_undefined(region)) continue;
		
		//Loop through the objects in the region
		for (var i = CM_LIST.NUM; i < region[CM_LIST.SIZE]; ++i)
		{
			var object = region[i];
			if (is_undefined(rayCastHasBeenDone[? object]))
			{
				CM_CAST_RAY(object, ray, mask);
				rayCastHasBeenDone[? object] = true;
			}
		}
		if (currX * regionsize < aabb[0] || currX * regionsize > aabb[3] || currY * regionsize < aabb[1] || currY * regionsize > aabb[4] || currZ * regionsize < aabb[2] || currZ * regionsize > aabb[5])
		{
			break;
		}
	}
	-- CM_RECURSION;
	ds_map_clear(rayCastHasBeenDone);
	return ray;
}