function cm_dynamic_set_matrix(dynamic, matrix, moving) 
{	
	/*	
		This script lets you make it seem like a colmesh instance has been transformed.
		What really happens though, is that the collision object is transformed by the inverse of the given matrix, 
		then it performs collision checks, and then it is transformed back. This is an efficient process.
		This script creates a new matrix from the given matrix, making sure that all the vectors are perpendicular, 
		and making sure the scaling is uniform (using the scale in the first column as reference).
			
		Set moving to true if your object moves from frame to frame, and false if it's a static object that only uses a dynamic for static transformations.
	*/
	var M = CM_DYNAMIC_M;
	var I = CM_DYNAMIC_I;
	var P = CM_DYNAMIC_P;
	CM_DYNAMIC_MOVING = moving;
	
	//Make a copy of the given matrix instead of using it directly
	array_copy(M, 0, matrix, 0, 16);
		
	//Find the scale based on the first column of the matrix
	CM_DYNAMIC_SCALE = point_distance_3d(0, 0, 0, M[0], M[1], M[2]);
	
	//Orthogonalize and normalize the vectors of the matrix
	cm_matrix_orthogonalize(M);
	
	//Rescale the matrix to the scale we found earlier
	cm_matrix_scale(M, CM_DYNAMIC_SCALE, CM_DYNAMIC_SCALE, CM_DYNAMIC_SCALE);
	
	//Store the previous inverse matrix
	array_copy(P, 0, I, 0, 16);
	
	//Invert the new world matrix
	cm_matrix_invert_orientation(M, I);
	
	//Update AABB
	__cmi_dynamic_update_aabb(dynamic);
}