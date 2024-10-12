/// @module Core

/// @func bbmod_lerp_delta_time(_from, _to, _factor, _deltaTime)
///
/// @desc Linearly interpolates two values, taking delta time into account.
///
/// @param {Real} _from The value to interpolate from.
/// @param {Real} _to The value to interpolate to.
/// @param {Real} _factor The interpolation factor.
/// @param {Real} _deltaTime The `delta_time`.
///
/// @return {Real} The resulting value.
function bbmod_lerp_delta_time(_from, _to, _factor, _deltaTime)
{
	gml_pragma("forceinline");
	// * 10 for backwards compatibility!
	return lerp(_from, _to, 1.0 - power(_factor, _deltaTime * 0.000001 * 10.0));
}
