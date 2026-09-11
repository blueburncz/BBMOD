/// @module PostProcessing

/// @func BBMOD_PostProcessEffect()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Base struct for all post-processing effects.
/// 
/// @see BBMOD_PostProcessor 
function BBMOD_PostProcessEffect() constructor
{
	/// @var {Struct.BBMOD_PostProcessor} The post-processor to which is this
	/// effect added or `undefined`.
	/// @readonly
	PostProcessor = undefined;

	/// @var {Bool} If `true` then the effect is enabled. Default value is
	/// `true`.
	Enabled = true;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes shared post-process effect state to a binary buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write to.
	///
	/// @return {Struct.BBMOD_PostProcessEffect} Returns `self`.
	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_bool, Enabled);
		return self;
	};

	/// @func from_buffer(_buffer)
	///
	/// @desc Reads shared post-process effect state from a binary buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to read from.
	///
	/// @return {Struct.BBMOD_PostProcessEffect} Returns `self`.
	static from_buffer = function (_buffer)
	{
		Enabled = buffer_read(_buffer, buffer_bool);
		return self;
	};

	/// @func draw(_surfaceDest, _surfaceSrc, _depth, _normals)
	///
	/// @desc Applies the effect to given surface.
	///
	/// @param {Id.Surface} _surfaceDest The destination surface.
	/// @param {Id.Surface} _surfaceSrc The surface to apply the post-processing
	/// effect to.
	/// @param {Id.Surface} _depth A surface containing the scene depth encoded
	/// in the RGB channels or `undefined` if not available.
	/// @param {Id.Surface} _normals A surface containing the scene's
	/// world-space normals in the RGB channels or `undefined` if not available.
	///
	/// @return {Id.Surface} Returns a surface with the effect applied. Must be
	/// either `_surfaceDest` or `_surfaceSrc`!
	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		return _surfaceSrc;
	};

	static destroy = function ()
	{
		return undefined;
	};
}
