/// @func bbmod_animation_key()
/// @desc Contains definition of the AnimationKey structure.
/// @see BBMOD_EAnimationKey

/// @enum An enumeration of members of an AnimationKey structure.
/// This structure is never instantiated, it only serves as an interface
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