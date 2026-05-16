// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_matrix_invert(M, I = array_create(16))
{
	//Proper matrix inversion
	var m0 = M[0], m1 = M[1], m2 = M[2], m3 = M[3], m4 = M[4], m5 = M[5], m6 = M[6], m7 = M[7], m8 = M[8], m9 = M[9], m10 = M[10], m11 = M[11], m12 = M[12], m13 = M[13], m14 = M[14], m15 = M[15];
	var a   = m5 * m10 - m9 * m6;
	var d   = m8 * m6  - m4 * m10;
	var g   = m4 * m9  - m8 * m5;
	var j   = m6 * m11 - m7 * m10;
	var m   = m9 * m7  - m5 * m11;
	var p   = m4 * m11 - m8 * m7;
	var i0  = dot_product_3d(m13,  m14,  m15,  j,  m,  a);
	var i4  = dot_product_3d(m12,  m14,  m15, -j,  p,  d);
	var i8  = dot_product_3d(m12,  m13,  m15, -m, -p,  g);
	var i12 = dot_product_3d(m12,  m13,  m14, -a, -d, -g);
	var det =   m0 * i0 + m1 * i4 + m2 * i8 + m3 * i12;
	if (det == 0){
		show_debug_message("Error in function cm_matrix_invert: The determinant is zero.");
		return M;
	}
	var b   = m9 * m2  - m1 * m10;
	var c   = m1 * m6  - m5 * m2;
	var e   = m0 * m10 - m8 * m2;
	var f   = m4 * m2  - m0 * m6;
	var h   = m8 * m1  - m0 * m9;
	var i   = m0 * m5  - m4 * m1;
	var k   = m3 * m10 - m2 * m11;
	var l   = m2 * m7  - m3 * m6;
	var n   = m1 * m11 - m9 * m3;
	var o   = m5 * m3  - m1 * m7;
	var q   = m8 * m3  - m0 * m11;
	var r   = m0 * m7  - m4 * m3;
	var invDet = 1 / det;
	I[@ 0]  = invDet * i0;
	I[@ 1]  = invDet * dot_product_3d(m13, m14, m15,  k,  n,  b);
	I[@ 2]  = invDet * dot_product_3d(m13, m14, m15,  l,  o,  c);
	I[@ 3]  = invDet * dot_product_3d(m3,  m7,  m11, -a, -b, -c);
	I[@ 4]  = invDet * i4;
	I[@ 5]  = invDet * dot_product_3d(m12, m14, m15, -k,  q,  e);
	I[@ 6]  = invDet * dot_product_3d(m12, m14, m15, -l,  r,  f);
	I[@ 7]  = invDet * dot_product_3d(m3,  m7,  m11, -d, -e, -f);
	I[@ 8]  = invDet * i8;
	I[@ 9]  = invDet * dot_product_3d(m12, m13, m15, -n, -q,  h);
	I[@ 10] = invDet * dot_product_3d(m12, m13, m15, -o, -r,  i);
	I[@ 11] = invDet * dot_product_3d(m3,  m7,  m11, -g, -h, -i);
	I[@ 12] = invDet * i12;
	I[@ 13] = invDet * dot_product_3d(m12, m13, m14, -b, -e, -h);
	I[@ 14] = invDet * dot_product_3d(m12, m13, m14, -c, -f, -i);
	I[@ 15] = invDet * dot_product_3d(m0,  m4,  m8,   a,  b,  c);
	return I;
}
/*
function cm_matrix_invert_proj(M, I = array_create(16))
{
	//Proper matrix inversion
	var m0 = M[0], m5 = M[5], m10 = M[10], m11 = M[11], m14 = M[14];
	I[@ 0]  = 1 / m0;
	I[@ 1]  = 0;
	I[@ 2]  = 0;
	I[@ 3]  = 0;
	I[@ 4]  = 0;
	I[@ 5]  = 1 / m5;
	I[@ 6]  = 0;
	I[@ 7]  = 0;
	I[@ 8]  = 0;
	I[@ 9]  = 0;
	I[@ 10] = 0;
	I[@ 11] = 1 / m14;
	I[@ 12] = 0;
	I[@ 13] = 0;
	I[@ 14] = 1 / m11;
	I[@ 15] = - m10 / (m14 * m11);
	return I;
}