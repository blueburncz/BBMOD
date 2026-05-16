/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_aab_debug_bake(aab, vbuff, matrix = matrix_build_identity(), mask = 0, hRep = 1, vRep = 1, color = undefined, alpha = 1)
{
	if (mask != 0 && (mask & CM_AAB_GROUP) == 0){return false;}
	
	if (is_undefined(color))
	{
		color = c_white;
	}
	if (color < 0)
	{
		//Make a seed for this object by combinging its parameters
		var seed =	CM_AAB_X + CM_AAB_Y + CM_AAB_Z +
					CM_AAB_HALFX + CM_AAB_HALFY + CM_AAB_HALFZ;
		color = make_color_hsv(floor(abs(seed) mod 256), 200, 230);
	}
	
	static S = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
	S[0]  = CM_AAB_HALFX;
	S[5]  = CM_AAB_HALFY;
	S[10] = CM_AAB_HALFZ;
	S[12] = CM_AAB_X;
	S[13] = CM_AAB_Y;
	S[14] = CM_AAB_Z;
	var M = matrix_multiply(S, matrix);
	
	//+z
	var n = matrix_transform_vertex(M, 0, 0, 1, 0);
	var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
	n[0] /= d;
	n[1] /= d;
	n[2] /= d;
	var v = matrix_transform_vertex(M, -1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, 1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	
	var v = matrix_transform_vertex(M, -1, 1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, 1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, vRep);
	vertex_color(vbuff, color, alpha);
	
	
	//-z
	var n = matrix_transform_vertex(M, 0, 0, -1, 0);
	var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
	n[0] /= d;
	n[1] /= d;
	n[2] /= d;
	var v = matrix_transform_vertex(M, -1, -1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, -1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	
	var v = matrix_transform_vertex(M, -1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, -1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	
	//+x
	var n = matrix_transform_vertex(M, 1, 0, 0, 0);
	var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
	n[0] /= d;
	n[1] /= d;
	n[2] /= d;
	var v = matrix_transform_vertex(M, 1, -1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	
	var v = matrix_transform_vertex(M, 1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, 1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	
	//-x
	var n = matrix_transform_vertex(M, -1, 0, 0, 0);
	var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
	n[0] /= d;
	n[1] /= d;
	n[2] /= d;
	var v = matrix_transform_vertex(M, -1, -1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	
	var v = matrix_transform_vertex(M, -1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, 1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, vRep);
	vertex_color(vbuff, color, alpha);
	
	
	//+y
	var n = matrix_transform_vertex(M, 0, 1, 0, 0);
	var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
	n[0] /= d;
	n[1] /= d;
	n[2] /= d;
	var v = matrix_transform_vertex(M, -1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, 1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	
	var v = matrix_transform_vertex(M, 1, 1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, 1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, 1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, vRep);
	vertex_color(vbuff, color, alpha);
	
	
	//-y
	var n = matrix_transform_vertex(M, 0, -1, 0, 0);
	var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
	n[0] /= d;
	n[1] /= d;
	n[2] /= d;
	var v = matrix_transform_vertex(M, -1, -1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, 0);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, -1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
	
	
	var v = matrix_transform_vertex(M, 1, -1, -1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, 1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, vRep);
	vertex_color(vbuff, color, alpha);
	
	var v = matrix_transform_vertex(M, -1, -1, 1);
	vertex_position_3d(vbuff, v[0], v[1], v[2]);
	vertex_normal(vbuff, n[0], n[1], n[2]);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, alpha);
}