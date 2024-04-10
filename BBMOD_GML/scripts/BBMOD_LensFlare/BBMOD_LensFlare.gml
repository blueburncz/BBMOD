/// @module PostProcessing

/// @var {Array<Struct.BBMOD_LensFlare>}
/// @private
global.__bbmodLensFlares = [];

/// @func BBMOD_LensFlare([_tint[, _position[, _range[, _falloff[, _depthThreshold[, _direction[, _angleInner[, _angleOuter]]]]]]]])
///
/// @desc A collection of {@link BBMOD_LensFlareElement}s that together define a
/// single lens flare instance.
///
/// @param {Struct.BBMOD_Color, Undefined} [_tint] The color to multiply lens
/// flare elements' color by. Defaults to {@link BBMOD_C_WHITE} if `undefined`.
/// @param {Struct.BBMOD_Vec3, Undefined} [_position] The position in the world
/// or `undefined`, in which case the property {@link BBMOD_LensFlare.Direction}
/// is used instead. Defaults to `undefined`.
/// @param {Real} [_range] The maximum distance at which is the lens flare
/// visible. Used only in case {@link BBMOD_LensFlare.Position} is not
/// `undefined`. Defaults to `infinity`.
/// @param {Real} [_falloff] A multiplier for {@link BBMOD_LensFlare.Range} used
/// to compute the distance from the camera at which the lens flare starts
/// fading away. Use values in range 0..1. Defaults to 0.8 (the lens flare
/// starts fading away at 80% of the `Range` property).
/// @param {Real} [_depthThreshold] The maximum allowed difference between the
/// flare's depth and the depth in the depth buffer. When larger, the lens flare
/// is not drawn. Defaults to 1.
/// @param {Struct.BBMOD_Vec3, Undefined} [_direction] The source light's
/// direction or `undefined` (default).
/// @param {Real, Undefined} [_angleInner] The inner cone angle in degrees (for
/// lens flares produced by spot lights) or `undefined` (default).
/// @param {Real, Undefined} [_angleOuter] The outer cone angle in degrees (for
/// lens flares produced by spot lights) or `undefined` (default).
///
/// @see bbmod_lens_flare_add
/// @see BBMOD_LensFlareElement
/// @see BBMOD_LensFlareEffect
function BBMOD_LensFlare(
	_tint=undefined,
	_position=undefined,
	_range=infinity,
	_falloff=0.8,
	_depthThreshold=1.0,
	_direction=undefined,
	_angleInner=undefined,
	_angleOuter=undefined
) constructor
{
	/// @var {Struct.BBMOD_Color} The color to multiply lens flare elements'
	/// color by. Default value is {@link BBMOD_C_WHITE}.
	/// @see BBMOD_LensFlareElement.ApplyTint
	Tint = _tint ?? BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Vec3, Undefined} The position in the world or
	/// `undefined`, in which case the property
	/// {@link BBMOD_LensFlare.Direction} is used instead. Default value is
	/// `undefined`.
	Position = _position;

	/// @var {Real} The maximum distance at which is the lens flare visible.
	/// Used only in case {@link BBMOD_LensFlare.Position} is not `undefined`.
	/// Default value is `infinity`.
	Range = _range;

	/// @var {Real} A multiplier for {@link BBMOD_LensFlare.Range} used to
	/// compute the distance from the camera at which the lens flare starts
	/// fading away. Use values in range 0..1. Default value is 0.8 (the lens
	/// flare starts fading away at 80% of the `Range` property).
	Falloff = _falloff;

	/// @var {Real} The maximum allowed difference between the flare's depth and
	/// the depth in the depth buffer. When larger, the lens flare is not drawn.
	/// Default value is 1.
	DepthThreshold = _depthThreshold;

	/// @var {Struct.BBMOD_Vec3, Undefined} The source light's direction or
	/// `undefined` (default).
	Direction = _direction;

	/// @var {Real, Undefined} The inner cone angle in degrees (for lens flares
	/// produced by spot lights) or `undefined` (default).
	AngleInner = _angleInner;

	/// @var {Real, Undefined} The outer cone angle in degrees (for lens flares
	/// produced by spot lights) or `undefined` (default).
	AngleOuter = _angleOuter;

	/// @var {Array<Struct.BBMOD_LensFlareElement>}
	/// @private
	__elements = [];

	static __uDepthTex          = shader_get_sampler_index(BBMOD_ShLensFlare, "u_texDepth");
	static __uStarburstTex      = shader_get_sampler_index(BBMOD_ShLensFlare, "u_texStarburst");
	static __uLensDirtTex       = shader_get_sampler_index(BBMOD_ShLensFlare, "u_texLensDirt");
	static __uLightPos          = shader_get_uniform(BBMOD_ShLensFlare, "u_vLightPos");
	static __uInvRes            = shader_get_uniform(BBMOD_ShLensFlare, "u_vInvRes");
	static __uColor             = shader_get_uniform(BBMOD_ShLensFlare, "u_vColor");
	static __uFadeOut           = shader_get_uniform(BBMOD_ShLensFlare, "u_fFadeOut");
	static __uClipFar           = shader_get_uniform(BBMOD_ShLensFlare, "u_fClipFar");
	static __uDepthThreshold    = shader_get_uniform(BBMOD_ShLensFlare, "u_fDepthThreshold");
	static __uStarburstUVs      = shader_get_uniform(BBMOD_ShLensFlare, "u_vStarburstUVs");
	static __uStarburstStrength = shader_get_uniform(BBMOD_ShLensFlare, "u_fStarburstStrength");
	static __uStarburstRot      = shader_get_uniform(BBMOD_ShLensFlare, "u_fStarburstRot");
	static __uLensDirtUVs       = shader_get_uniform(BBMOD_ShLensFlare, "u_vLensDirtUVs");
	static __uLensDirtStrength  = shader_get_uniform(BBMOD_ShLensFlare, "u_fLensDirtStrength");

	/// @func add_element(_element)
	///
	/// @desc Adds an element to the lens flare.
	///
	/// @param {Struct.BBMOD_LensFlareElement} _element The element to add.
	///
	/// @return {Struct.BBMOD_LensFlare} Returns `self`.
	static add_element = function (_element)
	{
		gml_pragma("forceinline");
		array_push(__elements, _element);
		return self;
	};

	/// @func get_elements()
	///
	/// @desc Retrieves a read-only array of all elements of the lens flare.
	///
	/// @return {Array<Struct.BBMOD_LensFlareElement>} A read-only array of all
	/// elements of the lens flare.
	static get_elements = function ()
	{
		gml_pragma("forceinline");
		return __elements;
	};

	/// @func add_ghosts(_sprite, _subimage, _count, _offsetFrom, _offsetTo, _scaleFrom, _scaleMid, _scaleTo, _colorFrom[, _colorTo[, _randomColor[, _applyTint[, _angle[, _angleRelative[, _fadeOut[, _applyStarburst]]]]]]])
	///
	/// @desc A utility function for adding multiple ghosts.
	///
	/// @param {Asset.GMSprite} _sprite The ghost sprite.
	/// @param {Real} _subimage The ghost sprite subimage.
	/// @param {Real} _count Number of ghosts to add.
	/// @param {Real} _offsetFrom The offset of the first ghost.
	/// @param {Real} _offsetTo The offset of the last ghost.
	/// @param {Real} _scaleFrom The scale of the first ghost.
	/// @param {Real} _scaleMid The scale of the middle ghost.
	/// @param {Real} _scaleTo The scale of the last ghost.
	/// @param {Struct.BBMOD_Color} _colorFrom The color of the first ghost.
	/// @param {Struct.BBMOD_Color, Undefined} [_colorTo] The color of the last
	/// ghost. Defaults to `_colorFrom` if `undefined`.
	/// @param {Bool} [_randomColor] If `true` then each ghost color is a random
	/// mix between `_colorFrom` and `_colorTo`, otherwise the color transitions
	/// from `_colorFrom` to `_colorTo`, going from the first ghost to the last.
	/// Defaults to `false` (no random mix).
	/// @param {Bool} [_applyTint] Whether to apply tint. Defaults to `false`.
	/// @param {Real} [_angle] The sprite angle. Defaults to 0.
	/// @param {Bool} [_angleRelative] Whether the angle is relative to the
	/// direction towards to light source. Defaults to `false`.
	/// @param {Bool} [_fadeOut] Whether to fade out ghosts at screen edges.
	/// Defaults to `true`.
	/// @param {Bool} [_applyStarburst] Whether to apply starburst texture.
	/// Defaults to `false`.
	///
	/// @return {Struct.BBMOD_LensFlare} Returns `self`.
	static add_ghosts = function (
		_sprite,
		_subimage,
		_count,
		_offsetFrom,
		_offsetTo,
		_scaleFrom,
		_scaleMid,
		_scaleTo,
		_colorFrom,
		_colorTo=undefined,
		_randomColor=false,
		_applyTint=false,
		_angle=0.0,
		_angleRelative=false,
		_fadeOut=true,
		_applyStarburst=false)
	{
		_colorTo ??= _colorFrom;

		for (var i = 0; i < _count; ++i)
		{
			var _index = i / (_count - 1);
			var _dist = (_index - 0.5) * 2.0;
			var _offset = new BBMOD_Vec2(lerp(_offsetFrom, _offsetTo, _index));
			var _scale = (_dist < 0.0)
 				? new BBMOD_Vec2(lerp(_scaleMid, _scaleFrom, -_dist))
				: new BBMOD_Vec2(lerp(_scaleMid, _scaleTo, _dist));
			var _color = _colorFrom.Mix(_colorTo, _randomColor ? random(1.0) : _index);
			var _element = new BBMOD_LensFlareElement(
				_sprite,
				_subimage,
				_offset,
				_scale,
				undefined,
				undefined,
				_color,
				_applyTint,
				_angle,
				_angleRelative,
				_fadeOut,
				_applyStarburst);
			add_element(_element);
		}
		return self;
	};

	/// @func draw(_postProcessor, _depth)
	///
	/// @desc Draws the lens flare.
	///
	/// @param {Struct.BBMOD_PostProcessor} _postProcessor The post-processor
	/// that draws the lens flares.
	/// @param {Id.Surface} _depth A surface containing scene depth encoded into
	/// the RGB channels.
	///
	/// @return {Struct.BBMOD_LensFlare} Returns `self`.
	static draw = function (_postProcessor, _depth)
	{
		if (Position == undefined && Direction == undefined)
		{
			return self;
		}

		var _camera = global.__bbmodCameraCurrent;
		if (_camera == undefined)
		{
			return self;
		}

		var _scale = _postProcessor.get_effect_scale();
		var _rect = _postProcessor.Rect;
		var _screenWidth = _rect.Width;
		var _screenHeight = _rect.Height;
		var _screenPos = _camera.world_to_screen(
			Position ?? new BBMOD_Vec4(-Direction.X, -Direction.Y, -Direction.Z, 0.0),
			_screenWidth, _screenHeight);

		if (_screenPos == undefined
			|| _screenPos.X < 0.0 || _screenPos.X > _screenWidth
			|| _screenPos.Y < 0.0 || _screenPos.Y > _screenHeight)
		{
			return self;
		}

		var _strength = 1.0;
		if (Position != undefined)
		{
			var _vec = _camera.Position.Sub(Position);

			if (Range != infinity)
			{
				var _dist = _vec.Length();
				_strength = 1.0 - min((_dist - (Range * Falloff)) / (Range * (1.0 - Falloff)), 1.0);
			}

			if (Direction != undefined
				&& AngleInner != undefined
				&& AngleOuter != undefined)
			{
				var _dir = _vec.Normalize();
				var _inner = dsin(AngleInner);
				var _outer = dsin(AngleOuter);
				var _dot = clamp(_dir.Dot(Direction.Normalize()), 0.0, 1.0);
				_strength *= clamp((_dot - _inner) / (_outer - _inner), 0.0, 1.0);
			}
		}
		else
		{
			_screenPos.Z = _camera.ZFar;
		}

		if (_strength <= 0.0)
		{
			return self;
		}

		var _x = _screenPos.X;
		var _y = _screenPos.Y;
		var _z = _screenPos.Z;
		var _vecX = (_screenWidth * 0.5) - _x;
		var _vecY = (_screenHeight * 0.5) - _y;
		var _direction = point_direction(0, 0, _vecX, _vecY);
		var _tintR = Tint.Red / 255.0;
		var _tintG = Tint.Green / 255.0;
		var _tintB = Tint.Blue / 255.0;
		var _tintA = Tint.Alpha;
		var _camRot = _camera.get_right().Dot(new BBMOD_Vec3(0, 0, 1))
			+ _camera.get_forward().Dot(new BBMOD_Vec3(0, 1, 0));

		gpu_push_state();
		gpu_set_tex_repeat(true);

		shader_set(BBMOD_ShLensFlare);
		shader_set_uniform_f(__uLightPos, _x, _y, _z);
		shader_set_uniform_f(__uInvRes, 1.0 / _screenWidth, 1.0 / _screenHeight);
		texture_set_stage(__uDepthTex, surface_get_texture(_depth));
		gpu_set_tex_filter_ext(__uDepthTex, false);
		shader_set_uniform_f(__uClipFar, _camera.ZFar);
		shader_set_uniform_f(__uDepthThreshold, DepthThreshold);

		texture_set_stage(__uStarburstTex, _postProcessor.Starburst);
		var _starburstUVs = texture_get_uvs(_postProcessor.Starburst);
		shader_set_uniform_f(__uStarburstUVs, _starburstUVs[0], _starburstUVs[1], _starburstUVs[2], _starburstUVs[3]);
		shader_set_uniform_f(__uStarburstRot, _camRot);

		texture_set_stage(__uLensDirtTex, _postProcessor.LensDirt);
		var _lensDirtUVs = texture_get_uvs(_postProcessor.LensDirt);
		shader_set_uniform_f(__uLensDirtUVs, _lensDirtUVs[0], _lensDirtUVs[1], _lensDirtUVs[2], _lensDirtUVs[3]);
		shader_set_uniform_f(__uLensDirtStrength, _postProcessor.LensDirtStrength);

		var _uColor = __uColor;
		var _uFadeOut = __uFadeOut;
		var _uStarburstStrength = __uStarburstStrength;
		var _starburstStrength = _postProcessor.StarburstStrength;

		gpu_set_blendmode(bm_add);

		for (var i = array_length(__elements) - 1; i >= 0; --i)
		{
			with (__elements[i])
			{
				var _elementX = _x + _vecX * Offset.X * 2.0;
				var _elementY = _y + _vecY * Offset.Y * 2.0;
				var _elementDistance = point_distance(
					_elementX / _screenWidth, _elementY / _screenHeight,
					_x / _screenWidth, _y / _screenHeight);
				var _elementScaleX = Scale.X * lerp(ScaleByDistanceMin.X, ScaleByDistanceMax.X, _elementDistance) * _scale;
				var _elementScaleY = Scale.Y * lerp(ScaleByDistanceMin.Y, ScaleByDistanceMax.Y, _elementDistance) * _scale
				var _elementColorR = Color.Red / 255.0;
				var _elementColorG = Color.Green / 255.0;
				var _elementColorB = Color.Blue / 255.0;
				var _elementColorA = Color.Alpha * _strength;

				if (ApplyTint)
				{
					_elementColorR *= _tintR;
					_elementColorG *= _tintG;
					_elementColorB *= _tintB;
					_elementColorA *= _tintA;
				}

				shader_set_uniform_f(_uFadeOut, FadeOut ? 1.0 : 0.0);
				shader_set_uniform_f(_uStarburstStrength, ApplyStarburst ? _starburstStrength : 0.0);
				shader_set_uniform_f(
					_uColor,
					_elementColorR,
					_elementColorG,
					_elementColorB,
					_elementColorA);
				draw_sprite_ext(
					Sprite, Subimage,
					_elementX, _elementY,
					_elementScaleX, _elementScaleY,
					Angle + _direction * (AngleRelative ? 1.0 : 0.0),
					c_white, 1.0);
			}
		}

		shader_reset();
		gpu_pop_state();

		return self;
	};
}


/// @func bbmod_lens_flare_add(_lensFlare)
///
/// @desc Adds a lens flare to be drawn with {@link BBMOD_LensFlaresEffect}.
///
/// @param {Struct.BBMOD_LensFlare} _lensFlare The lens flare.
///
/// @see bbmod_lens_flare_add
/// @see bbmod_lens_flare_count
/// @see bbmod_lens_flare_get
/// @see bbmod_lens_flare_remove
/// @see bbmod_lens_flare_remove_index
/// @see bbmod_lens_flare_clear
function bbmod_lens_flare_add(_lensFlare)
{
	gml_pragma("forceinline");
	array_push(global.__bbmodLensFlares, _lensFlare);
}

/// @func bbmod_lens_flare_count()
///
/// @desc Retrieves number of lens flares to be drawn.
///
/// @return {Real} The number of lens flares to be drawn.
///
/// @see bbmod_lens_flare_add
/// @see bbmod_lens_flare_get
/// @see bbmod_lens_flare_remove
/// @see bbmod_lens_flare_remove_index
/// @see bbmod_lens_flare_clear
function bbmod_lens_flare_count()
{
	gml_pragma("forceinline");
	return array_length(global.__bbmodLensFlares);
}

/// @func bbmod_lens_flare_get(_index)
///
/// @desc Retrieves a lens flare at given index.
///
/// @param {Real} _index The index of the lens flare.
///
/// @return {Struct.BBMOD_LensFlare} The lens flare.
///
/// @see bbmod_lens_flare_add
/// @see bbmod_lens_flare_count
/// @see bbmod_lens_flare_remove
/// @see bbmod_lens_flare_remove_index
/// @see bbmod_lens_flare_clear
function bbmod_lens_flare_get(_index)
{
	gml_pragma("forceinline");
	return global.__bbmodLensFlares[_index];
}

/// @func bbmod_lens_flare_remove(_lensFlare)
///
/// @desc Removes a lens flare so it is not drawn anymore.
///
/// @param {Struct.BBMOD_LensFlare} _lensFlare The lens flare to remove.
///
/// @return {Bool} Returns `true` if the lens flare was removed or `false` if
/// the lens flare was not found.
///
/// @see bbmod_lens_flare_add
/// @see bbmod_lens_flare_count
/// @see bbmod_lens_flare_get
/// @see bbmod_lens_flare_remove_index
/// @see bbmod_lens_flare_clear
function bbmod_lens_flare_remove(_lensFlare)
{
	gml_pragma("forceinline");
	var _lensFlares = global.__bbmodLensFlares;
	var i = 0;
	repeat (array_length(_lensFlares))
	{
		if (_lensFlares[i] == _lensFlare)
		{
			array_delete(_lensFlares, i, 1);
			return true;
		}
		++i;
	}
	return false;
}

/// @func bbmod_lens_flare_remove_index(_index)
///
/// @desc Removes a lens flare so it is not drawn anymore.
///
/// @param {Real} _index The index to remove the lens flare at.
///
/// @return {Bool} Always returns `true`.
///
/// @see bbmod_lens_flare_add
/// @see bbmod_lens_flare_count
/// @see bbmod_lens_flare_get
/// @see bbmod_lens_flare_remove
/// @see bbmod_lens_flare_clear
function bbmod_lens_flare_remove_index(_index)
{
	gml_pragma("forceinline");
	array_delete(global.__bbmodLensFlares, _index, 1);
	return true;
}

/// @func bbmod_lens_flare_clear()
///
/// @desc Removes all lens flares.
///
/// @see bbmod_lens_flare_add
/// @see bbmod_lens_flare_count
/// @see bbmod_lens_flare_get
/// @see bbmod_lens_flare_remove
/// @see bbmod_lens_flare_remove_index
function bbmod_lens_flare_clear()
{
	gml_pragma("forceinline");
	global.__bbmodLensFlares = [];
}
