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
	FocusDepth = 100;

	/// @var {Real}
	CoCScale = 8.0;

	/// @var {Real}
	BladeCount = 6.0;

	/// @var {Id.Surface}
	/// @private
	__surCoC = -1;

	/// @var {Id.Surface}
	/// @private
	__surCoCDownsample1 = -1;

	/// @var {Id.Surface}
	/// @private
	__surCoCDownsample2 = -1;

	/// @var {Id.Surface}
	/// @private
	__surCoCDownsample3 = -1;

	/// @var {Id.Surface}
	/// @private
	__surCoCNear = -1;

	static __uGetCoCFocusDepth = shader_get_uniform(BBMOD_ShGetCoC, "u_fFocusDepth");

	static __uDownsampleCoCTexel = shader_get_uniform(BBMOD_ShDownsampleCoC, "u_vTexel");

	static __uDoFCoCNear = shader_get_sampler_index(BBMOD_ShDoF, "u_texCoCNear");
	static __uDoFCoCFar = shader_get_sampler_index(BBMOD_ShDoF, "u_texCoCFar");
	static __uDoFCoCScale = shader_get_uniform(BBMOD_ShDoF, "u_fCoCScale");
	static __uDoFTexel = shader_get_uniform(BBMOD_ShDoF, "u_vTexel");
	static __uDoFBladeCount = shader_get_uniform(BBMOD_ShDoF, "u_fBladeCount");
	static __uDoFStep = shader_get_uniform(BBMOD_ShDoF, "u_fStep");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (_depth == undefined
			|| CoCScale <= 0.0)
		{
			return _surfaceSrc;
		}

		gpu_push_state();

		var _width = surface_get_width(_surfaceSrc);
		var _height = surface_get_height(_surfaceSrc);
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;

		__surCoC            = bbmod_surface_check(__surCoC,            _width, _height,         surface_rgba8unorm, false);
		__surCoCDownsample1 = bbmod_surface_check(__surCoCDownsample1, _width / 2, _height / 2, surface_rgba8unorm, false);
		__surCoCDownsample2 = bbmod_surface_check(__surCoCDownsample2, _width / 4, _height / 4, surface_rgba8unorm, false);
		__surCoCDownsample3 = bbmod_surface_check(__surCoCDownsample3, _width / 8, _height / 8, surface_rgba8unorm, false);
		__surCoCNear        = bbmod_surface_check(__surCoCNear,        _width / 8, _height / 8, surface_rgba8unorm, false);

		surface_set_target(__surCoC);
		shader_set(BBMOD_ShGetCoC);
		var _invZFar = 1.0 / bbmod_camera_get_zfar();
		shader_set_uniform_f(__uGetCoCFocusDepth, FocusDepth * _invZFar);
		draw_surface(_depth, 0, 0);
		shader_reset();
		surface_reset_target();

		shader_set(BBMOD_ShDownsampleCoC);
		var __uDownsampleTexel = shader_get_uniform(BBMOD_ShDownsampleCoC, "u_vTexel");
		surface_set_target(__surCoCDownsample1);
		shader_set_uniform_f(__uDownsampleTexel, 2.0 / _width, 2.0 / _height);
		draw_surface_stretched(__surCoC, 0, 0, _width / 2, _height / 2);
		surface_reset_target()

		surface_set_target(__surCoCDownsample2);
		shader_set_uniform_f(__uDownsampleTexel, 4.0 / _width, 4.0 / _height);
		draw_surface_stretched(__surCoCDownsample1, 0, 0, _width / 4, _height / 4);
		surface_reset_target()

		surface_set_target(__surCoCNear);
		shader_set_uniform_f(__uDownsampleTexel, 8.0 / _width, 8.0 / _height);
		draw_surface_stretched(__surCoCDownsample2, 0, 0, _width / 8, _height / 8);
		surface_reset_target()
		shader_reset();

		shader_set(BBMOD_ShGaussianBlur);
		var __uBlurTexel = shader_get_uniform(BBMOD_ShGaussianBlur, "u_vTexel");
		surface_set_target(__surCoCDownsample3);
		shader_set_uniform_f(__uBlurTexel, 8.0 / _width, 0.0);
		draw_surface(__surCoCNear, 0, 0);
		surface_reset_target()

		surface_set_target(__surCoCNear);
		shader_set_uniform_f(__uBlurTexel, 0.0, 8.0 / _height);
		draw_surface(__surCoCDownsample3, 0, 0);
		surface_reset_target()
		shader_reset();

		surface_set_target(_surfaceDest);
		shader_set(BBMOD_ShDoF);

		texture_set_stage(__uDoFCoCFar, surface_get_texture(__surCoC));
		gpu_set_tex_repeat_ext(__uDoFCoCFar, false);
		gpu_set_tex_filter_ext(__uDoFCoCFar, true);
		gpu_set_tex_mip_enable_ext(__uDoFCoCFar, false);

		texture_set_stage(__uDoFCoCNear, surface_get_texture(__surCoCNear));
		gpu_set_tex_repeat_ext(__uDoFCoCNear, false);
		gpu_set_tex_filter_ext(__uDoFCoCNear, true);
		gpu_set_tex_mip_enable_ext(__uDoFCoCNear, false);

		var _cocScale = min(CoCScale, 8.0);

		shader_set_uniform_f(__uDoFCoCScale, _cocScale);
		shader_set_uniform_f(__uDoFTexel, _texelWidth, _texelHeight);
		shader_set_uniform_f(__uDoFBladeCount, BladeCount);
		shader_set_uniform_f(__uDoFStep, 2.0 / _cocScale);
		draw_surface(_surfaceSrc, 0, 0);
		shader_reset();
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
		if (surface_exists(__surCoCDownsample1))
		{
			surface_free(__surCoCDownsample1);
		}
		if (surface_exists(__surCoCDownsample2))
		{
			surface_free(__surCoCDownsample2);
		}
		if (surface_exists(__surCoCDownsample3))
		{
			surface_free(__surCoCDownsample3);
		}
		if (surface_exists(__surCoCNear))
		{
			surface_free(__surCoCNear);
		}
		return undefined;
	};
}
