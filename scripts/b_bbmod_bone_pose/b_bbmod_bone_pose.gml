/// @func b_bbmod_bone_pose(bone, array, inverse_transform, matrix, animation)
/// @param {array} bone
/// @param {array} array
/// @param {array} inverse_transform
/// @param {array} matrix
/// @param {array} animation
// Thanks to http://ogldev.atspace.co.uk/www/tutorial38/tutorial38.html
var _bone = argument0;
var _array = argument1;
var _inverse_transform = argument2;
var _matrix = ce_matrix_clone(argument3);
var _animation = argument4;

var _animation_duration = _animation[@ B_EBBMODAnimation.Duration];
var _animation_tics_per_sec = _animation[@ B_EBBMODAnimation.TicsPerSecond];

var _time_in_seconds = current_time * 0.001;
var _time_in_tics = _time_in_seconds * _animation_tics_per_sec;
var _animation_time = _time_in_tics mod _animation_duration;

var _transform = _bone[@ B_EBBMODBone.TransformMatrix];
var _bone_index = _bone[@ B_EBBMODBone.Index];

if (_bone_index >= 0)
{
	var _bone_data = ds_map_find_value(_animation[@ B_EBBMODAnimation.Bones], _bone_index);

	if (!is_undefined(_bone_data))
	{
		// Find position
		var _positions = _bone_data[@ B_EBBMODAnimationBone.PositionKeys];
		var _positions_count = array_length_1d(_positions);
		var _position_key_next = _positions[0];

		var k = 0;
		for (/**/; k < _positions_count - 1; ++k)
		{
			_position_key_next = _positions[k + 1];
			if (_animation_time < _position_key_next[B_EBBMODPositionKey.Time])
			{
				break;
			}
		}

		// Interpolate position keys
		var _position_key = _positions[k];
		var _delta_time = _position_key_next[B_EBBMODPositionKey.Time] - _position_key[B_EBBMODPositionKey.Time];
		var _factor = (_animation_time - _position_key[B_EBBMODPositionKey.Time]) / _delta_time;
		_factor = clamp(_factor, 0, 1);
		var _position = ce_vec3_clone(_position_key[B_EBBMODPositionKey.Position]);
		ce_vec3_lerp(_position, _position_key_next[B_EBBMODPositionKey.Position], _factor);
		var _mat_position = matrix_build(
			_position[0], _position[1], _position[2],
			0, 0, 0,
			1, 1, 1
		);

		// Find rotation
		var _rotations = _bone_data[@ B_EBBMODAnimationBone.RotationKeys];
		var _rotations_count = array_length_1d(_rotations);
		var _rotation_key_next = _rotations[0];

		var k = 0;
		for (/**/; k < _rotations_count - 1; ++k)
		{
			_rotation_key_next = _rotations[k + 1];
			if (_animation_time < _rotation_key_next[B_EBBMODRotationKey.Time])
			{
				break;
			}
		}

		// Interpolate rotation frames
		var _rotation_key = _rotations[k];
		var _delta_time = _rotation_key_next[B_EBBMODRotationKey.Time] - _rotation_key[B_EBBMODRotationKey.Time];
		var _factor = (_animation_time - _rotation_key[B_EBBMODRotationKey.Time]) / _delta_time;
		_factor = clamp(_factor, 0, 1);
		var _rotation = ce_quaternion_clone(_rotation_key[B_EBBMODRotationKey.Rotation]);
		ce_quaternion_slerp(_rotation, _rotation_key_next[B_EBBMODRotationKey.Rotation], _factor);
		var _mat_rotation = ce_quaternion_to_matrix(_rotation);

		// Multiply transformation matrices
		_transform = matrix_multiply(_mat_rotation, _mat_position);
	}
}

// Apply offset
if (_bone_index >= 0)
{
	var _final_transform = _bone[@ B_EBBMODBone.OffsetMatrix];
	_final_transform = matrix_multiply(_final_transform, matrix_multiply(_transform, _matrix));
	_final_transform = matrix_multiply(_final_transform, _inverse_transform);

	array_copy(_array, _bone_index * 16, _final_transform, 0, 16);
}

_matrix = matrix_multiply(_transform, _matrix);

var _children = _bone[@ B_EBBMODBone.Children];
var _child_count = array_length_1d(_children);

for (var i = 0; i < _child_count; ++i)
{
	b_bbmod_bone_pose(_children[i], _array, _inverse_transform, _matrix, _animation);
}