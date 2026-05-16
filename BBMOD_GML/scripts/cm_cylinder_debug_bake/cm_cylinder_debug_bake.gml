/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_cylinder_debug_bake(cylinder, vbuff, matrix = matrix_build_identity(), mask = 0, hRep = 1, vRep = 1, color = undefined, alpha = 1, steps = 20)
{
	if (mask != 0 && (mask & CM_CYLINDER_GROUP) == 0){return false;}
	
	if (is_undefined(color))
	{
		color = c_white;
	}
	if (color < 0)
	{
		//Make a seed for this object by combinging its parameters
		var seed =	CM_CYLINDER_X1 + CM_CYLINDER_Y1 + CM_CYLINDER_Z1 +
					CM_CYLINDER_X2 + CM_CYLINDER_Y2 + CM_CYLINDER_Z2 +
					CM_CYLINDER_R * 100;
		color = make_color_hsv(floor(abs(seed) mod 256), 200, 230);
	}
	
	var H = point_distance_3d(CM_CYLINDER_DX, CM_CYLINDER_DY, CM_CYLINDER_DZ, 0, 0, 0);
	var R = CM_CYLINDER_R;
	static S = matrix_build_identity();
	cm_matrix_build_from_vector(CM_CYLINDER_X1, CM_CYLINDER_Y1, CM_CYLINDER_Z1, CM_CYLINDER_DX, CM_CYLINDER_DY, CM_CYLINDER_DZ, R, R, H, S);
	var M = matrix_multiply(S, matrix);
	
	for (var xx = 0; xx < steps; xx ++)
	{
		var xa1 = xx / steps * 2 * pi;
		var xa2 = (xx+1) / steps * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		
		var v = matrix_transform_vertex(M, xc1, xs1, 0);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc1, xs1, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, xx / steps * hRep, 0);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc2, xs2, 0);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc2, xs2, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (xx+1) / steps * hRep, 0);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc1, xs1, 1);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc1, xs1, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, xx / steps * hRep, vRep);
		vertex_color(vbuff, color, alpha);
		
		
		
		var v = matrix_transform_vertex(M, xc2, xs2, 0);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc2, xs2, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (xx+1) / steps * hRep, 0);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc2, xs2, 1);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc2, xs2, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, xx / steps * hRep, vRep);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc1, xs1, 1);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc1, xs1, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (xx+1) / steps * hRep, vRep);
		vertex_color(vbuff, color, alpha);
		
		
		
		//Bottom lid
		var v = matrix_transform_vertex(M, 1, 0, 0);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, 0, 0, -1, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, hRep, .5 * vRep);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc2, xs2, 0);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, 0, 0, -1, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (.5 + .5 * xc2) * hRep, (.5 + .5 * xs2) * vRep);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc1, xs1, 0);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, 0, 0, -1, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (.5 + .5 * xc1) * hRep, (.5 + .5 * xs1) * vRep);
		vertex_color(vbuff, color, alpha);
		
		
		//Top lid
		var v = matrix_transform_vertex(M, 1, 0, 1);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, 0, 0, 1, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, hRep, .5 * vRep);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc1, xs1, 1);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, 0, 0, 1, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (.5 + .5 * xc1) * hRep, (.5 + .5 * xs1) * vRep);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc2, xs2, 1);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, 0, 0, 1, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (.5 + .5 * xc2) * hRep, (.5 + .5 * xs2) * vRep);
		vertex_color(vbuff, color, alpha);
	}
}