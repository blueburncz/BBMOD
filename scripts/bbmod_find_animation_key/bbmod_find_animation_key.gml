/// @func bbmod_find_animation_key(keys, animation_time[, index])
/// @desc Finds an animation key for specified animation time.
/// @param {array} key An array of animation keys.
/// @param {real} animation_time The current animation time.
/// @param {real} [index] An index where to start looking. Defaults to 0.
/// @return {real} Index of found animation key.
gml_pragma("forceinline");

var _keys = argument[0];
var _animation_time = argument[1];
var _index/*:int*/= (argument_count > 2) ? argument[2] : 0;
var _key_count = array_length_1d(_keys);

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