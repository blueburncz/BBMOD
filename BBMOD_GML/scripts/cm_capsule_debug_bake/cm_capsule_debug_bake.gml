/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_capsule_debug_bake(capsule, vbuff, matrix = matrix_build_identity(), mask = 0, hRep = 1, vRep = 1, color = undefined, alpha = 1, hVerts = 20, vVerts = 12)
{
	if (mask != 0 && (mask & CM_CAPSULE_GROUP) == 0){return false;}
	
	if (is_undefined(color))
	{
		color = c_white;
	}
	if (color < 0)
	{
		//Make a seed for this object by combinging its parameters
		var seed =	CM_CAPSULE_X1 + CM_CAPSULE_Y1 + CM_CAPSULE_Z1 +
					CM_CAPSULE_X2 + CM_CAPSULE_Y2 + CM_CAPSULE_Z2 +
					CM_CAPSULE_R * 100;
		color = make_color_hsv(floor(abs(seed) mod 256), 200, 230);
	}
	
	var H = point_distance_3d(CM_CAPSULE_DX, CM_CAPSULE_DY, CM_CAPSULE_DZ, 0, 0, 0);
	static S = matrix_build_identity();
	cm_matrix_build_from_vector(CM_CAPSULE_X1, CM_CAPSULE_Y1, CM_CAPSULE_Z1, CM_CAPSULE_DX, CM_CAPSULE_DY, CM_CAPSULE_DZ, 1, 1, 1, S);
	var M = matrix_multiply(S, matrix);
	var R = CM_CAPSULE_R;
	
	for (var xx = 0; xx < hVerts; xx ++)
	{
		var xa1 = xx / hVerts * 2 * pi;
		var xa2 = (xx+1) / hVerts * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		
		var v = matrix_transform_vertex(M, xc1 * R, xs1 * R, 0);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc1, xs1, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, xx / hVerts * hRep, 0);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc2 * R, xs2 * R, 0);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc2, xs2, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, 0);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc1 * R, xs1 * R, H);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc1, xs1, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, xx / hVerts * hRep, vRep);
		vertex_color(vbuff, color, alpha);
		
		
		
		var v = matrix_transform_vertex(M, xc2 * R, xs2 * R, 0);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc2, xs2, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, 0);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc2 * R, xs2 * R, H);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc2, xs2, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, xx / hVerts * hRep, vRep);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc1 * R, xs1 * R, H);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		var v = matrix_transform_vertex(M, xc1, xs1, 0, 0);
		var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
		vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
		vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, vRep);
		vertex_color(vbuff, color, alpha);
		
		
		for (var yy = 0; yy < vVerts; yy ++)
		{
			var ya1 = yy / vVerts * pi / 2;
			var ya2 = (yy+1) / vVerts * pi / 2;
			var yc1 = cos(ya1);
			var ys1 = sin(ya1);
			var yc2 = cos(ya2);
			var ys2 = sin(ya2);
			
			//Draw the bottom hemisphere
			var v = matrix_transform_vertex(M, xc1 * ys1 * R, xs1 * ys1 * R, - yc1 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc1 * ys1, xs1 * ys1, - yc1, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * ys1 * R, xs2 * ys1 * R, - yc1 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, - yc1, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc1 * ys2 * R, xs1 * ys2 * R, - yc2 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, - yc2, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			
			var v = matrix_transform_vertex(M, xc1 * ys2 * R, xs1 * ys2 * R, - yc2 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, - yc2, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * ys1 * R, xs2 * ys1 * R, - yc1 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, - yc1, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * ys2 * R, xs2 * ys2 * R, - yc2 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc2 * ys2, xs2 * ys2, - yc2, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			
			//Draw top hemisphere
			var v = matrix_transform_vertex(M, xc2 * ys1 * R, xs2 * ys1 * R, H + yc1 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, yc1, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc1 * ys1 * R, xs1 * ys1 * R, H + yc1 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc1 * ys1, xs1 * ys1, yc1, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc1 * ys2 * R, xs1 * ys2 * R, H + yc2 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, yc2, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			
			var v = matrix_transform_vertex(M, xc2 * ys1 * R, xs2 * ys1 * R, H + yc1 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, yc1, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc1 * ys2 * R, xs1 * ys2 * R, H + yc2 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, yc2, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * ys2 * R, xs2 * ys2 * R, H + yc2 * R);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc2 * ys2, xs2 * ys2, yc2, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
		}
	}
}