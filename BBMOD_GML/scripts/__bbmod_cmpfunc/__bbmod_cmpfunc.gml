/// @module Core

/// @func bbmod_cmpfunc_to_string(_cmpfunc)
///
/// @desc Retrieves a name of a cmpfunc.
///
/// @param {Constant.ZFunction} _cmpfunc The cmpfunc to get the name of. Use one of the
/// `cmpfunc_*` constants.
///
/// @return {String} The name of the cmpfunc or an empty string on error.
function bbmod_cmpfunc_to_string(_cmpfunc)
{
	switch (_cmpfunc)
	{
	case cmpfunc_always:
		return "cmpfunc_always";

	case cmpfunc_equal:
		return "cmpfunc_equal";

	case cmpfunc_greater:
		return "cmpfunc_greater";

	case cmpfunc_greaterequal:
		return "cmpfunc_greaterequal";

	case cmpfunc_less:
		return "cmpfunc_less";

	case cmpfunc_lessequal:
		return "cmpfunc_lessequal";

	case cmpfunc_never:
		return "cmpfunc_never";

	case cmpfunc_notequal:
		return "cmpfunc_notequal";

	default:
		return "";
	}
}

/// @func bbmod_cmpfunc_from_string(_name)
///
/// @desc Retrieves a cmpfunc from its name.
///
/// @param {String} _name The name of the cmpfunc.
///
/// @return {Constant.ZFunction} One of the `cmpfunc_*` constants.
///
/// @throws {BBMOD_Exception} If an invalid name is passed.
function bbmod_cmpfunc_from_string(_name)
{
	switch (_name)
	{
	case "cmpfunc_always":
		return cmpfunc_always;

	case "cmpfunc_equal":
		return cmpfunc_equal;

	case "cmpfunc_greater":
		return cmpfunc_greater;

	case "cmpfunc_greaterequal":
		return cmpfunc_greaterequal;

	case "cmpfunc_less":
		return cmpfunc_less;

	case "cmpfunc_lessequal":
		return cmpfunc_lessequal;

	case "cmpfunc_never":
		return cmpfunc_never;

	case "cmpfunc_notequal":
		return cmpfunc_notequal;

	default:
		throw new BBMOD_Exception("Invalid cmpfunc \"" + _name + "\"!");
	}
}
