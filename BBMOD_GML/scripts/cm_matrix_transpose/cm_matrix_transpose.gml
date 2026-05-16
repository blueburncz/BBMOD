// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_matrix_transpose(M, T = array_create(16)) 
{
	T[@ 0]  = M[0];
	T[@ 1]  = M[4];
	T[@ 2]  = M[8];
	T[@ 3]  = M[12];
		 
	T[@ 4]  = M[1];
	T[@ 5]  = M[5];
	T[@ 6]  = M[9];
	T[@ 7]  = M[13];
	
	T[@ 8]  = M[2];
	T[@ 9]  = M[6];
	T[@ 10] = M[10];
	T[@ 11] = M[14];
	
	T[@ 12] = M[3];
	T[@ 13] = M[7];
	T[@ 14] = M[11];
	T[@ 15] = M[15];
	
	return T;
}
