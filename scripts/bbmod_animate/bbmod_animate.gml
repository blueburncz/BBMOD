/// @func bbmod_animate(model, animation_instance, anim_time)
/// @desc Animates a Model.
/// @param {array} model A Model structure.
/// @param {array} animation_instance An AnimationInstance structure.
/// @param {real} anim_time The current animation time.
//var _t = get_timer();

var _model = argument0;
var _anim_inst = argument1
var _animation = _anim_inst[BBMOD_EAnimationInstance.Animation];
var _animation_time = argument2;
var _anim_stack = global.__bbmod_anim_stack;
var _inverse_transform = _model[BBMOD_EModel.InverseTransformMatrix];
var _position_key_last = _anim_inst[BBMOD_EAnimationInstance.PositionKeyLast];
var _rotation_key_last = _anim_inst[BBMOD_EAnimationInstance.RotationKeyLast];
var _bone_transform = _anim_inst[BBMOD_EAnimationInstance.BoneTransform];
var _transform_array = _anim_inst[BBMOD_EAnimationInstance.TransformArray];
var _anim_bones = _animation[BBMOD_EAnimation.Bones];

ds_stack_push(_anim_stack, _model[BBMOD_EModel.Skeleton], matrix_build_identity());

var _mat_position = matrix_build_identity();
var _mat_rotation = matrix_build_identity();

while (!ds_stack_empty(_anim_stack))
{
	var _matrix = ds_stack_pop(_anim_stack);
	var _bone = ds_stack_pop(_anim_stack);
	var _transform = _bone[BBMOD_EBone.TransformMatrix];
	var _bone_index = _bone[BBMOD_EBone.Index];
	var _matrix_new;

	if (_bone_index >= 0)
	{
		var _bone_data = _anim_bones[_bone_index];

		if (!is_undefined(_bone_data))
		{
			#region Position
			var _positions = _bone_data[BBMOD_EAnimationBone.PositionKeys];
			var _positions_size = array_length_1d(_positions);
			var _index = _position_key_last[_bone_index];

			var _position_key;
			var _position_key_next;

			#region Find position keys
			var _found = false;
			repeat (_positions_size - 1 - _index)
			{
				_position_key = _positions[_index];
				_position_key_next = _positions[_index + 1];
				if (_animation_time < _position_key_next[BBMOD_EAnimationKey.Time])
				{
					_found = true;
					break;
				}
				++_index;
			}
			if (!_found)
			{
				_index = 0;
				repeat (_positions_size - 1 - _index)
				{
					_position_key = _positions[_index];
					_position_key_next = _positions[_index + 1];
					if (_animation_time < _position_key_next[BBMOD_EAnimationKey.Time])
					{
						_found = true;
						break;
					}
					++_index;
				}
			}
			#endregion Find position keys

			_position_key_last[@ _bone_index] = _index;

			var _position_key_time = _position_key[BBMOD_EAnimationKey.Time];
			var _delta_time = _position_key_next[BBMOD_EAnimationKey.Time] - _position_key_time;
			var _factor = (_delta_time == 0) ? 0 : (_animation_time - _position_key_time) / _delta_time;

			var _pos_from = _position_key[BBMOD_EPositionKey.Position];
			var _pos_to = _position_key_next[BBMOD_EPositionKey.Position];

			_mat_position[@ 12] = lerp(_pos_from[0], _pos_to[0], _factor);
			_mat_position[@ 13] = lerp(_pos_from[1], _pos_to[1], _factor);
			_mat_position[@ 14] = lerp(_pos_from[2], _pos_to[2], _factor);
			#endregion

			#region Rotation
			var _rotations = _bone_data[BBMOD_EAnimationBone.RotationKeys];
			var _rotations_size = array_length_1d(_rotations);
			var _index = _rotation_key_last[_bone_index];

			var _rotation_key;
			var _rotation_key_next;

			#region Find rotation keys
			var _found = false;
			repeat (_rotations_size - 1 - _index)
			{
				_rotation_key = _rotations[_index];
				_rotation_key_next = _rotations[_index + 1];
				if (_animation_time < _rotation_key_next[BBMOD_EAnimationKey.Time])
				{
					_found = true;
					break;
				}
				++_index;
			}
			if (!_found)
			{
				_index = 0;
				repeat (_rotations_size - 1 - _index)
				{
					_rotation_key = _rotations[_index];
					_rotation_key_next = _rotations[_index + 1];
					if (_animation_time < _rotation_key_next[BBMOD_EAnimationKey.Time])
					{
						_found = true;
						break;
					}
					++_index;
				}
			}
			#endregion Find rotation keys

			_rotation_key_last[@ _bone_index] = _index;

			var _rotation_key_time = _rotation_key[BBMOD_EAnimationKey.Time];
			var _delta_time = _rotation_key_next[BBMOD_EAnimationKey.Time] - _rotation_key_time;
			var _factor = (_delta_time == 0) ? 0 : (_animation_time - _rotation_key_time) / _delta_time;
	
			var _rot_from = _rotation_key[BBMOD_ERotationKey.Rotation];
			var _rot_to = _rotation_key_next[BBMOD_ERotationKey.Rotation];

			#region Quaternion slerp
			var _q10 = _rot_from[0];
			var _q11 = _rot_from[1];
			var _q12 = _rot_from[2];
			var _q13 = _rot_from[3];

			var _q20 = _rot_to[0];
			var _q21 = _rot_to[1];
			var _q22 = _rot_to[2];
			var _q23 = _rot_to[3];

			#region Normalize q1
			var _q1norm = 1 / sqrt(_q10 * _q10
				+ _q11 * _q11
				+ _q12 * _q12
				+ _q13 * _q13);

			_q10 *= _q1norm;
			_q11 *= _q1norm;
			_q12 *= _q1norm;
			_q13 *= _q1norm;
			#endregion Normalize q1

			#region Normalize q2
			var _q2norm = sqrt(_q20 * _q20
				+ _q21 * _q21
				+ _q22 * _q22
				+ _q23 * _q23);

			_q20 *= _q2norm;
			_q21 *= _q2norm;
			_q22 *= _q2norm;
			_q23 *= _q2norm;

			var _dot = _q10 * _q20
				+ _q11 * _q21
				+ _q12 * _q22
				+ _q13 * _q23;
			#endregion Normalize q2

			if (_dot < 0)
			{
				_dot = -_dot;
				_q20 *= -1;
				_q21 *= -1;
				_q22 *= -1;
				_q23 *= -1;
			}

			if (_dot > 0.9995)
			{
				_q10 = lerp(_q10, _q20, _factor);
				_q11 = lerp(_q11, _q21, _factor);
				_q12 = lerp(_q12, _q22, _factor);
				_q13 = lerp(_q13, _q23, _factor);
			}
			else
			{
				var _theta_0 = arccos(_dot);
				var _theta = _theta_0 * _factor;
				var _sin_theta = sin(_theta);
				var _sin_theta_0 = sin(_theta_0);
				var _s2 = _sin_theta / _sin_theta_0;
				var _s1 = cos(_theta) - (_dot * _s2);

				_q10 = (_q10 * _s1) + (_q20 * _s2);
				_q11 = (_q11 * _s1) + (_q21 * _s2);
				_q12 = (_q12 * _s1) + (_q22 * _s2);
				_q13 = (_q13 * _s1) + (_q23 * _s2);
			}
			#endregion Quaternion slerp

			#region Quaternion to matrix
			var _q0sqr = _q10 * _q10;
			var _q1sqr = _q11 * _q11;
			var _q2sqr = _q12 * _q12;
			var _q0q1 = _q10 * _q11;
			var _q0q2 = _q10 * _q12
			var _q3q2 = _q13 * _q12;
			var _q1q2 = _q11 * _q12;
			var _q3q0 = _q13 * _q10;
			var _q3q1 = _q13 * _q11;
			_mat_rotation[@ 0] = 1 - 2 * (_q1sqr + _q2sqr);
			_mat_rotation[@ 1] = 2 * (_q0q1 + _q3q2);
			_mat_rotation[@ 2] = 2 * (_q0q2 - _q3q1);
			_mat_rotation[@ 4] = 2 * (_q0q1 - _q3q2);
			_mat_rotation[@ 5] = 1 - 2 * (_q0sqr + _q2sqr);
			_mat_rotation[@ 6] = 2 * (_q1q2 + _q3q0);
			_mat_rotation[@ 8] = 2 * (_q0q2 + _q3q1);
			_mat_rotation[@ 9] = 2 * (_q1q2 - _q3q0);
			_mat_rotation[@ 10] = 1 - 2 * (_q0sqr + _q1sqr);
			#endregion Quaternion to matrix
			#endregion Rotation

			// Multiply transformation matrices
			_transform = matrix_multiply(_mat_rotation, _mat_position);
		}

		// Final transform
		_matrix_new = matrix_multiply(_transform, _matrix);
		var _final_transform = matrix_multiply(_matrix_new, _inverse_transform);

		var _arr = _bone_transform[_bone_index];
		if (!is_array(_arr))
		{
			_arr = array_create(16, 0);
			_bone_transform[@ _bone_index] = _arr;
		}
		array_copy(_arr, 0, _final_transform, 0, 16);

		_final_transform = matrix_multiply(_bone[BBMOD_EBone.OffsetMatrix], _final_transform);
		array_copy(_transform_array, _bone_index * 16, _final_transform, 0, 16);
	}
	else
	{
		_matrix_new = matrix_multiply(_transform, _matrix);
	}

	var _children = _bone[BBMOD_EBone.Children];
	var _child_count = array_length_1d(_children);

	var i = 0;
	repeat (_child_count)
	{
		ds_stack_push(_anim_stack, _children[i++], _matrix_new);
	}
}

//show_debug_message(get_timer() - _t);