/// @module Core

/// @func BBMOD_Property(_name, _type)
///
/// @desc A descriptor of a serializable property.
///
/// @param {String} _name The name of the property.
/// @param {Real} _type The type of the property. Use values from
/// {@link BBMOD_EPropertyType}.
///
/// @see BBMOD_EPropertyType
function BBMOD_Property(_name, _type) constructor
{
	/// @var {String} The name of the property.
	Name = _name;

	/// @var {Real} The type of the property. Use values from
	/// {@link BBMOD_EPropertyType}.
	/// @see BBMOD_EPropertyType
	Type = _type;

	/// @var {Bool} If `true` then the property is private. Default value is
	/// `false`.
	Private = false;
}
