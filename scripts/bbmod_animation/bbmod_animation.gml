/// @func bbmod_animation()
/// @desc Contains definition of the Animation structure.
/// @see BBMOD_EAnimation

/// @enum An enumeration of members of an Animation structure.
enum BBMOD_EAnimation
{
	/// @member The version of the animation file.
	Version,
	/// @member The duration of the animation (in tics).
	Duration,
	/// @member Number of animation tics per second.
	TicsPerSecond,
	/// @member An array of AnimationBone structures.
	Bones,
	/// @member The size of the Animation structure.
	SIZE
};