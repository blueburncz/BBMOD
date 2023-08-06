/// @module Core

/// @func bbmod_mipenable_to_string(_setting)
///
/// @desc Converts constants `mip_off`, `mip_on` and `mip_markedonly` to a string.
///
/// @param {Real} _setting The constant to convert to a string.
///
/// @return {String} The name of the constant as a string or an empty string on
/// error.
function bbmod_mipenable_to_string(_setting)
{
	switch (_setting)
	{
	case mip_off:
		return "mip_off";

	case mip_on:
		return "mip_on";

	case mip_markedonly:
		return "mip_markedonly";

	default:
		return "";
	}
}

/// @func bbmod_mipenable_from_string(_name)
///
/// @desc Converts strings "mip_off", "mip_on" and "mip_markedonly" to the
/// respective constants.
///
/// @param {String} _name The name of the constants.
///
/// @return {Real} One of constants `mip_off`, `mip_on` or `mip_markedonly`.
///
/// @throws {BBMOD_Exception} If an invalid constant name is passed.
function bbmod_mipenable_from_string(_name)
{
	switch (_name)
	{
	case "mip_off":
		return mip_off;

	case "mip_on":
		return mip_on;

	case "mip_markedonly":
		return mip_markedonly;

	default:
		throw new BBMOD_Exception("Invalid mip-enable setting \"" + _name + "\"!");
	}
}
