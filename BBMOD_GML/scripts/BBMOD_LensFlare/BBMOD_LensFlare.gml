/// @module PostProcessing

/// @var {Array<Struct.BBMOD_LensFlare>}
/// @private
global.__bbmodLensFlares = [];

/// @func BBMOD_LensFlare()
///
/// @desc A lens flare.
///
/// @see bbmod_lens_flare_add
/// @see BBMOD_LensFlareElement
/// @see BBMOD_LensFlareEffect
function BBMOD_LensFlare() constructor
{
	/// @var {Struct.BBMOD_Vec3} The position in the world or `undefined`,
	/// in which case the property {@link BBMOD_LensFlare.Direction} is used
	/// instead. Default value is `undefined`.
	Position = undefined;

	/// @var {Real} The maximum distance at which is the lens flare visible.
	/// Used only in case {@link BBMOD_LensFlare.Position} is not `undefined`.
	/// Default value is `infinity`.
	Range = infinity;

	/// @var {Real} A multiplier for {@link BBMOD_LensFlare.Range} used to
	/// compute the distance from the camera at which the lens flare starts
	/// fading away. Use values in range 0..1. Default value is 0.8 (the lens
	/// flare starts fading away at 80% of the `Range` property).
	Falloff = 0.8;

	/// @var {Real} The maximum allowed difference between the flare's depth and
	/// the depth in the depth buffer. When larger, the lens flare is not drawn.
	/// Default value is 1.
	DepthThreshold = 1.0;

	/// @var {Struct.BBMOD_Vec3, Undefined} The source light's direction or
	/// `undefined` (default).
	Direction = undefined;

	/// @var {Real, Undefined} The inner cone angle in degrees (for lens flares
	/// produced by spot lights) or `undefined` (default).
	AngleInner = undefined;

	/// @var {Real, Undefined} The outer cone angle in degrees (for lens flares
	/// produced by spot lights) or `undefined` (default).
	AngleOuter = undefined;

	/// @var {Array<Struct.BBMOD_LensFlareElement>}
	/// @private
	__elements = [];

	static __uFlareRaysTex     = shader_get_sampler_index(BBMOD_ShLensFlare, "u_texFlareRays");
	static __uDepthTex         = shader_get_sampler_index(BBMOD_ShLensFlare, "u_texDepth");
	static __uLensDirtTex      = shader_get_sampler_index(BBMOD_ShLensFlare, "u_texLensDirt");
	static __uLightPos         = shader_get_uniform(BBMOD_ShLensFlare, "u_vLightPos");
	static __uFlareRays        = shader_get_uniform(BBMOD_ShLensFlare, "u_fFlareRays")
	static __uInvRes           = shader_get_uniform(BBMOD_ShLensFlare, "u_vInvRes");
	static __uColor            = shader_get_uniform(BBMOD_ShLensFlare, "u_vColor");
	static __uFadeOut          = shader_get_uniform(BBMOD_ShLensFlare, "u_fFadeOut");
	static __uClipFar          = shader_get_uniform(BBMOD_ShLensFlare, "u_fClipFar");
	static __uDepthThreshold   = shader_get_uniform(BBMOD_ShLensFlare, "u_fDepthThreshold");
	static __uLensDirtUVs      = shader_get_uniform(BBMOD_ShLensFlare, "u_vLensDirtUVs");
	static __uLensDirtStrength = shader_get_uniform(BBMOD_ShLensFlare, "u_fLensDirtStrength");

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

		var _rect = _postProcessor.Rect;
		var _scale = _rect.Width / _postProcessor.DesignWidth;
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

		gpu_push_state();
		gpu_set_tex_repeat(true);

		shader_set(BBMOD_ShLensFlare);
		shader_set_uniform_f(__uLightPos, _x, _y, _z);
		texture_set_stage(__uFlareRaysTex, sprite_get_texture(BBMOD_SprFlareRays, 0));
		shader_set_uniform_f(__uInvRes, 1.0 / _screenWidth, 1.0 / _screenHeight);
		texture_set_stage(__uDepthTex, surface_get_texture(_depth));
		gpu_set_tex_filter_ext(__uDepthTex, false);
		shader_set_uniform_f(__uClipFar, _camera.ZFar);
		shader_set_uniform_f(__uDepthThreshold, DepthThreshold);

		texture_set_stage(__uLensDirtTex, _postProcessor.LensDirt);
		var _uvs = texture_get_uvs(_postProcessor.LensDirt);
		shader_set_uniform_f(__uLensDirtUVs, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
		shader_set_uniform_f(__uLensDirtStrength, _postProcessor.LensDirtStrength);

		var _uColor = __uColor;
		var _uFadeOut = __uFadeOut;
		var _uFlareRays = __uFlareRays;

		for (var i = array_length(__elements) - 1; i >= 0; --i)
		{
			with (__elements[i])
			{
				gpu_set_blendmode(BlendMode);
				shader_set_uniform_f(_uFadeOut, FadeOut ? 1.0 : 0.0);
				shader_set_uniform_f(_uFlareRays, FlareRays ? 1.0 : 0.0);
				shader_set_uniform_f(
					_uColor,
					Color.Red / 255.0,
					Color.Green / 255.0,
					Color.Blue / 255.0,
					Color.Alpha * _strength);
				draw_sprite_ext(
					Sprite, Subimage, _x + _vecX * Offset.X, _y + _vecY * Offset.Y,
					Scale.X * _scale, Scale.Y * _scale, Angle + _direction * (AngleRelative ? 1.0 : 0.0),
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
/// @desc Adds a lens flare to be drawn.
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
	var _punctualLights = global.__bbmodLensFlares;
	var i = 0;
	repeat (array_length(_punctualLights))
	{
		if (_punctualLights[i] == _lensFlare)
		{
			array_delete(_punctualLights, i, 1);
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
