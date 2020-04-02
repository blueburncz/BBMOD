/// @func bbmod_animation_instance()

/// @enum An enumeration of members of an AnimationInstance structure.
enum BBMOD_EAnimationInstance
{
	/// @member The currently played animation.
	Animation,
	/// @member Animation time in last frame. Used to reset members in
	/// looping animations or when switching between animations.
	AnimationTimeLast,
	/// @member An index of a position key which was used last frame.
	/// Used to optimize search of position keys in following frames.
	PositionKeyLast,
	/// @member An index of a rotation key which was used last frame.
	/// Used to optimize search of rotation keys in following frames.
	RotationKeyLast,
	/// @member An array containing transformation matrices of all bones.
	/// Used to pass current model pose as a uniform to a vertex shader.
	TransformArray,
	/// @member The size of an AnimationInstance structure.
	SIZE
};