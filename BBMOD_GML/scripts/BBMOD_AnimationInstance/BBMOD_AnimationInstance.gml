/// @func BBMOD_AnimationInstance(_animation)
/// @desc An instance of an animation. Used for animation playback.
/// @param {BBMOD_Animation} _animation An animation to create an instance of.
/// @see BBMOD_Animation
function BBMOD_AnimationInstance(_animation) constructor
{
	/// @var {BBMOD_Animation} The animation to be played.
	/// @see BBMOD_Animation
	/// @readonly
	Animation = _animation;

	/// @var {bool} If `true` then the animation should be looped.
	/// @readonly
	Loop = false;

	/// @var {int} The last frame when animation events were executed.
	/// @private
	EventExecuted = -1;
}