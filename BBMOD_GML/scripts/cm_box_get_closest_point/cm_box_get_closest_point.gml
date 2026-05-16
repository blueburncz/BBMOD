function cm_box_get_closest_point(box, x, y, z)
{
	/*
		A supplementary function, not meant to be used by itself.
		Used by colmesh.getClosestPoint
	*/
	//Find normalized block space position
	var p = matrix_transform_vertex(CM_BOX_I, x, y, z);
	var bx = p[0], by = p[1], bz = p[2];
	var b = max(abs(bx), abs(by), abs(bz));
		
	//If the center of the sphere is inside the cube, normalize the largest axis
	if (b <= 1){
		if (b == abs(bx))		bx = sign(bx);
		else if (b == abs(by))	by = sign(by);
		else					bz = sign(bz);
		return matrix_transform_vertex(CM_BOX_M, bx, by, bz);
	}
	return matrix_transform_vertex(CM_BOX_M, clamp(bx, -1, 1), clamp(by, -1, 1), clamp(bz, -1, 1));
}