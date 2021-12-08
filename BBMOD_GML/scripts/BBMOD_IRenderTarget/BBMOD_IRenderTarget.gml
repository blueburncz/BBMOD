/// @func BBMOD_IRenderTarget()
/// @desc An interface for structs which can be used as a render target.
function BBMOD_IRenderTarget() constructor
{
	/// @func set_target()
	/// @desc Sets the render target.
	/// @return {bool} Returns `true` if the render target was set.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	/// @see BBMOD_IRenderTarget.reset_target
	static set_target = function () {
		throw new BBMOD_NotImplementedException();
		//return self;
	};

	/// @func reset_target()
	/// @desc Resets the render target.
	/// @return {BBMOD_IRenderTarget} Returns `self`.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	/// @see BBMOD_IRenderTarget.set_target
	static reset_target = function () {
		throw new BBMOD_NotImplementedException();
		//return self;
	};
}