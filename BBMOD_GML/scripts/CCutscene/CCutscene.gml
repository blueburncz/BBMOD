/// @var {CCutscene/undefined}
/// @private
global.__cutscene = undefined;

/// @func GetCutscene()
/// @desc Retrieves the currently active cutscene.
/// @return {CCutscene/undefined} The active cutscene or undefined.
function GetCutscene()
{
	gml_pragma("forceinline");
	return global.__cutscene;
}

/// @func CStage(_text)
/// @desc A stage of a cutscene.
/// @param {string} _text The stage's subtitle.
function CStage(_text) constructor
{
	/// @var {CCutscene}
	/// @private
	Cutscene = undefined;

	/// @var {string} The stage's subtitle.
	Text = _text;

	/// @var {uint} The duration of the stage in ms.
	Duration = string_length(Text)
		* (game_get_speed(gamespeed_microseconds) / 1000)
		* 2;

	/// @var {uint} How long have the stage been active for in ms.
	/// @private
	CurrentTime = 0;

	/// @var {func} A function executed when the cutscene enters this stage.
	OnEnter = function () {};

	/// @var {func} A function executed while the cutscene is in the stage.
	/// Should take `delta_time` as the first argument.
	OnUpdate = function (_deltaTime) {};

	/// @var {func} A function executed when the cutscene leaves this stage.
	OnLeave = function () {};

	/// @func GetProgress()
	/// @desc Retrieves the progress of the stage, computed from how long has
	/// the stage been active divided by its duration.
	/// @return {real} A value in range 0..1, where 0 is the beginning of the
	/// stage and 1 is the end of the stage.
	static GetProgress = function () {
		gml_pragma("forceinline");
		return clamp(CurrentTime / Duration, 0.0, 1.0);
	};

	/// @func GetText()
	/// @desc Retrieves the stage text, shortened based on the progress of the
	/// stage, i.e. progress 0 does not show any text and progress 1 show the
	/// entire text.
	/// @return {string} The shortened stage text.
	static GetText = function () {
		gml_pragma("forceinline");
		return string_copy(Text, 1, string_length(Text) * GetProgress());
	};

	/// @func HasNext()
	/// @desc Checks whether the cutscene has a next stage.
	/// @return {bool} Returns true if the cutscene has a next stage.
	static HasNext = function () {
		gml_pragma("forceinline");
		return Cutscene.HasNext();
	};

	/// @func Next()
	/// @desc Goes to the next stage of the cutscene.
	/// @return {CStage} Returns `self`.
	static Next = function () {
		gml_pragma("forceinline");
		Cutscene.Next();
		return self;
	};
}

/// @func CCutscene()
/// @desc A cutscene composed from stages.
/// @see CStage
function CCutscene() constructor
{
	/// @var {CStage[]} An array of the cutscene's stages.
	/// @readonly
	Stages = [];

	/// @var {uint} The index of the current stage.
	/// @readonly
	Current = 0;

	/// @var {bool} If true then the cutscene is currently playing.
	/// @readonly
	Active = false;

	/// @func AddStage(_stage)
	/// @desc Adds a stage to the cutscene.
	/// @param {CStage} _stage The stage to add.
	/// @return {CCutscene} Returns `self`.
	static AddStage = function (_stage) {
		gml_pragma("forceinline");
		array_push(Stages, _stage);
		_stage.Cutscene = self;
		return self;
	};

	/// @func GetStage()
	/// @desc Retrieves the current stage of the cutscene.
	/// @return {CStage} The current stage.
	static GetStage = function () {
		gml_pragma("forceinline");
		return Stages[Current];
	};

	/// @func Start()
	/// @desc Starts playing the cutscene.
	/// @return {CCutscene} Returns `self`.
	static Start = function () {
		if (array_length(Stages) == 0)
		{
			return self;
		}
		global.__cutscene = self;
		Active = true;
		Current = 0;
		var _stage = Stages[Current];
		_stage.CurrentTime = 0;
		_stage.OnEnter();
		return self;
	};

	/// @func Update(_deltaTime)
	/// @desc Updates the cutscene. This should be executed each Step!
	/// @param {uint} _deltaTime The `delta_time`.
	/// @return {CCutscene} Returns `self`.
	static Update = function (_deltaTime) {
		var _stage = Stages[Current];
		_stage.CurrentTime += _deltaTime / 1000.0;
		if (_stage.GetProgress() <= 1.0)
		{
			_stage.OnUpdate(_deltaTime);
		}
		return self;
	};

	/// @func HasNext()
	/// @desc Checks whether the cutscene has a next stage.
	/// @return {bool} Returns true if the cutscene has a next stage.
	static HasNext = function () {
		gml_pragma("forceinline");
		return (Current < array_length(Stages) - 1);
	};

	/// @func Next()
	/// @desc Goes to the next stage of the cutscene.
	/// @return {CCutscene} Returns `self`.
	static Next = function () {
		var _stageCurrent = Stages[Current];
		if (_stageCurrent.GetProgress() < 1.0)
		{
			// Only jump to the end of the current stage if it has not finished yet
			_stageCurrent.CurrentTime = _stageCurrent.Duration;
			return self;
		}
		_stageCurrent.OnLeave();
		if (!HasNext())
		{
			// The end of the cutscene
			global.__cutscene = undefined;
			Active = false;
			return self;
		}
		// Go to the next stage
		++Current;
		var _stageNext = Stages[Current];
		_stageNext.CurrentTime = 0;
		_stageNext.OnEnter();
		return self;
	};
}