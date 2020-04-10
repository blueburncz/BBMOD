/// @func bbmod_animation_player()
/// @desc Contains definition of the AnimationPlayer structure.
/// @see BBMOD_EAnimationPlayer

/// @enum An enumeration of member of an AnimationPlayer structure.
enum BBMOD_EAnimationPlayer
{
	/// @member A Model which the AnimationPlayer animates.
	Model,
	/// @member List of animations to play.
	Animations,
	/// @member The last played AnimationInstance.
	AnimationInstanceLast,
	/// @member The size of the AnimationPlayer structure.
	SIZE
};