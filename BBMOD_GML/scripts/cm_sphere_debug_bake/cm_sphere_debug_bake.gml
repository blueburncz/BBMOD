/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_sphere_debug_bake(sphere, vbuff, matrix = matrix_build_identity(), mask = 0, hRep = 2, vRep = 1, color = undefined, alpha = 1, hVerts = 28, vVerts = 16)
{
	if (mask != 0 && (mask & CM_SPHERE_GROUP) == 0){return false;}
	
	if (is_undefined(color))
	{
		color = c_white;
	}
	if (color < 0)
	{
		//Make a seed for this object by combinging its parameters
		var seed =	CM_SPHERE_X + CM_SPHERE_Y + CM_SPHERE_Z + CM_SPHERE_R * 100;
		color = make_color_hsv(floor(abs(seed) mod 256), 200, 230);
	}
	
	static S = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
	S[0] = CM_SPHERE_R;
	S[5] = CM_SPHERE_R;
	S[10] = CM_SPHERE_R;
	S[12] = CM_SPHERE_X;
	S[13] = CM_SPHERE_Y;
	S[14] = CM_SPHERE_Z;
	var M = matrix_multiply(S, matrix);
	for (var xx = 0; xx < hVerts; xx ++)
	{
		var xa1 = xx / hVerts * 2 * pi;
		var xa2 = (xx+1) / hVerts * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		for (var yy = 0; yy < vVerts; yy ++)
		{
			var ya1 = yy / vVerts * pi;
			var ya2 = (yy+1) / vVerts * pi;
			var yc1 = cos(ya1);
			var ys1 = sin(ya1);
			var yc2 = cos(ya2);
			var ys2 = sin(ya2);
			
			var v = matrix_transform_vertex(M, xc1 * ys1, xs1 * ys1, yc1);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc1 * ys1, xs1 * ys1, yc1, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, yc2);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, yc2, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, yc1);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, yc1, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, yc2);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, yc2, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * ys2, xs2 * ys2, yc2);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc2 * ys2, xs2 * ys2, yc2, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, yc1);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var v = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, yc1, 0);
			var d = point_distance_3d(0, 0, 0, v[0], v[1], v[2]);
			vertex_normal(vbuff, v[0] / d, v[1] / d, v[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
		}
	}
}