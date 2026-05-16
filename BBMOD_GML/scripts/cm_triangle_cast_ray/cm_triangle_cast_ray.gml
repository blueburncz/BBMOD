function cm_triangle_cast_ray(triangle, ray, mask = ray[CM_RAY.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.castRay
	*/
	if (mask != 0 && (mask & CM_TRIANGLE_GROUP) == 0){return ray;}
	
	var ox = ray[CM_RAY.X1];
	var oy = ray[CM_RAY.Y1];
	var oz = ray[CM_RAY.Z1];
	var dx = ray[CM_RAY.X2] - ox;
	var dy = ray[CM_RAY.Y2] - oy;
	var dz = ray[CM_RAY.Z2] - oz;
	var nx = CM_TRIANGLE_NX;
	var ny = CM_TRIANGLE_NY;
	var nz = CM_TRIANGLE_NZ;
	var h = dot_product_3d(dx, dy, dz, nx, ny, nz);
	if (h == 0){return ray;} //Continue if the ray is parallel to the surface of the triangle (ie. perpendicular to the triangle's normal)
	var v1x = CM_TRIANGLE_X1;
	var v1y = CM_TRIANGLE_Y1;
	var v1z = CM_TRIANGLE_Z1;
	var s = - sign(h);
	var t = dot_product_3d(v1x - ox, v1y - oy, v1z - oz, nx, ny, nz) / h;
	if (t < 0 || t > ray[CM_RAY.T]){return ray;} //Continue if the intersection is too far behind or in front of the ray
	var itsX = ox + dx * t;
	var itsY = oy + dy * t;
	var itsZ = oz + dz * t;

	//Check first edge
	var v2x = CM_TRIANGLE_X2;
	var v2y = CM_TRIANGLE_Y2;
	var v2z = CM_TRIANGLE_Z2;
	var ax = itsX - v1x;
	var ay = itsY - v1y;
	var az = itsZ - v1z;
	var bx = v2x - v1x;
	var by = v2y - v1y;
	var bz = v2z - v1z;
	var w1 = dot_product_3d(nx, ny, nz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by);
	if (w1 < 0){return ray;} //Continue if the intersection is outside this edge of the triangle
	if (w1 == 0)
	{
		var h = dot_product_3d(ax, ay, az, bx, by, bz);
		if (h < 0 || h > dot_product_3d(bx, by, bz, bx, by, bz)){return ray;} //Intersection is perfectly on this triangle edge. Continue if outside triangle.
	}
	
	//Check second edge
	var v3x = CM_TRIANGLE_X3;
	var v3y = CM_TRIANGLE_Y3;
	var v3z = CM_TRIANGLE_Z3;
	ax = itsX - v2x;
	ay = itsY - v2y;
	az = itsZ - v2z;
	bx = v3x - v2x;
	by = v3y - v2y;
	bz = v3z - v2z;
	var w2 = dot_product_3d(nx, ny, nz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by);
	if (w2 < 0){return ray;} //Continue if the intersection is outside this edge of the triangle
	if (w2 == 0)
	{
		var h = dot_product_3d(ax, ay, az, bx, by, bz);
		if (h < 0 || h > dot_product_3d(bx, by, bz, bx, by, bz)){return ray;} //Intersection is perfectly on this triangle edge. Continue if outside triangle.
	}
	
	//Check third edge
	ax = itsX - v3x;
	ay = itsY - v3y;
	az = itsZ - v3z;
	bx = v1x - v3x;
	by = v1y - v3y;
	bz = v1z - v3z;
	var w3 = dot_product_3d(nx, ny, nz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by);
	if (w3 < 0){return ray;} //Continue if the intersection is outside this edge of the triangle
	if (w3 == 0)
	{
		var h = dot_product_3d(ax, ay, az, bx, by, bz);
		if (h < 0 || h > dot_product_3d(bx, by, bz, bx, by, bz)){return ray;} //Intersection is perfectly on this triangle edge. Continue if outside triangle.
	}
	
	if (CM_TRIANGLE_TYPE == CM_OBJECTS.SMDSTRIANGLE || CM_TRIANGLE_TYPE == CM_OBJECTS.SMSSTRIANGLE)
	{
		//This is a smooth triangle
		var sum = w1 + w2 + w3;
		w1 /= sum;
		w2 /= sum;
		w3 /= sum;
		var n1 = CM_TRIANGLE_N3;
		var n2 = CM_TRIANGLE_N1;
		var n3 = CM_TRIANGLE_N2;
		nx = dot_product_3d(n1[0], n2[0], n3[0], w1, w2, w3);
		ny = dot_product_3d(n1[1], n2[1], n3[1], w1, w2, w3);
		nz = dot_product_3d(n1[2], n2[2], n3[2], w1, w2, w3);
		s /= point_distance_3d(0, 0, 0, nx, ny, nz);
	}
	
	//The line intersects the triangle. Save the triangle normal and intersection.
	ray[@ CM_RAY.T] = t;
	ray[@ CM_RAY.HIT] = true;
	ray[@ CM_RAY.X] = itsX;
	ray[@ CM_RAY.Y] = itsY;
	ray[@ CM_RAY.Z] = itsZ;
	ray[@ CM_RAY.NX] = nx * s;
	ray[@ CM_RAY.NY] = ny * s;
	ray[@ CM_RAY.NZ] = nz * s;
	ray[@ CM_RAY.OBJECT] = triangle;
	return ray;
}