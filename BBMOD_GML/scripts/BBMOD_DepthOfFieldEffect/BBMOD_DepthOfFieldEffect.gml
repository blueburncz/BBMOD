/// @func BBMOD_DepthOfFieldEffect()
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Depth of field (post-processing effect).
function BBMOD_DepthOfFieldEffect()
	: BBMOD_PostProcessEffect() constructor
{
	static PostProcessEffect_destroy = destroy;

	/// @var {Real}
	CoCFocusDepth = 150;

	/// @var {Real}
	CoCScale = 8.0;

	/// @var {Id.Surface}
	/// @private
	__surCoC = -1;

	/// @var {Id.Surface}
	/// @private
	__surCoCBlurred = -1;

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (_depth == undefined)
		{
			return _surfaceSrc;
		}

		gpu_push_state();

		var _width = surface_get_width(_surfaceSrc);
		var _height = surface_get_height(_surfaceSrc);
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;

		var _wheel = mouse_wheel_up() - mouse_wheel_down();
		CoCScale = max(CoCScale + _wheel * keyboard_check(vk_control), 0.0);
		CoCFocusDepth = max(CoCFocusDepth + _wheel * !keyboard_check(vk_control) * 5, 0.0);

		__surCoC = bbmod_surface_check(__surCoC, _width, _height, surface_rgba8unorm, false);
		__surCoCBlurred = bbmod_surface_check(__surCoCBlurred, _width, _height, surface_rgba8unorm, false);

		surface_set_target(__surCoCBlurred);
		draw_clear(c_black);
		shader_set(BBMOD_ShGetCoC);
		shader_set_uniform_f(shader_get_uniform(BBMOD_ShGetCoC, "u_fDepthFocus"), CoCFocusDepth / bbmod_camera_get_zfar());
		draw_surface(_depth, 0, 0);
		shader_reset();
		surface_reset_target();

		shader_set(BBMOD_ShSpreadCoCNear);
		shader_set_uniform_f(shader_get_uniform(BBMOD_ShSpreadCoCNear, "u_fCoCScale"), CoCScale);
		shader_set_uniform_f(shader_get_uniform(BBMOD_ShSpreadCoCNear, "u_vTexel"), _texelWidth, _texelHeight);
		surface_set_target(__surCoC);
		draw_clear(c_black);
		draw_surface(__surCoCBlurred, 0, 0);
		surface_reset_target();
		shader_reset();

		//shader_set(BBMOD_ShBlurCoCNear);
		//var _uTexel = shader_get_uniform(BBMOD_ShBlurCoCNear, "u_vTexel");
		//surface_set_target(__surCoCBlurred);
		//draw_clear(c_black);
		//shader_set_uniform_f(_uTexel, _texelWidth * CoCScale, 0.0);
		//draw_surface(__surCoC, 0, 0);
		//surface_reset_target();

		//surface_set_target(__surCoC);
		//draw_clear(c_black);
		//shader_set_uniform_f(_uTexel, 0.0, _texelHeight * CoCScale);
		//draw_surface(__surCoCBlurred, 0, 0);
		//surface_reset_target();
		//shader_reset();

		//draw_surface(_surface, 0, 0);
		//shader_set(BBMOD_ShDoFFar);
		//var _uDepth = shader_get_sampler_index(BBMOD_ShDoFFar, "u_texDepth");
		//texture_set_stage(_uDepth, surface_get_texture(_depth));
		//gpu_set_tex_repeat_ext(_uDepth, false);
		//gpu_set_tex_filter_ext(_uDepth, false);
		//gpu_set_tex_mip_enable_ext(_uDepth, false);
		//shader_set_uniform_f(shader_get_uniform(BBMOD_ShDoFFar, "u_fDepthFocus"), CoCFocusDepth / bbmod_camera_get_zfar());
		//shader_set_uniform_f(shader_get_uniform(BBMOD_ShDoFFar, "u_fCoCScale"), CoCScale);
		//shader_set_uniform_f(shader_get_uniform(BBMOD_ShDoFFar, "u_vTexel"), _texelWidth, _texelHeight);
		//draw_surface(_surface, 0, 0);
		//shader_reset();

		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShDoFNear);
		var _uCoC = shader_get_sampler_index(BBMOD_ShDoFNear, "u_texCoC");
		texture_set_stage(_uCoC, surface_get_texture(__surCoC));
		gpu_set_tex_repeat_ext(_uCoC, false);
		gpu_set_tex_filter_ext(_uCoC, false);
		gpu_set_tex_mip_enable_ext(_uCoC, false);
		shader_set_uniform_f(shader_get_uniform(BBMOD_ShDoFNear, "u_fCoCScale"), CoCScale);
		shader_set_uniform_f(shader_get_uniform(BBMOD_ShDoFNear, "u_vTexel"), _texelWidth, _texelHeight);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
		if (keyboard_check(ord("Q")))
		{
			draw_surface(__surCoC, 0, 0);
		}
		surface_reset_target();

		gpu_pop_state();

		return _surfaceDest;
	};

	static destroy = function ()
	{
		PostProcessEffect_destroy();
		if (surface_exists(__surCoC))
		{
			surface_free(__surCoC);
		}
		if (surface_exists(__surCoCBlurred))
		{
			surface_free(__surCoCBlurred);
		}
		return undefined;
	};
}
