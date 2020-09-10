/// @enum An enumeration of members of a legacy animation struct.
/// @obsolete This legacy struct is obsolete. Please use
/// {@link BBMOD_Animation} instead.
enum BBMOD_EAnimation
{
	/// @member {real} The version of the animation file.
	/// @readonly
	Version,
	/// @member {real} The duration of the animation (in tics).
	/// @readonly
	Duration,
	/// @member {real} Number of animation tics per second.
	/// @readonly
	TicsPerSecond,
	/// @member {BBMOD_EAnimationBone[]} An array of animation bones.
	/// @see BBMOD_EAnimationBone
	/// @readonly
	Bones,
	/// @member The size of the struct.
	SIZE
};

/// @func bbmod_animation_create_transition(_model, _anim_from, _time_from, _anim_to, _time_to, _duration)
/// @desc Creates a new animation transition between two specified animations.
/// @param {BBMOD_Model} _model A model.
/// @param {BBMOD_Animation} _anim_from The first animation.
/// @param {real} _time_from Animation time of the first animation.
/// @param {BBMOD_Animation} _anim_to The second animation.
/// @param {real} _time_to Animation time of the second animation.
/// @param {real} _duration The duration of the transition in seconds.
/// @return {BBMOD_Animation} The created transition.
/// @private
function bbmod_animation_create_transition(_model, _anim_from, _time_from, _anim_to, _time_to, _duration)
{
	var _anim_stack = global.__bbmod_anim_stack;

	var _transition = new BBMOD_Animation();
	_transition.Version = _anim_from.Version;
	_transition.Duration = _duration;
	_transition.TicsPerSecond = 1;
	_transition.Bones = array_create(_model.BoneCount, undefined);

	ds_stack_push(_anim_stack, _model.Skeleton);

	while (!ds_stack_empty(_anim_stack))
	{
		var _bone = ds_stack_pop(_anim_stack);
		var _bone_index = _bone[BBMOD_EBone.Index];

		if (_bone_index >= 0)
		{
			var _bone_data_from = array_get(_anim_from.Bones, _bone_index);
			var _bone_data_to = array_get(_anim_to.Bones, _bone_index);

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

				array_set(_transition.Bones, _bone_index, _anim_bone);
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

/// @func bbmod_get_animation_time(_animation, _time_in_seconds)
/// @desc Calculates animation time from current time in seconds.
/// @param {BBMOD_Animation} _animation An animation.
/// @param {real} _time_in_seconds The current time in seconds.
/// @return {real} The animation time.
/// @deprecated This function is deprecated. Please use
/// {@link BBMOD_Animation.get_animation_time} instead.
/// @private
function bbmod_get_animation_time(_animation, _time_in_seconds)
{
	gml_pragma("forceinline");
	var _time_in_tics = _time_in_seconds * _animation.TicsPerSecond;
	return (_time_in_tics mod _animation.Duration);
}

/// @func bbmod_get_interpolated_position_key(_positions, _time[, _index])
/// @desc Creates a new position key by interpolating two closest ones for
/// specified animation time.
/// @param {BBMOD_EPositionKey[]} _positions An array of position keys.
/// @param {real} _time The current animation time.
/// @param {real} [_index] An index where to start searching for two closest
/// position keys for specified time. Defaults to 0.
/// @return {BBMOD_EPositionKey} The interpolated position key.
/// @private
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
/// @private
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
/// @desc An animation which can be played using {@link BBMOD_AnimationPlayer}.
/// @param {string} _file The "*.bbanim" animation file to load.
/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one does
/// not match with this, then the model will not be loaded.
/// @example
/// ```gml
/// try
/// {
///     anim_walk = new BBMOD_Animation("walk.bbanim");
/// }
/// catch (e)
/// {
///     // The animation failed to load!
/// }
/// ```
/// @throws {BBMOD_Error} When the animation fails to load.
function BBMOD_Animation() constructor
{
	var _file = (argument_count > 0) ? argument[0] : undefined;
	var _sha1 = (argument_count > 1) ? argument[1] : undefined;

	/// @var {real} The version of the animation file.
	/// @readonly
	Version = 0;

	/// @var {real} The duration of the animation (in tics).
	/// @readonly
	Duration = 0;

	/// @var {real} Number of animation tics per second.
	/// @readonly
	TicsPerSecond = 0;

	/// @var {BBMOD_EAnimationBone[]} An array of animation bones.
	/// @see BBMOD_EAnimationBone
	/// @readonly
	Bones = [];

	/// @func get_animation_time(_time_in_seconds)
	/// @desc Calculates animation time from current time in seconds.
	/// @param {real} _time_in_seconds The current time in seconds.
	/// @return {real} The animation time.
	/// @private
	static get_animation_time = function (_time_in_seconds) {
		return bbmod_get_animation_time(animation, _time_in_seconds);
	};

	/// @func from_buffer(_buffer)
	/// @desc Loads animation data from a buffer.
	/// @param {buffer} _buffer The buffer to load the data from.
	/// @return {BBMOD_Animation} Returns `self` to allow method chaining.
	/// @private
	static from_buffer = function (_buffer) {
		Duration = buffer_read(_buffer, buffer_f64);
		TicsPerSecond = buffer_read(_buffer, buffer_f64);

		var _mesh_bone_count = buffer_read(_buffer, buffer_u32);

		Bones = array_create(_mesh_bone_count, undefined);

		var _affected_bone_count = buffer_read(_buffer, buffer_u32);

		repeat (_affected_bone_count)
		{
			var _bone_data = bbmod_animation_bone_load(_buffer);
			var _bone_index = _bone_data[BBMOD_EAnimationBone.BoneIndex];
			Bones[@ _bone_index] = _bone_data;
		}

		return self;
	};

	/// @func from_file(_file[, _sha1])
	/// @desc Loads animation data from a file.
	/// @param {string} _file The path to the file.
	/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one
	/// does not match with this, then the animation will not be loaded.
	/// @return {BBMOD_Animation} Returns `self` to allow method chaining.
	/// @throws {BBMOD_Error} If loading fails.
	/// @private
	static from_file = function (_file) {
		var _sha1 = (argument_count > 1) ? argument[1] : undefined;

		if (!file_exists(_file))
		{
			throw new BBMOD_Error("File " + _file + " does not exist!");
		}

		if (!is_undefined(_sha1))
		{
			if (sha1_file(_file) != _sha1)
			{
				throw new BBMOD_Error("SHA1 does not match!");
			}
		}

		var _buffer = buffer_load(_file);
		buffer_seek(_buffer, buffer_seek_start, 0);

		var _type = buffer_read(_buffer, buffer_string);
		if (_type != "bbanim")
		{
			buffer_delete(_buffer);
			throw new BBMOD_Error("Not a BBANIM file!");
		}

		Version = buffer_read(_buffer, buffer_u8);
		if (Version != 1)
		{
			buffer_delete(_buffer);
			throw new BBMOD_Error("Invalid version " + string(Version) + "!");
		}

		from_buffer(_buffer);
		buffer_delete(_buffer);
		return self;
	};

	if (_file != undefined)
	{
		from_file(_file, _sha1);
	}
}