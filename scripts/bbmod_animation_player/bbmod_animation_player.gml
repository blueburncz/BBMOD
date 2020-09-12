/// @macro {string} An event triggered on animation end. The event data
/// will containg the animation that was finished playing.
/// @see BBMOD_AnimationPlayer.OnEvent
#macro BBMOD_EV_ANIMATION_END "bbmod_ev_animation_end"

/// @var {ds_stack} A stack used when posing skeletons to avoid recursion.
/// @private
global.__bbmod_anim_stack = ds_stack_create();

/// @func bbmod_animation_player_create(_model)
/// @desc Creates a new animation player for given model.
/// @param {BBMOD_Model} _model A model.
/// @return {BBMOD_AnimationPlayer} The created animation player.
/// @deprecated This functions is deprecated. Please use {@link BBMOD_AnimationPlayer}
/// instead.
function bbmod_animation_player_create(_model)
{
	gml_pragma("forceinline");
	return new BBMOD_AnimationPlayer(_model);
}

/// @func bbmod_animation_player_destroy(_animation_player)
/// @desc Frees any memory used by an animation player.
/// @param {BBMOD_AnimationPlayer} _animation_player The animation player.
/// @deprecated This function is deprecated. Please use {@link BBMOD_AnimationPlayer.destroy}
/// instead.
function bbmod_animation_player_destroy(_animation_player)
{
	gml_pragma("forceinline");
	_animation_player.destroy();
}

/// @func bbmod_animation_player_update(_animation_player, _current_time[, _interpolate_frames])
/// @desc Updates an animation player. Should be call each frame.
/// @param {BBMOD_AnimationPlayer} _animation_player The animation player.
/// @param {real} _current_time The current time in seconds. This argument is
/// now ignored, because the animation player has its own mechanisms for controlling
/// playback speed.
/// @param {bool} [_interpolate_frames] Set to `false` do disable interpolation
/// between animation frames. This results into worse visual fidelity, but it
/// improves framerate. Defaults to `true`.
/// @deprecated This function is deprecated. Please use {@link BBMOD_AnimationPlayer.update}
/// instead.
function bbmod_animation_player_update(_anim_player, _current_time)
{
	gml_pragma("forceinline");
	_anim_player.InterpolateFrames = (argument_count > 2) ? argument[2] : true;
	_anim_player.update();
}

/// @func bbmod_get_transform(_animation_player)
/// @desc Returns an array of current transformation matrices for animated models.
/// @param {BBMOD_AnimationPlayer} _animation_player An animation player.
/// @return {real[]} The array of transformation matrices.
/// @deprecated This function is deprecated. Please use {@link BBMOD_AnimationPlayer.get_transform}
/// instead.
function bbmod_get_transform(_animation_player)
{
	gml_pragma("forceinline");
	return _animation_player.get_transform();
}

/// @func bbmod_get_bone_transform(_animation_player, _bone_index)
/// @desc Returns a transformation matrix of a bone, which can be used
/// for example for attachments.
/// @param {BBMOD_AnimationPlayer} _animation_player An animation player.
/// @param {real} _bone_index The index of the bone.
/// @return {real[]} The transformation matrix.
/// @deprecated This function is deprecated. Please use {@link BBMOD_AnimationPlayer.get_bone_transform}
/// instead.
function bbmod_get_bone_transform(_animation_player, _bone_index)
{
	gml_pragma("forceinline");
	return _animation_player.get_bone_transform(_bone_index);
}

/// @func bbmod_set_bone_position(_animation_player, _bone_id, _position)
/// @desc Defines a bone position to be used instead of one from the animation
/// that's currently playing.
/// @param {BBMOD_AnimationPlayer} _animation_player The animation player.
/// @param {real} _bone_id The id of the bone to transform.
/// @param {real[]/undefined} _position An array with the new bone position `[x,y,z]`,
/// or `undefined` to disable the override.
/// @note This should be used before {@link bbmod_animation_player_update}
/// is executed.
/// @deprecated This function is deprecated. Please use {@link BBMOD_AnimationPlayer.set_bone_position}
/// instead.
function bbmod_set_bone_position(_animation_player, _bone_id, _position)
{
	gml_pragma("forceinline");
	_animation_player.set_bone_position(_bone_id, _position);
}

/// @func bbmod_set_bone_rotation(_animation_player, _bone_id, _quaternion)
/// @desc Defines a bone rotation to be used instead of one from the animation
/// that's currently playing.
/// @param {BBMOD_AnimationPlayer} _animation_player The animation player.
/// @param {real} _bone_id The id of the bone to transform.
/// @param {real[]/undefined} _quaternion An array with the new bone rotation `[x,y,z,w]`,
/// or `undefined` to disable the override.
/// @note This should be used before {@link bbmod_animation_player_update}
/// is executed.
/// @deprecated This function is deprecated. Please use {@link BBMOD_AnimationPlayer.set_bone_rotation}
/// instead.
function bbmod_set_bone_rotation(_animation_player, _bone_id, _quaternion)
{
	gml_pragma("forceinline");
	_animation_player.set_bone_rotation(_bone_id, _quaternion);
}

/// @func bbmod_play(_animation_player, _animation[, _loop])
/// @desc Starts playing an animation.
/// @param {BBMOD_AnimationPlayer} _animation_player An animation player.
/// @param {BBMOD_Animation} _animation The animation to play.
/// @param {bool} [_loop] `true` to loop the animation. Defaults to `false`.
/// @deprecated This function is deprecated. Please use {@link BBMOD_AnimationPlayer.play} instead.
function bbmod_play(_animation_player, _animation)
{
	gml_pragma("forceinline");
	var _loop = (argument_count > 2) ? argument[2] : false;
	_animation_player.play(_animation, _loop);
}

/// @func BBMOD_AnimationPlayer(_model[, _paused])
/// @desc An animation player. Each instance of an animated model should have
/// its own animation player.
/// @param {BBMOD_Model} _model A model that the animation player animates.
/// @param {bool} [_paused] If `true` then the animation player is created
/// as paused. Defaults to `false`.
/// @example
/// Following code shows how to load models and animations in a resource manager
/// object and then play animations in multiple instances of a character object.
/// ```gml
/// /// @desc Create event of OResourceManager
/// mod_character = new BBMOD_Model("character.bbmod");
/// anim_idle = new BBMOD_Animation("index.bbanim");
///
/// /// @desc Create event of OCharacter
/// model = OResourceManager.mod_character;
/// animation_player = new BBMOD_AnimationPlayer(model);
/// animation_player.play(OResourceManager.anim_idle, true);
///
/// /// @desc Step event of OCharacter
/// animation_player.update();
///
/// /// @desc Draw event of OCharacter
/// bbmod_material_reset();
/// model.render(undefined, animation_player.get_transform());
/// bbmod_material_reset();
/// ```
/// @see BBMOD_Model
/// @see BBMOD_Animation
function BBMOD_AnimationPlayer(_model) constructor
{
	/// @var {BBMOD_Model} A model that the animation player animates.
	/// @readonly
	Model = _model;

	/// @var {ds_list<BBMOD_Animation>} List of animations to play.
	/// @see BBMOD_Animation
	/// @private
	Animations = ds_list_create();

	/// @var {BBMOD_AnimationInstance} The last played animation instance.
	/// @see BBMOD_AnimationInstance
	/// @private
	AnimationInstanceLast = undefined;

	/// @var {array<real[]>} Array of 3D vectors for node position overriding.
	/// @see BBMOD_AnimationPlayer.set_bone_position
	/// @private
	NodePositionOverride = array_create(Model.NodeCount, undefined);

	/// @var {array<real[]>} Array of quaternions for bone rotation overriding.
	/// @see BBMOD_AnimationPlayer.set_bone_rotation
	/// @private
	NodeRotationOverride = array_create(Model.NodeCount, undefined);

	/// @var {bool} If `true`, then the animation playback is paused.
	Paused = (argument_count > 1) ? argument[1] : false;

	/// @var {real} The current animation playback time.
	Time = 0;

	/// @var {real} Controls animation playback speed.
	PlaybackSpeed = 1;

	/// @var {bool} If `true`, then the animation player interpolates between
	/// frames. Setting this to `false` increases performance, but decreases
	/// quality of animation playback.
	InterpolateFrames = true;

	/// @var {function/undefined} A function executed when an animation event
	/// occurs. It will be given two arguments - the event type and an
	/// {@link BBMOD_Animation}. Use `undefined` for no function.
	/// @example
	/// ```gml
	/// animation_player = new BBMOD_AnimationPlayer(model);
	/// animation_player.OnEvent = function (_event, _animation) {
	///     switch (_event)
	///     {
	///     case BBMOD_EV_ANIMATION_END:
	///         // Do something when _animation ends...
	///         break;
	///     }
	/// };
	/// ```
	/// @see BBMOD_EV_ANIMATION_END
	OnEvent = undefined;

	/// @func animate(_animation_instance, _animation_time)
	/// @desc Calculates skeleton's current transformation matrices.
	/// @param {BBMOD_AnimationInstance} _animation_instance An animation instance.
	/// @param {real} _animation_time The current animation time.
	/// @private
	static animate = function (_animation_instance, _animation_time) {
		//var _t = get_timer();

		var _model = Model;
		var _animation = _animation_instance.Animation;
		var _anim_stack = global.__bbmod_anim_stack;
		var _inverse_transform = _model.InverseTransformMatrix;
		var _position_key_last = _animation_instance.PositionKeyLast;
		var _rotation_key_last = _animation_instance.RotationKeyLast;
		var _bone_transform = _animation_instance.BoneTransform;
		var _transform_array = _animation_instance.TransformArray;
		var _anim_nodes = _animation.Nodes;
		var _skeleton = _model.Skeleton;
		var _position_overrides = NodePositionOverride;
		var _rotation_overrides = NodeRotationOverride;
		var _interpolate_frames = InterpolateFrames;

		ds_stack_push(_anim_stack, _model.RootNode, matrix_build_identity());

		var _mat_transform = matrix_build_identity();

		while (!ds_stack_empty(_anim_stack))
		{
			var _matrix = ds_stack_pop(_anim_stack);
			var _node = ds_stack_pop(_anim_stack);
			var _transform = _node[BBMOD_ENode.TransformMatrix];
			var _node_index = _node[BBMOD_ENode.Index];

			show_debug_message("");
			show_debug_message(["node", _node[BBMOD_ENode.Name]]);
			show_debug_message(["index", _node[BBMOD_ENode.Index]]);
			show_debug_message(["is_bone", _node[BBMOD_ENode.IsBone]]);

			var _node_data = _anim_nodes[_node_index];

			show_debug_message(["has_data", _node_data != undefined]);

			if (_node_data != undefined)
			{
				

				#region Position
				var _override = undefined; //_position_overrides[_node_index];

				if (_override == undefined)
				{
					var _positions = _node_data[BBMOD_EAnimationNode.PositionKeys];
					var _positions_size = array_length(_positions);
					var _index = _position_key_last[_node_index];

					show_debug_message(["index_last", _index]);

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

					_position_key_last[@ _node_index] = _index;
					show_debug_message(["index_current", _index]);

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
				var _override = undefined; //_rotation_overrides[_node_index];
				var _q10, _q11, _q12, _q13;

				if (_override == undefined)
				{
					var _rotations = _node_data[BBMOD_EAnimationNode.RotationKeys];
					var _rotations_size = array_length(_rotations);
					var _index = _rotation_key_last[_node_index];

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

					_rotation_key_last[@ _node_index] = _index;

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
			var _matrix_new = matrix_multiply(_transform, _matrix);

			if (_node[BBMOD_ENode.IsBone])
			{
				var _final_transform = matrix_multiply(_matrix_new, _inverse_transform);

				var _arr = _bone_transform[_node_index];
				if (!is_array(_arr))
				{
					_arr = array_create(16, 0);
					_bone_transform[@ _node_index] = _arr;
				}
				array_copy(_arr, 0, _final_transform, 0, 16);

				var _offset_matrix = _skeleton[_node_index][BBMOD_EBone.OffsetMatrix];
				_final_transform = matrix_multiply(_offset_matrix, _final_transform);
				array_copy(_transform_array, _node_index * 16, _final_transform, 0, 16);
			}

			var _children = _node[BBMOD_ENode.Children];
			var _child_count = array_length(_children);

			var i = 0;
			repeat (_child_count)
			{
				ds_stack_push(_anim_stack, _children[i++], _matrix_new);
			}
		}

		//show_debug_message(get_timer() - _t);
	}

	/// @func update()
	/// @desc Updates the animation player. This should be called every frame in
	/// the step event.
	/// @return {BBMOD_AnimationPlayer} Returns `self` to allow method chaining.
	static update = function () {
		if (Paused)
		{
			return self;
		}

		Time += delta_time * 0.000001 * PlaybackSpeed;

		repeat (ds_list_size(Animations))
		{
			var _anim_inst = Animations[| 0];

			if (is_undefined(_anim_inst.AnimationStart))
			{
				_anim_inst.AnimationStart = Time;
			}

			var _animation_start = _anim_inst.AnimationStart;
			var _animation = _anim_inst.Animation;
			var _animation_time = bbmod_get_animation_time(_animation, Time - _animation_start);
			var _looped = (_animation_time < _anim_inst.AnimationTimeLast);

			if (_looped && !_anim_inst.Loop)
			{
				if (OnEvent != undefined)
				{
					OnEvent(BBMOD_EV_ANIMATION_END, _animation);
				}
				ds_list_delete(Animations, 0);
				continue;
			}

			_anim_inst.AnimationTime = _animation_time;

			var _bone_count = Model.BoneCount;
			var _node_count = Model.NodeCount;

			var _initialized = (!is_undefined(_anim_inst.BoneTransform)
				&& !is_undefined(_anim_inst.TransformArray));

			if (!_initialized)
			{
				_anim_inst.BoneTransform =
					array_create(_bone_count * 16, undefined);
				_anim_inst.TransformArray =
					array_create(_bone_count * 16, 0);
			}

			if (!_initialized || _looped)
			{
				_anim_inst.PositionKeyLast =
					array_create(_node_count, 0);
				_anim_inst.RotationKeyLast =
					array_create(_node_count, 0);
			}

			_anim_inst.AnimationTimeLast = _animation_time;

			animate(_anim_inst, _animation_time);

			AnimationInstanceLast = _anim_inst;
		}

		return self;
	};

	/// @func play(_animation[, _loop])
	/// @desc Starts playing an animation.
	/// @param {BBMOD_Animation} _animation An animation to play.
	/// @param {bool} [_loop] If `true` then the animation will be looped. Defaults
	/// to `false`.
	/// @return {BBMOD_AnimationPlayer} Returns `self` to allow method chaining.
	static play = function (_animation) {
		var _loop = (argument_count > 1) ? argument[1] : false;
		//Time = 0;
		var _animation_list = Animations;
		var _animation_last = AnimationInstanceLast;

		ds_list_clear(_animation_list);

		if (!is_undefined(_animation_last))
		{
			var _transition = bbmod_animation_create_transition(
				Model,
				_animation_last.Animation,
				_animation_last.AnimationTime,
				_animation,
				0,
				0.1);

			var _transition_animation_instance = new BBMOD_AnimationInstance(_transition);
			ds_list_add(_animation_list, _transition_animation_instance);
		}

		var _animation_instance = new BBMOD_AnimationInstance(_animation);
		_animation_instance.Loop = _loop;
		ds_list_add(_animation_list, _animation_instance);

		return self;
	};

	/// @func get_transform()
	/// @desc Returns an array of current transformation matrices of all bones.
	/// @return {real[]} The array of transformation matrices.
	static get_transform = function () {
		var _animation = AnimationInstanceLast;
		if (!is_undefined(_animation))
		{
			return _animation.TransformArray;
		}
		return Model.get_bindpose_transform();
	};

	/// @func get_bone_transform(_bone_index)
	/// @desc Returns a transformation matrix of a bone, which can be used
	/// for example for attachments.
	/// @param {real} _bone_index An index of a bone.
	/// @return {real[]} The transformation matrix.
	static get_bone_transform = function (_bone_index) {
		var _anim_inst = AnimationInstanceLast;
		if (is_undefined(_anim_inst))
		{
			return matrix_build_identity();
		}
		return _anim_inst.BoneTransform[_bone_index];
	};

	/// @func set_bone_position(_bone_index, _position)
	/// @desc Changes a position of a bone.
	/// @param {real} _bone_index An index of a bone.
	/// @param {real[]} _position An `[x,y,z]` position of a bone.
	/// @return {BBMOD_AnimationPlayer} Returns `self` to allow method chaining.
	static set_bone_position = function (_bone_index, _position) {
		gml_pragma("forceinline");
		NodePositionOverride[@ _bone_index] = _position;
		return self;
	};

	/// @func set_bone_rotation(_bone_index, _rotation)
	/// @desc Changes a rotation of a bone.
	/// @param {real} _bone_index An index of a bone.
	/// @param {real[]} _rotation A quaternion.
	static set_bone_rotation = function (_bone_index, _rotation) {
		gml_pragma("forceinline");
		NodeRotationOverride[@ _bone_index] = _rotation;
		return self;
	};

	/// @func destroy()
	/// @desc Frees memory used by the animation player. Use this in combination
	/// with `delete` to destroy the struct.
	/// @example
	/// ```gml
	/// animation_player.destroy();
	/// delete animation_player;
	/// ```
	static destroy = function () {
		ds_list_destroy(_animation_player.Animations);
	};
}