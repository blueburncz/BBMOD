function __cmi_torus_intersects_cube(torus, hsize, bX, bY, bZ) 
{
	/*
		A supplementary function, not meant to be used by itself.
		Returns true if the shape intersects the given axis-aligned cube
	*/
	var aabb = cm_torus_get_aabb(torus);
	if abs(aabb[0] + aabb[3] - 2 * bX) > abs(aabb[3] - aabb[0] + 2 * hsize)
	|| abs(aabb[1] + aabb[4] - 2 * bY) > abs(aabb[4] - aabb[1] + 2 * hsize)
	|| abs(aabb[2] + aabb[5] - 2 * bZ) > abs(aabb[5] - aabb[2] + 2 * hsize) return false;
	return true;
}