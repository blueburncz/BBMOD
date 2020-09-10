CE_PRAGMA_ONCE;

/// @func ce_matrix_create(_m00, _m01, _m02, _m03, _m10, _m11, _m12, _m13, _m20, _m21, _m22, _m23, _m30, _m31, _m32, _m33)
/// @desc Creates a matrix with given components.
/// @param {real} _m00.._m03 The first row of the matrix.
/// @param {real} _m10.._m13 The second row of the matrix.
/// @param {real} _m20.._m23 The third row of the matrix.
/// @param {real} _m30.._m33 The fourth row of the matrix.
/// @return {array} The created matrix.
function ce_matrix_create(
	_m00, _m01, _m02, _m03,
	_m10, _m11, _m12, _m13,
	_m20, _m21, _m22, _m23,
	_m30, _m31, _m32, _m33)
{
	gml_pragma("forceinline");
	return [
		_m00, _m01, _m02, _m03,
		_m10, _m11, _m12, _m13,
		_m20, _m21, _m22, _m23,
		_m30, _m31, _m32, _m33
	];
}

/// @func ce_matrix_add_componentwise(_m1, _m2)
/// @desc Adds matrices `_m1`, `_m2` componentwise and stores the result to `_m1`.
/// @param {array} _m1 The first matrix.
/// @param {array} _m2 The second matrix.
function ce_matrix_add_componentwise(_m1, _m2)
{
	gml_pragma("forceinline");
	_m1[@ 0] += _m2[@ 0];
	_m1[@ 1] += _m2[@ 1];
	_m1[@ 2] += _m2[@ 2];
	_m1[@ 3] += _m2[@ 3];
	_m1[@ 4] += _m2[@ 4];
	_m1[@ 5] += _m2[@ 5];
	_m1[@ 6] += _m2[@ 6];
	_m1[@ 7] += _m2[@ 7];
	_m1[@ 8] += _m2[@ 8];
	_m1[@ 9] += _m2[@ 9];
	_m1[@ 10] += _m2[@ 10];
	_m1[@ 11] += _m2[@ 11];
	_m1[@ 12] += _m2[@ 12];
	_m1[@ 13] += _m2[@ 13];
	_m1[@ 14] += _m2[@ 14];
	_m1[@ 15] += _m2[@ 15];
}

/// @func ce_matrix_build_lookat(_from, _to, _up)
/// @desc Builds a look-at matrix from given vec3.
/// @param {array} _from Camera's position vector.
/// @param {array} _to Camera's target position.
/// @param {array} _up Camera's up vector.
/// @return {array} The created matrix.
function ce_matrix_build_lookat(_from, _to, _up)
{
	gml_pragma("forceinline");
	return matrix_build_lookat(
		_from[0], _from[1], _from[2],
		_to[0], _to[1], _to[2],
		_up[0], _up[1], _up[2]);
}

/// @func ce_matrix_clone(_m)
/// @desc Creates a clone of the matrix.
/// @param {array} _m The matrix to create a clone of.
/// @return {array} The created matrix.
function ce_matrix_clone(_m)
{
	gml_pragma("forceinline");
	var _clone = array_create(16, 0);
	array_copy(_clone, 0, _m, 0, 16);
	return _clone;
}

/// @func ce_matrix_create_from_columns(_c0, _c1, _c2, _c3)
/// @desc Creates a matrix with specified columns.
/// @param {array} _c0 The first column of the matrix.
/// @param {array} _c1 The second column of the matrix.
/// @param {array} _c2 The third column of the matrix.
/// @param {array} _c3 The fourth column of the matrix.
/// @return {array} The created matrix.
function ce_matrix_create_from_columns(_c0, _c1, _c2, _c3)
{
	gml_pragma("forceinline");
	return [
		_c0[0], _c0[1], _c0[2], _c0[3],
		_c1[0], _c1[1], _c1[2], _c1[3],
		_c2[0], _c2[1], _c2[2], _c2[3],
		_c3[0], _c3[1], _c3[2], _c3[3]
	];
}

/// @func ce_matrix_create_from_rows(_r0, _r1, _r2, _r3)
/// @desc Creates a matrix with specified rows.
/// @param {array} _r0 The first row of the matrix.
/// @param {array} _r1 The second row of the matrix.
/// @param {array} _r2 The third row of the matrix.
/// @param {array} _r3 The fourth row of the matrix.
/// @return {array} The created matrix.
function ce_matrix_create_from_rows(_r0, _r1, _r2, _r3)
{
	gml_pragma("forceinline");
	return [
		_r0[0], _r1[0], _r2[0], _r3[0],
		_r0[1], _r1[1], _r2[1], _r3[1],
		_r0[2], _r1[2], _r2[2], _r3[2],
		_r0[3], _r1[3], _r2[3], _r3[3]
	];
}

/// @func ce_matrix_determinant(_m)
/// @desc Gets the determinant of the matrix.
/// @param {array} _m The matrix.
/// @return {real} The determinant of the matrix.
function ce_matrix_determinant(_m)
{
	gml_pragma("forceinline");
	var _m0 = _m[0];
	var _m1 = _m[1];
	var _m2 = _m[2];
	var _m3 = _m[3];
	var _m4 = _m[4];
	var _m5 = _m[5];
	var _m6 = _m[6];
	var _m7 = _m[7];
	var _m8 = _m[8];
	var _m9 = _m[9];
	var _m10 = _m[10];
	var _m11 = _m[11];
	var _m12 = _m[12];
	var _m13 = _m[13];
	var _m14 = _m[14];
	var _m15 = _m[15];
	return(_m3*_m6*_m9*_m12-_m2*_m7*_m9*_m12-_m3*_m5*_m10*_m12+_m1*_m7*_m10*_m12
		+_m2*_m5*_m11*_m12-_m1*_m6*_m11*_m12-_m3*_m6*_m8*_m13+_m2*_m7*_m8*_m13
		+_m3*_m4*_m10*_m13-_m0*_m7*_m10*_m13-_m2*_m4*_m11*_m13+_m0*_m6*_m11*_m13
		+_m3*_m5*_m8*_m14-_m1*_m7*_m8*_m14-_m3*_m4*_m9*_m14+_m0*_m7*_m9*_m14
		+_m1*_m4*_m11*_m14-_m0*_m5*_m11*_m14-_m2*_m5*_m8*_m15+_m1*_m6*_m8*_m15
		+_m2*_m4*_m9*_m15-_m0*_m6*_m9*_m15-_m1*_m4*_m10*_m15+_m0*_m5*_m10*_m15);
}

/// @func ce_matrix_inverse(_m)
/// @desc Inverts the matrix.
/// @param {array} _m The matrix.
function ce_matrix_inverse(_m)
{
	gml_pragma("forceinline");
	var _s = 1 / ce_matrix_determinant(_m);
	var _m0 = _m[0];
	var _m1 = _m[1];
	var _m2 = _m[2];
	var _m3 = _m[3];
	var _m4 = _m[4];
	var _m5 = _m[5];
	var _m6 = _m[6];
	var _m7 = _m[7];
	var _m8 = _m[8];
	var _m9 = _m[9];
	var _m10 = _m[10];
	var _m11 = _m[11];
	var _m12 = _m[12];
	var _m13 = _m[13];
	var _m14 = _m[14];
	var _m15 = _m[15];
	_m[@ 0] = _s * (_m6 * _m11 * _m13 - _m7 * _m10 * _m13 + _m7 * _m9 * _m14 - _m5 * _m11 * _m14 - _m6 * _m9 * _m15 + _m5 * _m10 * _m15);
	_m[@ 1] = _s * (_m3 * _m10 * _m13 - _m2 * _m11 * _m13 - _m3 * _m9 * _m14 + _m1 * _m11 * _m14 + _m2 * _m9 * _m15 - _m1 * _m10 * _m15);
	_m[@ 2] = _s * (_m2 * _m7 * _m13 - _m3 * _m6 * _m13 + _m3 * _m5 * _m14 - _m1 * _m7 * _m14 - _m2 * _m5 * _m15 + _m1 * _m6 * _m15);
	_m[@ 3] = _s * (_m3 * _m6 * _m9 - _m2 * _m7 * _m9 - _m3 * _m5 * _m10 + _m1 * _m7 * _m10 + _m2 * _m5 * _m11 - _m1 * _m6 * _m11);
	_m[@ 4] = _s * (_m7 * _m10 * _m12 - _m6 * _m11 * _m12 - _m7 * _m8 * _m14 + _m4 * _m11 * _m14 + _m6 * _m8 * _m15 - _m4 * _m10 * _m15);
	_m[@ 5] = _s * (_m2 * _m11 * _m12 - _m3 * _m10 * _m12 + _m3 * _m8 * _m14 - _m0 * _m11 * _m14 - _m2 * _m8 * _m15 + _m0 * _m10 * _m15);
	_m[@ 6] = _s * (_m3 * _m6 * _m12 - _m2 * _m7 * _m12 - _m3 * _m4 * _m14 + _m0 * _m7 * _m14 + _m2 * _m4 * _m15 - _m0 * _m6 * _m15);
	_m[@ 7] = _s * (_m2 * _m7 * _m8 - _m3 * _m6 * _m8 + _m3 * _m4 * _m10 - _m0 * _m7 * _m10 - _m2 * _m4 * _m11 + _m0 * _m6 * _m11);
	_m[@ 8] = _s * (_m5 * _m11 * _m12 - _m7 * _m9 * _m12 + _m7 * _m8 * _m13 - _m4 * _m11 * _m13 - _m5 * _m8 * _m15 + _m4 * _m9 * _m15);
	_m[@ 9] = _s * (_m3 * _m9 * _m12 - _m1 * _m11 * _m12 - _m3 * _m8 * _m13 + _m0 * _m11 * _m13 + _m1 * _m8 * _m15 - _m0 * _m9 * _m15);
	_m[@ 10] = _s * (_m1 * _m7 * _m12 - _m3 * _m5 * _m12 + _m3 * _m4 * _m13 - _m0 * _m7 * _m13 - _m1 * _m4 * _m15 + _m0 * _m5 * _m15);
	_m[@ 11] = _s * (_m3 * _m5 * _m8 - _m1 * _m7 * _m8 - _m3 * _m4 * _m9 + _m0 * _m7 * _m9 + _m1 * _m4 * _m11 - _m0 * _m5 * _m11);
	_m[@ 12] = _s * (_m6 * _m9 * _m12 - _m5 * _m10 * _m12 - _m6 * _m8 * _m13 + _m4 * _m10 * _m13 + _m5 * _m8 * _m14 - _m4 * _m9 * _m14);
	_m[@ 13] = _s * (_m1 * _m10 * _m12 - _m2 * _m9 * _m12 + _m2 * _m8 * _m13 - _m0 * _m10 * _m13 - _m1 * _m8 * _m14 + _m0 * _m9 * _m14);
	_m[@ 14] = _s * (_m2 * _m5 * _m12 - _m1 * _m6 * _m12 - _m2 * _m4 * _m13 + _m0 * _m6 * _m13 + _m1 * _m4 * _m14 - _m0 * _m5 * _m14);
	_m[@ 15] = _s * (_m1 * _m6 * _m8 - _m2 * _m5 * _m8 + _m2 * _m4 * _m9 - _m0 * _m6 * _m9 - _m1 * _m4 * _m10 + _m0 * _m5 * _m10);
}

/// @func ce_matrix_multiply_componentwise(_m1, _m2)
/// @desc Multiplies matrices `_m1`, `_m2` componentwise and stores the result to
/// `_m1`.
/// @param {array} _m1 The first matrix.
/// @param {array} _m2 The second matrix.
function ce_matrix_multiply_componentwise(_m1, _m2)
{
	gml_pragma("forceinline");
	_m1[@ 0] *= _m2[@ 0];
	_m1[@ 1] *= _m2[@ 1];
	_m1[@ 2] *= _m2[@ 2];
	_m1[@ 3] *= _m2[@ 3];
	_m1[@ 4] *= _m2[@ 4];
	_m1[@ 5] *= _m2[@ 5];
	_m1[@ 6] *= _m2[@ 6];
	_m1[@ 7] *= _m2[@ 7];
	_m1[@ 8] *= _m2[@ 8];
	_m1[@ 9] *= _m2[@ 9];
	_m1[@ 10] *= _m2[@ 10];
	_m1[@ 11] *= _m2[@ 11];
	_m1[@ 12] *= _m2[@ 12];
	_m1[@ 13] *= _m2[@ 13];
	_m1[@ 14] *= _m2[@ 14];
	_m1[@ 15] *= _m2[@ 15];
}

/// @func ce_matrix_scale(_m, _s)
/// @desc Scales the matrix by the value.
/// @param {array} _m The matrix to scale.
/// @param {real} _s The value to scale the matrix by.
function ce_matrix_scale(_m, _s)
{
	gml_pragma("forceinline");
	_m[@ 0] *= _s;
	_m[@ 1] *= _s;
	_m[@ 2] *= _s;
	_m[@ 3] *= _s;
	_m[@ 4] *= _s;
	_m[@ 5] *= _s;
	_m[@ 6] *= _s;
	_m[@ 7] *= _s;
	_m[@ 8] *= _s;
	_m[@ 9] *= _s;
	_m[@ 10] *= _s;
	_m[@ 11] *= _s;
	_m[@ 12] *= _s;
	_m[@ 13] *= _s;
	_m[@ 14] *= _s;
	_m[@ 15] *= _s;
}

/// @func ce_matrix_subtract_componentwise(_m1, _m2)
/// @desc Subtracts matrices `_m1`, `_m2` componentwise and stores the result to
/// `_m1`.
/// @param {array} _m1 The first matrix.
/// @param {array} _m2 The second matrix.
function ce_matrix_subtract_componentwise(_m1, _m2)
{
	gml_pragma("forceinline");
	_m1[@ 0] -= _m2[@ 0];
	_m1[@ 1] -= _m2[@ 1];
	_m1[@ 2] -= _m2[@ 2];
	_m1[@ 3] -= _m2[@ 3];
	_m1[@ 4] -= _m2[@ 4];
	_m1[@ 5] -= _m2[@ 5];
	_m1[@ 6] -= _m2[@ 6];
	_m1[@ 7] -= _m2[@ 7];
	_m1[@ 8] -= _m2[@ 8];
	_m1[@ 9] -= _m2[@ 9];
	_m1[@ 10] -= _m2[@ 10];
	_m1[@ 11] -= _m2[@ 11];
	_m1[@ 12] -= _m2[@ 12];
	_m1[@ 13] -= _m2[@ 13];
	_m1[@ 14] -= _m2[@ 14];
	_m1[@ 15] -= _m2[@ 15];
}

/// @func ce_matrix_to_euler(_m)
/// @desc Gets euler angles from the YXZ rotation matrix.
/// @param {array} _m The YXZ rotation matrix.
/// @return {array} An array containing the euler angles `[rot_x, rot_y, rot_z]`.
/// @source https://www.geometrictools.com/Documentation/EulerAngles.pdf
function ce_matrix_to_euler(_m)
{
	gml_pragma("forceinline");
	var _theta_x, _theta_y, _theta_z;
	var _m6 = _m[6];

	if (_m6 < 1)
	{
		if (_m6 > -1)
		{
			_theta_x = arcsin(-_m6);
			_theta_y = arctan2(_m[2], _m[10]);
			_theta_z = arctan2(_m[4], _m[5]);
		}
		else
		{
			_theta_x = pi * 0.5;
			_theta_y = -arctan2(-_m[1], _m[0]);
			_theta_z = 0;
		}
	}
	else
	{
		_theta_x = -pi * 0.5;
		_theta_y = arctan2(-_m[1], _m[0]);
		_theta_z = 0;
	}

	return [
		(360 + radtodeg(_theta_x)) mod 360,
		(360 + radtodeg(_theta_y)) mod 360,
		(360 + radtodeg(_theta_z)) mod 360
	];
}

/// @func ce_matrix_transpose(_m)
/// @desc Transposes the matrix.
/// @param {array} _m The matrix to be transposed.
function ce_matrix_transpose(_m)
{
	var _c = ce_matrix_clone(_m);
	_m[@ 0] = _c[ 0]; _m[@ 4] = _c[ 1]; _m[@ 8] = _c[ 2]; _m[@ 12] = _c[ 3];
	_m[@ 1] = _c[ 4]; _m[@ 5] = _c[ 5]; _m[@ 9] = _c[ 6]; _m[@ 13] = _c[ 7];
	_m[@ 2] = _c[ 8]; _m[@ 6] = _c[ 9]; _m[@ 10] = _c[10]; _m[@ 14] = _c[11];
	_m[@ 3] = _c[12]; _m[@ 7] = _c[13]; _m[@ 11] = _c[14]; _m[@ 15] = _c[15];
}