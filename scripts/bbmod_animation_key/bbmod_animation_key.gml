/// @func bbmod_animation_key()

/// @enum An enumeration of members of an AnimationKey structure.
/// This structure is never instantiated, it only serves as a parent
/// for specific animation keys.
enum BBMOD_EAnimationKey
{
	/// @member Time when the animation key occurs.
	Time,
	/// @member Additional key data.
	Data,
	/// @member The size of the AnimationKey structure.
	SIZE
};