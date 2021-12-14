#macro BBMOD_BONE_SPACE_PARENT (1 << 0)
#macro BBMOD_BONE_SPACE_WORLD (1 << 1)
#macro BBMOD_BONE_SPACE_BONE (1 << 2)

/// @func BBMOD_Animation([_file[, _sha1]])
/// @desc An animation which can be played using {@link BBMOD_AnimationPlayer}.
/// @param {string} [_file] A "*.bbanim" animation file to load. If not
/// specified, then an empty animation is created.
/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one does
/// not match with this, then the model will not be loaded.
/// @example
/// Following code loads an animation from a file `Walk.bbanim`:
///
/// ```gml
/// try
/// {
///     animWalk = new BBMOD_Animation("Walk.bbanim");
/// }
/// catch (_exception)
/// {
///     // The animation failed to load!
/// }
/// ```
///
/// You can also load animations from buffers like so:
///
/// ```gml
/// var _buffer = buffer_load("Walk.anim");
/// try
/// {
///     animWalk = new BBMOD_Animation().from_buffer(_buffer);
/// }
/// catch (_exception)
/// {
///     // Failed to load an animation from the buffer!
/// }
/// buffer_delete(_buffer);
/// ```
/// @throws {BBMOD_Exception} When the animation fails to load.
function BBMOD_Animation(_file, _sha1) constructor
{
	/// @var {real} The version of the animation file.
	/// @readonly
	Version = BBMOD_VERSION;

	/// @var {uint} The transformation spaces included in the animation file.
	/// @private
	Spaces = 0;

	/// @var {real} The duration of the animation (in tics).
	/// @readonly
	Duration = 0;

	/// @var {real} Number of animation tics per second.
	/// @readonly
	TicsPerSecond = 0;

	/// @var {array<real[]>/undefined}
	/// @private
	FramesParent = [];

	/// @var {array<real[]>/undefined}
	/// @private
	FramesWorld = [];

	/// @var {array<real[]>/undefined}
	/// @private
	FramesBone = [];

	/// @var {bool}
	/// @private
	IsTransition = false;

	/// @var {real} Duration of transition into this animation (in seconds).
	/// Must be a value greater or equal to 0!
	TransitionIn = 0.1;

	/// @var {real} Duration of transition out of this animation (in seconds).
	/// Must be a value greater or equal to 0!
	TransitionOut = 0;

	/// @var {array} Custom animation events in form of `[frame, name, ...]`.
	/// @private
	Events = [];

	/// @func add_event(_frame, _name)
	/// @desc Adds a custom animation event.
	/// @param {uint} _frame The frame at which should be the event triggered.
	/// @param {string} _name The name of the event.
	/// @return {BBMOD_Animation} Returns `self`.
	/// @example
	/// ```gml
	/// animWalk = new BBMOD_Animation("Data/Character_Walk.bbanim");
	/// animWalk.add_event(0, "Footstep")
	///     .add_event(16, "Footstep");
	/// animationPlayer.on_event("Footstep", method(self, function () {
	///     // Play footstep sound...
	/// }));
	/// ```
	static add_event = function (_frame, _name) {
		gml_pragma("forceinline");
		array_push(Events, _frame, _name);
		return self;
	};

	/// @func supports_attachments()
	/// @desc Checks whether the animation supports bone attachments.
	/// @return {bool} Returns true if the animation supports bone attachments.
	static supports_attachments = function () {
		gml_pragma("forceinline");
		return ((Spaces & (BBMOD_BONE_SPACE_PARENT | BBMOD_BONE_SPACE_WORLD)) != 0);
	};

	/// @func supports_bone_transform()
	/// @desc Checks whether the animation supports bone transformation through
	/// code.
	/// @return {bool} Returns true if the animation supports bone
	/// transformation through code.
	static supports_bone_transform = function () {
		gml_pragma("forceinline");
		return ((Spaces & BBMOD_BONE_SPACE_PARENT) != 0);
	};

	/// @func supports_transitions()
	/// @desc Checks whether the animation supports transitions.
	/// @return {bool} Returns true if the animation supports transitions.
	static supports_transitions = function () {
		gml_pragma("forceinline");
		return ((Spaces & (BBMOD_BONE_SPACE_PARENT | BBMOD_BONE_SPACE_WORLD)) != 0);
	};

	/// @func get_animation_time(_timeInSeconds)
	/// @desc Calculates animation time from current time in seconds.
	/// @param {real} _timeInSeconds The current time in seconds.
	/// @return {real} The animation time.
	/// @private
	static get_animation_time = function (_timeInSeconds) {
		gml_pragma("forceinline");
		return round(_timeInSeconds * TicsPerSecond);
	};

	/// @func from_buffer(_buffer)
	/// @desc Loads animation data from a buffer.
	/// @param {buffer} _buffer The buffer to load the data from.
	/// @return {BBMOD_Animation} Returns `self`.
	/// @throws {BBMOD_Exception} If loading fails.
	static from_buffer = function (_buffer) {
		var _type = buffer_read(_buffer, buffer_string);
		if (_type != "bbanim")
		{
			throw new BBMOD_Exception("Not a BBANIM!");
		}

		Version = buffer_read(_buffer, buffer_u8);
		if (Version != BBMOD_VERSION)
		{
			throw new BBMOD_Exception(
				"Invalid BBANIM version " + string(Version) + "!");
		}

		Spaces = buffer_read(_buffer, buffer_u8);
		Duration = buffer_read(_buffer, buffer_f64);
		TicsPerSecond = buffer_read(_buffer, buffer_f64);

		var _modelNodeCount = buffer_read(_buffer, buffer_u32);
		var _modelNodeSize = _modelNodeCount * 8;
		var _modelBoneCount = buffer_read(_buffer, buffer_u32);
		var _modelBoneSize = _modelBoneCount * 8;

		FramesParent = (Spaces & BBMOD_BONE_SPACE_PARENT) ? [] : undefined;
		FramesWorld = (Spaces & BBMOD_BONE_SPACE_WORLD) ? [] : undefined;
		FramesBone = (Spaces & BBMOD_BONE_SPACE_BONE) ? [] : undefined;

		repeat (Duration)
		{
			if (Spaces & BBMOD_BONE_SPACE_PARENT)
			{
				array_push(FramesParent,
					bbmod_array_from_buffer(_buffer, buffer_f32, _modelNodeSize));
			}

			if (Spaces & BBMOD_BONE_SPACE_WORLD)
			{
				array_push(FramesWorld,
					bbmod_array_from_buffer(_buffer, buffer_f32, _modelNodeSize));
			}

			if (Spaces & BBMOD_BONE_SPACE_BONE)
			{
				array_push(FramesBone,
					bbmod_array_from_buffer(_buffer, buffer_f32, _modelBoneSize));
			}
		}

		return self;
	};

	/// @func from_file(_file[, _sha1])
	/// @desc Loads animation data from a file.
	/// @param {string} _file The path to the file.
	/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one
	/// does not match with this, then the animation will not be loaded.
	/// @return {BBMOD_Animation} Returns `self`.
	/// @throws {BBMOD_Exception} If loading fails.
	static from_file = function (_file, _sha1) {
		if (!file_exists(_file))
		{
			throw new BBMOD_Exception("File " + _file + " does not exist!");
		}

		if (_sha1 != undefined)
		{
			if (sha1_file(_file) != _sha1)
			{
				throw new BBMOD_Exception("SHA1 does not match!");
			}
		}

		var _error = undefined;
		var _buffer = buffer_load(_file);

		buffer_seek(_buffer, buffer_seek_start, 0);

		try
		{
			from_buffer(_buffer);
		}
		catch (_e)
		{
			_error = _e;
		}

		buffer_delete(_buffer);

		if (_error)
		{
			throw _error;
		}

		return self;
	};

	if (_file != undefined)
	{
		from_file(_file, _sha1);
	}

	/// @func create_transition(_timeFrom, _animTo, _timeTo)
	/// @desc Creates a new animation transition.
	/// @param {real} _timeFrom Animation time of this animation that we are
	/// transitioning from.
	/// @param {BBMOD_Animation} _animTo The animation to transition to.
	/// @param {real} _timeTo Animation time of the target animation.
	/// @return {BBMOD_Animation/undefined} The created transition or `undefined`
	/// if the animations have different optimization levels or if they do not
	/// support transitions
	static create_transition = function (_timeFrom, _animTo, _timeTo) {
		if ((Spaces & (BBMOD_BONE_SPACE_PARENT | BBMOD_BONE_SPACE_WORLD)) == 0
			|| Spaces != _animTo.Spaces)
		{
			return undefined;
		}

		var _transition = new BBMOD_Animation();
		_transition.Version = Version;
		_transition.Spaces = (Spaces & BBMOD_BONE_SPACE_PARENT)
			? BBMOD_BONE_SPACE_PARENT
			: BBMOD_BONE_SPACE_WORLD;
		_transition.Duration = round((TransitionOut + _animTo.TransitionIn) * TicsPerSecond);
		_transition.TicsPerSecond = TicsPerSecond;
		_transition.IsTransition = true;

		var _frameFrom, _frameTo, _framesDest;

		if (Spaces & BBMOD_BONE_SPACE_PARENT)
		{
			_frameFrom = FramesParent[_timeFrom];
			_frameTo = _animTo.FramesParent[_timeTo];
			_framesDest = _transition.FramesParent;
		}
		else
		{
			_frameFrom = FramesWorld[_timeFrom];
			_frameTo = _animTo.FramesWorld[_timeTo];
			_framesDest = _transition.FramesWorld;
		}

		var _time = 0;
		repeat (_transition.Duration)
		{
			var _frameSize = array_length(_frameFrom);
			var _frame = array_create(_frameSize);

			var i = 0;
			repeat (_frameSize / 8)
			{
				var _factor = _time / _transition.Duration;

				// First dual quaternion
				var _dq10 = _frameFrom[i];
				var _dq11 = _frameFrom[i + 1];
				var _dq12 = _frameFrom[i + 2];
				var _dq13 = _frameFrom[i + 3];
				// (* 2 since we use this only in the translation reconstruction)
				var _dq14 = _frameFrom[i + 4] * 2;
				var _dq15 = _frameFrom[i + 5] * 2;
				var _dq16 = _frameFrom[i + 6] * 2;
				var _dq17 = _frameFrom[i + 7] * 2;

				// Second dual quaternion
				var _dq20 = _frameTo[i];
				var _dq21 = _frameTo[i + 1];
				var _dq22 = _frameTo[i + 2];
				var _dq23 = _frameTo[i + 3];
				// (* 2 since we use this only in the translation reconstruction)
				var _dq24 = _frameTo[i + 4] * 2;
				var _dq25 = _frameTo[i + 5] * 2;
				var _dq26 = _frameTo[i + 6] * 2;
				var _dq27 = _frameTo[i + 7] * 2;

				// Lerp between reconstructed translations
				var _pos0 = lerp(
					_dq17 * (-_dq10) + _dq14 * _dq13 + _dq15 * (-_dq12) - _dq16 * (-_dq11),
					_dq27 * (-_dq20) + _dq24 * _dq23 + _dq25 * (-_dq22) - _dq26 * (-_dq21),
					_factor,
				);

				var _pos1 = lerp(
					_dq17 * (-_dq11) + _dq15 * _dq13 + _dq16 * (-_dq10) - _dq14 * (-_dq12),
					_dq27 * (-_dq21) + _dq25 * _dq23 + _dq26 * (-_dq20) - _dq24 * (-_dq22),
					_factor,
				);

				var _pos2 = lerp(
					_dq17 * (-_dq12) + _dq16 * _dq13 + _dq14 * (-_dq11) - _dq15 * (-_dq10),
					_dq27 * (-_dq22) + _dq26 * _dq23 + _dq24 * (-_dq21) - _dq25 * (-_dq20),
					_factor,
				);

				// Slerp rotations and store result into _dq1
				var _norm;

				_norm = 1 / sqrt(_dq10 * _dq10
					+ _dq11 * _dq11
					+ _dq12 * _dq12
					+ _dq13 * _dq13);

				_dq10 *= _norm;
				_dq11 *= _norm;
				_dq12 *= _norm;
				_dq13 *= _norm;

				_norm = sqrt(_dq20 * _dq20
					+ _dq21 * _dq21
					+ _dq22 * _dq22
					+ _dq23 * _dq23);

				_dq20 *= _norm;
				_dq21 *= _norm;
				_dq22 *= _norm;
				_dq23 *= _norm;

				var _dot = _dq10 * _dq20
					+ _dq11 * _dq21
					+ _dq12 * _dq22
					+ _dq13 * _dq23;

				if (_dot < 0)
				{
					_dot = -_dot;
					_dq20 *= -1;
					_dq21 *= -1;
					_dq22 *= -1;
					_dq23 *= -1;
				}

				if (_dot > 0.9995)
				{
					_dq10 = lerp(_dq10, _dq20, _factor);
					_dq11 = lerp(_dq11, _dq21, _factor);
					_dq12 = lerp(_dq12, _dq22, _factor);
					_dq13 = lerp(_dq13, _dq23, _factor);
				}
				else
				{
					var _theta0 = arccos(_dot);
					var _theta = _theta0 * _factor;
					var _sinTheta = sin(_theta);
					var _sinTheta0 = sin(_theta0);
					var _s2 = _sinTheta / _sinTheta0;
					var _s1 = cos(_theta) - (_dot * _s2);

					_dq10 = (_dq10 * _s1) + (_dq20 * _s2);
					_dq11 = (_dq11 * _s1) + (_dq21 * _s2);
					_dq12 = (_dq12 * _s1) + (_dq22 * _s2);
					_dq13 = (_dq13 * _s1) + (_dq23 * _s2);
				}

				// Create new dual quaternion from translation and rotation and
				// write it into the frame
				_frame[@ i]     = _dq10;
				_frame[@ i + 1] = _dq11;
				_frame[@ i + 2] = _dq12;
				_frame[@ i + 3] = _dq13;
				_frame[@ i + 4] = (+_pos0 * _dq13 + _pos1 * _dq12 - _pos2 * _dq11) * 0.5;
				_frame[@ i + 5] = (+_pos1 * _dq13 + _pos2 * _dq10 - _pos0 * _dq12) * 0.5;
				_frame[@ i + 6] = (+_pos2 * _dq13 + _pos0 * _dq11 - _pos1 * _dq10) * 0.5;
				_frame[@ i + 7] = (-_pos0 * _dq10 - _pos1 * _dq11 - _pos2 * _dq12) * 0.5;

				i += 8;
			}

			array_push(_framesDest, _frame);
			++_time;
		}

		return _transition;
	};
}