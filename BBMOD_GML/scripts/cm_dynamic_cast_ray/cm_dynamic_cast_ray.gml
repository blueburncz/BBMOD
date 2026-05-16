function cm_dynamic_cast_ray(dynamic, ray, mask = ray[CM_RAY.MASK])
{
	//Avoid creating arrays on the fly by storing a local array for each recursion level
	static rays = array_create(CM_MAX_RECURSIONS);
	
	//Transform the ray to the dynamic's local space
	var I = CM_DYNAMIC_I;
	var p1 = matrix_transform_vertex(I, ray[CM_RAY.X1], ray[CM_RAY.Y1], ray[CM_RAY.Z1]);
	var p2 = matrix_transform_vertex(I, ray[CM_RAY.X2], ray[CM_RAY.Y2], ray[CM_RAY.Z2]);
	var localRay = cm_ray_clear(rays[CM_RECURSION], p1[0], p1[1], p1[2], p2[0], p2[1], p2[2], ray[CM_RAY.MASK]);
	rays[CM_RECURSION] = localRay;
	localRay[CM_RAY.T] = ray[CM_RAY.T];
	
	//Increase recursion counter and perform a ray cast in local space
	++ CM_RECURSION;
	cm_cast_ray(CM_DYNAMIC_OBJECT, localRay, mask);
	-- CM_RECURSION;
	
	//There was no intersection. Return the un-altered array
	if (!localRay[CM_RAY.HIT]) return ray;
	
	//Transform back to world-space
	ray[@ CM_RAY.T] = localRay[CM_RAY.T];
	var M = CM_DYNAMIC_M;
	var e = matrix_transform_vertex(M, localRay[CM_RAY.X],  localRay[CM_RAY.Y],  localRay[CM_RAY.Z]);
	var n = matrix_transform_vertex(M, localRay[CM_RAY.NX], localRay[CM_RAY.NY], localRay[CM_RAY.NZ],   0);
	ray[@ CM_RAY.X] = e[0];
	ray[@ CM_RAY.Y] = e[1];
	ray[@ CM_RAY.Z] = e[2];
	ray[@ CM_RAY.NX] = n[0];
	ray[@ CM_RAY.NY] = n[1];
	ray[@ CM_RAY.NZ] = n[2];
	
	ray[@ CM_RAY.HIT] = true;
	ray[@ CM_RAY.OBJECT] = cm_list(dynamic, localRay[CM_RAY.OBJECT]);
	
	return ray;
}