/// b_bbmod_create_transform_array(node)
/// @param {real} node
/// @return {array}
gml_pragma("forceinline");
return array_create(argument0[? "bone_count"] * 16, 0);