/// @func b_bbmod_bone_pose(bone, array, inverse_transform, matrix, animation, animation_time)
/// @param {array} bone
/// @param {array} array
/// @param {array} inverse_transform
/// @param {array} matrix
/// @param {array} animation
/// @param {real} animation_time
// Thanks to http://ogldev.atspace.co.uk/www/tutorial38/tutorial38.html
gml_pragma("forceinline");

var _bone = argument0;
var _array = argument1;
var _inverse_transform = argument2;
var _matrix = argument3;
var _animation = argument4;
var _animation_time = argument5;

var _transform = _bone[@ B_EBBMODBone.TransformMatrix];
var _bone_index = _bone[@ B_EBBMODBone.Index];

if (_bone_index >= 0)
{
	var _bone_data = array_get(_animation[@ B_EBBMODAnimation.Bones], _bone_index);

	if (!is_undefined(_bone_data))
	{
		var _factor;
		var k;

		// Find position keys
		var _positions = _bone_data[@ B_EBBMODAnimationBone.PositionKeys];
		k = b_bbmod_find_animation_key(_positions, _animation_time, position_key_last[_bone_index]);
		var _position_key = b_bbmod_get_animation_key(_positions, k);
		var _position_key_next = b_bbmod_get_animation_key(_positions, k + 1);
		position_key_last[@ _bone_index] = k;

		// Interpolate between the keys
		_factor = b_bbmod_get_animation_key_interpolation_factor(
			_position_key, _position_key_next, _animation_time);
		var _position = _position_key[B_EBBMODPositionKey.Position];
		var _position_next = _position_key_next[B_EBBMODPositionKey.Position];
		var _mat_position = matrix_build(
			lerp(_position[0], _position_next[0], _factor),
			lerp(_position[1], _position_next[1], _factor),
			lerp(_position[2], _position_next[2], _factor),
			0, 0, 0,
			1, 1, 1);

		// Find rotation keys
		var _rotations = _bone_data[@ B_EBBMODAnimationBone.RotationKeys];
		k = b_bbmod_find_animation_key(_rotations, _animation_time, rotation_key_last[_bone_index]);
		var _rotation_key = b_bbmod_get_animation_key(_rotations, k);
		var _rotation_key_next = b_bbmod_get_animation_key(_rotations, k + 1);
		rotation_key_last[@ _bone_index] = k;

		// Interpolate between the keys
		_factor = b_bbmod_get_animation_key_interpolation_factor(
			_rotation_key, _rotation_key_next, _animation_time);
		var _rotation = ce_quaternion_clone(_rotation_key[B_EBBMODRotationKey.Rotation]);
		ce_quaternion_slerp(_rotation, _rotation_key_next[B_EBBMODRotationKey.Rotation], _factor);
		var _mat_rotation = ce_quaternion_to_matrix(_rotation);

		// Multiply transformation matrices
		_transform = matrix_multiply(_mat_rotation, _mat_position);
	}

	// Apply offset
	var _final_transform = _bone[@ B_EBBMODBone.OffsetMatrix];
	_final_transform = matrix_multiply(_final_transform, matrix_multiply(_transform, _matrix));
	_final_transform = matrix_multiply(_final_transform, _inverse_transform);
	array_copy(_array, _bone_index * 16, _final_transform, 0, 16);
}

return matrix_multiply(_transform, _matrix);