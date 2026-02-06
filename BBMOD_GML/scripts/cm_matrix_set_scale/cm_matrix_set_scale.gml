// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_matrix_set_scale(M, toScale, siScale, upScale)
{
	/*
		Scaled the given matrix along its own axes
	*/
	var lto = point_distance_3d(0, 0, 0, M[0], M[1], M[2]);
	var lsi = point_distance_3d(0, 0, 0, M[4], M[5], M[6]);
	var lup = point_distance_3d(0, 0, 0, M[8], M[9], M[10]);
	toScale /= lto;
	siScale /= lsi;
	upScale /= lup;
	M[@ 0] *= toScale;
	M[@ 1] *= toScale;
	M[@ 2] *= toScale;
	M[@ 4] *= siScale;
	M[@ 5] *= siScale;
	M[@ 6] *= siScale;
	M[@ 8] *= upScale;
	M[@ 9] *= upScale;
	M[@ 10]*= upScale;
	return M;
}