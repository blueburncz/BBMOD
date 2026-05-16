function __cmi_dynamic_update_aabb(dynamic)
{
	//Returns the AABB of the shape as an array with six values
	var mm = cm_get_aabb(CM_DYNAMIC_OBJECT);
	var xs = (mm[3] - mm[0]) * .5;
	var ys = (mm[4] - mm[1]) * .5;
	var zs = (mm[5] - mm[2]) * .5;
	var mx = (mm[0] + mm[3]) * .5;
	var my = (mm[1] + mm[4]) * .5;
	var mz = (mm[2] + mm[5]) * .5;
	var M = CM_DYNAMIC_M;
	var t = matrix_transform_vertex(M, mx, my, mz);
	var dx = abs(M[0] * xs) + abs(M[4] * ys) + abs(M[8] * zs);
	var dy = abs(M[1] * xs) + abs(M[5] * ys) + abs(M[9] * zs);
	var dz = abs(M[2] * xs) + abs(M[6] * ys) + abs(M[10]* zs);
	array_copy(CM_DYNAMIC_AABBPREV, 0, CM_DYNAMIC_AABB, 0, 6);
	CM_DYNAMIC_AABB[@ 0] = t[0] - dx;
	CM_DYNAMIC_AABB[@ 1] = t[1] - dy;
	CM_DYNAMIC_AABB[@ 2] = t[2] - dz;
	CM_DYNAMIC_AABB[@ 3] = t[0] + dx;
	CM_DYNAMIC_AABB[@ 4] = t[1] + dy;
	CM_DYNAMIC_AABB[@ 5] = t[2] + dz;
}