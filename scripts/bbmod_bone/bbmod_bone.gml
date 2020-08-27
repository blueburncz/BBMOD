/// @enum An enumeration of members of a Bone structure.
enum BBMOD_EBone
{
	/// @member The name of the bone.
	Name,
	/// @member The index of the bone.
	Index,
	/// @member The transformation matrix.
	TransformMatrix,
	/// @member The offset matrix.
	OffsetMatrix,
	/// @member An array of child Bone structures.
	Children,
	/// @member The size of the Bone structure.
	SIZE
};

/// @func bbmod_bone_load(_buffer)
/// @desc Loads a Bone structure from a buffer.
/// @param {real} _buffer The buffer to load the structure from.
/// @return {array} The loaded Bone structure.
function bbmod_bone_load(_buffer)
{
	var _bone = array_create(BBMOD_EBone.SIZE, 0);

	_bone[@ BBMOD_EBone.Name] = buffer_read(_buffer, buffer_string);
	_bone[@ BBMOD_EBone.Index] = buffer_read(_buffer, buffer_f32);
	_bone[@ BBMOD_EBone.TransformMatrix] = bbmod_load_matrix(_buffer);
	_bone[@ BBMOD_EBone.OffsetMatrix] = bbmod_load_matrix(_buffer);

	var _child_count = buffer_read(_buffer, buffer_u32);
	var _children = array_create(_child_count, 0);

	_bone[@ BBMOD_EBone.Children] = _children;

	var i = 0
	repeat (_child_count)
	{
		_children[@ i++] = bbmod_bone_load(_buffer);
	}

	return _bone;
}