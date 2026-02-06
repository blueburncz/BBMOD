function cm_box_debug_draw(box, tex = -1, color = undefined, alpha = 1, mask = 0)
{
	if (mask > 0 && (mask & CM_BOX_GROUP) == 0){return false;}
	
	var vbuff = cm_get_vbuffer(box);
	
	var m = CM_BOX_M;
	if (is_undefined(color))
	{
		color = c_white;
	}
	if (color < 0)
	{
		//Make a seed for this object by combinging its parameters
		var seed = 0;
		for (var i = 0; i < 16; ++i){seed += m[i];}
		color = make_color_hsv(floor(abs(seed) mod 256), 200, 230);
	}
	var reset = false;
	if (shader_current() == -1)
	{
		shader_set(sh_cm_debug);	
		reset = true;
	}
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_radius"), 0);
	shader_set_uniform_f(shader_get_uniform(shader_current(), "u_color"), color_get_red(color) / 255, color_get_green(color) / 255, color_get_blue(color) / 255, alpha);
	var W = matrix_get(matrix_world);
	matrix_set(matrix_world, matrix_multiply(m, W));
	vertex_submit(vbuff, pr_trianglelist, tex);
	matrix_set(matrix_world, W);
	
	if (reset) shader_reset();
}