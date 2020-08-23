/// @enum An enumeration of members of an AnimationKey structure.
/// This structure is never instantiated, it only serves as an interface
/// for specific animation keys.
enum BBMOD_EAnimationKey
{
	/// @member Time when the animation key occurs.
	Time,
	/// @member Additional key data.
	Data,
	/// @member The size of the AnimationKey structure.
	SIZE
};

/// @func bbmod_find_animation_key(_keys, _animation_time[, _index])
/// @desc Finds an animation key for specified animation time.
/// @param {array} _key An array of animation keys.
/// @param {real} _animation_time The current animation time.
/// @param {real} [_index] An index where to start looking. Defaults to 0.
/// @return {real} Index of found animation key.
function bbmod_find_animation_key()
{
	gml_pragma("forceinline");

	var _keys = argument[0];
	var _animation_time = argument[1];
	var _index/*:int*/= (argument_count > 2) ? argument[2] : 0;
	var _key_count = array_length(_keys);

	repeat (_key_count)
	{
		if (_index + 1 >= _key_count)
		{
			_index = 0;
		}
		var _key_next = _keys[clamp(_index + 1, 0, _key_count - 1)];
		if (_animation_time < _key_next[BBMOD_EAnimationKey.Time])
		{
			BBMOD_KEY_INDEX_LAST = _index;
			return _index;
		}
		++_index;
	}

	BBMOD_KEY_INDEX_LAST = _index;
	return _index;
}

/// @func bbmod_get_animation_key(_keys, _index)
/// @desc Retrieves an AnimationKey at specified index. Checks for boundaries
/// to never read outside of the `keys` array.
/// @param {array} _keys An array of AnimationKey structures.
/// @param {real} _index The index.
/// @return {array} The AnimationKey.
function bbmod_get_animation_key(_keys, _index)
{
	gml_pragma("forceinline");
	return _keys[clamp(_index, 0, array_length(_keys) - 1)];
}

/// @func bbmod_get_animation_key_interpolation_factor(_key, _key_next, _animation_time)
/// @desc Calculates interpolation factor between two AnimationKey structures
/// at specified animation time.
/// @param {array} _key The first AnimationKey structure.
/// @param {array} _key_next The second AnimationKey structure.
/// @param {real} _animation_time The animation time.
/// @return {real} The calculated interpolation factor.
function bbmod_get_animation_key_interpolation_factor(_key, _key_next, _animation_time)
{
	gml_pragma("forceinline");
	var _delta_time = _key_next[BBMOD_EAnimationKey.Time] - _key[BBMOD_EAnimationKey.Time];
	if (_delta_time == 0)
	{
		return 0;
	}
	var _factor = (_animation_time - _key[BBMOD_EAnimationKey.Time]) / _delta_time;
	return clamp(_factor, 0, 1);
}