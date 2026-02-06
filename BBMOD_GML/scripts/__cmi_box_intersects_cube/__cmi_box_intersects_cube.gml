function __cmi_box_intersects_cube(box, hsize, bX, bY, bZ) 
{
	var aabb = cm_box_get_aabb(box);
	if abs(aabb[0] + aabb[3] - 2 * bX) > abs(aabb[3] - aabb[0] + 2 * hsize)
	|| abs(aabb[1] + aabb[4] - 2 * bY) > abs(aabb[4] - aabb[1] + 2 * hsize)
	|| abs(aabb[2] + aabb[5] - 2 * bZ) > abs(aabb[5] - aabb[2] + 2 * hsize) return false;
	return true;
}