/// @func BBMOD_DepthOfFieldEffect()
///
/// @extends BBMOD_PostProcessEffect
///
/// @desc Depth of field (post-processing effect).
function BBMOD_DepthOfFieldEffect()
	: BBMOD_PostProcessEffect() constructor
{
	static PostProcessEffect_destroy = destroy;

	/// @var {Real} Distance from the camera from which are objects completely
	/// in focus. Ignored if `AutoFocus` is enabled. Default value is 100.
	/// @see BBMOD_DepthOfFieldEffect.AutoFocus
	FocusStart = 100;

	/// @var {Real} Distance from the camera to which are objects completely in
	/// focus. Ignored if `AutoFocus` is enabled. Default value is 200.
	/// @see BBMOD_DepthOfFieldEffect.AutoFocus
	FocusEnd = 200;

	/// @var {Bool} If `true` then focus distance is automatically computed from
	/// the depth buffer. Default value is `false`.
	/// @see BBMOD_DepthOfFieldEffect.AutoFocusPoint
	AutoFocus = false;

	/// @var {Struct.BBMOD_Vec2} Screen coordiate to sample the depth buffer at
	/// when `AutoFocus` is enabled. Use values in range `(0, 0)` (top left
	/// corner) to `(1, 1)` (bottom right corner). Default value is `(0.5, 0.5)`
	/// (screen center).
	///
	/// @note This requires readback of the depth buffer on the CPU, which
	/// negatively affects performance!
	///
	/// @see BBMOD_DepthOfFieldEffect.AutoFocus
	AutoFocusPoint = new BBMOD_Vec2(0.5);

	/// @var {Real} Determines how fast the current focus distance lerps to the
	/// auto focus distance. Use values in range `(0; 1]`, where values closer
	/// to 0 mean slowly and 1 means immediately. Default value is 0.1.
	/// @see BBMOD_DepthOfFieldEffect.AutoFocus
	AutoFocusFactor = 0.1;

	/// @var {Real} Distance over which objects transition from completely in
	/// focus to competely out of focus in the near plane. Default value is 50.
	BlurRangeNear = 50;

	/// @var {Real} Distance over which objects transition from completely in
	/// focus to completely out of focus in the far plane. Default value is 50.
	BlurRangeFar = 50;

	/// @var {Real} The scale of the blur size in the near plane. Use values in
	/// range 0..1, where 0 is disabled and 1 is full blur. Using values greater
	/// than 1 is possible but can produce visual artifacts. Default value is 1.
	BlurScaleNear = 1.0;

	/// @var {Real} The scale of the blur size in the far plane. Use values in
	/// range 0..1, where 0 is disabled and 1 is full blur. Using values greater
	/// than 1 is possible but can produce visual artifacts. Default value is 1.
	BlurScaleFar = 1.0;

	/// @var {Real} Controls the shape of bokeh. Use values greater or equal to
	/// 3 for number of edges. Values lower than 3 result into a perfect circle.
	/// Default value is 6 (hexagon).
	BokehShape = 6.0;

	/// @var {Real} Number of samples taken when rendering the depth of field.
	/// Greater values produce better looking results but decrease performance.
	/// Default value is 32.
	SampleCount = 32;

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

	/// @var {Id.Surface}
	/// @private
	__surAutoFocus = -1;

	static __uGetCoCFocusStart = shader_get_uniform(BBMOD_ShGetCoC, "u_fFocusStart");
	static __uGetCoCFocusEnd = shader_get_uniform(BBMOD_ShGetCoC, "u_fFocusEnd");
	static __uGetCoCBlurRangeNear = shader_get_uniform(BBMOD_ShGetCoC, "u_fBlurRangeNear");
	static __uGetCoCBlurRangeFar = shader_get_uniform(BBMOD_ShGetCoC, "u_fBlurRangeFar");

	static __uDownsampleCoCTexel = shader_get_uniform(BBMOD_ShDownsampleCoC, "u_vTexel");

	static __uDoFCoCNear = shader_get_sampler_index(BBMOD_ShDoF, "u_texCoCNear");
	static __uDoFCoCFar = shader_get_sampler_index(BBMOD_ShDoF, "u_texCoCFar");
	static __uDoFCoCScaleNear = shader_get_uniform(BBMOD_ShDoF, "u_fCoCScaleNear");
	static __uDoFCoCScaleFar = shader_get_uniform(BBMOD_ShDoF, "u_fCoCScaleFar");
	static __uDoFTexel = shader_get_uniform(BBMOD_ShDoF, "u_vTexel");
	static __uDoFBokehShape = shader_get_uniform(BBMOD_ShDoF, "u_fBokehShape");
	static __uDoFStep = shader_get_uniform(BBMOD_ShDoF, "u_fStep");

	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		if (_depth == undefined)
		{
			return _surfaceSrc;
		}

		var _width = surface_get_width(_surfaceSrc);
		var _height = surface_get_height(_surfaceSrc);
		var _zfar = bbmod_camera_get_zfar();

		if (AutoFocus)
		{
			var _focusPointX = round((_width - 1) * clamp(AutoFocusPoint.X, 0, 1));
			var _focusPointY = round((_height - 1) * clamp(AutoFocusPoint.Y, 0, 1));
			__surAutoFocus = bbmod_surface_check(__surAutoFocus, 1, 1, surface_rgba8unorm, false);
			surface_copy_part(__surAutoFocus, 0, 0, _depth, _focusPointX, _focusPointY, 1, 1);
			var _pixel = surface_getpixel(__surAutoFocus, 0, 0);
			var _r = color_get_red(_pixel) / 255.0;
			var _g = color_get_green(_pixel) / 255.0;
			var _b = color_get_blue(_pixel) / 255.0;
			var _inv255 = 1.0 / 255.0;
			var _focusDepth = (_r + (_g * _inv255) + (_b * _inv255 * _inv255)) * _zfar;
			FocusStart += (_focusDepth - FocusStart) * AutoFocusFactor;
			FocusEnd = FocusStart;
		}

		if (SampleCount < 1
			|| (BlurScaleNear <= 0.0 && BlurScaleFar <= 0.0))
		{
			return _surfaceSrc;
		}

		gpu_push_state();

		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;

		__surCoC            = bbmod_surface_check(__surCoC,            _width, _height,         surface_rgba8unorm, false);
		__surCoCDownsample1 = bbmod_surface_check(__surCoCDownsample1, _width / 2, _height / 2, surface_rgba8unorm, false);
		__surCoCDownsample2 = bbmod_surface_check(__surCoCDownsample2, _width / 4, _height / 4, surface_rgba8unorm, false);
		__surCoCDownsample3 = bbmod_surface_check(__surCoCDownsample3, _width / 8, _height / 8, surface_rgba8unorm, false);
		__surCoCNear        = bbmod_surface_check(__surCoCNear,        _width / 8, _height / 8, surface_rgba8unorm, false);

		// Get CoC
		surface_set_target(__surCoC);
		shader_set(BBMOD_ShGetCoC);
		var _invZFar = 1.0 / _zfar;
		var _focusStart = min(FocusStart, FocusEnd);
		var _focusEnd = max(FocusStart, FocusEnd);
		shader_set_uniform_f(__uGetCoCFocusStart, _focusStart * _invZFar);
		shader_set_uniform_f(__uGetCoCFocusEnd, _focusEnd * _invZFar);
		shader_set_uniform_f(__uGetCoCBlurRangeNear, BlurRangeNear * _invZFar);
		shader_set_uniform_f(__uGetCoCBlurRangeFar, BlurRangeFar * _invZFar);
		draw_surface(_depth, 0, 0);
		shader_reset();
		surface_reset_target();

		// Downsample near CoC
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

		// Blur downsampled CoC
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

		// Apply DoF
		surface_set_target(_surfaceDest);
		draw_surface(_surfaceSrc, 0, 0);
		shader_set(BBMOD_ShDoF);

		texture_set_stage(__uDoFCoCFar, surface_get_texture(__surCoC));
		gpu_set_tex_repeat_ext(__uDoFCoCFar, false);
		gpu_set_tex_filter_ext(__uDoFCoCFar, true);
		gpu_set_tex_mip_enable_ext(__uDoFCoCFar, false);

		texture_set_stage(__uDoFCoCNear, surface_get_texture(__surCoCNear));
		gpu_set_tex_repeat_ext(__uDoFCoCNear, false);
		gpu_set_tex_filter_ext(__uDoFCoCNear, true);
		gpu_set_tex_mip_enable_ext(__uDoFCoCNear, false);

		var _cocScaleNear = max(BlurScaleNear * 8.0, 0.0);
		var _cocScaleFar = max(BlurScaleFar * 8.0, 0.0);

		shader_set_uniform_f(__uDoFCoCScaleNear, _cocScaleNear);
		shader_set_uniform_f(__uDoFCoCScaleFar, _cocScaleFar);
		shader_set_uniform_f(__uDoFTexel, _texelWidth, _texelHeight);
		shader_set_uniform_f(__uDoFBokehShape, BokehShape);
		shader_set_uniform_f(__uDoFStep, 2.0 / sqrt(SampleCount));
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
		if (surface_exists(__surAutoFocus))
		{
			surface_free(__surAutoFocus);
		}
		return undefined;
	};
}
