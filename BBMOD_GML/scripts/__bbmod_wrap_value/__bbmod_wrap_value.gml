/// @module Core

/// @func bbmod_wrap_value(_value, _rangeMax)
///
/// @desc Wraps given value to range 0..max-1.
///
/// @param {Real} _value The value to be wrapped.
/// @param {Real} _rangeMax The maximum value to wrap around. Minimum is always 0.
///
/// @return The value wrapped to range 0..max-1.
function bbmod_wrap_value(_value, _rangeMax)
{
	gml_pragma("forceinline");
	return ((_value % _rangeMax) + _rangeMax) % _rangeMax;
}
