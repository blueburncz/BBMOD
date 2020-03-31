/// @func bbmod_animation()

/// @enum An enumeration of members of an Animation structure.
enum BBMOD_EAnimation
{
	/// @enum The version of the animation file.
	Version,
	/// @enum The duration of the animation (in tics).
	Duration,
	/// @enum Number of animation tics per second.
	TicsPerSecond,
	/// @enum An array of AnimationBone structures.
	Bones,
	/// @enum The size of the Animation structure.
	SIZE
};