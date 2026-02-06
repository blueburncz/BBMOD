/// @func cm_matrix_build_from_vector(x, y, z, vx, vy, vz, toScale, siScale, upScale, targetM*)
function cm_matrix_build_from_vector(X, Y, Z, vx, vy, vz, toScale, siScale, upScale, targetM = array_create(16))
{
	/*
		Creates a matrix based on the vector (vx, vy, vz).
		The vector will be used as basis for the up-vector of the matrix, ie. indices 8, 9, 10.
	*/
	targetM[@ 0]  = abs(vx) < abs(vy);
	targetM[@ 1]  = 1;
	targetM[@ 2]  = 0;
	targetM[@ 3]  = 0;
	targetM[@ 4]  = 0;
	targetM[@ 5]  = 0;
	targetM[@ 6]  = 1;
	targetM[@ 7]  = 0;
	targetM[@ 8]  = vx;
	targetM[@ 9]  = vy;
	targetM[@ 10] = vz;
	targetM[@ 11] = 0;
	targetM[@ 12] = X;
	targetM[@ 13] = Y;
	targetM[@ 14] = Z;
	targetM[@ 15] = 1;
	return cm_matrix_scale(cm_matrix_orthogonalize(targetM), toScale, siScale, upScale);
}