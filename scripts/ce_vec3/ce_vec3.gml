/// @func ce_vec3_create([_x[, _y[, _z]]])
/// @desc Creates a new 3D vector.
/// @param {real} [_x] The first vector component. Defaults to 0.
/// @param {real} [_y] The second vector component. Defaults to `_x`.
/// @param {real} [_z] The third vector component. Defaults to `_y`.
/// @return {array} The created vector.
/// @note One could also just write `[x, y, z]`, which would give the same
/// result.
function ce_vec3_create()
{
	gml_pragma("forceinline");
	var _x = (argument_count > 0) ? argument[0] : 0;
	var _y = (argument_count > 1) ? argument[1] : _x;
	var _z = (argument_count > 2) ? argument[2] : _y;
	return [_x, _y, _z];
}

/// @func ce_vec3_abs(_v)
/// @desc Sets vector's components to their absolute value.
/// @param {array} _v The vector.
function ce_vec3_abs(_v)
{
	gml_pragma("forceinline");
	_v[@ 0] = abs(_v[0]);
	_v[@ 1] = abs(_v[1]);
	_v[@ 2] = abs(_v[2]);
}

/// @func ce_vec3_add(_v1, _v2)
/// @desc Adds vectors `_v1`, `_v2` and stores the result into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
function ce_vec3_add(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] += _v2[0];
	_v1[@ 1] += _v2[1];
	_v1[@ 2] += _v2[2];
}

/// @func ce_vec3_ceil(_v)
/// @desc Ceils each component of the vector.
/// @param {array} _v The vector to ceil.
function ce_vec3_ceil(_v)
{
	gml_pragma("forceinline");
	_v[@ 0] = ceil(_v[0]);
	_v[@ 1] = ceil(_v[1]);
	_v[@ 2] = ceil(_v[2]);
}

/// @func ce_vec3_clamp_length(_v, _min, _max)
/// @desc Clamps vector's length between `min` and `max`.
/// @param {array} _v The vector.
/// @param {real} _min The minimum vector length.
/// @param {real} _max The maximum vector length.
function ce_vec3_clamp_length(_v, _min, _max)
{
	gml_pragma("forceinline");
	var _length = ce_vec3_length(_v);
	ce_vec3_normalize(_v);
	ce_vec3_scale(_v, clamp(_length, _min, _max));
}

/// @func ce_vec3_clone(_v)
/// @desc Creates a clone of the vector.
/// @param {array} _v The vector.
/// @return {array} The created clone.
function ce_vec3_clone(_v)
{
	gml_pragma("forceinline");
	var _clone = array_create(3, 0);
	array_copy(_clone, 0, _v, 0, 3);
	return _clone;
}

/// @func ce_vec3_create_barycentric(_v1, _v2, _v3, _f, _g)
/// @desc Creates a new vector using barycentric coordinates, following formula
/// `_v1 + _f(_v2-_v1) + _g(_v3-_v1)`.
/// @param {array} _v1 The first point of triangle.
/// @param {array} _v2 The second point of triangle.
/// @param {array} _v3 The third point of triangle.
/// @param {real} _f The first weighting factor.
/// @param {real} _g The second weighting factor.
/// @return {array} The created vector.
function ce_vec3_create_barycentric(_v1, _v2, _v3, _f, _g)
{
	gml_pragma("forceinline");
	var _v10 = _v1[0];
	var _v11 = _v1[1];
	var _v12 = _v1[2];
	return [
		_v10 + _f*(_v2[0]-_v10) + _g*(_v3[0]-_v10),
		_v11 + _f*(_v2[1]-_v11) + _g*(_v3[1]-_v11),
		_v12 + _f*(_v2[2]-_v12) + _g*(_v3[2]-_v12)
	];
}

/// @func ce_vec3_cross(_v1, _v2)
/// @desc Gets the cross product of the vectors `_v1`, `_v2` and stores it to
/// `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
function ce_vec3_cross(_v1, _v2)
{
	gml_pragma("forceinline");
	var _v10 = _v1[0];
	var _v11 = _v1[1];
	var _v12 = _v1[2];
	var _v20 = _v2[0];
	var _v21 = _v2[1];
	var _v22 = _v2[2];
	_v1[@ 0] = _v11*_v22 - _v12*_v21;
	_v1[@ 1] = _v12*_v20 - _v10*_v22;
	_v1[@ 2] = _v10*_v21 - _v11*_v20;
}

/// @func ce_vec3_dot(_v1, _v2)
/// @desc Gets the dot product of vectors `_v1` and `_v2`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @return {real} The dot product.
function ce_vec3_dot(_v1, _v2)
{
	gml_pragma("forceinline");
	return (_v1[0] * _v2[0]
		+ _v1[1] * _v2[1]
		+ _v1[2] * _v2[2]);
}

/// @func ce_vec3_equals(_v1, _v2)
/// @desc Gets whether vectors `_v1` and `_v2` are equal.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @return {bool} `true` if the vectors are equal.
function ce_vec3_equals(_v1, _v2)
{
	gml_pragma("forceinline");
	return (_v1[0] == _v2[0]
		&& _v1[1] == _v2[1]
		&& _v1[2] == _v2[2]);
}

/// @func ce_vec3_floor(_v)
/// @desc Floors each component of the vector.
/// @param {array} _v The vector to floor.
function ce_vec3_floor(_v)
{
	gml_pragma("forceinline");
	_v[@ 0] = floor(_v[0]);
	_v[@ 1] = floor(_v[1]);
	_v[@ 2] = floor(_v[2]);
}

/// @func ce_vec3_frac(_v)
/// @desc Sets each component of the input vector to it's decimal part.
/// @param {array} _v The input vector.
function ce_vec3_frac(_v)
{
	gml_pragma("forceinline");
	_v[@ 0] = frac(_v[0]);
	_v[@ 1] = frac(_v[1]);
	_v[@ 2] = frac(_v[2]);
}

/// @func ce_vec3_length(_v)
/// @desc Gets length of the vector.
/// @param {array} _v The vector.
/// @return {real} The vector's length.
function ce_vec3_length(_v)
{
	gml_pragma("forceinline");
	var _v0 = _v[0];
	var _v1 = _v[1];
	var _v2 = _v[2];
	return sqrt(_v0 * _v0
		+ _v1 * _v1
		+ _v2 * _v2);
}

/// @func ce_vec3_lengthsqr(_v)
/// @desc Gets squared length of the vector.
/// @param {array} _v The vector.
/// @return {real} The vector's squared length.
function ce_vec3_lengthsqr(_v)
{
	gml_pragma("forceinline");
	var _v0 = _v[0];
	var _v1 = _v[1];
	var _v2 = _v[2];
	return (_v0 * _v0
		+ _v1 * _v1
		+ _v2 * _v2);
}

/// @func ce_vec3_lerp(_v1, _v2, _s)
/// @desc Linearly interpolates between vectors `_v1`, `_v2` and stores the
/// resulting vector into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @param {real} _s The interpolation factor.
function ce_vec3_lerp(_v1, _v2, _s)
{
	gml_pragma("forceinline");
	_v1[@ 0] = lerp(_v1[0], _v2[0], _s);
	_v1[@ 1] = lerp(_v1[1], _v2[1], _s);
	_v1[@ 2] = lerp(_v1[2], _v2[2], _s);
}

/// @func ce_vec3_max_component(_v)
/// @desc Gets the largest component of the vector.
/// @param {array} _v The vector.
/// @return {real} The vetor's largest component.
/// @example
/// Here the `_max` variable would be equal to `3`.
/// ```gml
/// var _vec = [1, 2, 3];
/// var _max = ce_vec3_max_component(_vec);
/// ```
function ce_vec3_max_component(_v)
{
	gml_pragma("forceinline");
	return max(_v[0], _v[1], _v[2]);
}

/// @func ce_vec3_maximize(_v1, _v2)
/// @desc Gets a vector that is made up of the largest components of the
/// vectors `_v1`, `_v2` and stores it into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @example
/// This would make the vector `_v1` equal to `[2, 4, 6]`.
/// ```gml
/// var _v1 = [1, 4, 5];
/// var _v2 = [2, 3, 6];
/// ce_vec3_maximize(_v1, _v2);
/// ```
function ce_vec3_maximize(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] = max(_v1[0], _v2[0]);
	_v1[@ 1] = max(_v1[1], _v2[1]);
	_v1[@ 2] = max(_v1[2], _v2[2]);
}

/// @func ce_vec3_min_component(_v)
/// @desc Gets the smallest component of the vector.
/// @param {array} _v The vector.
/// @return {real} The vetor's smallest component.
/// @example
/// Here the `_min` variable would be equal to `1`.
/// ```gml
/// var _vec = [1, 2, 3];
/// var _min = ce_vec3_min_component(_vec);
/// ```
function ce_vec3_min_component(_v)
{
	gml_pragma("forceinline");
	return min(_v[0], _v[1], _v[2]);
}

/// @func ce_vec3_minimize(_v1, _v2)
/// @desc Gets a vector that is made up of the smallest components of the
/// vectors `_v1`, `_v2` and stores it into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @example
/// This would make the vector `_v1` equal to `[1, 3, 5]`.
/// ```gml
/// var _v1 = [1, 4, 5];
/// var _v2 = [2, 3, 6];
/// ce_vec3_minimize(_v1, _v2);
/// ```
function ce_vec3_minimize(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] = min(_v1[0], _v2[0]);
	_v1[@ 1] = min(_v1[1], _v2[1]);
	_v1[@ 2] = min(_v1[2], _v2[2]);
}

/// @func ce_vec3_multiply(_v1, _v2)
/// @desc Multiplies the vectors `_v1`, `_v2` componentwise and stores the result
/// into `_v1`.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @example
/// This would make the vector `_v1` equal to `[4, 10, 18]`.
/// ```gml
/// var _v1 = [1, 2, 3];
/// var _v2 = [4, 5, 6];
/// ce_vec3_multiply(_v1, _v2);
/// ```
function ce_vec3_multiply(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] *= _v2[0];
	_v1[@ 1] *= _v2[1];
	_v1[@ 2] *= _v2[2];
}

/// @func ce_vec3_normalize(_v)
/// @desc Normalizes the vector (makes the vector's length equal to `1`).
/// @param {array} _v The vector to be normalized.
function ce_vec3_normalize(_v)
{
	gml_pragma("forceinline");
	var _length_sqr = ce_vec3_lengthsqr(_v);
	if (_length_sqr > 0)
	{
		var _n = 1 / sqrt(_length_sqr);
		_v[@ 0] *= _n;
		_v[@ 1] *= _n;
		_v[@ 2] *= _n;
	}
}

/// @func ce_vec3_orthonormalize(_v1, _v2)
/// @desc Orthonormalizes the vectors using the Gram–Schmidt process.
/// @param {array} _v1 The first vector.
/// @param {array} _v2 The second vector.
/// @return {bool} `true` if the vectors were orthonormalized.
/// @source https://www.gamedev.net/forums/topic/585184-orthonormalize-two-vectors/
function ce_vec3_orthonormalize(_in_v1, _in_v2)
{
	gml_pragma("forceinline");

	var _v1 = ce_vec3_clone(_in_v1);
	ce_vec3_normalize(_v1);
	var _proj = ce_vec3_clone(_v1);
	ce_vec3_scale(_proj, ce_vec3_dot(_in_v2, _v1));
	var _v2 = ce_vec3_clone(_in_v2);
	ce_vec3_subtract(_v2, _proj);

	if (ce_vec3_lengthsqr(_v2) <= 0)
	{
		return false;
	}

	ce_vec3_normalize(_v2);

	_in_v1[@ 0] = _v1[0];
	_in_v1[@ 1] = _v1[1];
	_in_v1[@ 2] = _v1[2];

	_in_v2[@ 0] = _v2[0];
	_in_v2[@ 1] = _v2[1];
	_in_v2[@ 2] = _v2[2];

	return true;
}

/// @func ce_vec3_project(_v, _screen, _mat)
/// @desc Projects the vector from world space into screen space.
/// @param {array} _v The vector.
/// @param {array} _screen An array containing `[screen_width, screen_height]`.
/// @param {array} _mat The world * view * projection matrix.
function ce_vec3_project(_v, _screen, _mat)
{
	gml_pragma("forceinline");
	var _vec = [_v[0], _v[1], _v[2], 1];
	ce_vec4_transform(_vec, _mat);
	var _s = 1 / _vec[3];
	_vec[0] *= _s;
	_vec[1] *= _s;
	_v[@ 0] = (_vec[0] * 0.5 + 0.5) * _screen[0];
	_v[@ 1] = (1 - (_vec[1] * 0.5 + 0.5)) * _screen[1];
	_v[@ 2] = _vec[2];
}

/// @func ce_vec3_reflect(_v, _n)
/// @desc Reflects the incident vector `_v` off the normal vector `_n`.
/// @param {array} _v The incident vector.
/// @param {array} _n The normal vector.
function ce_vec3_reflect(_v, _n)
{
	gml_pragma("forceinline");
	var _dot = ce_vec3_dot(_v, _n);
	_v[@ 0] = _v[0] - 2 * _dot * _n[0];
	_v[@ 1] = _v[1] - 2 * _dot * _n[1];
	_v[@ 2] = _v[2] - 2 * _dot * _n[2];
}

/// @func ce_vec3_scale(_v, _s)
/// @desc Scales the vector's components by the given value.
/// @param {array} _v The vector.
/// @param {real} _s The value to scale the components by.
function ce_vec3_scale(_v, _s)
{
	gml_pragma("forceinline");
	_v[@ 0] *= _s;
	_v[@ 1] *= _s;
	_v[@ 2] *= _s;
}

/// @func ce_vec3_slerp(_v1, _v2, _s)
/// @desc Performs a spherical linear interpolation between the vectors `_v1`,
/// `_v2` and stores the result to `_v1`.
/// @param {array} _v1 The first vector. Should be normalized!
/// @param {array} _v2 The second vector. Should be normalized!
/// @param {real} _s The slerping factor.
/// @source https://keithmaggio.wordpress.com/2011/02/15/math-magician-lerp-slerp-and-nlerp/
function ce_vec3_slerp(_v1, _v2, _s)
{
	gml_pragma("forceinline");
	var _dot = clamp(ce_vec3_dot(_v1, _v2), -1, 1); 
	var _theta = arccos(_dot) * _s;
	var _relative_vec = ce_vec3_clone(_v2);
	var _sub = ce_vec3_clone(_v1);
	ce_vec3_scale(_sub, _dot);
	ce_vec3_subtract(_relative_vec, _sub);
	ce_vec3_normalize(_relative_vec);
	ce_vec3_scale(_v1, cos(_theta));
	ce_vec3_scale(_relative_vec, sin(_theta));
	ce_vec3_add(_v1, _relative_vec);
}

/// @func ce_vec3_subtract(_v1, _v2)
/// @desc Subtracts vector `_v2` from `_v1` and stores the result into `_v1`.
/// @param {array} _v1 The vector to subtract from.
/// @param {array} _v2 The vector to subtract.
function ce_vec3_subtract(_v1, _v2)
{
	gml_pragma("forceinline");
	_v1[@ 0] -= _v2[0];
	_v1[@ 1] -= _v2[1];
	_v1[@ 2] -= _v2[2];
}

/// @func ce_vec3_transform(_v, _m)
/// @desc Transforms a 4D vector `[_v_x, _v_y, _v_z, 1]` by the matrix `_m` and stores
/// `[x, y, z]` of the resulting vector to `v`.
/// @param {array} _v The vector to transform.
/// @param {array} _m The transform matrix.
function ce_vec3_transform(_v, _m)
{
	gml_pragma("forceinline");
	var _w = [_v[0], _v[1], _v[2], 1];
	ce_vec4_transform(_w, _m);
	_v[@ 0] = _w[0];
	_v[@ 1] = _w[1];
	_v[@ 2] = _w[2];
}

/// @func ce_vec3_unproject(_v, _screen, _mat)
/// @desc Unprojects the vector from screen space to world space.
/// @param {array} _v The vector in screen space.
/// @param {array} _screen An array containing `[screen_width, screen_height]`.
/// @param {array} _mat The inverse world * view * projection matrix.
function ce_vec3_unproject(_v, _screen, _mat)
{
	gml_pragma("forceinline");
	var _vector = [
		(_v[0] / _screen[0]) * 2 - 1,
		1 - (_v[1] / _screen[1]) * 2,
		_v[2],
		1
	];
	ce_vec4_transform(_vector, _mat);
	_v[@ 0] = _vector[0];
	_v[@ 1] = _vector[1];
	_v[@ 2] = _vector[2];
}