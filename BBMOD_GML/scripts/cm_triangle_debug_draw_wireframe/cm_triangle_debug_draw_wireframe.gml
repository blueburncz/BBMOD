function cm_triangle_debug_draw_wireframe(triangle, tex = -1, color = undefined, alpha = 1, mask = 0)
{
	if (mask > 0 && (mask & CM_TRIANGLE_GROUP) == 0){return false;}
	static vbuff = vertex_create_buffer();
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
	var n = [CM_TRIANGLE_NX, CM_TRIANGLE_NY, CM_TRIANGLE_NZ];
	
	vertex_begin(vbuff, global.cm_format);
	
		if smooth n = CM_TRIANGLE_N1;
		vertex_position_3d(vbuff, CM_TRIANGLE_X1, CM_TRIANGLE_Y1, CM_TRIANGLE_Z1);
		vertex_normal(vbuff, n[0], n[1], n[2]);
		vertex_texcoord(vbuff, 0, 0);
		vertex_color(vbuff, color, 1);
	
		if smooth n = CM_TRIANGLE_N2;
		vertex_position_3d(vbuff, CM_TRIANGLE_X2, CM_TRIANGLE_Y2, CM_TRIANGLE_Z2);
		vertex_normal(vbuff, n[0], n[1], n[2]);
		vertex_texcoord(vbuff, 1, 0);
		vertex_color(vbuff, color, 1);
	
		if smooth n = CM_TRIANGLE_N3;
		vertex_position_3d(vbuff, CM_TRIANGLE_X3, CM_TRIANGLE_Y3, CM_TRIANGLE_Z3);
		vertex_normal(vbuff, n[0], n[1], n[2]);
		vertex_texcoord(vbuff, 0, 1);
		vertex_color(vbuff, color, 1);
		
		if smooth n = CM_TRIANGLE_N1;
		vertex_position_3d(vbuff, CM_TRIANGLE_X1, CM_TRIANGLE_Y1, CM_TRIANGLE_Z1);
		vertex_normal(vbuff, n[0], n[1], n[2]);
		vertex_texcoord(vbuff, 0, 0);
		vertex_color(vbuff, color, 1);
	
	vertex_end(vbuff);
	
	var reset = false;
	if (shader_current() == -1)
	{
		shader_set(sh_cm_debug);	
		reset = true;
	}
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_radius"), 0);
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_color"), color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, alpha);
	
	vertex_submit(vbuff, pr_linestrip, tex);
	
	if (reset)
	{
		shader_reset();	
	}
}