/// @func CState(_name)
/// @desc A state machine's state.
/// @param {string} _name The name of the state.
/// @see CStateMachine
function CState(_name) constructor
{
	/// @var {CStateMachine}
	/// @private
	StateMachine = undefined;

	/// @var {string} The name of the state.
	Name = _name;

	/// @var {func/undefined} Must take the state as the first argument.
	OnEnter = undefined;

	/// @var {func/undefined} Must take the state as the first argument.
	OnUpdate = undefined;

	/// @var {func/undefined} Must take the state as the first argument.
	OnExit = undefined;

	/// @var {bool} If true then the state machine is currently in this state.
	/// @readonly
	Active = false;

	/// @var {uint}
	/// @private
	ActiveSince = 0;

	/// @func GetDuration()
	/// @desc Retrieves how long has the state been active (in ms).
	/// @return {uint} Milliseconds elapsed since the activation of the state.
	static GetDuration = function () {
		gml_pragma("forceinline");
		return (current_time - ActiveSince);
	};
}

/// @func CStateMachine()
/// @desc A state machine.
/// @see CState
function CStateMachine() constructor
{
	/// @var {CState[]} An array of sates.
	/// @private
	StateArray = [];

	/// @var {CState/undefined} The initial state.
	/// @readonly
	StateInitial = undefined;

	/// @var {CState/undefined} The current state.
	/// @private
	State = undefined;

	/// @var {func/undefined} A function executed when the state changes.
	/// It must take the state machine as the first argument and its previous
	/// state as the second argument.
	OnStateChange = undefined;

	/// @func AddState(_state[, _initial])
	/// @desc Adds a state to the state machine.
	/// @param {CState} _state The state to add.
	/// @param {bool} [_initial] If true then the state is the initial state
	/// of the state machine. Defaults to false.
	/// @return {CStateMachine} Returns self.
	/// @throws {string} If the added state should be initial but the state
	/// machine already has an initial state.
	static AddState = function (_state) {
		gml_pragma("forceinline");
		_state.StateMachine = self;
		array_push(StateArray, _state);
		if (argument_count > 1 && argument[1])
		{
			if (StateInitial != undefined)
			{
				throw "State machine already has an initial state!";
			}
			StateInitial = _state;
		}
		return self;
	};

	/// @func GetState()
	/// @desc Retrieves the current state.
	/// @return {CState/undefined} The current state.
	static GetState = function () {
		gml_pragma("forceinline");
		return State;
	};

	/// @func ChangeState(_state)
	/// @desc Changes the state of the state machine and executes
	/// {@link CStateMachine.OnStateChange}.
	/// @param {uint} _state The new state.
	/// @return {CStateMachine} Returns itself.
	/// @throws {string} If an invalid state is passed.
	static ChangeState = function (_state) {
		gml_pragma("forceinline");

		// Check if the state is valid
		if (_state.StateMachine != self)
		{
			throw "Invalid state \"" + string(_state.Name) + "\"!";
		}

		// Exit current state
		var _statePrev = State;

		if (_statePrev != undefined)
		{
			if (_statePrev.OnExit != undefined)
			{
				_statePrev.Active = false;
				_statePrev.OnExit(_statePrev);
			}
		}

		// Enter new state
		State = _state;
		State.Active = true;
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

	/// @func Update()
	/// @desc Executes function for the current state of the state machine
	/// (if defined).
	/// @return {CStateMachine} Returns itself.
	static Update = function () {
		gml_pragma("forceinline");

		if (State == undefined && StateInitial != undefined)
		{
			ChangeState(StateInitial);
		}

		if (State != undefined && State.OnUpdate != undefined)
		{
			State.OnUpdate(State);
		}

		return self;
	};
}