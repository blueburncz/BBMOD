/// @func BBMOD_Exception([_msg])
/// @desc The base struct for exceptions thrown by the BBMOD library.
/// @param {String} [_msg] An exception message. Defaults to an empty string.
function BBMOD_Exception(_msg) constructor
{
	/// @var {String} The exception message.
	/// @readonly
	Message = (_msg != undefined) ? _msg : "";
}