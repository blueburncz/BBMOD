/// @module Rendering.PostProcessing

/// @func BBMOD_PostProcessor()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Handles post-processing effects like color grading, chromatic
/// aberration, grayscale effect, vignette and anti-aliasing.
///
/// @see BBMOD_PostProcessEffect
function BBMOD_PostProcessor() constructor
{
	/// @var {Bool} If `true` then the post-processor is enabled. Default value
	/// is `true`.
	Enabled = true;

	/// @var {Array<Struct.BBMOD_PostProcessEffect>} An array of all effects
	/// added to the post-processor.
	/// @readonly
	Effects = [];

	/// @var {Pointer.Texture} The lookup table texture used for color grading.
	/// @deprecated Please use {@link BBMOD_ColorGradingEffect} instead.
	ColorGradingLUT = sprite_get_texture(BBMOD_SprColorGradingLUT, 0);

	/// @var {Real} The strength of the chromatic aberration effect. Use 0 to
	/// disable the effect. Defaults to 0.
	/// @deprecated Please use {@link BBMOD_ChromaticAberrationEffect} instead.
	ChromaticAberration = 0.0;

	/// @var {Struct.BBMOD_Vec3} Chromatic aberration offsets for RGB channels.
	/// Defaults to `(-1, 0, 1)`.
	/// @deprecated Please use {@link BBMOD_ChromaticAberrationEffect} instead.
	ChromaticAberrationOffset = new BBMOD_Vec3(-1.0, 0.0, 1.0);

	/// @var {Real} The strength of the grayscale effect. Use values in range
	/// 0..1, where 0 means the original color and 1 means grayscale. Defaults
	/// to 0.
	/// @deprecated Please use {@link BBMOD_MonochromeEffect} instead.
	Grayscale = 0.0;

	/// @var {Real} The strength of the vignette effect. Defaults to 0.
	/// @deprecated Please use {@link BBMOD_VignetteEffect} instead.
	Vignette = 0.0;

	/// @var {Constant.Color} The color of the vignette effect. Defaults to
	/// `c_black`.
	/// @deprecated Please use {@link BBMOD_VignetteEffect} instead.
	VignetteColor = c_black;

	/// @var {Real} Antialiasing technique to use. Use values from
	/// {@link BBMOD_EAntialiasing}. Defaults to
	/// {@link BBMOD_EAntialiasing.None}.
	/// @deprecated Please use {@link BBMOD_FXAAEffect} instead.
	Antialiasing = BBMOD_EAntialiasing.None;

	/// @var {Id.Surface}
	/// @private
	__surPostProcess1 = -1;

	/// @var {Id.Surface}
	/// @private
	__surPostProcess2 = -1;

	/// @func add_effect(_effect)
	///
	/// @desc Adds an effect to the post-processor.
	///
	/// @param {Struct.BBMOD_PostProcessEffect} _effect The effect to add.
	///
	/// @return {Struct.BBMOD_PostProcessor} Returns `self`.
	static add_effect = function (_effect)
	{
		gml_pragma("forceinline");
		bbmod_assert(
			_effect.PostProcessor == undefined,
			"Effect is already added to a post-processor!");
		array_push(Effects, _effect);
		_effect.PostProcessor = self;
		return self;
	};

	/// @func remove_effect(_effect)
	///
	/// @desc Removes an effect from the post-processor.
	///
	/// @param {Struct.BBMOD_PostProcessEffect} _effect The effect to add.
	///
	/// @return {Struct.BBMOD_PostProcessor} Returns `self`.
	static remove_effect = function (_effect)
	{
		bbmod_assert(
			_effect.PostProcessor == self,
			"Effect is not added to this post-processor!");
		for (var i = array_length(Effects) - 1; i >= 0; --i)
		{
			if (Effects == _effect)
			{
				_effect.PostProcessor = undefined;
				array_delete(Effects, i, 1);
				break;
			}
		}
		return self;
	};

	/// @func draw(_surface, _x, _y[, _depth[, _normals]])
	///
	/// @desc If enabled, draws a surface with post-processing applied,
	/// otherwise draws the original surface.
	///
	/// @param {Id.Surface} _surface The surface to draw with post-processing
	/// applied.
	/// @param {Real} _x The X position to draw the surface at.
	/// @param {Real} _y The Y position to draw the surface at.
	/// @param {Id.Surface} [_depth] A surface containing the scene depth
	/// encoded into RGB channels or `undefined` if not available.
	/// @param {Id.Surface} [_normals] A surface containing the scene's
	/// world-space normals in the RGB channels or `undefined` if not available.
	///
	/// @return {Struct.BBMOD_PostProcessor} Returns `self`.
	///
	/// @see BBMOD_PostProcessor.Enabled
	static draw = function (
		_surface, _x, _y, _depth=undefined, _normals=undefined)
	{
		if (!Enabled)
		{
			draw_surface(_surface, _x, _y);
			return self;
		}

		var _width = surface_get_width(_surface);
		var _height = surface_get_height(_surface);
		var _world = matrix_get(matrix_world);
		matrix_set(matrix_world, matrix_build_identity());

		__surPostProcess1 = bbmod_surface_check(
			__surPostProcess1, _width, _height, surface_rgba8unorm, false);
		__surPostProcess2 = bbmod_surface_check(
			__surPostProcess2, _width, _height, surface_rgba8unorm, false);

		var _surSrc = _surface;
		var _surDest = __surPostProcess1;

		gpu_push_state();
		gpu_set_tex_filter(true);
		gpu_set_tex_repeat(false);
		gpu_set_blendenable(false);

		////////////////////////////////////////////////////////////////////////
		//
		// Legacy
		//
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;

		surface_set_target(_surDest);

		////////////////////////////////////////////////////////////////////////
		// Do post-processing
		var _shader = BBMOD_ShPostProcess;
		shader_set(_shader);
		texture_set_stage(
			shader_get_sampler_index(_shader, "u_texLut"),
			ColorGradingLUT);
		shader_set_uniform_f(
			shader_get_uniform(_shader, "u_vTexel"),
			_texelWidth, _texelHeight);
		shader_set_uniform_f(
			shader_get_uniform(_shader, "u_vOffset"),
			ChromaticAberrationOffset.X,
			ChromaticAberrationOffset.Y,
			ChromaticAberrationOffset.Z);
		shader_set_uniform_f(
			shader_get_uniform(_shader, "u_fDistortion"),
			ChromaticAberration);
		shader_set_uniform_f(
			shader_get_uniform(_shader, "u_fGrayscale"),
			Grayscale);
		shader_set_uniform_f(
			shader_get_uniform(_shader, "u_fVignette"),
			Vignette);
		shader_set_uniform_f(
			shader_get_uniform(_shader, "u_vVignetteColor"),
			color_get_red(VignetteColor) / 255.0,
			color_get_green(VignetteColor) / 255.0,
			color_get_blue(VignetteColor) / 255.0);
		draw_surface(_surSrc, 0, 0);
		shader_reset();

		surface_reset_target();

		_surSrc = _surDest;
		_surDest = __surPostProcess2;

		////////////////////////////////////////////////////////////////////////
		// Apply anti-aliasing to the final surface
		if (Antialiasing == BBMOD_EAntialiasing.FXAA)
		{
			surface_set_target(_surDest);

			_shader = BBMOD_ShFXAA;
			shader_set(_shader);
			shader_set_uniform_f(
				shader_get_uniform(_shader, "u_vTexelVS"),
				_texelWidth, _texelHeight);
			shader_set_uniform_f(
				shader_get_uniform(_shader, "u_vTexelPS"),
				_texelWidth, _texelHeight);
			draw_surface(_surSrc, 0, 0);
			shader_reset();

			surface_reset_target();

			var _temp = _surSrc;
			_surSrc = _surDest;
			_surDest = _temp;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// New post-processing chain
		//
		var _count = array_length(Effects);

		for (var i = 0; i < _count; ++i)
		{
			var _effect = Effects[i];
			if (_effect.Enabled)
			{
				_surSrc = _effect.draw(_surDest, _surSrc, _depth, _normals);
				_surDest = (_surSrc == __surPostProcess1)
					? __surPostProcess2 : __surPostProcess1;
			}
		}

		draw_surface(_surSrc, _x, _y);

		////////////////////////////////////////////////////////////////////////

		matrix_set(matrix_world, _world);
		gpu_pop_state();

		return self;
	};

	static destroy = function ()
	{
		for (var i = array_length(Effects) - 1; i >= 0; --i)
		{
			Effects[i].destroy();
		}
		Effects = undefined;

		if (surface_exists(__surPostProcess1))
		{
			surface_free(__surPostProcess1);
		}

		if (surface_exists(__surPostProcess2))
		{
			surface_free(__surPostProcess2);
		}

		return undefined;
	};
}
