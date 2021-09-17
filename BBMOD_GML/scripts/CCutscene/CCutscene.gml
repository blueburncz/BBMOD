/// @var {CCutscene/undefined}
/// @private
global.__cutscene = undefined;

/// @func GetCutscene()
/// @return {CCutscene/undefined}
function GetCutscene()
{
	return global.__cutscene;
}

/// @func CStage(_text)
/// @param {string} _text
function CStage(_text) constructor
{
	/// @var {CCutscene}
	/// @private
	Cutscene = undefined;

	/// @var {string}
	Text = _text;

	/// @var {uint} The duration of the stage in ms.
	Duration = string_length(Text)
		* (game_get_speed(gamespeed_microseconds) / 1000)
		* 2;

	/// @var {uint} How long have the stage been active for in ms.
	/// @private
	CurrentTime = 0;

	/// @var {func}
	OnEnter = function () {};

	/// @var {func}
	OnUpdate = function (_deltaTime) {};

	/// @var {func}
	OnLeave = function () {};

	/// @func GetProgress()
	/// @return {real}
	static GetProgress = function () {
		gml_pragma("forceinline");
		return clamp(CurrentTime / Duration, 0.0, 1.0);
	};

	/// @func GetText()
	/// @return {string}
	static GetText = function () {
		gml_pragma("forceinline");
		return string_copy(Text, 1, string_length(Text) * GetProgress());
	};

	/// @func HasNext()
	/// @return {bool}
	static HasNext = function () {
		gml_pragma("forceinline");
		return Cutscene.HasNext();
	};

	/// @func Next()
	/// @return {CStage}
	static Next = function () {
		gml_pragma("forceinline");
		Cutscene.Next();
		return self;
	};
}

/// @func CCutscene()
function CCutscene() constructor
{
	/// @var {CStage}
	/// @readonly
	Stages = [];

	/// @var {uint}
	/// @readonly
	Current = 0;

	/// @var {uint}
	/// @private
	CurrentTime = 0;

	/// @var {bool}
	/// @readonly
	Active = false;

	/// @func AddStage(_stage)
	/// @param {CStage} _stage
	/// @return {CCutscene}
	static AddStage = function (_stage) {
		gml_pragma("forceinline");
		array_push(Stages, _stage);
		_stage.Cutscene = self;
		return self;
	};

	/// @func GetStage()
	/// @return {CStage}
	static GetStage = function () {
		gml_pragma("forceinline");
		return Stages[Current];
	};

	/// @func Start()
	/// @return {CCutscene}
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
	/// @param {uint} _deltaTime
	/// @return {CCutscene}
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
	/// @return {bool}
	static HasNext = function () {
		gml_pragma("forceinline");
		return (Current < array_length(Stages) - 1);
	};

	/// @func Next()
	/// @return {CCutscene}
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