/// @func b_bbmod_rotation_key_to_matrix(rotation_key)
/// @param {array} rotation_key
/// @return {array}
gml_pragma("forceinline");
return ce_quaternion_to_matrix(argument0[B_EBBMODRotationKey.Rotation]);