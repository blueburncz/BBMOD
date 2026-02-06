function cm_capsule_debug_draw(capsule, tex = -1, color = undefined, alpha = 1, mask = 0)
{
	if (mask > 0 && (mask & CM_CAPSULE_GROUP) == 0){return false;}
	
	var vbuff = cm_get_vbuffer(capsule);
	
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
	static M = matrix_build_identity();
	if (H > 0)
	{
		cm_matrix_build_from_vector(CM_CAPSULE_X1, CM_CAPSULE_Y1, CM_CAPSULE_Z1, CM_CAPSULE_DX, CM_CAPSULE_DY, CM_CAPSULE_DZ, 1, 1, H, M);
	}
	else
	{
		M = matrix_build(CM_CAPSULE_X1, CM_CAPSULE_Y1, CM_CAPSULE_Z1, 0, 0, 0, 1, 1, 1);
	}
		
	var W = matrix_get(matrix_world);
	var scale = point_distance_3d(0, 0, 0, W[0], W[1], W[2]);
	if (shader_current() == -1)
	{
		shader_set(sh_cm_debug);	
	}
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_radius"), CM_CAPSULE_R * scale);
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_color"), color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, alpha);
	matrix_set(matrix_world, matrix_multiply(M, W));
	vertex_submit(vbuff, pr_trianglelist, tex);
	matrix_set(matrix_world, W);
	
	if (shader_current() == sh_cm_debug)
	{
		shader_reset();	
	}
}

function cm_create_capsule_vbuff(hVerts, vVerts, hRep, vRep, color)
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
		
		vertex_position_3d(vbuff, 0, 0, 0);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / hVerts * hRep, 0);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, 0, 0, 0);
		vertex_normal(vbuff, xc2, xs2, 0);
		vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, 0);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, 0, 0, 1);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / hVerts * hRep, vRep);
		vertex_color(vbuff, color, 1);
		
		
		vertex_position_3d(vbuff, 0, 0, 0);
		vertex_normal(vbuff, xc2, xs2, 0);
		vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, 0);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, 0, 0, 1);
		vertex_normal(vbuff, xc2, xs2, 0);
		vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, vRep);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, 0, 0, 1);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / hVerts * hRep, vRep);
		vertex_color(vbuff, color, 1);
		
		
		for (var yy = 0; yy < vVerts; yy ++)
		{
			var ya1 = yy / vVerts * pi / 2;
			var ya2 = (yy+1) / vVerts * pi / 2;
			var yc1 = cos(ya1);
			var ys1 = sin(ya1);
			var yc2 = cos(ya2);
			var ys2 = sin(ya2);
			
			//Draw the bottom hemisphere
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc1 * ys1, xs1 * ys1, - yc1);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, - yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, - yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, - yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, - yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc2 * ys2, xs2 * ys2, - yc2);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			
			//Draw top hemisphere
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc1 * ys1, xs1 * ys1, yc1);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc2 * ys2, xs2 * ys2, yc2);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_color(vbuff, color, 1);
			
		}
	}
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}

