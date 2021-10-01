/// @func BBMOD_AnimationStateMachine(_model)
/// @extends BBMOD_StateMachine
/// @desc A state machine that controls animation playback.
/// @param {BBMOD_Model} _model A model that the state machine animates.
/// @see BBMOD_AnimationState
function BBMOD_AnimationStateMachine(_model)
	: BBMOD_StateMachine() constructor
{
	static Super = {
		update: update,
		destroy: destroy,
	};

	/// @var {BBMOD_AnimationPlayer} The state machine's animation player.
	/// @readonly
	AnimationPlayer = new BBMOD_AnimationPlayer(_model);

	static update = function (_deltaTime) {
		method(self, Super.update)(_deltaTime);
		if (State != undefined)
		{
			AnimationPlayer.change(State.Animation, State.Loop);
		}
		AnimationPlayer.update(_deltaTime);
		return self;
	};

	static destroy = function () {
		method(self, Super.destroy)();
		AnimationPlayer.destroy();
	};
}