/// bbmod_create_transform_array(bbmod)
/// @param {real} bbmod
/// @return {array}
gml_pragma("forceinline");
return array_create(argument0[BBMOD_EModel.BoneCount] * 16, 0);