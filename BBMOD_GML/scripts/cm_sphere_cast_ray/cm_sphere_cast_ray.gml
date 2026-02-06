function cm_sphere_cast_ray(sphere, ray, mask = ray[CM_RAY.MASK])
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.castRay
	*/
	if (mask != 0 && (mask & CM_SPHERE_GROUP) == 0){return ray;}
	
	var X = CM_SPHERE_X;
	var Y = CM_SPHERE_Y;
	var Z = CM_SPHERE_Z;
	var R = CM_SPHERE_R;
	
	var rox = ray[CM_RAY.X1];
	var roy = ray[CM_RAY.Y1];
	var roz = ray[CM_RAY.Z1];
	var rdx = ray[CM_RAY.X2] - rox;
	var rdy = ray[CM_RAY.Y2] - roy;
	var rdz = ray[CM_RAY.Z2] - roz;
	var dx = X - rox;
	var dy = Y - roy;
	var dz = Z - roz;

	var v = dot_product_3d(rdx, rdy, rdz, rdx, rdy, rdz);
	var d = dot_product_3d(dx, dy, dz, dx, dy, dz);
	var t = dot_product_3d(rdx, rdy, rdz, dx, dy, dz);
	var u = t * t + v * (R * R - d);
	
	if (u < 0){return ray;}
	
	u = sqrt(max(u, 0));
	if (t < u)
	{
		//The ray started inside the sphere
		//if (!doublesided){return -1;} //The ray started inside the sphere, and the sphere is not doublesided. There is no way this ray can intersect the sphere.
		t += u; //Project to the inside of the sphere
		if (t < 0){return ray;} //The sphere is behind the ray
	}
	else
	{
		//Project to the outside of the sphere
		t -= u;
		if (t > v)
		{
			//The sphere is too far away
			return ray;
		}
	}
	t /= v;
	if (t > ray[CM_RAY.T]){return ray;}
	var itsX = rox + rdx * t;
	var itsY = roy + rdy * t;
	var itsZ = roz + rdz * t;
	ray[@ CM_RAY.T] = t;
	ray[@ CM_RAY.HIT] = true;
	ray[@ CM_RAY.X] = itsX;
	ray[@ CM_RAY.Y] = itsY;
	ray[@ CM_RAY.Z] = itsZ;
	ray[@ CM_RAY.NX] = (itsX - X) / R;
	ray[@ CM_RAY.NY] = (itsY - Y) / R;
	ray[@ CM_RAY.NZ] = (itsZ - Z) / R;
	ray[@ CM_RAY.OBJECT] = sphere;
	return ray;
}