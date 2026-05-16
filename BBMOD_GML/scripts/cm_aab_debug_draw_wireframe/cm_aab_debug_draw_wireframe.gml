function cm_aab_debug_draw_wireframe(aab, tex = -1, color = undefined, alpha = 1, mask = 0)
{
	if (mask > 0 && (mask & CM_AAB_GROUP) == 0){return false;}
	
	var vbuff = global.cm_vbuffers_wf[CM_OBJECTS.AAB];
	if (vbuff < 0)
	{
		vbuff = cm_create_block_vbuff_wireframe(1, 1, c_white);
		global.cm_vbuffers_wf[CM_OBJECTS.AAB] = vbuff;
	}
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
	
	static M = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
	M[0]  = CM_AAB_HALFX;
	M[5]  = CM_AAB_HALFY;
	M[10] = CM_AAB_HALFZ;
	M[12] = CM_AAB_X;
	M[13] = CM_AAB_Y;
	M[14] = CM_AAB_Z;
		
	var sh = shader_current();
	var W = matrix_get(matrix_world);
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

function cm_create_block_vbuff_wireframe(hRep, vRep, color)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.cm_format);
	
	//+z
	vertex_position_3d(vbuff, -1, -1, 1);
	vertex_normal(vbuff, -1, -1, 1);
	vertex_texcoord(vbuff, 0, 0);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, -1, 1);
	vertex_normal(vbuff, 1, -1, 1);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, 1, 1);
	vertex_normal(vbuff, -1, 1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, 1, 1);
	vertex_normal(vbuff, 1, 1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, -1, 1);
	vertex_normal(vbuff, -1, -1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, 1, 1);
	vertex_normal(vbuff, -1, 1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, -1, 1);
	vertex_normal(vbuff, 1, -1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, 1, 1);
	vertex_normal(vbuff, 1, 1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, -1, 1);
	vertex_normal(vbuff, -1, -1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, 1, 1);
	vertex_normal(vbuff, 1, 1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, 1, 1);
	vertex_normal(vbuff, -1, 1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, -1, 1);
	vertex_normal(vbuff, 1, -1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	//-z
	vertex_position_3d(vbuff, -1, -1, -1);
	vertex_normal(vbuff, -1, -1, -1);
	vertex_texcoord(vbuff, 0, 0);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, -1, -1);
	vertex_normal(vbuff, 1, -1, -1);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, 1, -1);
	vertex_normal(vbuff, -1, 1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, 1, -1);
	vertex_normal(vbuff, 1, 1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, -1, -1);
	vertex_normal(vbuff, -1, -1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, 1, -1);
	vertex_normal(vbuff, -1, 1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, -1, -1);
	vertex_normal(vbuff, 1, -1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, 1, -1);
	vertex_normal(vbuff, 1, 1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, -1, -1);
	vertex_normal(vbuff, -1, -1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, 1, -1);
	vertex_normal(vbuff, 1, 1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, 1, -1);
	vertex_normal(vbuff, -1, 1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, -1, -1);
	vertex_normal(vbuff, 1, -1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	//Vertical edges
	vertex_position_3d(vbuff, -1, -1, 1);
	vertex_normal(vbuff,  -1, -1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, -1, -1);
	vertex_normal(vbuff, -1, -1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, -1, 1);
	vertex_normal(vbuff, 1, -1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, -1, -1);
	vertex_normal(vbuff, 1, -1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, 1, 1);
	vertex_normal(vbuff, -1, 1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, -1, 1, -1);
	vertex_normal(vbuff, -1, 1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, 1, 1);
	vertex_normal(vbuff, 1, 1, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	vertex_position_3d(vbuff, 1, 1, -1);
	vertex_normal(vbuff, 1, 1, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_color(vbuff, color, 1);
	
	
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}