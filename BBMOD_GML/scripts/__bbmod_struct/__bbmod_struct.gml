/// @module Core

// Feather ignore GM1021

/// @func bbmod_struct_to_buffer(_buffer, _value)
///
/// @desc Writes a constructor-backed struct to a binary buffer.
///
/// @param {Id.Buffer} _buffer The destination buffer.
/// @param {Struct} _value The struct to serialize.
///
/// @return {Struct} Returns `_value`.
function bbmod_struct_to_buffer(_buffer, _value)
{
	var _constructorName = instanceof(_value);
	if (_constructorName == undefined || _constructorName == "struct")
	{
		throw new BBMOD_Exception("Struct has no constructor.");
	}
	if (!variable_struct_exists(_value, "to_buffer") || !is_method(_value.to_buffer))
	{
		throw new BBMOD_Exception(
			"Struct does not support binary serialization: " + _constructorName);
	}
	buffer_write(_buffer, buffer_string, _constructorName);
	_value.to_buffer(_buffer);
	return _value;
}

/// @func bbmod_struct_from_buffer(_buffer)
///
/// @desc Reads and constructs a struct from a binary buffer.
///
/// @param {Id.Buffer} _buffer The source buffer.
///
/// @return {Struct} The reconstructed struct.
function bbmod_struct_from_buffer(_buffer)
{
	var _constructorName = buffer_read(_buffer, buffer_string);
	var _constructor = asset_get_index(_constructorName);
	if (_constructor == -1)
	{
		throw new BBMOD_Exception("Unknown struct: " + _constructorName);
	}
	var _value = new _constructor();
	if (!variable_struct_exists(_value, "from_buffer") || !is_method(_value.from_buffer))
	{
		throw new BBMOD_Exception(
			"Struct does not support binary serialization: " + _constructorName);
	}
	_value.from_buffer(_buffer);
	return _value;
}
