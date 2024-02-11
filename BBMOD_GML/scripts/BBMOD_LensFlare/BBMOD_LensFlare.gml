/// @module LensFlares

/// @var {Array<Struct.BBMOD_LensFlare>}
/// @private
global.__bbmodLensFlares = [];

/// @func BBMOD_LensFlare([_position[, _depthThreshold]])
///
/// @desc A lens flare.
///
/// @param {Struct.BBMOD_Vec3} [_position] The position in the world. Defaults
/// to `(0, 0, 0)` if `undefined`.
/// @param {Real} [_depthThreshold] The maximum allowed difference between the
/// flare's depth and the depth in the depth buffer. When larger, the lens flare
/// is not drawn. Defaults to 1.
///
/// @see bbmod_lens_flare_add
/// @see BBMOD_LensFlareElement
function BBMOD_LensFlare(_position=undefined, _depthThreshold=1.0) constructor
{
	/// @var {Struct.BBMOD_Vec3} The position in the world. Default value is
	/// `(0, 0, 0)`.
	Position = _position ?? new BBMOD_Vec3();

	/// @var {Real} The maximum allowed difference between the flare's depth and
	/// the depth in the depth buffer. When larger, the lens flare is not drawn.
	/// Default value is 1.
	DepthThreshold = _depthThreshold;

	/// @var {Array<Struct.BBMOD_LensFlareElement>}
	/// @private
	__elements = [];

	static __uLightPos = shader_get_uniform(BBMOD_ShLensFlare, "u_vLightPos");
	static __uFlareRaysTex = shader_get_sampler_index(BBMOD_ShLensFlare, "u_texFlareRays");
	static __uFlareRays = shader_get_uniform(BBMOD_ShLensFlare, "u_fFlareRays")
	static __uLensDirtTex = shader_get_sampler_index(BBMOD_ShLensFlare, "u_texLensDirt");
	static __uLensDirtUVs = shader_get_uniform(BBMOD_ShLensFlare, "u_vLensDirtUVs");
	static __uInvRes = shader_get_uniform(BBMOD_ShLensFlare, "u_vInvRes");
	static __uColor = shader_get_uniform(BBMOD_ShLensFlare, "u_vColor");
	static __uFadeOut = shader_get_uniform(BBMOD_ShLensFlare, "u_fFadeOut");

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

	/// @func draw()
	///
	/// @desc Draws the lens flare.
	///
	/// @return {Struct.BBMOD_LensFlare} Returns `self`.
	static draw = function ()
	{
		if (global.__bbmodCameraCurrent == undefined)
		{
			return self;
		}

		var _screenWidth = window_get_width();
		var _screenHeight = window_get_height();
		var _screenPos = global.__bbmodCameraCurrent.world_to_screen(Position, _screenWidth, _screenHeight);

		if (_screenPos == undefined)
		{
			return self;
		}

		var _x = _screenPos.X;
		var _y = _screenPos.Y;
		var _z = _screenPos.Z;
		var _vecX = _screenWidth * 0.5 - _x;
		var _vecY = _screenHeight * 0.5 - _y;
		var _direction = point_direction(0, 0, _vecX, _vecY);

		gpu_push_state();
		gpu_set_tex_repeat(true);
		shader_set(BBMOD_ShLensFlare);
		shader_set_uniform_f(
			__uLightPos,
			_x,
			_screenHeight - _y, // FIXME: WTF is going on here?!
			_z);
		var _texLensDirt = sprite_get_texture(BBMOD_SprLensDirt, 0);
		var _lensDirtUVs = texture_get_uvs(_texLensDirt);
		texture_set_stage(__uLensDirtTex, _texLensDirt);
		shader_set_uniform_f(__uLensDirtUVs, _lensDirtUVs[0], _lensDirtUVs[1], _lensDirtUVs[2], _lensDirtUVs[3]);
		texture_set_stage(__uFlareRaysTex, sprite_get_texture(BBMOD_SprFlareRays, 0));
		shader_set_uniform_f(__uInvRes, 1.0 / _screenWidth, 1.0 / _screenHeight);
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
					Color.Alpha);
				draw_sprite_ext(
					Sprite, Subimage, _x + _vecX * Offset.X, _y + _vecY * Offset.Y,
					Scale.X, Scale.Y, Angle + _direction * (AngleRelative ? 1.0 : 0.0),
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
