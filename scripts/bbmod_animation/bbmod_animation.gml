/// @enum An enumeration of members of a BBMOD_EAnimation legacy struct.
enum BBMOD_EAnimation
{
	/// @member The version of the animation file.
	Version,
	/// @member The duration of the animation (in tics).
	Duration,
	/// @member Number of animation tics per second.
	TicsPerSecond,
	/// @member An array of BBMOD_EAnimationBone legacy structs.
	Bones,
	/// @member The size of the BBMOD_EAnimation legacy struct.
	SIZE
};

/// @func bbmod_animation_create_transition(_model, _anim_from, _time_from, _anim_to, _time_to, _duration)
/// @desc Creates a new animation transition between two specified animations.
/// @param {BBMOD_EModel} _model A model.
/// @param {BBMOD_EAnimation} _anim_from The first animation.
/// @param {real} _time_from Animation time of the first animation.
/// @param {BBMOD_EAnimation} _anim_to The second animation.
/// @param {real} _time_to Animation time of the second animation.
/// @param {real} _duration The duration of the transition in seconds.
/// @return {BBMOD_EAnimation} The created transition.
function bbmod_animation_create_transition(_model, _anim_from, _time_from, _anim_to, _time_to, _duration)
{
	var _anim_stack = global.__bbmod_anim_stack;

	var _transition = array_create(BBMOD_EAnimation.SIZE, 0);
	_transition[@ BBMOD_EAnimation.Version] = _anim_from[BBMOD_EAnimation.Version];
	_transition[@ BBMOD_EAnimation.Duration] = _duration;
	_transition[@ BBMOD_EAnimation.TicsPerSecond] = 1;
	_transition[@ BBMOD_EAnimation.Bones] = array_create(_model[BBMOD_EModel.BoneCount], undefined);

	ds_stack_push(_anim_stack, _model[BBMOD_EModel.Skeleton]);

	while (!ds_stack_empty(_anim_stack))
	{
		var _bone = ds_stack_pop(_anim_stack);
		var _bone_index = _bone[BBMOD_EBone.Index];

		if (_bone_index >= 0)
		{
			var _bone_data_from = array_get(_anim_from[BBMOD_EAnimation.Bones], _bone_index);
			var _bone_data_to = array_get(_anim_to[BBMOD_EAnimation.Bones], _bone_index);

			if (!is_undefined(_bone_data_from)
				&& !is_undefined(_bone_data_to))
			{
				var _positions, _rotations;

				// Keys from
				_positions = _bone_data_from[BBMOD_EAnimationBone.PositionKeys];
				var _position_from = bbmod_get_interpolated_position_key(
					_positions, _time_from);

				_rotations = _bone_data_from[BBMOD_EAnimationBone.RotationKeys];
				var _rotation_from = bbmod_get_interpolated_rotation_key(
					_rotations, _time_from);

				_position_from[@ BBMOD_EPositionKey.Time] = 0;
				_rotation_from[@ BBMOD_ERotationKey.Time] = 0;

				// Keys to
				_positions = _bone_data_to[BBMOD_EAnimationBone.PositionKeys];
				var _position_to = bbmod_get_interpolated_position_key(
					_positions, _time_to);

				_rotations = _bone_data_to[BBMOD_EAnimationBone.RotationKeys];
				var _rotation_to = bbmod_get_interpolated_rotation_key(
					_rotations, _time_to);

				_position_to[@ BBMOD_EPositionKey.Time] = _duration;
				_rotation_to[@ BBMOD_ERotationKey.Time] = _duration;

				// Create a bone with from,to keys
				var _anim_bone = array_create(BBMOD_EAnimationBone.SIZE, 0);
				_anim_bone[@ BBMOD_EAnimationBone.BoneIndex] = _bone_index;
				_anim_bone[@ BBMOD_EAnimationBone.PositionKeys] = [
					_position_from,
					_position_to,
				];
				_anim_bone[@ BBMOD_EAnimationBone.RotationKeys] = [
					_rotation_from,
					_rotation_to,
				];

				array_set(_transition[BBMOD_EAnimation.Bones], _bone_index, _anim_bone);
			}
		}

		var _children = _bone[BBMOD_EBone.Children];
		var _child_count = array_length(_children);

		for (var i = 0; i < _child_count; ++i)
		{
			ds_stack_push(_anim_stack, _children[i]);
		}
	}

	return _transition;
}

/// @func bbmod_animation_load(_buffer, _version)
/// @desc Loads an animation from a buffer.
/// @param {real} _buffer The buffer to load the struct from.
/// @param {real} _version The version of the animation file.
/// @return {BBMOD_EAnimation} The loaded animation.
function bbmod_animation_load(_buffer, _version)
{
	var _animation = array_create(BBMOD_EAnimation.SIZE, 0);
	_animation[@ BBMOD_EAnimation.Version] = _version;
	_animation[@ BBMOD_EAnimation.Duration] = buffer_read(_buffer, buffer_f64);
	_animation[@ BBMOD_EAnimation.TicsPerSecond] = buffer_read(_buffer, buffer_f64);

	var _mesh_bone_count = buffer_read(_buffer, buffer_u32);

	var _bones = array_create(_mesh_bone_count, undefined);
	_animation[@ BBMOD_EAnimation.Bones] = _bones;

	var _affected_bone_count = buffer_read(_buffer, buffer_u32);

	repeat (_affected_bone_count)
	{
		var _bone_data = bbmod_animation_bone_load(_buffer);
		var _bone_index = _bone_data[BBMOD_EAnimationBone.BoneIndex];
		_bones[@ _bone_index] = _bone_data;
	}

	return _animation;
}

/// @func bbmod_get_animation_time(_animation, _time_in_seconds)
/// @desc Calculates animation time from current time in seconds.
/// @param {BBMOD_EAnimation} _animation An animation.
/// @param {real} _time_in_seconds The current time in seconds.
/// @return {real} The animation time.
function bbmod_get_animation_time(_animation, _time_in_seconds)
{
	gml_pragma("forceinline");
	var _time_in_tics = _time_in_seconds * _animation[@ BBMOD_EAnimation.TicsPerSecond];
	return (_time_in_tics mod _animation[@ BBMOD_EAnimation.Duration]);
}

/// @func bbmod_get_interpolated_position_key(_positions, _time[, _index])
/// @desc Creates a new position key by interpolating two closest ones for
/// specified animation time.
/// @param {BBMOD_EPositionKey[]} _positions An array of position keys.
/// @param {real} _time The current animation time.
/// @param {real} [_index] An index where to start searching for two closest
/// position keys for specified time. Defaults to 0.
/// @return {BBMOD_EPositionKey} The interpolated position key.
function bbmod_get_interpolated_position_key(_positions, _time)
{
	var _index = (argument_count > 2) ? argument[2] : 0;
	var k = bbmod_find_animation_key(_positions, _time, _index);
	var _position_key = bbmod_get_animation_key(_positions, k);
	var _position_key_next = bbmod_get_animation_key(_positions, k + 1);
	var _factor = bbmod_get_animation_key_interpolation_factor(
		_position_key, _position_key_next, _time);
	return bbmod_position_key_interpolate(
		_position_key, _position_key_next, _factor);
}

/// @func bbmod_get_interpolated_rotation_key(_rotations, _time[, _index])
/// @desc Creates a new rotation key by interpolating two closest ones for
/// specified animation time.
/// @param {BBMOD_ERotationKey} _rotations An array of rotation keys.
/// @param {real} _time The current animation time.
/// @param {real} [_index] An index where to start searching for two closest
/// rotation keys for specified time. Defaults to 0.
/// @return {BBMOD_ERotationKey} The interpolated rotation key.
function bbmod_get_interpolated_rotation_key(_rotations, _time)
{
	var _index = (argument_count > 2) ? argument[2] : 0;
	var k = bbmod_find_animation_key(_rotations, _time, _index);
	var _rotation_key = bbmod_get_animation_key(_rotations, k);
	var _rotation_key_next = bbmod_get_animation_key(_rotations, k + 1);
	var _factor = bbmod_get_animation_key_interpolation_factor(
		_rotation_key, _rotation_key_next, _time);
	return bbmod_rotation_key_interpolate(
		_rotation_key, _rotation_key_next, _factor);
}

/// @func BBMOD_Animation(_file[, _sha1])
/// @desc An OOP wrapper around the BBMOD_EAnimation legacy struct.
/// @param {string} _file
/// @param {string} [_sha1]
function BBMOD_Animation(_file) constructor
{
	var _sha1 = (argument_count > 1) ? argument[1] : undefined;

	/// @var {BBMOD_EAnimation} The animation that this struct wraps.
	animation = bbmod_load(_file, _sha1);

	if (animation == BBMOD_NONE)
	{
		throw new BBMOD_Error("Could not load file " + _file);
	}

	/// @func get_animation_time(_time_in_seconds)
	/// @desc Calculates animation time from current time in seconds.
	/// @param {real} _time_in_seconds The current time in seconds.
	/// @return {real} The animation time.
	static get_animation_time = function (_time_in_seconds) {
		return bbmod_get_animation_time(animation, _time_in_seconds);
	};
}