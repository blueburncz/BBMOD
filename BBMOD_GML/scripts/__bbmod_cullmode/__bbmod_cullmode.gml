/// @func bbmod_cullmode_to_string(_cullmode)
///
/// @desc Retrieves a name of a cull mode.
///
/// @param {Constant.CullMode} _cullmode The cull mode to get the name of. Use one of the
/// `cull_*` constants.
///
/// @return {String} The name of the cull mode.
function bbmod_cullmode_to_string(_cullmode)
{
	switch (_cullmode)
	{
	case cull_clockwise:
		return "cull_clockwise";

	case cull_counterclockwise:
		return "cull_counterclockwise";

	case cull_noculling:
		return "cull_noculling";

	default:
		return "";
	}
}

/// @func bbmod_cullmode_from_string(_name)
///
/// @desc Retrieves a cull mode from its name.
///
/// @param {String} _name The name of the cull mode.
///
/// @return {Constant.CullMode} One of the `cull_*` constants.
///
/// @throws {BBMOD_Exception} If an invalid name is passed.
function bbmod_cullmode_from_string(_name)
{
	switch (_name)
	{
	case "cull_clockwise":
		return cull_clockwise;

	case "cull_counterclockwise":
		return cull_counterclockwise;

	case "cull_noculling":
		return cull_noculling;

	default:
		throw new BBMOD_Exception("Invalid cull mode \"" + _name + "\"!");
	}
}
