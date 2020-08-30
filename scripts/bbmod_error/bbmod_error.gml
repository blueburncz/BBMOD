/// @func BBMOD_Error([_msg])
/// @param {string} [_msg] An error message. Defaults to an empty string.
function BBMOD_Error() constructor
{
	msg = (argument_count > 0) ? argument[0] : "";
}