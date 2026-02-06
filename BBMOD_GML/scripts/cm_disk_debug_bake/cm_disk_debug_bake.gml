/*
	This function will let you bake this shape into a vertex buffer.
	Useful for batching shapes together when debugging.
*/

function cm_disk_debug_bake(disk, vbuff, matrix = matrix_build_identity(), mask = 0, hRep = 1, vRep = 1, color = undefined, alpha = 1, hVerts = 28, vVerts = 12)
{
	if (mask != 0 && (mask & CM_DISK_GROUP) == 0){return false;}
	
	if (is_undefined(color))
	{
		color = c_white;
	}
	if (color < 0)
	{
		//Make a seed for this object by combinging its parameters
		var seed =  CM_DISK_X + CM_DISK_Y + CM_DISK_Z +
					CM_DISK_BIGRADIUS + CM_DISK_SMALLRADIUS * 100 +
					(CM_DISK_NX + CM_DISK_NY + CM_DISK_NZ) * 100;
		color = make_color_hsv(floor(abs(seed) mod 256), 200, 230);
	}
	
	static S = array_create(16);
	var cx = CM_DISK_X;
	var cy = CM_DISK_Y;
	var cz = CM_DISK_Z;
	var nx = CM_DISK_NX;
	var ny = CM_DISK_NY;
	var nz = CM_DISK_NZ;
	var r  = CM_DISK_SMALLRADIUS;
	var R  = CM_DISK_BIGRADIUS;
	cm_matrix_build_from_vector(cx, cy, cz, nx, ny, nz, 1, 1, 1, S);
	var M = matrix_multiply(S, matrix);
	
	for (var xx = 0; xx < hVerts; xx ++)
	{
		var xa1 = xx / hVerts * 2 * pi;
		var xa2 = (xx+1) / hVerts * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		
		//Top lid
		var n = matrix_transform_vertex(M, 0, 0, 1, 0);
		var v = matrix_transform_vertex(M, R, 0, r);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		vertex_normal(vbuff, n[0], n[1], n[2]);
		vertex_texcoord(vbuff, hRep, 0);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc1 * R, xs1 * R, r);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		vertex_normal(vbuff, n[0], n[1], n[2]);
		vertex_texcoord(vbuff, xc1 * hRep, xs1 * vRep);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc2 * R, xs2 * R, r);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		vertex_normal(vbuff, n[0], n[1], n[2]);
		vertex_texcoord(vbuff, xc2 * hRep, xs2 * vRep);
		vertex_color(vbuff, color, alpha);
		
		//Bottom lid
		var v = matrix_transform_vertex(M, R, 0, -r);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		vertex_normal(vbuff, - n[0], - n[1], - n[2]);
		vertex_texcoord(vbuff, hRep, 0);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc2 * R, xs2 * R, -r);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		vertex_normal(vbuff, - n[0], - n[1], - n[2]);
		vertex_texcoord(vbuff, xc2 * hRep, xs2 * vRep);
		vertex_color(vbuff, color, alpha);
		
		var v = matrix_transform_vertex(M, xc1 * R, xs1 * R, -r);
		vertex_position_3d(vbuff, v[0], v[1], v[2]);
		vertex_normal(vbuff, - n[0], - n[1], - n[2]);
		vertex_texcoord(vbuff, xc1 * hRep, xs1 * vRep);
		vertex_color(vbuff, color, alpha);
		
		//Edge
		for (var yy = 0; yy < vVerts; yy ++)
		{
			var ya1 = yy / vVerts * pi;
			var ya2 = (yy+1) / vVerts * pi;
			var yc1 = cos(ya1);
			var ys1 = sin(ya1);
			var yc2 = cos(ya2);
			var ys2 = sin(ya2);
			
			var v = matrix_transform_vertex(M, xc1 * R + xc1 * ys1 * r, xs1 * R + xs1 * ys1 * r, yc1 * r);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var n = matrix_transform_vertex(M, xc1 * ys1, xs1 * ys1, yc1, 0);
			var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
			vertex_normal(vbuff, n[0] / d, n[1] / d, n[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc1 * R + xc1 * ys2 * r, xs1 * R + xs1 * ys2 * r, yc2 * r);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var n = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, yc2, 0);
			var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
			vertex_normal(vbuff, n[0] / d, n[1] / d, n[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * R + xc2 * ys1 * r, xs2 * R + xs2 * ys1 * r, yc1 * r);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var n = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, yc1, 0);
			var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
			vertex_normal(vbuff, n[0] / d, n[1] / d, n[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			
			var v = matrix_transform_vertex(M, xc1 * R + xc1 * ys2 * r, xs1 * R + xs1 * ys2 * r, yc2 * r);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var n = matrix_transform_vertex(M, xc1 * ys2, xs1 * ys2, yc2, 0);
			var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
			vertex_normal(vbuff, n[0] / d, n[1] / d, n[2] / d);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * R + xc2 * ys2 * r, xs2 * R + xs2 * ys2 * r, yc2 * r);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var n = matrix_transform_vertex(M, xc2 * ys2, xs2 * ys2, yc2, 0);
			var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
			vertex_normal(vbuff, n[0] / d, n[1] / d, n[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
			var v = matrix_transform_vertex(M, xc2 * R + xc2 * ys1 * r, xs2 * R + xs2 * ys1 * r, yc1 * r);
			vertex_position_3d(vbuff, v[0], v[1], v[2]);
			var n = matrix_transform_vertex(M, xc2 * ys1, xs2 * ys1, yc1, 0);
			var d = point_distance_3d(0, 0, 0, n[0], n[1], n[2]);
			vertex_normal(vbuff, n[0] / d, n[1] / d, n[2] / d);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, alpha);
			
		}
	}
}