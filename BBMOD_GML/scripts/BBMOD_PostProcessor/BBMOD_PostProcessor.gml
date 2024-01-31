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
	/// @var {Id.Surface}
	/// @private
	__surPostProcess = -1;

	/// @var {Bool} If `true` then the post-processor is enabled. Default value
	/// is `true`.
	Enabled = true;

	/// @var {Pointer.Texture} The lookup table texture used for color grading.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	ColorGradingLUT = sprite_get_texture(BBMOD_SprColorGradingLUT, 0);

	/// @var {Real} The strength of the chromatic aberration effect. Use 0 to
	/// disable the effect. Defaults to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	ChromaticAberration = 0.0;

	/// @var {Real} Chromatic aberration offsets for RGB channels. Defaults to
	/// `(-1, 0, 1)`.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	ChromaticAberrationOffset = new BBMOD_Vec3(-1.0, 0.0, 1.0);

	/// @var {Real} The strength of the grayscale effect. Use values in range
	/// 0..1, where 0 means the original color and 1 means grayscale. Defaults
	/// to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	Grayscale = 0.0;

	/// @var {Real} The strength of the vignette effect. Defaults to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	Vignette = 0.0;

	/// @var {Real} The color of the vignette effect. Defaults to `c_black`.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	VignetteColor = c_black;

	/// @var {Real} Antialiasing technique to use. Use values from
	/// {@link BBMOD_EAntialiasing}. Defaults to
	/// {@link BBMOD_EAntialiasing.None}.
	Antialiasing = BBMOD_EAntialiasing.None;

	/// @var {Array}
	/// @private
	__effects = [];

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

		var _world = matrix_get(matrix_world);
		var _width = surface_get_width(_surface);
		var _height = surface_get_height(_surface);
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;
		var _surFinal = _surface;

		gpu_push_state();
		gpu_set_tex_filter(true);
		gpu_set_tex_repeat(false);
		gpu_set_blendenable(false);

		////////////////////////////////////////////////////////////////////////
		// Do post-processing
		if (Antialiasing != BBMOD_EAntialiasing.None)
		{
			// If anti-aliasing is enabled, we need to do post-processing in
			// another surface...
			__surPostProcess = bbmod_surface_check(
				__surPostProcess, _width, _height, surface_rgba8unorm, false);
			surface_set_target(__surPostProcess);
			matrix_set(matrix_world, matrix_build_identity());
		}

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
		draw_surface(
			_surface,
			(Antialiasing == BBMOD_EAntialiasing.None) ? _x : 0,
			(Antialiasing == BBMOD_EAntialiasing.None) ? _y : 0);
		shader_reset();

		if (Antialiasing != BBMOD_EAntialiasing.None)
		{
			// Reset surface...
			surface_reset_target();
			matrix_set(matrix_world, _world);
			_surFinal = __surPostProcess;
		}

		////////////////////////////////////////////////////////////////////////
		// Apply anti-aliasing to the final surface
		if (Antialiasing == BBMOD_EAntialiasing.FXAA)
		{
			_shader = BBMOD_ShFXAA;
			shader_set(_shader);
			shader_set_uniform_f(
				shader_get_uniform(_shader, "u_vTexelVS"),
				_texelWidth, _texelHeight);
			shader_set_uniform_f(
				shader_get_uniform(_shader, "u_vTexelPS"),
				_texelWidth, _texelHeight);
			draw_surface(_surFinal, _x, _y);
			shader_reset();
		}

		gpu_pop_state();

		return self;
	};

	static destroy = function ()
	{
		if (surface_exists(__surPostProcess))
		{
			surface_free(__surPostProcess);
		}

		for (var i = array_length(__effects); i >= 0; --i)
		{
			__effects[i].destroy();
		}
		__effects = undefined;

		return undefined;
	};
}

/// @func BBMOD_PostProcessEffect()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Base struct for all post-processing effects.
/// 
/// @see BBMOD_PostProcessor 
function BBMOD_PostProcessEffect() constructor
{
	/// @var {Struct.BBMOD_PostProcessor} The post-processor to which is this
	/// effect added or `undefined`.
	/// @readonly
	PostProcessor = undefined;

	/// @func draw(_surface, _depth, _normals)
	///
	/// @desc Applies the effect to given surface.
	///
	/// @param {Id.Surface} _surface The surface to apply the post-processing
	/// effect to.
	/// @param {Id.Surface} _depth A surface containing the scene depth encoded
	/// in the RGB channels or `undefined` if not available.
	/// @param {Id.Surface} _normals A surface containing the scene's
	/// world-space normals in the RGB channels or `undefined` if not available.
	///
	/// @return {Id.Surface} A surface with the post-processing effect applied
	/// to it.
	static draw = function (_surface, _depth, _normals)
	{
		return _surface;
	};

	static destroy = function ()
	{
		return undefined;
	};
}
