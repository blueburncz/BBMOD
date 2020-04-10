/// @func bbmod_rotation_key()
/// @desc Contains definition of the RotationKey structure.
/// @see BBMOD_ERotationKey

/// @enum An enumeration of member of a RotationKey structure.
enum BBMOD_ERotationKey
{
	/// @member Time when the animation key occurs.
	Time,
	/// @member A quaternion.
	Rotation,
	/// @member The size of the RotationKey structure.
	SIZE
};