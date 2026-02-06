function cm_matrix_orthogonalize(M, to = false)
{
	/*
		This makes sure the three vectors of the given matrix are all unit length
		and perpendicular to each other, using the up direction as master.
		GameMaker does something similar when creating a lookat matrix. People often use [0, 0, 1]
		as the up direction, but this vector is not used directly for creating the view matrix; rather, 
		it's being used as reference, and the entire view matrix is being orthogonalized to the looking direction.
	*/
	if (to)
	{
		var l = point_distance_3d(0, 0, 0, M[0], M[1], M[2]);
		if (l != 0 && l != 1)
		{
			M[@ 0] /= l;
			M[@ 1] /= l;
			M[@ 2] /= l;
		}
	
		var dp = dot_product_3d(M[0], M[1], M[2], M[8], M[9], M[10]);
		M[@ 8]  -= M[0] * dp;
		M[@ 9]  -= M[1] * dp;
		M[@ 10] -= M[2] * dp;
		l = point_distance_3d(0, 0, 0, M[8], M[9], M[10]);
		if (l != 0 && l != 1)
		{
			l = 1 / l;
			M[@ 8] *= l;
			M[@ 9] *= l;
			M[@ 10] *= l;
		}
	}
	else
	{
		var l = point_distance_3d(0, 0, 0, M[8], M[9], M[10]);
		if (l != 0 && l != 1)
		{
			M[@ 8]  /= l;
			M[@ 9]  /= l;
			M[@ 10] /= l;
		}
		
		var dp = dot_product_3d(M[0], M[1], M[2], M[8], M[9], M[10]);
		M[@ 0] -= M[8]  * dp;
		M[@ 1] -= M[9]  * dp;
		M[@ 2] -= M[10] * dp;
		l = point_distance_3d(0, 0, 0, M[0], M[1], M[2]);
		if (l != 0 && l != 1)
		{
			M[@ 0] /= l;
			M[@ 1] /= l;
			M[@ 2] /= l;
		}
	}
	
	//The last vector is automatically normalized, since the two other vectors now are perpendicular unit vectors
	M[@ 4] = M[9]  * M[2] - M[10] * M[1];
	M[@ 5] = M[10] * M[0] - M[8]  * M[2];
	M[@ 6] = M[8]  * M[1] - M[9]  * M[0];
	
	return M;
}