/// @module Core

/// @func bbmod_blendmode_to_string(_blendmode)
///
/// @desc Retrieves a name of a basic blend mode.
///
/// @param {Constant.BlendMode} _blendmode The basic blend mode to get the name of.
/// Use one of constants `bm_add`, `bm_max`, `bm_normal` or `bm_subtract`.
///
/// @return {String} The name of the basic blend mode.
function bbmod_blendmode_to_string(_blendmode)
{
	switch (_blendmode)
	{
	case bm_add:
		return "bm_add";

	case bm_max:
		return "bm_max";

	case bm_normal:
		return "bm_normal";

	case bm_subtract:
		return "bm_subtract";

	default:
		return "";
	}
}

/// @func bbmod_blendmode_from_string(_name)
///
/// @desc Retrieves a basic blend mode from its name.
///
/// @param {String} _name The name of the basic blend mode.
///
/// @return {Constant.BlendMode} One of constants `bm_add`, `bm_max`, `bm_normal` or
/// `bm_subtract`.
///
/// @throws {BBMOD_Exception} If an invalid name is passed.
function bbmod_blendmode_from_string(_name)
{
	switch (_name)
	{
	case "bm_add":
		return bm_add;

	case "bm_max":
		return bm_max;

	case "bm_normal":
		return bm_normal;

	case "bm_subtract":
		return bm_subtract;

	default:
		throw new BBMOD_Exception("Invalid basic blend mode \"" + _name + "\"!");
	}
}
