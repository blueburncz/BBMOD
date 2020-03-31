/// @func bbmod_bone()

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