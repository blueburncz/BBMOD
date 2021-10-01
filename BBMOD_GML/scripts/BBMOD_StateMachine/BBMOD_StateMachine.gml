/// @func BBMOD_StateMachine()
/// @extends BBMOD_Struct
/// @desc A state machine.
/// @see BBMOD_State
function BBMOD_StateMachine()
	: BBMOD_Struct() constructor
{
	/// @var {BBMOD_State[]} An array of sates.
	/// @private
	StateArray = [];

	/// @var {BBMOD_State/undefined} The initial state.
	/// @readonly
	StateInitial = undefined;

	/// @var {BBMOD_State/undefined} The current state.
	/// @private
	State = undefined;

	/// @var {func/undefined} A function executed when the state changes.
	/// It must take the state machine as the first argument and its previous
	/// state as the second argument.
	OnStateChange = undefined;

	/// @func add_state(_state[, _initial])
	/// @desc Adds a state to the state machine.
	/// @param {BBMOD_State} _state The state to add.
	/// @param {bool} [_initial] If true then the state is the initial state
	/// of the state machine. Defaults to false.
	/// @return {BBMOD_StateMachine} Returns `self`.
	/// @throws {BBMOD_Exception} If the added state should be initial but the state
	/// machine already has an initial state.
	static add_state = function (_state, _initial=false) {
		gml_pragma("forceinline");
		_state.StateMachine = self;
		array_push(StateArray, _state);
		if (_initial)
		{
			if (StateInitial != undefined)
			{
				throw new BBMOD_Exception("State machine already has an initial state!");
			}
			StateInitial = _state;
		}
		return self;
	};

	/// @func get_state()
	/// @desc Retrieves the current state.
	/// @return {BBMOD_State/undefined} The current state.
	static get_state = function () {
		gml_pragma("forceinline");
		return State;
	};

	/// @func change_state(_state)
	/// @desc Changes the state of the state machine and executes
	/// {@link BBMOD_StateMachine.OnStateChange}.
	/// @param {uint} _state The new state.
	/// @return {BBMOD_StateMachine} Returns itself.
	/// @throws {BBMOD_Exception} If an invalid state is passed.
	static change_state = function (_state) {
		gml_pragma("forceinline");

		// Check if the state is valid
		if (_state.StateMachine != self)
		{
			throw new BBMOD_Exception("Invalid state \"" + string(_state.Name) + "\"!");
		}

		// Exit current state
		var _statePrev = State;

		if (_statePrev != undefined)
		{
			if (_statePrev.OnExit != undefined)
			{
				_statePrev.IsActive = false;
				_statePrev.OnExit(_statePrev);
			}
		}

		// Enter new state
		State = _state;
		State.IsActive = true;
		State.ActiveSince = current_time;

		if (State.OnEnter != undefined)
		{
			State.OnEnter(State);
		}

		// Trigger OnStateChange
		if (OnStateChange != undefined)
		{
			OnStateChange(self, _statePrev);
		}

		return self;
	};

	/// @func update(_deltaTime)
	/// @desc Executes function for the current state of the state machine
	/// (if defined).
	/// @param {real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {BBMOD_StateMachine} Returns `self`.
	static update = function (_deltaTime) {
		gml_pragma("forceinline");

		if (State == undefined && StateInitial != undefined)
		{
			change_state(StateInitial);
		}

		if (State != undefined && State.OnUpdate != undefined)
		{
			State.OnUpdate(State);
		}

		return self;
	};

	/// @func destroy()
	/// @desc Frees resources used by the state machine from memory.
	static destroy = function () {
		for (var i = array_length(StateArray) - 1; i >= 0; --i)
		{
			StateArray[i].destroy();
		}
	};
}