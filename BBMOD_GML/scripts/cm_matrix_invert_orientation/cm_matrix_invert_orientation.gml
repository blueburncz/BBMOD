// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_matrix_invert_orientation(M, I = array_create(16)) 
{
	//Returns the inverse of a 4x4 matrix. Assumes indices 3, 7 and 11 are 0, and index 15 is 1
	//With this assumption a lot of factors cancel out
	var m0 = M[0], m1 = M[1], m2 = M[2], m4 = M[4], m5 = M[5], m6 = M[6], m8 = M[8], m9 = M[9], m10 = M[10], m12 = M[12], m13 = M[13], m14 = M[14];
	var i0  =   m5 * m10 -  m9 * m6;
	var i4  =   m8 * m6  -  m4 * m10;
	var i8  =   m4 * m9  -  m8 * m5;
	var det =   dot_product_3d(m0, m1, m2, i0, i4, i8);
	if (det == 0)
	{
		show_debug_message("Error in function cm_matrix_invert_orientation: The determinant is zero.");
		return M;
	}
	var invDet = 1 / det;
	I[@ 0]  =   invDet * i0;
	I[@ 1]  =   invDet * (m9 * m2  - m1 * m10);
	I[@ 2]  =   invDet * (m1 * m6  - m5 * m2);
	I[@ 3]  =   0;
	I[@ 4]  =   invDet * i4;
	I[@ 5]  =   invDet * (m0 * m10 - m8 * m2);
	I[@ 6]  =   invDet * (m4 * m2  - m0 * m6);
	I[@ 7]  =   0;
	I[@ 8]  =   invDet * i8;
	I[@ 9]  =   invDet * (m8 * m1  - m0 * m9);
	I[@ 10] =   invDet * (m0 * m5  - m4 * m1);
	I[@ 11] =   0;
	I[@ 12] = - dot_product_3d(m12, m13, m14, I[0], I[4], I[8]);
	I[@ 13] = - dot_product_3d(m12, m13, m14, I[1], I[5], I[9]);
	I[@ 14] = - dot_product_3d(m12, m13, m14, I[2], I[6], I[10]);
	I[@ 15] =   dot_product_3d(m8,  m9,  m10, I[2], I[6], I[10]);
	return I;
}