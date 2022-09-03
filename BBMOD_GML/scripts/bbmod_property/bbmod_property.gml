/// @func BBMOD_Property(_name, _type)
///
/// @desc
///
/// @param {String} _name
/// @param {Real} _type Use values from {@link BBMOD_EPropertyType}.
///
/// @see BBMOD_EPropertyType
function BBMOD_Property(_name, _type) constructor
{
	/// @var {String}
	Name = _name;

	/// @var {Real} Use values from {@link BBMOD_EPropertyType}.
	/// @see BBMOD_EPropertyType
	Type = _type;

	/// @var {Bool} If `true` then the property is private. Default value is
	/// `false`.
	Private = false;
}
