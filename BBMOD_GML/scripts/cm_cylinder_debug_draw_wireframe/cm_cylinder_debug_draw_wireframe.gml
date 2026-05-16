function cm_cylinder_debug_draw_wireframe(cylinder, tex = -1, color = undefined, alpha = 1, mask = 0)
{
	if (mask > 0 && (mask & CM_CYLINDER_GROUP) == 0){return false;}
	
	var vbuff = global.cm_vbuffers_wf[CM_OBJECTS.CYLINDER];
	if (vbuff < 0)
	{
		vbuff = cm_create_cylinder_vbuff_wireframe(20, 1, 1, c_white);
		global.cm_vbuffers_wf[CM_OBJECTS.CYLINDER] = vbuff;
	}
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
	
	static M = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
	var R = CM_CYLINDER_R;
	var H = point_distance_3d(CM_CYLINDER_DX, CM_CYLINDER_DY, CM_CYLINDER_DZ, 0, 0, 0);
	static M = matrix_build_identity();
	cm_matrix_build_from_vector(CM_CYLINDER_X1, CM_CYLINDER_Y1, CM_CYLINDER_Z1, CM_CYLINDER_DX, CM_CYLINDER_DY, CM_CYLINDER_DZ, R, R, H, M);
		
	var W = matrix_get(matrix_world);
	var scale = point_distance_3d(0, 0, 0, W[0], W[1], W[2]);
	var reset = false;
	if (shader_current() == -1)
	{
		shader_set(sh_cm_debug);
		reset = true;
	}
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_radius"), 0);
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_color"), color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, alpha);
	matrix_set(matrix_world, matrix_multiply(M, W));
	vertex_submit(vbuff, pr_linelist, tex);
	matrix_set(matrix_world, W);
	
	if (reset)
	{
		shader_reset();	
	}
}

function cm_create_cylinder_vbuff_wireframe(steps, hRep, vRep, color)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.cm_format);
	for (var xx = 0; xx < steps; xx ++)
	{
		var xa1 = xx / steps * 2 * pi;
		var xa2 = (xx+1) / steps * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / steps * hRep, 0);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, xc1, xs1, 1);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / steps * hRep, vRep);
		vertex_color(vbuff, color, 1);
		
		
		//Bottom lid
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, (.5 + .5 * xc2) * hRep, (.5 + .5 * xs2) * vRep);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, (.5 + .5 * xc1) * hRep, (.5 + .5 * xs1) * vRep);
		vertex_color(vbuff, color, 1);
		
		
		//Top lid
		vertex_position_3d(vbuff, xc1, xs1, 1);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, (.5 + .5 * xc1) * hRep, (.5 + .5 * xs1) * vRep);
		vertex_color(vbuff, color, 1);
		
		vertex_position_3d(vbuff, xc2, xs2, 1);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, (.5 + .5 * xc2) * hRep, (.5 + .5 * xs2) * vRep);
		vertex_color(vbuff, color, 1);
		
	}
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}

