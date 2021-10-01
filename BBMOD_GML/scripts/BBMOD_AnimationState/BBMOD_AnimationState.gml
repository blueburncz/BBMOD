/// @func BBMOD_AnimationState(_name, _animation[, _loop])
/// @extends BBMOD_State
/// @desc A state of an animation state machine.
/// @param {string} _name The name of the state.
/// @param {BBMOD_Animation} _animation The animation played while the
/// is active.
/// @param {bool} [_loop] If `true` then the animation will be looped.
/// Defaults to `false`.
/// @see BBMOD_AnimationStateMachine
function BBMOD_AnimationState(_name, _animation, _loop=false)
	: BBMOD_State(_name) constructor
{
	/// @var {BBMOD_Animation} The animation played while the state is active.
	/// @readonly
	Animation = _animation;

	/// @var {bool} If `true` then the animation is played in loops.
	/// @readonly
	Loop = _loop;
}