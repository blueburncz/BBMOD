/// @func b_bbmod_find_animation_key(keys, animation_time[, index])
/// @param {array} key An array of animation keys.
/// @param {real} animation_time The current animation time.
/// @param {real} [index] An index where to start looking. Defaults to 0.
/// @return {real} Index of found animation key.
gml_pragma("forceinline");

var _keys = argument[0];
var _animation_time = argument[1];
var _index = (argument_count > 2) ? argument[2] : 0;
var _key_count = array_length_1d(_keys);

repeat (2)
{
	for (/**/; _index < _key_count - 1; ++_index)
	{
		var _key_next = _keys[_index + 1];
		if (_animation_time < _key_next[B_EBBMODAnimationKey.Time])
		{
			return _index;
		}
	}
	_index = 0;
}

return _index;