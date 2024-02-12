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
	Position = undefined

	/// @var {Real} The maximum distance at which is the lens flare visible.
	/// Used only in case {@link BBMOD_LensFlare.Position} is not `undefined`.
	Range = 1.0;

	/// @var {Real} The maximum allowed difference between the flare's depth and
	/// the depth in the depth buffer. When larger, the lens flare is not drawn.
	/// Default value is 1.
	DepthThreshold = 1.0;

	/// @var {Struct.BBMOD_Vec3} The direction towards the light source placed
	/// at an infinite distance. Used if {@link BBMOD_LensFlare.Position} is
	/// `undefined`. Default value is `(1, 1, 1)`.
	Direction = new BBMOD_Vec3(1.0);

	/// @var {Array<Struct.BBMOD_LensFlareElement>}
	/// @private
	__elements = [];

	static __uLightPos = shader_get_uniform(BBMOD_ShLensFlare, "u_vLightPos");
	static __uFlareRaysTex = shader_get_sampler_index(BBMOD_ShLensFlare, "u_texFlareRays");
	static __uFlareRays = shader_get_uniform(BBMOD_ShLensFlare, "u_fFlareRays")
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
		var _camera = global.__bbmodCameraCurrent;

		if (_camera == undefined)
		{
			return self;
		}

		var _screenWidth = window_get_width();
		var _screenHeight = window_get_height();

		var _screenPos = _camera.world_to_screen(
			Position ?? new BBMOD_Vec4(Direction.X, Direction.Y, Direction.Z, 0.0),
			_screenWidth, _screenHeight);

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
		shader_set_uniform_f(__uLightPos, _x, _y, _z);
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
