/// @func BBMOD_AnimationStateMachine(_animationPlayer)
/// @extends BBMOD_StateMachine
/// @desc A state machine that controls animation playback.
/// @param {BBMOD_AnimationPlayer} _animationPlayer The animation player to control.
/// @see BBMOD_AnimationPlayer
/// @see BBMOD_AnimationState
function BBMOD_AnimationStateMachine(_animationPlayer)
	: BBMOD_StateMachine() constructor
{
	static Super_StateMachine = {
		update: update,
	};

	/// @var {BBMOD_AnimationPlayer} The state machine's animation player.
	/// @readonly
	AnimationPlayer = _animationPlayer;

	AnimationPlayer.on_event(method(self, function (_data, _event) {
		if (State != undefined)
		{
			State.trigger_event(_event, _data);
		}
	}));

	static update = function (_deltaTime) {
		method(self, Super_StateMachine.update)(_deltaTime);
		if (State != undefined)
		{
			AnimationPlayer.change(State.Animation, State.Loop);
		}
		AnimationPlayer.update(_deltaTime);
		return self;
	};
}