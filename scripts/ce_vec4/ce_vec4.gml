CE_PRAGMA_ONCE;

/// @func ce_vec4_create(x[, _y, _z, _w])
/// @desc Creates a new vector with given components. If only the first value
/// is supplied, then it is used for every component.
/// @param {real} _x The first vector component.
/// @param {real} [_y] The second vector component.
/// @param {real} [_z] The third vector component.
/// @param {real} [_w] The fourth vector component.
/// @return {array} The created vector.
/// @note One could also just write `[x, y, z, w]`, which would give the same
/// result.
function ce_vec4_create()
{
	gml_pragma("forceinline");
	if (argument_count == 1)
	{
		return array_create(4, argument[0]);
	}
	if (argument_count == 3)
	{
		return [argument[0], argument[1], argument[2], argument[3]];
	}
}

/// @func ce_vec4_abs(_v)
/// @desc Sets vector's components to their absolute value.
/// @param {array} _v The vector.
function ce_vec4_abs(_v)
{
	gml_pragma("forceinline");
	_v[@ 0] = abs(_v[0]);
	_v[@ 1] = abs(_v[1]);
	_v[@ 2] = abs(_v[2]);
	_v[@ 3] = abs(_v[3]);
}

/// @func ce_vec4_add(_v1, _v2)
/// @desc Adds vectors `_v1`, `_v2` and stores the result into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
function ce_vec4_add(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] += _v2[0];
	_v1[@ 1] += _v2[1];
	_v1[@ 2] += _v2[2];
	_v1[@ 3] += _v2[3];
}

/// @func ce_vec4_ceil(_v)
/// @desc Ceils each component of the vector.
/// @param {array} _v The vector to ceil.
function ce_vec4_ceil(_v)
{
	gml_pragma("forceinline");
	_v[@ 0] = ceil(_v[0]);
	_v[@ 1] = ceil(_v[1]);
	_v[@ 2] = ceil(_v[2]);
	_v[@ 3] = ceil(_v[3]);
}

/// @func ce_vec4_clamp_length(_v, min, max)
/// @desc Clamps vector's length between `min` and `max`.
/// @param {array} _v The vector.
/// @param {real} _min The minimum vector length.
/// @param {real} _max The maximum vector length.
function ce_vec4_clamp_length(_v, _min, _max)
{
	gml_pragma("forceinline");
	ce_vec4_normalize(_v);
	ce_vec4_scale(_v, clamp(ce_vec4_length(_v), _min, _max));
}

/// @func ce_vec4_clone(_v)
/// @desc Creates a clone of the vector.
/// @param {array} _v The vector.
/// @return {array} The created clone.
function ce_vec4_clone(_v)
{
	gml_pragma("forceinline");
	var _clone = array_create(4, 0);
	array_copy(_clone, 0, _v, 0, 4);
	return _clone;
}

/// @func ce_vec4_create_barycentric(_v1, _v2, _v3, _f, _g)
/// @desc Creates a new vector using barycentric coordinates, following formula
/// `_v1 + _f(_v2-_v1) + _g(_v3-_v1)`.
/// @param {array} _v1 The first point of triangle.
/// @param {array} _v2 The second point of triangle.
/// @param {array} _v3 The third point of triangle.
/// @param {real} _f The first weighting factor.
/// @param {real} _g The second weighting factor.
/// @return {array} The created vector.
function ce_vec4_create_barycentric(_v1, _v2, _v3, _f, _g)
{
	gml_pragma("forceinline");
	var _v10 = _v1[0];
	var _v11 = _v1[1];
	var _v12 = _v1[2];
	var _v13 = _v1[3];
	return [
		_v10 + _f*(_v2[0]-_v10) + _g*(_v3[0]-_v10),
		_v11 + _f*(_v2[1]-_v11) + _g*(_v3[1]-_v11),
		_v12 + _f*(_v2[2]-_v12) + _g*(_v3[2]-_v12),
		_v13 + _f*(_v2[3]-_v13) + _g*(_v3[3]-_v13),
	];
}

/// @func ce_vec4_dot(_v1, _v2)
/// @desc Gets the dot product of vectors `_v1` and `_v2`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @return {real} The dot product.
function ce_vec4_dot(_v1, _v2)
{
	gml_pragma("forceinline");
	return (_v1[0] * _v2[0]
		+ _v1[1] * _v2[1]
		+ _v1[2] * _v2[2]
		+ _v1[3] * _v2[3]);
}

/// @func ce_vec4_equals(_v1, _v2)
/// @desc Gets whether vectors `_v1` and `_v2` are equal.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @return {bool} `true` if the vectors are equal.
function ce_vec4_equals(_v1, _v2)
{
	gml_pragma("forceinline");
	return (_v1[0] == _v2[0]
		&& _v1[1] == _v2[1]
		&& _v1[2] == _v2[2]
		&& _v1[3] == _v2[3]);
}

/// @func ce_vec4_floor(_v)
/// @desc Floors each component of the vector.
/// @param {array} _v The vector to floor.
function ce_vec4_floor(_v)
{
	gml_pragma("forceinline");
	_v[@ 0] = floor(_v[0]);
	_v[@ 1] = floor(_v[1]);
	_v[@ 2] = floor(_v[2]);
	_v[@ 3] = floor(_v[3]);
}

/// @func ce_vec4_frac(_v)
/// @desc Sets each component of the input vector to its decimal part.
/// @param {array} _v The input vector.
function ce_vec4_frac(_v)
{
	gml_pragma("forceinline");
	_v[@ 0] = frac(_v[0]);
	_v[@ 1] = frac(_v[1]);
	_v[@ 2] = frac(_v[2]);
	_v[@ 3] = frac(_v[3]);
}

/// @func ce_vec4_length(_v)
/// @desc Gets length of the vector.
/// @param {array} _v The vector.
/// @return {real} The vector's length.
function ce_vec4_length(_v)
{
	gml_pragma("forceinline");
	var _v0 = _v[0];
	var _v1 = _v[1];
	var _v2 = _v[2];
	var _v3 = _v[3];
	return sqrt(_v0 * _v0
		+ _v1 * _v1
		+ _v2 * _v2
		+ _v3 * _v3);
}

/// @func ce_vec4_lengthsqr(_v)
/// @desc Gets squared length of the vector.
/// @param {array} _v The vector.
/// @return {real} The vector's squared length.
function ce_vec4_lengthsqr(_v)
{
	gml_pragma("forceinline");
	var _v0 = _v[0];
	var _v1 = _v[1];
	var _v2 = _v[2];
	var _v3 = _v[3];
	return (_v0 * _v0
		+ _v1 * _v1
		+ _v2 * _v2
		+ _v3 * _v3);
}

/// @func ce_vec4_lerp(_v1, _v2, _s)
/// @desc Linearly interpolates between vectors `_v1`, `_v2` and stores the
/// resulting vector into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @param {real} _s The interpolation factor.
function ce_vec4_lerp(_v1, _v2, _s)
{
	gml_pragma("forceinline");
	_v1[@ 0] = lerp(_v1[0], _v2[0], _s);
	_v1[@ 1] = lerp(_v1[1], _v2[1], _s);
	_v1[@ 2] = lerp(_v1[2], _v2[2], _s);
	_v1[@ 3] = lerp(_v1[3], _v2[3], _s);
}

/// @func ce_vec4_max_component(_v)
/// @desc Gets the largest component of the vector.
/// @param {array} _v The vector.
/// @return {real} The vetor's largest component.
/// @example
/// Here the `_max` variable would be equal to `4`.
/// ```gml
/// var _v = [1, 2, 3, 4];
/// var _max = ce_vec4_max_component(_v);
/// ```
function ce_vec4_max_component(_v)
{
	gml_pragma("forceinline");
	return max(_v[0], _v[1], _v[2], _v[3]);
}

/// @func ce_vec4_maximize(_v1, _v2)
/// @desc Gets a vector that is made up of the largest components of the
/// vectors `_v1`, `_v2` and stores it into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @example
/// This would make the vector `_v1` equal to `[2, 4, 6, 8]`.
/// ```gml
/// var _v1 = [1, 4, 5, 8];
/// var _v2 = [2, 3, 6, 7];
/// ce_vec4_maximize(_v1, _v2);
/// ```
function ce_vec4_maximize(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] = max(_v1[0], _v2[0]);
	_v1[@ 1] = max(_v1[1], _v2[1]);
	_v1[@ 2] = max(_v1[2], _v2[2]);
	_v1[@ 3] = max(_v1[3], _v2[3]);
}

/// @func ce_vec4_min_component(_v)
/// @desc Gets the smallest component of the vector.
/// @param {array} _v The vector.
/// @return {real} The vetor's smallest component.
/// @example
/// Here the `_min` variable would be equal to `1`.
/// ```gml
/// var _v = [1, 2, 3, 4];
/// var _min = ce_vec4_min_component(_v);
/// ```
function ce_vec4_min_component(_v)
{
	gml_pragma("forceinline");
	return min(_v[0], _v[1], _v[2], _v[3]);
}

/// @func ce_vec4_minimize(_v1, _v2)
/// @desc Gets a vector that is made up of the smallest components of the
/// vectors `_v1`, `_v2` and stores it into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @example
/// This would make the vector `_v1` equal to `[1, 3, 5, 7]`.
/// ```gml
/// var _v1 = [1, 4, 5, 8];
/// var _v2 = [2, 3, 6, 7];
/// ce_vec4_minimize(_v1, _v2);
/// ```
function ce_vec4_minimize(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] = min(_v1[0], _v2[0]);
	_v1[@ 1] = min(_v1[1], _v2[1]);
	_v1[@ 2] = min(_v1[2], _v2[2]);
	_v1[@ 3] = min(_v1[3], _v2[3]);
}

/// @func ce_vec4_multiply(_v1, _v2)
/// @desc Multiplies the vectors `_v1`, `_v2` componentwise and stores the result
/// into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @example
/// This would make the vector `_v1` equal to `[5, 12, 21, 32]`.
/// ```gml
/// var _v1 = [1, 2, 3, 4];
/// var _v2 = [5, 6, 7, 8];
/// ce_vec4_multiply(_v1, _v2);
/// ```
function ce_vec4_multiply(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] *= _v2[0];
	_v1[@ 1] *= _v2[1];
	_v1[@ 2] *= _v2[2];
	_v1[@ 3] *= _v2[3];
}

/// @func ce_vec4_normalize(_v)
/// @desc Normalizes the vector (makes the vector's length equal to `1`).
/// @param {array} _v The vector to be normalized.
function ce_vec4_normalize(_v)
{
	gml_pragma("forceinline");
	var _length_sqr = ce_vec4_lengthsqr(_v);
	if (_length_sqr > 0)
	{
		var _n = 1 / sqrt(_length_sqr);
		_v[@ 0] *= _n;
		_v[@ 1] *= _n;
		_v[@ 2] *= _n;
		_v[@ 3] *= _n;
	}
}

/// @func ce_vec4_scale(_v, _s)
/// @desc Scales the vector's components by the given value.
/// @param {array} _v The vector.
/// @param {real} _s The value to scale the components by.
function ce_vec4_scale(_v, _s)
{
	gml_pragma("forceinline");
	_v[@ 0] *= _s;
	_v[@ 1] *= _s;
	_v[@ 2] *= _s;
	_v[@ 3] *= _s;
}

/// @func ce_vec4_subtract(_v1, _v2)
/// @desc Subtracts vector `_v2` from `_v1` and stores the result into `_v1`.
/// @param {array} _v1 The vector to subtract from.
/// @param {array} _v2 The vector to subtract.
function ce_vec4_subtract(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] -= _v2[0];
	_v1[@ 1] -= _v2[1];
	_v1[@ 2] -= _v2[2];
	_v1[@ 3] -= _v2[3];
}

/// @func ce_vec4_transform(_v, _m)
/// @desc Transforms the vector by the matrix.
/// @param {array} _v The vector to transform.
/// @param {array} _m The transform matrix.
function ce_vec4_transform(_v, _m)
{
	gml_pragma("forceinline");
	var _v0 = _v[0];
	var _v1 = _v[1];
	var _v2 = _v[2];
	var _v3 = _v[3];

	_v[@ 0] = _m[ 0]*_v0 + _m[ 4]*_v1 + _m[ 8]*_v2 + _m[12]*_v3;
	_v[@ 1] = _m[ 1]*_v0 + _m[ 5]*_v1 + _m[ 9]*_v2 + _m[13]*_v3;
	_v[@ 2] = _m[ 2]*_v0 + _m[ 6]*_v1 + _m[10]*_v2 + _m[14]*_v3;
	_v[@ 3] = _m[ 3]*_v0 + _m[ 7]*_v1 + _m[11]*_v2 + _m[15]*_v3;
}