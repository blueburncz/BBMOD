function cm_torus_cast_ray(torus, ray, mask = ray[CM_RAY.MASK])
{
	/*
		This is an approximation using the same principle as ray marching
	*/
	if (mask != 0 && (mask & CM_TORUS_GROUP) == 0){return ray;}
	
	var repetitions = 14;
	
	var X = CM_TORUS_X;
	var Y = CM_TORUS_Y;
	var Z = CM_TORUS_Z;
	var rayx = ray[CM_RAY.X1];
	var rayy = ray[CM_RAY.Y1];
	var rayz = ray[CM_RAY.Z1];
	var x1 = rayx - X;
	var y1 = rayy - Y;
	var z1 = rayz - Z;
	var dx = ray[CM_RAY.X2] - rayx;
	var dy = ray[CM_RAY.Y2] - rayy;
	var dz = ray[CM_RAY.Z2] - rayz;
	var nx = CM_TORUS_NX;
	var ny = CM_TORUS_NY;
	var nz = CM_TORUS_NZ;
	var R = CM_TORUS_BIGRADIUS;
	
	static __x = 1;
	static __y = sqrt(2);
	static __z = pi;
	var sx = ny * __z - nz * __y;
	var sy = nz * __x - nx * __z;
	var sz = nx * __y - ny * __x;
	var s = point_distance_3d(0, 0, 0, sx, sy, sz);
	sx /= s;
	sy /= s;
	sz /= s;
	var tx = sy * nz - sz * ny;
	var ty = sz * nx - sx * nz;
	var tz = sx * ny - sy * nx;
	
	var lox = dot_product_3d(x1, y1, z1, tx, ty, tz) / R;
	var loy = dot_product_3d(x1, y1, z1, sx, sy, sz) / R;
	var loz = dot_product_3d(x1, y1, z1, nx, ny, nz) / R;
	
	var ldx = dot_product_3d(dx, dy, dz, tx, ty, tz) / R;
	var ldy = dot_product_3d(dx, dy, dz, sx, sy, sz) / R;
	var ldz = dot_product_3d(dx, dy, dz, nx, ny, nz) / R;
	
	var l = point_distance_3d(0, 0, 0, ldx, ldy, ldz);
	ldx /= l;
	ldy /= l;
	ldz /= l;
	var p = 0, n = 0, t = 0;
	var radiusRatio = CM_TORUS_SMALLRADIUS / CM_TORUS_BIGRADIUS;
	repeat repetitions 
	{
		p = n;
		n = (point_distance(0, 0, point_distance(0, 0, lox, loy) - 1, loz) - radiusRatio);
		t += n;
		if ((p > 0 && n > R) || t > l || t < 0) return ray; //The ray missed or didn't reach the torus
		lox += ldx * n;	
		loy += ldy * n;
		loz += ldz * n;
	}
	if (n > p) return ray; //If the new distance estimate is larger than the previous one, the ray must have missed a close point and is moving away from the object 
	
	t /= l;
	if (t > ray[CM_RAY.T]){return ray;}
	var itsX = lerp(ray[CM_RAY.X1], ray[CM_RAY.X2], t);
	var itsY = lerp(ray[CM_RAY.Y1], ray[CM_RAY.Y2], t);
	var itsZ = lerp(ray[CM_RAY.Z1], ray[CM_RAY.Z2], t);
	
	var ringx = itsX - X;
	var ringy = itsY - Y;
	var ringz = itsZ - Z;
	var dp = dot_product_3d(ringx, ringy, ringz, nx, ny, nz);
	ringx -= nx * dp;
	ringy -= ny * dp;
	ringz -= nz * dp;
	var l = point_distance_3d(ringx, ringy, ringz, 0, 0, 0);
	
	if (l == 0) return ray;
	var _d = R / l;
	ringx = X + ringx * _d;
	ringy = Y + ringy * _d;
	ringz = Z + ringz * _d;
	
	var n = point_distance_3d(itsX, itsY, itsZ, ringx, ringy, ringz);
	if (n == 0) return ray;
	
	ray[@ CM_RAY.T] = t;
	ray[@ CM_RAY.HIT] = true;
	ray[@ CM_RAY.X] = itsX;
	ray[@ CM_RAY.Y] = itsY;
	ray[@ CM_RAY.Z] = itsZ;
	ray[@ CM_RAY.NX] = (itsX - ringx) / n;
	ray[@ CM_RAY.NY] = (itsY - ringy) / n;
	ray[@ CM_RAY.NZ] = (itsZ - ringz) / n;
	ray[@ CM_RAY.OBJECT] = torus;
	return ray;
}