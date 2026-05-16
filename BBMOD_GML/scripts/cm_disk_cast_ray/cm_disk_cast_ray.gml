function cm_disk_cast_ray(disk, ray, mask = ray[CM_RAY.MASK])
{
	/*
		This is an approximation using the same principle as ray marching
	*/
	if (mask != 0 && (mask & CM_DISK_GROUP) == 0){return ray;}
	
	var repetitions = 14;
	
	var X = CM_DISK_X;
	var Y = CM_DISK_Y;
	var Z = CM_DISK_Z;
	var rayx = ray[CM_RAY.X1];
	var rayy = ray[CM_RAY.Y1];
	var rayz = ray[CM_RAY.Z1];
	var x1 = rayx - X;
	var y1 = rayy - Y;
	var z1 = rayz - Z;
	var dx = ray[CM_RAY.X2] - rayx;
	var dy = ray[CM_RAY.Y2] - rayy;
	var dz = ray[CM_RAY.Z2] - rayz;
	var nx = CM_DISK_NX;
	var ny = CM_DISK_NY;
	var nz = CM_DISK_NZ;
	var r = CM_DISK_SMALLRADIUS;
	var R = CM_DISK_BIGRADIUS;
	
	var sx = ny * z1 - nz * y1;
	var sy = nz * x1 - nx * z1;
	var sz = nx * y1 - ny * x1;
	var s = point_distance_3d(0, 0, 0, sx, sy, sz);
	sx /= s;
	sy /= s;
	sz /= s;
	var tx = sy * nz - sz * ny;
	var ty = sz * nx - sx * nz;
	var tz = sx * ny - sy * nx;
	
	var lox = dot_product_3d(x1, y1, z1, tx, ty, tz) / R;
	var loy = 0; //Per definition
	var loz = dot_product_3d(x1, y1, z1, nx, ny, nz) / R;
	
	var ldx = dot_product_3d(dx, dy, dz, tx, ty, tz) / R;
	var ldy = dot_product_3d(dx, dy, dz, sx, sy, sz) / R;
	var ldz = dot_product_3d(dx, dy, dz, nx, ny, nz) / R;
	
	var l = point_distance_3d(0, 0, 0, ldx, ldy, ldz);
	ldx /= l;
	ldy /= l;
	ldz /= l;
	var p = 0, n = 0, t = 0;
	var radiusRatio = r / R;
	repeat repetitions 
	{
		p = n;
		n = (point_distance(0, 0, max(0, point_distance(0, 0, lox, loy) - 1), loz) - radiusRatio);
		t += n;
		if ((p > 0 && n > R) || t > l || t < 0) return ray; //The ray missed or didn't reach the disk
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
	
	var diskx = itsX - X;
	var disky = itsY - Y;
	var diskz = itsZ - Z;
	var dp = dot_product_3d(diskx, disky, diskz, nx, ny, nz);
	diskx -= nx * dp;
	disky -= ny * dp;
	diskz -= nz * dp;
	var l = point_distance_3d(diskx, disky, diskz, 0, 0, 0);
	
	if (l == 0) return ray;
	var _d = min(R, l) / l;
	diskx = X + diskx * _d;
	disky = Y + disky * _d;
	diskz = Z + diskz * _d;
	
	var n = point_distance_3d(itsX, itsY, itsZ, diskx, disky, diskz);
	if (n == 0) return ray;
	
	ray[@ CM_RAY.T] = t;
	ray[@ CM_RAY.HIT] = true;
	ray[@ CM_RAY.X] = itsX;
	ray[@ CM_RAY.Y] = itsY;
	ray[@ CM_RAY.Z] = itsZ;
	ray[@ CM_RAY.NX] = (itsX - diskx) / n;
	ray[@ CM_RAY.NY] = (itsY - disky) / n;
	ray[@ CM_RAY.NZ] = (itsZ - diskz) / n;
	ray[@ CM_RAY.OBJECT] = disk;
	return ray;
}