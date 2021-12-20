/// @func bbmod_lerp_delta_time(_from, _to, _factor, _deltaTime)
/// @desc Linearly interpolates two values, taking delta time into account.
/// @param {real} _from The value to interpolate from.
/// @param {real} _to The value to interpolate to.
/// @param {real} _factor The interpolation factor.
/// @param {real} _deltaTime The `delta_time`.
/// @return {real} The resulting value.
function bbmod_lerp_delta_time(_from, _to, _factor, _deltaTime)
{
	gml_pragma("forceinline");
	return lerp(
		_from,
		_to,
		_factor * (_deltaTime / game_get_speed(gamespeed_microseconds)));
}