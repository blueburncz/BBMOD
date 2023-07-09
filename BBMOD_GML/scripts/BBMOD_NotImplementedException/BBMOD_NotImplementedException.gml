/// @module Core

/// @func BBMOD_NotImplementedException()
///
/// @extends BBMOD_Exception
///
/// @desc An exception thrown when called method is not implemented.
function BBMOD_NotImplementedException()
	: BBMOD_Exception("Method not implemented!") constructor
{
}

/// @func __bbmod_throw_not_implemented_exception()
///
/// @throws {BBMOD_NotImplementedException}
///
/// @private
function __bbmod_throw_not_implemented_exception()
{
	throw new BBMOD_NotImplementedException();
}
