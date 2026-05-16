////////////////////////////////////////
// -- Check AABB --
function cm_check_aabb(object, aabb)
{
	var minmax = cm_get_aabb(object);
	if abs(minmax[0] + minmax[3] - aabb[0] - aabb[3]) > abs(minmax[3] - minmax[0] + aabb[3] - aabb[0]) return false;
	if abs(minmax[1] + minmax[4] - aabb[1] - aabb[4]) > abs(minmax[4] - minmax[1] + aabb[4] - aabb[1]) return false;
	if abs(minmax[2] + minmax[5] - aabb[2] - aabb[5]) > abs(minmax[5] - minmax[2] + aabb[5] - aabb[2]) return false;
	return true;
}