/// @func bbmod_get_animation_key(keys, index)
/// @desc Retrieves an animation key at specified index. Checks for boundaries
/// to never read outside of the `keys` array.
/// @param {array} keys An array of AnimationKey structures.
/// @param {real} index The index.
/// @return {array} The animation key.
gml_pragma("forceinline");
return argument0[clamp(argument1, 0, array_length_1d(argument0) - 1)];