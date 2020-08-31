/// @enum An enumeration of members of a BBMOD_EAnimationKey legacy struct.
/// This struct is never instantiated, it only serves as an interface for
/// specific animation keys.
enum BBMOD_EAnimationKey
{
	/// @member Time when the animation key occurs.
	Time,
	/// @member Additional key data.
	Data,
	/// @member The size of the BBMOD_EAnimationKey legacy struct.
	SIZE
};

/// @func bbmod_find_animation_key(_keys, _animation_time[, _index])
/// @desc Finds an animation key for specified animation time.
/// @param {BBMOD_EAnimationKey} _key An array of animation keys.
/// @param {real} _animation_time The current animation time.
/// @param {real} [_index] An index where to start looking. Defaults to 0.
/// @return {real} Index of found animation key.
function bbmod_find_animation_key(_keys, _animation_time)
{
	gml_pragma("forceinline");

	var _index = (argument_count > 2) ? argument[2] : 0;
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
/// @desc Retrieves an animation key at specified index. Checks for boundaries
/// to never read outside of the `keys` array.
/// @param {BBMOD_EAnimationKey[]} _keys An array of animation keys.
/// @param {real} _index The index.
/// @return {BBMOD_EAnimationKey} The animation key.
function bbmod_get_animation_key(_keys, _index)
{
	gml_pragma("forceinline");
	return _keys[clamp(_index, 0, array_length(_keys) - 1)];
}

/// @func bbmod_get_animation_key_interpolation_factor(_key, _key_next, _animation_time)
/// @desc Calculates interpolation factor between two animationo keys
/// at specified animation time.
/// @param {BBMOD_EAnimationKey} _key The first animation key.
/// @param {BBMOD_EAnimationKey} _key_next The second animation key.
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