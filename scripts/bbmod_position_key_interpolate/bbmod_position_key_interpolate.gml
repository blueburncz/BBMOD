/// @func bbmod_position_key_interpolate(pk1, pk2, factor)
/// @desc Interpolates between two position keys.
/// @param {array} pk1 The first position key.
/// @param {array} pk2 The second position key.
/// @param {real} factor The interpolation factor. Should be a value in range 0..1.
/// @return {array} A new key with the interpolated animation time and position.
var _pk1 = argument0;
var _pk2 = argument1;
var _factor = argument2;
var _key = array_create(BBMOD_EPositionKey.SIZE, 0);
_key[@ BBMOD_EPositionKey.Time] = lerp(
	_pk1[BBMOD_EPositionKey.Time],
	_pk2[BBMOD_EPositionKey.Time],
	_factor);
var _pos = ce_vec3_clone(_pk1[BBMOD_EPositionKey.Position]);
ce_vec3_lerp(_pos, _pk2[BBMOD_EPositionKey.Position], _factor);
_key[@ BBMOD_EPositionKey.Position] = _pos;
return _key;