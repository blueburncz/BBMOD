/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_triangle_debug_bake(triangle, vbuff, matrix = matrix_build_identity(), mask = 0, hRep = 1, vRep = 1, color = undefined, alpha = 1)
{
	if (mask > 0 && (mask & CM_TRIANGLE_GROUP) == 0){return false;}
	if (is_undefined(color))
	{
		color = c_white;
	}
	if (color < 0)
	{
		//Make a seed for this triangle by combinging its parameters
		var seed =	CM_TRIANGLE_X1 + CM_TRIANGLE_Y1 + CM_TRIANGLE_Z1 + 
					CM_TRIANGLE_X2 + CM_TRIANGLE_Y2 + CM_TRIANGLE_Z2 + 
					CM_TRIANGLE_X3 + CM_TRIANGLE_Y3 + CM_TRIANGLE_Z3 + 
					100 * (CM_TRIANGLE_NX + CM_TRIANGLE_NY + CM_TRIANGLE_NZ);
		color = make_color_hsv(floor(abs(seed) mod 256), 200, 230);
	}
	var smooth = CM_TRIANGLE_TYPE == CM_OBJECTS.SMDSTRIANGLE || CM_TRIANGLE_TYPE == CM_OBJECTS.SMSSTRIANGLE;
	var n;
	if (smooth)
	{
		var N = CM_TRIANGLE_N1;
		n = matrix_transform_vertex(matrix, N[0], N[1], N[2], 0);
		var d = max(0.00001, point_distance_3d(0, 0, 0, n[0], n[1], n[2]));
		n[0] /= d; n[1] /= d; n[2] /= d;
	}
	else
	{
		n = matrix_transform_vertex(matrix, CM_TRIANGLE_NX, CM_TRIANGLE_NY, CM_TRIANGLE_NZ, 0);
		var d = max(0.00001, point_distance_3d(0, 0, 0, n[0], n[1], n[2]));
		n[0] /= d; n[1] /= d; n[2] /= d;
	}
	
	var v = matrix_transform_vertex(matrix, CM_TRIANGLE_X1, CM_TRIANGLE_Y1, CM_TRIANGLE_Z1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, 0);
	vertex_color(vbuff, color, alpha);
	
	if (smooth)
	{
		var N = CM_TRIANGLE_N2;
		n = matrix_transform_vertex(matrix, N[0], N[1], N[2], 0);
		d = max(0.00001, point_distance_3d(0, 0, 0, n[0], n[1], n[2]));
		n[0] /= d; n[1] /= d; n[2] /= d;
	}
	
	var v = matrix_transform_vertex(matrix, CM_TRIANGLE_X2, CM_TRIANGLE_Y2, CM_TRIANGLE_Z2);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 1, 0);
	vertex_color(vbuff, color, alpha);
	
	if (smooth)
	{
		var N = CM_TRIANGLE_N3;
		n = matrix_transform_vertex(matrix, N[0], N[1], N[2], 0);
		d = max(0.00001, point_distance_3d(0, 0, 0, n[0], n[1], n[2]));
		n[0] /= d; n[1] /= d; n[2] /= d;
	}
	
	var v = matrix_transform_vertex(matrix, CM_TRIANGLE_X3, CM_TRIANGLE_Y3, CM_TRIANGLE_Z3);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, 1);
	vertex_color(vbuff, color, alpha);
}