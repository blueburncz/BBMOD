/// @func bbmod_animation_player()
/// @desc Contains definition of the AnimationPlayer structure.
/// @see BBMOD_EAnimationPlayer
function bbmod_animation_player()
{
	/// @enum An enumeration of member of an AnimationPlayer structure.
	enum BBMOD_EAnimationPlayer
	{
		/// @member A Model which the AnimationPlayer animates.
		Model,
		/// @member List of animations to play.
		Animations,
		/// @member The last played AnimationInstance.
		AnimationInstanceLast,
		/// @member Array of 3D vectors for bone position overriding.
		BonePositionOverride,
		/// @member Array of quaternions for bone position overriding.
		BoneRotationOverride,
		/// @member The size of the AnimationPlayer structure.
		SIZE
	};
}

/// @func bbmod_animation_player_create(_model)
/// @desc Creates a new AnimationPlayer for given Model.
/// @param {array} model A Model structure.
/// @return {array} The created AnimationPlayer structure.
function bbmod_animation_player_create(_model)
{
	var _bone_count = _model[BBMOD_EModel.BoneCount];
	var _anim_player = array_create(BBMOD_EAnimationPlayer.SIZE, 0);
	_anim_player[@ BBMOD_EAnimationPlayer.Model] = _model;
	_anim_player[@ BBMOD_EAnimationPlayer.Animations] = ds_list_create();
	_anim_player[@ BBMOD_EAnimationPlayer.AnimationInstanceLast] = undefined;
	_anim_player[@ BBMOD_EAnimationPlayer.BonePositionOverride] = array_create(_bone_count, undefined);
	_anim_player[@ BBMOD_EAnimationPlayer.BoneRotationOverride] = array_create(_bone_count, undefined);
	return _anim_player;
}

/// @func bbmod_animation_player_destroy(_animation_player)
/// @desc Frees any memory used by an AnimationPlayer structure.
/// @param {array} _animation_player The AnimationPlayer structure.
function bbmod_animation_player_destroy(_animation_player)
{
	ds_list_destroy(_animation_player[BBMOD_EAnimationPlayer.Animations]);
}

/// @func bbmod_animation_player_update(_animation_player, _current_time[, _interpolate_frames])
/// @desc Updates an AnimationPlayer structure. Should be call each frame.
/// @param {array} _animation_player The AnimationPlayer structure.
/// @param {real} _current_time The current time in seconds.
/// @param {bool} [_interpolate_frames] Set to `false` do disable interpolation
/// between animation frames. This results into worse visual fidelity, but it
/// improves framerate. Defaults to `true`.
function bbmod_animation_player_update()
{
	var _anim_player = argument[0];
	var _current_time = argument[1];
	var _interpolate_frames = (argument_count > 2) ? argument[2] : true;
	var _animations = _anim_player[BBMOD_EAnimationPlayer.Animations];

	repeat (ds_list_size(_animations))
	{
		var _anim_inst = _animations[| 0];

		if (is_undefined(_anim_inst[BBMOD_EAnimationInstance.AnimationStart]))
		{
			_anim_inst[@ BBMOD_EAnimationInstance.AnimationStart] = _current_time;
		}
		var _animation_start = _anim_inst[BBMOD_EAnimationInstance.AnimationStart];

		var _animation = _anim_inst[BBMOD_EAnimationInstance.Animation];

		var _animation_time = bbmod_get_animation_time(_animation, _current_time - _animation_start);
		var _looped = (_animation_time < _anim_inst[BBMOD_EAnimationInstance.AnimationTimeLast]);

		if (_looped && !_anim_inst[BBMOD_EAnimationInstance.Loop])
		{
			ce_trigger_event(BBMOD_EV_ANIMATION_END, _animation);
			ds_list_delete(_animations, 0);
			continue;
		}

		_anim_inst[@ BBMOD_EAnimationInstance.AnimationTime] = _animation_time;

		var _bone_count = array_length(_animation[BBMOD_EAnimation.Bones]);
		var _initialized = (!is_undefined(_anim_inst[BBMOD_EAnimationInstance.BoneTransform])
			&& !is_undefined(_anim_inst[BBMOD_EAnimationInstance.TransformArray]));

		if (!_initialized)
		{
			_anim_inst[@ BBMOD_EAnimationInstance.BoneTransform] =
				array_create(_bone_count * 16, 0);
			_anim_inst[@ BBMOD_EAnimationInstance.TransformArray] =
				array_create(_bone_count * 16, 0);
		}

		if (!_initialized || _looped)
		{
			_anim_inst[@ BBMOD_EAnimationInstance.PositionKeyLast] =
				array_create(_bone_count, 0);
			_anim_inst[@ BBMOD_EAnimationInstance.RotationKeyLast] =
				array_create(_bone_count, 0);
		}

		_anim_inst[@ BBMOD_EAnimationInstance.AnimationTimeLast] = _animation_time;

		bbmod_animate(_anim_player, _anim_inst, _animation_time, _interpolate_frames);

		_anim_player[@ BBMOD_EAnimationPlayer.AnimationInstanceLast] = _anim_inst;
	}
}

/// @func bbmod_animate(_animation_player, _animation_instance, _animation_time, _interpolate_frames)
/// @desc Calculates skeleton's current transformation matrices.
/// @param {array} _animation_player An AnimationPlayer structure.
/// @param {array} _animation_instance An AnimationInstance structure.
/// @param {real} _animation_time The current animation time.
/// @param {bool} _interpolate_frames True to interpolate between animation frames.
function bbmod_animate(_animation_player, _animation_instance, _animation_time, _interpolate_frames)
{
	//var _t = get_timer();

	var _model = _animation_player[BBMOD_EAnimationPlayer.Model];
	var _animation = _animation_instance[BBMOD_EAnimationInstance.Animation];
	var _anim_stack = global.__bbmod_anim_stack;
	var _inverse_transform = _model[BBMOD_EModel.InverseTransformMatrix];
	var _position_key_last = _animation_instance[BBMOD_EAnimationInstance.PositionKeyLast];
	var _rotation_key_last = _animation_instance[BBMOD_EAnimationInstance.RotationKeyLast];
	var _bone_transform = _animation_instance[BBMOD_EAnimationInstance.BoneTransform];
	var _transform_array = _animation_instance[BBMOD_EAnimationInstance.TransformArray];
	var _anim_bones = _animation[BBMOD_EAnimation.Bones];
	var _position_overrides = _animation_player[BBMOD_EAnimationPlayer.BonePositionOverride];
	var _rotation_overrides = _animation_player[BBMOD_EAnimationPlayer.BoneRotationOverride];

	ds_stack_push(_anim_stack, _model[BBMOD_EModel.Skeleton], matrix_build_identity());

	var _mat_transform = matrix_build_identity();

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
				var _override = _position_overrides[_bone_index];

				if (_override == undefined)
				{
					var _positions = _bone_data[BBMOD_EAnimationBone.PositionKeys];
					var _positions_size = array_length(_positions);
					var _index = _position_key_last[_bone_index];

					var _position_key;
					var _position_key_next;

				#region Find position keys
					repeat (_positions_size)
					{
						if (_index + 1 >= _positions_size)
						{
							_index = 0;
						}
						_position_key = _positions[_index];
						_position_key_next = _positions[clamp(_index + 1, 0, _positions_size - 1)];
						if (_animation_time < _position_key_next[BBMOD_EAnimationKey.Time])
						{
							break;
						}
						++_index;
					}
				#endregion Find position keys

					_position_key_last[@ _bone_index] = _index;

					if (_interpolate_frames)
					{
						var _position_key_time = _position_key[BBMOD_EAnimationKey.Time];
						var _delta_time = _position_key_next[BBMOD_EAnimationKey.Time] - _position_key_time;
						var _factor = (_delta_time == 0) ? 0 : (_animation_time - _position_key_time) / _delta_time;

						var _pos_from = _position_key[BBMOD_EPositionKey.Position];
						var _pos_to = _position_key_next[BBMOD_EPositionKey.Position];

						_mat_transform[12] = lerp(_pos_from[0], _pos_to[0], _factor);
						_mat_transform[13] = lerp(_pos_from[1], _pos_to[1], _factor);
						_mat_transform[14] = lerp(_pos_from[2], _pos_to[2], _factor);
					}
					else // Interpolated
					{
						var _pos_from = _position_key[BBMOD_EPositionKey.Position];

						_mat_transform[12] = _pos_from[0];
						_mat_transform[13] = _pos_from[1];
						_mat_transform[14] = _pos_from[2];
					} // No interpolation
				}
				else // Animation
				{
					_mat_transform[12] = _override[0];
					_mat_transform[13] = _override[1];
					_mat_transform[14] = _override[2];
				} // Override
			#endregion

			#region Rotation
				var _override = _rotation_overrides[_bone_index];
				var _q10, _q11, _q12, _q13;

				if (_override == undefined)
				{
					var _rotations = _bone_data[BBMOD_EAnimationBone.RotationKeys];
					var _rotations_size = array_length(_rotations);
					var _index = _rotation_key_last[_bone_index];

					var _rotation_key;
					var _rotation_key_next;

				#region Find rotation keys
					repeat (_rotations_size)
					{
						if (_index + 1 >= _rotations_size)
						{
							_index = 0;
						}
						_rotation_key = _rotations[_index];
						_rotation_key_next = _rotations[clamp(_index + 1, 0, _rotations_size - 1)];
						if (_animation_time < _rotation_key_next[BBMOD_EAnimationKey.Time])
						{
							break;
						}
						++_index;
					}
				#endregion Find rotation keys

					_rotation_key_last[@ _bone_index] = _index;

					if (_interpolate_frames)
					{
						var _rotation_key_time = _rotation_key[BBMOD_EAnimationKey.Time];
						var _delta_time = _rotation_key_next[BBMOD_EAnimationKey.Time] - _rotation_key_time;
						var _factor = (_delta_time == 0) ? 0 : (_animation_time - _rotation_key_time) / _delta_time;
	
						var _rot_from = _rotation_key[BBMOD_ERotationKey.Rotation];
						var _rot_to = _rotation_key_next[BBMOD_ERotationKey.Rotation];

					#region Quaternion slerp
						_q10 = _rot_from[0];
						_q11 = _rot_from[1];
						_q12 = _rot_from[2];
						_q13 = _rot_from[3];

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
						var _q2norm = 1 / sqrt(_q20 * _q20
							+ _q21 * _q21
							+ _q22 * _q22
							+ _q23 * _q23);

						_q20 *= _q2norm;
						_q21 *= _q2norm;
						_q22 *= _q2norm;
						_q23 *= _q2norm;
					#endregion Normalize q2

						var _dot = _q10 * _q20
							+ _q11 * _q21
							+ _q12 * _q22
							+ _q13 * _q23;

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
					}
					else // Interpolated
					{
						var _rot_from = _rotation_key[BBMOD_ERotationKey.Rotation];

						_q10 = _rot_from[0];
						_q11 = _rot_from[1];
						_q12 = _rot_from[2];
						_q13 = _rot_from[3];
					} // No interpolation
				}
				else // Animation
				{
					_q10 = _override[0];
					_q11 = _override[1];
					_q12 = _override[2];
					_q13 = _override[3];
				} // Override

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

				_mat_transform[0] = 1 - 2 * (_q1sqr + _q2sqr);
				_mat_transform[1] = 2 * (_q0q1 + _q3q2);
				_mat_transform[2] = 2 * (_q0q2 - _q3q1);
				_mat_transform[4] = 2 * (_q0q1 - _q3q2);
				_mat_transform[5] = 1 - 2 * (_q0sqr + _q2sqr);
				_mat_transform[6] = 2 * (_q1q2 + _q3q0);
				_mat_transform[8] = 2 * (_q0q2 + _q3q1);
				_mat_transform[9] = 2 * (_q1q2 - _q3q0);
				_mat_transform[10] = 1 - 2 * (_q0sqr + _q1sqr);
			#endregion Quaternion to matrix
			#endregion Rotation

				_transform = _mat_transform;
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
		var _child_count = array_length(_children);

		var i = 0;
		repeat (_child_count)
		{
			ds_stack_push(_anim_stack, _children[i++], _matrix_new);
		}
	}

	//show_debug_message(get_timer() - _t);
}

/// @func bbmod_get_transform(_animation_player)
/// @desc Returns an array of current transformation matrices for animated models.
/// @param {array} _animation_player An AnimationPlayer structure.
/// @return {array} The array of transformation matrices.
function bbmod_get_transform(_animation_player)
{
	var _animation = _animation_player[BBMOD_EAnimationPlayer.AnimationInstanceLast];
	if (!is_undefined(_animation))
	{
		return _animation[BBMOD_EAnimationInstance.TransformArray];
	}
	var _model = _animation_player[BBMOD_EAnimationPlayer.Model];
	return bbmod_model_get_bindpose_transform(_model);
}

/// @func bbmod_get_bone_transform(_animation_player, _bone_index)
/// @desc Returns a transformation matrix of a bone, which can be used
/// for example for attachments.
/// @param {array} _animation_player An AnimationPlayer structure.
/// @param {real} _bone_index The index of the bone.
/// @return {array} The transformation matrix.
function bbmod_get_bone_transform(_animation_player, _bone_index)
{
	var _anim_inst = _animation_player[BBMOD_EAnimationPlayer.AnimationInstanceLast];
	if (is_undefined(_anim_inst))
	{
		return matrix_build_identity();
	}
	return array_get(_anim_inst[BBMOD_EAnimationInstance.BoneTransform], _bone_index);
}

/// @func bbmod_set_bone_position(_animation_player, _bone_id, _position)
/// @desc Defines a bone position to be used instead of one from the animation
/// that's currently playing.
/// @param {array} _animation_player The animation player structure.
/// @param {real} _bone_id The id of the bone to transform.
/// @param {array/undefined} _position An array with the new bone position `[x,y,z]`,
/// or `undefined` to disable the override.
/// @note This should be used before [bbmod_animation_player_update](./bbmod_animation_player_update.html)
/// is executed.
function bbmod_set_bone_position(_animation_player, _bone_id, _position)
{
	gml_pragma("forceinline");
	var _overrides = _animation_player[BBMOD_EAnimationPlayer.BonePositionOverride];
	_overrides[@ _bone_id] = _position;
}

/// @func bbmod_set_bone_rotation(_animation_player, _bone_id, _quaternion)
/// @desc Defines a bone rotation to be used instead of one from the animation
/// that's currently playing.
/// @param {array} _animation_player The animation player structure.
/// @param {real} _bone_id The id of the bone to transform.
/// @param {array/undefined} _quaternion An array with the new bone rotation `[x,y,z,w]`,
/// or `undefined` to disable the override.
/// @note This should be used before [bbmod_animation_player_update](./bbmod_animation_player_update.html)
/// is executed.
function bbmod_set_bone_rotation(_animation_player, _bone_id, _quaternion)
{
	gml_pragma("forceinline");
	var _overrides = _animation_player[BBMOD_EAnimationPlayer.BoneRotationOverride];
	_overrides[@ _bone_id] = _quaternion;
}

/// @func bbmod_play(_animation_player, _animation[, _loop])
/// @desc Starts playing an animation.
/// @param {struct} _animation_player An AnimationPlayer structure.
/// @param {struct} _animation An Animation to play.
/// @param {bool} [_loop] True to loop the animation. Defaults to false.
function bbmod_play()
{
	var _animation_player = argument[0];
	var _animation = argument[1];
	var _loop = (argument_count > 2) ? argument[2] : false;

	var _animation_list = _animation_player[BBMOD_EAnimationPlayer.Animations]; 
	var _animation_last = _animation_player[@ BBMOD_EAnimationPlayer.AnimationInstanceLast];

	ds_list_clear(_animation_list);

	if (!is_undefined(_animation_last))
	{
		var _transition = bbmod_animation_create_transition(
			_animation_player[BBMOD_EAnimationPlayer.Model],
			_animation_last[BBMOD_EAnimationInstance.Animation],
			_animation_last[BBMOD_EAnimationInstance.AnimationTime],
			_animation,
			0,
			0.1);

		var _transition_animation_instance = bbmod_animation_instance_create(_transition);
		ds_list_add(_animation_list, _transition_animation_instance);
	}

	var _animation_instance = bbmod_animation_instance_create(_animation);
	_animation_instance[@ BBMOD_EAnimationInstance.Loop] = _loop;
	ds_list_add(_animation_list, _animation_instance);
}

/// @func BBMOD_AnimationPlayer(_model)
/// @desc An OOP wrapper around BBMOD_EAnimationPlayer.
/// @param {array} _model A BBMOD_EModel that the animation player animates.
function BBMOD_AnimationPlayer(_model) constructor
{
	/// @var {array} A BBMOD_EModel that the animation player animates.
	model = _model;

	/// @var {bool} If true, then the animation player interpolates between
	/// frames. Setting this to false increases performance, but decreases
	/// quality of animation playback.
	interpolate_frames = true;

	/// @var {array} A BBMOD_EAnimationPlayer that this struct wraps.
	animation_player = bbmod_animation_player_create(model);

	/// @desc Updates the animation player. This should be called every frame
	/// in the step event.
	/// @param {real} _current_time The current time in seconds.
	static update = function (_current_time) {
		bbmod_animation_player_update(animation_player, _current_time, interpolate_frames);
	};

	/// @desc Starts playing an animation.
	/// @param {array} _animation A BBMOD_EAnimation to play.
	static play = function (_animation) {
		var _loop = (argument_count > 1) ? argument[1] : false;
		bbmod_play(animation_player, _animation, _loop);
	};

	/// @return {array} Returns current transformations of all bones.
	static get_transform = function () {
		return bbmod_get_transform(animation_player);
	};

	/// @param {real} _bone_index An index of a bone.
	/// @return {array} Returns current transformation of a specific bone.
	static get_bone_transform = function (_bone_index) {
		return bbmod_get_bone_transform(animation_player, _bone_index);
	};

	/// @desc Changes a position of a bone.
	/// @param {real} _bone_index An index of a bone.
	/// @param {array} _position An x,y,z position of a bone.
	static set_bone_position = function (_bone_index, _position) {
		bbmod_set_bone_position(animation_player, _bone_index, _position);
	};

	/// @desc Changes a rotation of a bone.
	/// @param {real} _bone_index An index of a bone.
	/// @param {array} _rotation A quaternion.
	static set_bone_rotation = function (_bone_index, _rotation) {
		bbmod_set_bone_rotation(animation_player, _bone_index, _rotation);
	};
}