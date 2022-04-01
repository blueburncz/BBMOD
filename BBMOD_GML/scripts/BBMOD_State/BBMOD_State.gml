/// @func BBMOD_State(_name)
/// @extends BBMOD_Class
/// @desc A state of a state machine.
/// @param {String} _name The name of the state.
/// @see BBMOD_StateMachine
function BBMOD_State(_name)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_StateMachine/Undefined} The state machine to which this state
	/// belongs.
	/// @readonly
	StateMachine = undefined;

	/// @var {String} The name of the state.
	Name = _name;

	/// @var {func/Undefined} A function executed when a state machines enters
	/// this state. Should take the state as the first argument.
	OnEnter = undefined;

	/// @var {func/Undefined} A function executed while the state is active.
	/// Should take the state as the first argument and delta time as the second.
	OnUpdate = undefined;

	/// @var {func/Undefined} A function executed when a state machine exists this
	/// state. Should take the state as the first argument.
	OnExit = undefined;

	/// @var {Bool} If `true` then the state is currently active.
	/// @readonly
	IsActive = false;

	/// @var {Real}
	/// @private
	ActiveSince = 0;

	/// @func get_duration()
	/// @desc Retrieves how long (in milliseconds) has the state been active for.
	/// @return {Real} Number of milliseconds for which has the state been active.
	static get_duration = function () {
		gml_pragma("forceinline");
		return (current_time - ActiveSince);
	};
}