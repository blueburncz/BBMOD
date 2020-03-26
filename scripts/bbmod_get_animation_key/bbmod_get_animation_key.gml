/// @func bbmod_get_animation_key(keys, index)
/// @param {array} keys
/// @param {real} index
/// @param {array}
gml_pragma("forceinline");
return argument0[clamp(argument1, 0, array_length_1d(argument0) - 1)];