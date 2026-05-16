function cm_box_get_aabb(box)
{
	/*
			Returns the AABB of the shape as an array with six values
	*/
	var M = CM_BOX_M;
	var dx = abs(M[0]) + abs(M[4]) + abs(M[8]);
	var dy = abs(M[1]) + abs(M[5]) + abs(M[9]);
	var dz = abs(M[2]) + abs(M[6]) + abs(M[10]);
	return [M[12] - dx,
			M[13] - dy,
			M[14] - dz,
			M[12] + dx,
			M[13] + dy,
			M[14] + dz];
}