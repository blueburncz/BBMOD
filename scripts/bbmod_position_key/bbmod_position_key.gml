/// @func bbmod_position_key()
/// @desc Contains definition of the PositionKey structure.
/// @see BBMOD_EPositionKey
function bbmod_position_key()
{
	/// @enum An enumeration of members of a PositionKey structure.
	enum BBMOD_EPositionKey
	{
		/// @member Time when the animation key occurs.
		Time,
		/// @member A 3D position vector.
		Position,
		/// @member The size of the PositionKey structure.
		SIZE
	};
}

/// @func bbmod_position_key_interpolate(_pk1, _pk2, _factor)
/// @desc Interpolates between two PositionKey structures.
/// @param {array} _pk1 The first PositionKey structure.
/// @param {array} _pk2 The second PositionKey structure.
/// @param {real} _factor The interpolation factor. Should be a value in range 0..1.
/// @return {array} A new PositionKey with the interpolated animation time and
/// position.
function bbmod_position_key_interpolate(_pk1, _pk2, _factor)
{
	var _key = array_create(BBMOD_EPositionKey.SIZE, 0);
	_key[@ BBMOD_EPositionKey.Time] = lerp(
		_pk1[BBMOD_EPositionKey.Time],
		_pk2[BBMOD_EPositionKey.Time],
		_factor);
	var _pos = ce_vec3_clone(_pk1[BBMOD_EPositionKey.Position]);
	ce_vec3_lerp(_pos, _pk2[BBMOD_EPositionKey.Position], _factor);
	_key[@ BBMOD_EPositionKey.Position] = _pos;
	return _key;
}

/// @func bbmod_position_key_load(_buffer)
/// @desc Loads a PositionKey structure from a buffer.
/// @param {real} _buffer The buffer to load the structure from.
/// @return {array} The loaded PositionKey structure.
function bbmod_position_key_load(_buffer)
{
	var _key = array_create(BBMOD_EPositionKey.SIZE, 0);
	_key[@ BBMOD_EPositionKey.Time] = buffer_read(_buffer, buffer_f64);;
	_key[@ BBMOD_EPositionKey.Position] = bbmod_load_vec3(_buffer);
	return _key;
}

/// @func bbmod_position_key_to_matrix(_position_key)
/// @desc Creates a translation matrix from a PositionKey structure.
/// @param {array} _position_key The PositionKey structure.
/// @return {array} The created matrix.
function bbmod_position_key_to_matrix(_position_key)
{
	gml_pragma("forceinline");
	var _position = _position_key[BBMOD_EPositionKey.Position];
	return matrix_build(
		_position[0],
		_position[1],
		_position[2],
		0, 0, 0,
		1, 1, 1);
}