/// @func bbmod_rotation_key_to_matrix(rotation_key)
/// @desc Creates a rotation matrix from a RotationKey structure.
/// @param {array} rotation_key The RotationKey structure.
/// @return {array} The created matrix.
gml_pragma("forceinline");
return ce_quaternion_to_matrix(argument0[BBMOD_ERotationKey.Rotation]);