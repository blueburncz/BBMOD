/// @module PostProcessing

// Feather ignore GM1021

/// @func BBMOD_PostProcessor()
///
/// @extends {BBMOD_Resource}
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Handles post-processing effects like color grading, chromatic
/// aberration, grayscale effect, vignette and anti-aliasing.
///
/// @see BBMOD_PostProcessEffect
function BBMOD_PostProcessor(): BBMOD_Resource() constructor
{
	static Resource_destroy = destroy;

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

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	ColorGradingLUTFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_PostProcessor.ColorGradingLUT}, or
	/// `undefined`. Takes precedence over the texture when defined.
	ColorGradingLUTSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_PostProcessor.ColorGradingLUTSprite} to use.
	ColorGradingLUTSubimage = 0;

	/// @var {Bool} Whether this processor owns
	/// {@link BBMOD_PostProcessor.ColorGradingLUTSprite}.
	ColorGradingLUTOwned = false;

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

	/// @var {Real, Undefined} The width of the screen for which was the game
	/// designed or `undefined`. Effects are scaled based on this and the
	/// current width of the screen if not `undefined`. Default value is 1366.
	///
	/// @note This has precedence before `DesignHeight`. If none of the two are
	/// defined, then effect scale is 1.
	///
	/// @see BBMOD_PostProcessor.DesignHeight
	DesignWidth = 1366;

	/// @var {Real, Undefined} The height of the screen for which was the game
	/// designed or `undefined`. Effects are scaled based on this and the
	/// current height of the screen if not `undefined`. Default value is
	/// `undefined`.
	///
	/// @note `DesignWidth` has precedence before this. If none of the two are
	/// defined, then effect scale is 1.
	///
	/// @see BBMOD_PostProcessor.DesignWidth
	DesignHeight = undefined;

	/// @var {Struct.BBMOD_Rect} The screen size and position.
	/// @note This is not initialized before {@link BBMOD_PostProcessor.draw} is
	/// called!
	/// @readonly
	Rect = new BBMOD_Rect();

	/// @var {Real}
	/// @private
	__renderScale = 1.0;

	/// @var {Pointer.Texture} A lens dirt texture applied to effects like light
	/// bloom and lens flares. Default is `BBMOD_SprLensDirt`.
	LensDirt = sprite_get_texture(BBMOD_SprLensDirt, 0);

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	LensDirtFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_PostProcessor.LensDirt}, or `undefined`.
	/// Takes precedence over the texture when defined.
	LensDirtSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_PostProcessor.LensDirtSprite} to use.
	LensDirtSubimage = 0;

	/// @var {Bool} Whether this processor owns
	/// {@link BBMOD_PostProcessor.LensDirtSprite}.
	LensDirtOwned = false;
	/// @var {Real} The intensity of the lens dirt effect. Use values in range
	/// 0..1, where 0 is disabled and 1 is the maximum intensity. Default value
	/// is 1.
	LensDirtStrength = 1.0;

	/// @var {Pointer.Texture} A starburst texture applied to lens flares (when
	/// enabled). Default is `BBMOD_SprLensFlareStarburst`.
	/// @see BBMOD_LensFlareElement.ApplyStarburst
	Starburst = sprite_get_texture(BBMOD_SprLensFlareStarburst, 0);

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	StarburstFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_PostProcessor.Starburst}, or `undefined`.
	/// Takes precedence over the texture when defined.
	StarburstSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_PostProcessor.StarburstSprite} to use.
	StarburstSubimage = 0;

	/// @var {Bool} Whether this processor owns
	/// {@link BBMOD_PostProcessor.StarburstSprite}.
	StarburstOwned = false;
	/// @var {Real} The intensity of the starburst effect. Use values in range
	/// 0..1, where 0 is disabled and 1 is the maximum intensity. Default value
	/// is 1.
	StarburstStrength = 1.0;

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
			if (Effects[i] == _effect)
			{
				_effect.PostProcessor = undefined;
				array_delete(Effects, i, 1);
				break;
			}
		}
		return self;
	};

	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_string, "BBPOST");
		buffer_write(_buffer, buffer_u32, 1);
		buffer_write(_buffer, buffer_bool, Enabled);
		buffer_write(_buffer, buffer_bool, DesignWidth != undefined);
		if (DesignWidth != undefined)
		{
			buffer_write(_buffer, buffer_f64, DesignWidth);
		}
		buffer_write(_buffer, buffer_bool, DesignHeight != undefined);
		if (DesignHeight != undefined)
		{
			buffer_write(_buffer, buffer_f64, DesignHeight);
		}
		buffer_write(_buffer, buffer_f64, ChromaticAberration);
		ChromaticAberrationOffset.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_f64, Grayscale);
		buffer_write(_buffer, buffer_f64, Vignette);
		buffer_write(_buffer, buffer_u32, VignetteColor);
		buffer_write(_buffer, buffer_u32, Antialiasing);
		bbmod_texture_ref_to_buffer(_buffer, self, "ColorGradingLUT");
		bbmod_texture_ref_to_buffer(_buffer, self, "LensDirt");
		buffer_write(_buffer, buffer_f64, LensDirtStrength);
		bbmod_texture_ref_to_buffer(_buffer, self, "Starburst");
		buffer_write(_buffer, buffer_f64, StarburstStrength);
		buffer_write(_buffer, buffer_u32, array_length(Effects));
		for (var i = 0; i < array_length(Effects); ++i)
		{
			var _effect = Effects[i];
			var _constructorName = instanceof(_effect);
			if (_constructorName == undefined || _constructorName == "struct")
			{
				throw new BBMOD_Exception("Post-process effect has no constructor.");
			}
			buffer_write(_buffer, buffer_string, _constructorName);
			_effect.to_buffer(_buffer);
		}
		IsLoaded = true;
		return self;
	};

	static from_buffer = function (_buffer)
	{
		if (buffer_read(_buffer, buffer_string) != "BBPOST")
		{
			throw new BBMOD_Exception("Invalid BBPOST resource header.");
		}
		if (buffer_read(_buffer, buffer_u32) != 1)
		{
			throw new BBMOD_Exception("Unsupported BBPOST resource version.");
		}
		for (var j = array_length(Effects) - 1; j >= 0; --j)
		{
			Effects[j].destroy();
		}
		Effects = [];
		bbmod_texture_ref_destroy(self, "ColorGradingLUT");
		bbmod_texture_ref_destroy(self, "LensDirt");
		bbmod_texture_ref_destroy(self, "Starburst");
		Enabled = buffer_read(_buffer, buffer_bool);
		DesignWidth = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		DesignHeight = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		ChromaticAberration = buffer_read(_buffer, buffer_f64);
		ChromaticAberrationOffset = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f64);
		Grayscale = buffer_read(_buffer, buffer_f64);
		Vignette = buffer_read(_buffer, buffer_f64);
		VignetteColor = buffer_read(_buffer, buffer_u32);
		Antialiasing = buffer_read(_buffer, buffer_u32);
		bbmod_texture_ref_from_buffer(_buffer, self, "ColorGradingLUT");
		bbmod_texture_ref_from_buffer(_buffer, self, "LensDirt");
		LensDirtStrength = buffer_read(_buffer, buffer_f64);
		bbmod_texture_ref_from_buffer(_buffer, self, "Starburst");
		StarburstStrength = buffer_read(_buffer, buffer_f64);
		var _effectCount = buffer_read(_buffer, buffer_u32);
		if (_effectCount > 100000)
		{
			throw new BBMOD_Exception("Invalid post-process effect count.");
		}
		for (var i = 0; i < _effectCount; ++i)
		{
			var _constructorName = buffer_read(_buffer, buffer_string);
			var _constructor = asset_get_index(_constructorName);
			if (_constructor == -1)
			{
				throw new BBMOD_Exception(
					"Unknown post-process effect: " + _constructorName);
			}
			add_effect(new _constructor().from_buffer(_buffer));
		}
		IsLoaded = true;
		return self;
	};

	/// @func get_effect_scale()
	///
	/// @desc Retrieves the current effect scale based on the current screen
	/// size and properties `DesignWidth` and `DesignHeight`.
	///
	/// @return {Real} The current effect scale.
	///
	/// @see BBMOD_PostProcessor.DesignWidth
	/// @see BBMOD_PostProcessor.DesignHeight
	static get_effect_scale = function ()
	{
		if (DesignWidth != undefined)
		{
			return Rect.Width / DesignWidth;
		}
		if (DesignHeight != undefined)
		{
			return Rect.Height / DesignHeight;
		}
		return 1.0;
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
		_surface, _x, _y, _depth = undefined, _normals = undefined)
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

		draw_surface_stretched(_surSrc, _x, _y, Rect.Width / __renderScale, Rect.Height / __renderScale);

		matrix_set(matrix_world, _world);
		gpu_pop_state();

		return self;
	};

	static destroy = function ()
	{
		Resource_destroy();
		bbmod_texture_ref_destroy(self, "ColorGradingLUT");
		bbmod_texture_ref_destroy(self, "LensDirt");
		bbmod_texture_ref_destroy(self, "Starburst");
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
