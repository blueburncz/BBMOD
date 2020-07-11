var _shader = BBMOD_ShPostProcess;
shader_set(_shader);
var _lut_index = shader_get_sampler_index(_shader, "u_texLut");
texture_set_stage(_lut_index, sprite_get_texture(BBMOD_SprColorGrading, 0));
gpu_set_tex_filter_ext(_lut_index, true);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fLutIndex"), 0);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
	1 / surface_get_width(application_surface),
	1 / surface_get_height(application_surface));
shader_set_uniform_f(shader_get_uniform(_shader, "u_fDistortion"), 6);
var _scale = 1 / application_surface_scale;
draw_surface_ext(application_surface, 0, 0, _scale, _scale, 0, c_white, 1);
shader_reset();

//draw_sprite_part(SprColorGrading, 0, 0, 0, 256, 16, 0, 0);

switch (mode_current)
{
case EMode.Normal:
	draw_text(0, 32, "with (instances) {}");
	break;

case EMode.Static:
	draw_text(0, 32, "Static batch");
	break;

case EMode.Dynamic:
	draw_text(0, 32, "Dynamic batch");
	break;
}