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
	/// @return {Struct.BBMOD_PostProcessEffect} Returns `self`.
	static draw = function (_surfaceDest, _surfaceSrc, _depth, _normals)
	{
		return self;
	};

	static destroy = function ()
	{
		return undefined;
	};
}
