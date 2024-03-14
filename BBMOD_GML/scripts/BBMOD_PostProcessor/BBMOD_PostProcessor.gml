/// @module PostProcessing

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
	/// @obsolete Please use {@link BBMOD_ColorGradingEffect} instead.
	ColorGradingLUT = sprite_get_texture(BBMOD_SprColorGradingLUT, 0);

	/// @var {Real} The strength of the chromatic aberration effect. Use 0 to
	/// disable the effect. Defaults to 0.
	/// @obsolete Please use {@link BBMOD_ChromaticAberrationEffect} instead.
	ChromaticAberration = 0.0;

	/// @var {Struct.BBMOD_Vec3} Chromatic aberration offsets for RGB channels.
	/// Defaults to `(-1, 0, 1)`.
	/// @obsolete Please use {@link BBMOD_ChromaticAberrationEffect} instead.
	ChromaticAberrationOffset = new BBMOD_Vec3(-1.0, 0.0, 1.0);

	/// @var {Real} The strength of the grayscale effect. Use values in range
	/// 0..1, where 0 means the original color and 1 means grayscale. Defaults
	/// to 0.
	/// @obsolete Please use {@link BBMOD_MonochromeEffect} instead.
	Grayscale = 0.0;

	/// @var {Real} The strength of the vignette effect. Defaults to 0.
	/// @obsolete Please use {@link BBMOD_VignetteEffect} instead.
	Vignette = 0.0;

	/// @var {Constant.Color} The color of the vignette effect. Defaults to
	/// `c_black`.
	/// @obsolete Please use {@link BBMOD_VignetteEffect} instead.
	VignetteColor = c_black;

	/// @var {Real} Antialiasing technique to use. Use values from
	/// {@link BBMOD_EAntialiasing}. Defaults to
	/// {@link BBMOD_EAntialiasing.None}.
	/// @obsolete Please use {@link BBMOD_FXAAEffect} instead.
	Antialiasing = BBMOD_EAntialiasing.None;

	/// @var {Id.Surface}
	/// @private
	__surPostProcess1 = -1;

	/// @var {Id.Surface}
	/// @private
	__surPostProcess2 = -1;

	/// @var {Real} The width of the screen for which was the game designed.
	/// Effects are scaled based on this and the current width of the screen.
	DesignWidth = 1366;

	/// @var {Real} The height of the screen for which was the game designed.
	DesignHeight = 768;

	/// @var {Struct.BBMOD_Rect} The screen size and position.
	/// @note This is not initialized before {@link BBMOD_PostProcessor.draw} is
	/// called!
	/// @readonly
	Rect = new BBMOD_Rect();

	/// @var {Pointer.Texture} The lens dirt texture. Default is
	/// `BBMOD_SprLensDirt`.
	LensDirt = sprite_get_texture(BBMOD_SprLensDirt, 0);

	/// @var {Real} The intensity of the lens dirt effect. Use values in range
	/// 0..1, where 0 is disabled and 1 is the maximum intensity. Default value
	/// is 1.
	LensDirtStrength = 1.0;

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
		Rect.X = _x;
		Rect.Y = _y;
		Rect.Width = surface_get_width(_surface);
		Rect.Height = surface_get_height(_surface);

		if (!Enabled)
		{
			draw_surface(_surface, _x, _y);
			return self;
		}

		var _width = surface_get_width(_surface);
		var _height = surface_get_height(_surface);
		var _world = matrix_get(matrix_world);
		matrix_set(matrix_world, matrix_build_identity());

		var _surfaceFormat = bbmod_hdr_is_supported()
			? surface_rgba16float : surface_rgba8unorm;

		__surPostProcess1 = bbmod_surface_check(
			__surPostProcess1, _width, _height, _surfaceFormat, false);
		__surPostProcess2 = bbmod_surface_check(
			__surPostProcess2, _width, _height, _surfaceFormat, false);

		gpu_push_state();
		gpu_set_tex_filter(true);
		gpu_set_tex_repeat(false);
		gpu_set_blendenable(false);

		var _surSrc = _surface;
		var _surDest = __surPostProcess1;
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
