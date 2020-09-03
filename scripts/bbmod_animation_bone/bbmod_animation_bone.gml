/// @enum An enumeration of members of an BBMOD_EAnimationBone legacy struct.
/// @private
enum BBMOD_EAnimationBone
{
	/// @member The bone index.
	BoneIndex,
	/// @member An array of {@link BBMOD_EPositionKey} legacy structs.
	PositionKeys,
	/// @member An array of {@link BBMOD_ERotationKey} legacy structs.
	RotationKeys,
	/// @member Total number of members of this enum.
	SIZE
};

/// @func bbmod_animation_bone_load(_buffer)
/// @desc Loads a bone from a buffer.
/// @param {real} _buffer The buffer to load the struct from.
/// @return {BBMOD_EAnimationBone} The loaded bone.
/// @private
function bbmod_animation_bone_load(_buffer)
{
	var i = 0;

	var _animation_bone = array_create(BBMOD_EAnimationBone.SIZE, 0);
	_animation_bone[@ BBMOD_EAnimationBone.BoneIndex] = buffer_read(_buffer, buffer_f32);

	// Load position keys
	var _position_key_count = buffer_read(_buffer, buffer_u32);
	var _position_keys = array_create(_position_key_count, 0);
	_animation_bone[@ BBMOD_EAnimationBone.PositionKeys] = _position_keys;

	//i = 0;
	repeat (_position_key_count)
	{
		_position_keys[@ i++] = bbmod_position_key_load(_buffer);
	}

	// Load rotation keys
	var _rotation_key_count = buffer_read(_buffer, buffer_u32);
	var _rotation_keys = array_create(_rotation_key_count, 0);
	_animation_bone[@ BBMOD_EAnimationBone.RotationKeys] = _rotation_keys;

	i = 0;
	repeat (_rotation_key_count)
	{
		_rotation_keys[@ i++] = bbmod_rotation_key_load(_buffer);
	}

	return _animation_bone;
}