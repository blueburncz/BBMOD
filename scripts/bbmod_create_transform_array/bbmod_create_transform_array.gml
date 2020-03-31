/// bbmod_create_transform_array(bbmod)
/// @desc Creates a transformation array for a BBMOD structure. This array is
/// passed to vertex shaders as uniform to transform animated models.
/// @param {real} bbmod The BBMOD structure.
/// @return {array} The created array.
gml_pragma("forceinline");
return array_create(argument0[BBMOD_EModel.BoneCount] * 16, 0);