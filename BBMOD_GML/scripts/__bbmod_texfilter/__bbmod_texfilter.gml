/// @module Core

/// @func bbmod_texfilter_to_string(_setting)
///
/// @desc Converts constants `tf_point`, `tf_linear` and `tf_anisotropic` to a string.
///
/// @param {Real} _setting The constant to convert to a string.
///
/// @return {String} The name of the constant as a string or an empty string on
/// error.
function bbmod_texfilter_to_string(_setting)
{
	switch (_setting)
	{
		case tf_point:
			return "tf_point";

		case tf_linear:
			return "tf_linear";

		case tf_anisotropic:
			return "tf_anisotropic";

		default:
			return "";
	}
}

/// @func bbmod_texfilter_from_string(_name)
///
/// @desc Converts strings "tf_point", "tf_linear" and "tf_anisotropic" to the
/// respective constants.
///
/// @param {String} _name The name of the constants.
///
/// @return {Real} One of constants `tf_point`, `tf_linear` or `tf_anisotropic`.
///
/// @throws {BBMOD_Exception} If an invalid constant name is passed.
function bbmod_texfilter_from_string(_name)
{
	switch (_name)
	{
		case "tf_point":
			return tf_point;

		case "tf_linear":
			return tf_linear;

		case "tf_anisotropic":
			return tf_anisotropic;

		default:
			throw new BBMOD_Exception("Invalid texture filtering setting \"" + _name + "\"!");
	}
}
