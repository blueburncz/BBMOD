function cm_disk_debug_draw(disk, tex = -1, color = undefined, alpha = 1, mask = 0)
{
	if (mask > 0 && (mask & CM_DISK_GROUP) == 0){return false;}
	
	var vbuff = cm_get_vbuffer(disk);
	
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
	
	static M = array_create(16);
	var cx = CM_DISK_X;
	var cy = CM_DISK_Y;
	var cz = CM_DISK_Z;
	var nx = CM_DISK_NX;
	var ny = CM_DISK_NY;
	var nz = CM_DISK_NZ;
	var r  = CM_DISK_SMALLRADIUS;
	var R  = CM_DISK_BIGRADIUS;
	
	var W = matrix_get(matrix_world);
	var scale = point_distance_3d(0, 0, 0, W[0], W[1], W[2]);
	cm_matrix_build_from_vector(cx, cy, cz, nx, ny, nz, R, R, R, M);
		
	var reset = false;
	if (shader_current() == -1)
	{
		shader_set(sh_cm_debug);	
		reset = true;
	}
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_radius"), r * scale);
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_color"), color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, alpha);
	matrix_set(matrix_world, matrix_multiply(M, W));
	vertex_submit(vbuff, pr_trianglelist, tex);
	matrix_set(matrix_world, W);
	
	if (reset)
	{
		shader_reset();	
	}
}

function cm_create_disk_vbuff(hVerts, vVerts, hRep, vRep, color)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.cm_format);
	for (var xx = 0; xx < hVerts; xx ++)
	{
		var xa1 = xx / hVerts * 2 * pi;
		var xa2 = (xx+1) / hVerts * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		
		vertex_position_3d(vbuff, 1, 0, 0);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, hRep, 0);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, xc1 * hRep, xs1 * vRep);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, xc2 * hRep, xs2 * vRep);
		vertex_color(vbuff, color, 1);
		
		
		vertex_position_3d(vbuff, 1, 0, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, hRep, 0);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, xc2 * hRep, xs2 * vRep);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, xc1 * hRep, xs1 * vRep);
		vertex_color(vbuff, color, 1);
		
		
		for (var yy = 0; yy < vVerts; yy ++)
		{
			var ya1 = yy / vVerts * pi;
			var ya2 = (yy+1) / vVerts * pi;
			var yc1 = cos(ya1);
			var ys1 = sin(ya1);
			var yc2 = cos(ya2);
			var ys2 = sin(ya2);
			
			vertex_position_3d(vbuff, xc1, xs1, 0);
			vertex_normal(vbuff, xc1 * ys1, xs1 * ys1, yc1);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, xc1, xs1, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, xc2, xs2, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			
			vertex_position_3d(vbuff, xc1, xs1, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, xc2, xs2, 0);
			vertex_normal(vbuff, xc2 * ys2, xs2 * ys2, yc2);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, xc2, xs2, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
		}
	}
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}