CE_PRAGMA_ONCE;

/// @func ce_quaternion_create(_x, _y, _z, _w)
/// @desc Creates a quaternion.
/// @param {real} _x The x component of the quaternion.
/// @param {real} _y The y component of the quaternion.
/// @param {real} _z The z component of the quaternion.
/// @param {real} _w The w component of the quaternion.
/// @return {array} The created quaternion.
function ce_quaternion_create(_x, _y, _z, _w)
{
	gml_pragma("forceinline");
	return [_x, _y, _z, _w];
}

/// @func ce_quaternion_add(_q1, _q2)
/// @desc Adds the quaternions `_q1`, `_q2` and stores the result to `_q1`.
/// @param {array} _q1 The first quaternion.
/// @param {array} _q2 The second quaternion.
function ce_quaternion_add(_q1, _q2)
{
	_q1[@ 0] += _q2[0];
	_q1[@ 1] += _q2[1];
	_q1[@ 2] += _q2[2];
	_q1[@ 3] += _q2[3];
}

/// @func ce_quaternion_clone(_q)
/// @desc Creates a clone of the quaternion.
/// @param {array} _q The quaternion.
/// @return {array} The created quaternion.
function ce_quaternion_clone(_q)
{
	gml_pragma("forceinline");
	var _clone = array_create(4, 0);
	array_copy(_clone, 0, _q, 0, 4);
	return _clone;
}

/// @func ce_quaternion_conjugate(_q)
/// @desc Conjugates the quaternion.
/// @param {array} _q The quaternion.
function ce_quaternion_conjugate(_q)
{
	_q[@ 0] = -_q[0];
	_q[@ 1] = -_q[1];
	_q[@ 2] = -_q[2];
}

/// @func ce_quaternion_create_from_axisangle(_axis, _angle)
/// @desc Creates a quaternion form the axis an the angle.
/// @param {array} _axis A 3D vector representing the axis.
/// @param {real} _angle The angle in degrees.
/// @return {array} The created quaternion.
function ce_quaternion_create_from_axisangle(_axis, _angle)
{
	var _sin_half_angle = -dsin(_angle * 0.5);
	return [
		_axis[0] * _sin_half_angle,
		_axis[1] * _sin_half_angle,
		_axis[2] * _sin_half_angle,
		dcos(_angle * 0.5)
	];
}

/// @func ce_quaternion_create_fromto_rotation(_from, _to)
/// @desc Creates a quaternion that represents rotation from one vector to
/// another.
/// @param {array} _from The 3D "from" vector.
/// @param {array} _to The 3D "to" vector.
/// @return {array} The created quaternion.
function ce_quaternion_create_fromto_rotation(_from, _to)
{
	var _dot = ce_vec3_dot(_from, _to);
	var _axis;
	if (_dot <= math_get_epsilon() - 1)
	{
		_axis = [1, 0, 0];
		ce_vec3_cross(_axis, _from);
		if (ce_vec3_length(_axis) < math_get_epsilon())
		{
			_axis = [0, 1, 0];
			ce_vec3_cross(_axis, _from);
		}
		ce_vec3_normalize(_axis);
		return ce_quaternion_create_from_axisangle(_axis, 180);
	}
	if (_dot >= 1 - math_get_epsilon())
	{
		return ce_quaternion_create_identity();
	}
	_axis = ce_vec3_clone(_from);
	ce_vec3_cross(_axis, _to);
	var _quat = ce_quaternion_create(_axis[0], _axis[1], _axis[2], 1 + _dot);
	ce_quaternion_normalize(_quat);
	return _quat;
}

/// @func ce_quaternion_create_identity()
/// @desc Creates an identity quaternion.
/// @return {array} The created identity quaternion.
function ce_quaternion_create_identity()
{
	gml_pragma("forceinline");
	return [0, 0, 0, 1];
}

/// @func ce_quaternion_create_look_rotation(_forward, _up)
/// @desc Creates a quaternion with the specified forward and up vectors. These
/// vectors must not be parallel! If they are, then an identity quaternion
/// will be returned.
/// @param {array} _forward The 3D forward unit vector.
/// @param {array} _up The 3D up unit vector.
/// @return {array} An array representing the quaternion.
/// @source https://www.gamedev.net/forums/topic/613595-quaternion-lookrotationlookat-up/4876913/
function ce_quaternion_create_look_rotation(_forward, _up)
{
	ce_vec3_orthonormalize(_forward, _up);
	var _right = ce_vec3_clone(_up);
	ce_vec3_cross(_right, _forward);

	var _m00 = _right[0];
	var _m01 = _up[0];
	var _m02 = _forward[0];

	var _m10 = _right[1];
	var _m11 = _up[1];
	var _m12 = _forward[1];

	var _m20 = _right[2];
	var _m21 = _up[2];
	var _m22 = _forward[2];

	var _w = sqrt(1 + _m00 + _m11 + _m22) * 0.5;
	var _w4_recip = 1 / (4 * _w);

	return ce_quaternion_create(
		(_m21 - _m12) * _w4_recip,
		(_m02 - _m20) * _w4_recip,
		(_m10 - _m01) * _w4_recip,
		_w);
}

/// @func ce_quaternion_dot(_q1, _q2)
/// @desc Gets the dot product of the two quaternions.
/// @param {array} _q1 The first quaternion.
/// @param {array} _q2 The second quaternion.
/// @return {real} The dot product of the two quaternions.
function ce_quaternion_dot(_q1, _q2)
{
	gml_pragma("forceinline");
	return (_q1[0] * _q2[0]
		+ _q1[1] * _q2[1]
		+ _q1[2] * _q2[2]
		+ _q1[3] * _q2[3]);
}

/// @func ce_quaternion_inverse(_q)
/// @desc Inverts the quaternion.
/// @param {array} _q The quaternion.
function ce_quaternion_inverse(_q)
{
	ce_quaternion_conjugate(_q);
	var _n = 1 / ce_quaternion_length(_q);
	ce_quaternion_scale(_q, _n);
}

/// @func ce_quaternion_length(_q)
/// @desc Gets the length of the quaternion.
/// @param {array} _q The quaternion.
/// @return {real} The length of the quaternion.
function ce_quaternion_length(_q)
{
	gml_pragma("forceinline");
	var _q0 = _q[0];
	var _q1 = _q[1];
	var _q2 = _q[2];
	var _q3 = _q[3];
	return sqrt(_q0 * _q0
		+ _q1 * _q1
		+ _q2 * _q2
		+ _q3 * _q3);
}

/// @func ce_quaternion_lengthsqr(_q)
/// @desc Gets the squared length of the quaternion.
/// @param {array} _q An array representing the quaternion.
/// @return {real} The squared length of the quaternion.
function ce_quaternion_lengthsqr(_q) {
	gml_pragma("forceinline");
	var _q0 = _q[0];
	var _q1 = _q[1];
	var _q2 = _q[2];
	var _q3 = _q[3];
	return (_q0 * _q0
		+ _q1 * _q1
		+ _q2 * _q2
		+ _q3 * _q3);
}

/// @func ce_quaternion_lerp(_q1, _q2, _s)
/// @desc Performs a linear interpolation between the quaternions `_q1`, `_q2`
/// and stores the result to `_q1`.
/// @param {array} _q1 The first quaternion.
/// @param {array} _q2 The second quaternion.
/// @param {real} _s The lerping factor.
function ce_quaternion_lerp(_q1, _q2, _s)
{
	_q1[@ 0] = lerp(_q1[0], _q2[0], _s);
	_q1[@ 1] = lerp(_q1[1], _q2[1], _s);
	_q1[@ 2] = lerp(_q1[2], _q2[2], _s);
	_q1[@ 3] = lerp(_q1[3], _q2[3], _s);
}

/// @func ce_quaternion_multiply(_q1, _q2)
/// @desc Multiplies the quaternions `_q1`, `_q2` and stores the result to `_q1`.
/// @param {array} _q1 The first quaternion.
/// @param {array} _q2 The second quaternion.
function ce_quaternion_multiply(_q1, _q2)
{
	var _q10 = _q1[0];
	var _q11 = _q1[1];
	var _q12 = _q1[2];
	var _q13 = _q1[3];
	var _q20 = _q2[0];
	var _q21 = _q2[1];
	var _q22 = _q2[2];
	var _q23 = _q2[3];

	_q1[@ 0] = _q11 * _q22 - _q12 * _q21
		+ _q13 * _q20 + _q10 * _q23;
	_q1[@ 1] = _q12 * _q20 - _q10 * _q22
		+ _q13 * _q21 + _q11 * _q23;
	_q1[@ 2] = _q10 * _q21 - _q11 * _q20
		+ _q13 * _q22 + _q12 * _q23;
	_q1[@ 3] = _q13 * _q23 - _q10 * _q20
		- _q11 * _q21 - _q12 * _q22;
}

/// @func ce_quaternion_normalize(_q)
/// @desc Normalizes the quaternion.
/// @param {array} _q The quaternion.
function ce_quaternion_normalize(_q)
{
	var _length_sqr = ce_quaternion_lengthsqr(_q);
	if (_length_sqr <= 0)
	{
		return;
	}
	var _n = 1 / sqrt(_length_sqr);
	_q[@ 0] *= _n;
	_q[@ 1] *= _n;
	_q[@ 2] *= _n;
	_q[@ 3] *= _n;
}

/// @func ce_quaternion_rotate(_q, _v)
/// @desc Rotates the 3D vector by the quaternion.
/// @param {array} _q The quaternion.
/// @param {array} _v The 3D vector.
function ce_quaternion_rotate(_q, _v)
{
	var _clone = ce_quaternion_clone(_q);
	ce_quaternion_normalize(_clone);
	var _V = ce_quaternion_create(_v[0], _v[1], _v[2], 0);
	var _conjugate = ce_quaternion_clone(_clone);
	ce_quaternion_conjugate(_clone);
	var _rot = ce_quaternion_clone(_clone);
	ce_quaternion_multiply(_rot, _V);
	ce_quaternion_multiply(_rot, _conjugate);
	_v[@ 0] = _rot[0];
	_v[@ 1] = _rot[1];
	_v[@ 2] = _rot[2];
}

/// @func ce_quaternion_scale(_q, _s)
/// @desc Scales a quaternion by the value.
/// @param {array} _q The quaternion.
/// @param {real} _s The value to scale the quaternion by.
function ce_quaternion_scale(_q, _s)
{
	_q[@ 0] *= _s;
	_q[@ 1] *= _s;
	_q[@ 2] *= _s;
	_q[@ 3] *= _s;
}

/// @func ce_quaternion_slerp(_q1, _q2, _s)
/// @desc Performs a spherical linear interpolation between the quaternions
/// `_q1`, `_q2` and stores the result to `_q1`.
/// @param {array} _q1 The first quaternion.
/// @param {array} _q2 The second quaternion.
/// @param {real} _s The slerping factor.
/// @source https://en.wikipedia.org/wiki/Slerp#Source_code
function ce_quaternion_slerp(_q1, _q2, _s)
{
	var _q10 = _q1[0];
	var _q11 = _q1[1];
	var _q12 = _q1[2];
	var _q13 = _q1[3];

	var _q20 = _q2[0];
	var _q21 = _q2[1];
	var _q22 = _q2[2];
	var _q23 = _q2[3];

	var _q1norm = 1 / sqrt(_q10 * _q10
		+ _q11 * _q11
		+ _q12 * _q12
		+ _q13 * _q13);

	_q10 *= _q1norm;
	_q11 *= _q1norm;
	_q12 *= _q1norm;
	_q13 *= _q1norm;

	var _q2norm = sqrt(_q20 * _q20
		+ _q21 * _q21
		+ _q22 * _q22
		+ _q23 * _q23);

	_q20 *= _q2norm;
	_q21 *= _q2norm;
	_q22 *= _q2norm;
	_q23 *= _q2norm;

	var _dot = _q10 * _q20
		+ _q11 * _q21
		+ _q12 * _q22
		+ _q13 * _q23;

	if (_dot < 0)
	{
		_dot = -_dot;
		_q20 *= -1;
		_q21 *= -1;
		_q22 *= -1;
		_q23 *= -1;
	}

	if (_dot > 0.9995)
	{
		_q1[@ 0] = lerp(_q10, _q20, _s);
		_q1[@ 1] = lerp(_q11, _q21, _s);
		_q1[@ 2] = lerp(_q12, _q22, _s);
		_q1[@ 3] = lerp(_q13, _q23, _s);
	}
	else
	{
		var _theta_0 = arccos(_dot);
		var _theta = _theta_0 * _s;
		var _sin_theta = sin(_theta);
		var _sin_theta_0 = sin(_theta_0);
		var _s2 = _sin_theta / _sin_theta_0;
		var _s1 = cos(_theta) - (_dot * _s2);

		_q1[@ 0] = (_q10 * _s1) + (_q20 * _s2);
		_q1[@ 1] = (_q11 * _s1) + (_q21 * _s2);
		_q1[@ 2] = (_q12 * _s1) + (_q22 * _s2);
		_q1[@ 3] = (_q13 * _s1) + (_q23 * _s2);
	}
}

/// @func ce_quaternion_subtract(q1, _q2)
/// @desc Subtracts quaternion `_q2` from `_q1` and stores the result into `_q1`.
/// @param {array} _q1 The quaternion to subtract from.
/// @param {array} _q2 The quaternion to subtract.
function ce_quaternion_subtract(_q1, _q2)
{
	_q1[@ 0] -= _q2[0];
	_q1[@ 1] -= _q2[1];
	_q1[@ 2] -= _q2[2];
	_q1[@ 3] -= _q2[3];
}

/// @func ce_quaternion_to_angle(_q)
/// @desc Gets quaternion angle in degrees.
/// @param {array} _q The quaternion.
/// @return {real} The quaternion angle in degrees.
function ce_quaternion_to_angle(_q)
{
	gml_pragma("forceinline");
	return radtodeg(arccos(_q[3]) * 2);
}

/// @func ce_quaternion_to_axis(_q)
/// @desc Creates 3D axis from the quaternion.
/// @param {array} _q The quaternion.
/// @return {array} The created axis as `[x, y, z]`.
function ce_quaternion_to_axis(_q)
{
	var _sin_theta_inv = 1 / sin(arccos(_q[3]));
	return [
		_q[0] * _sin_theta_inv,
		_q[1] * _sin_theta_inv,
		_q[2] * _sin_theta_inv
	];
}

/// @func ce_quaternion_to_matrix(_q)
/// @desc Creates a rotation matrix from the quaternion.
/// @param {array} _q The quaternion.
/// @return {array} The created rotation matrix.
function ce_quaternion_to_matrix(_q)
{
	gml_pragma("forceinline");
	var _q0 = _q[0];
	var _q1 = _q[1];
	var _q2 = _q[2];
	var _q3 = _q[3];
	var _q0sqr = _q0 * _q0;
	var _q1sqr = _q1 * _q1;
	var _q2sqr = _q2 * _q2;
	var _q0q1 = _q0 * _q1;
	var _q0q2 = _q0 * _q2
	var _q3q2 = _q3 * _q2;
	var _q1q2 = _q1 * _q2;
	var _q3q0 = _q3 * _q0;
	var _q3q1 = _q3 * _q1;
	return [
		1 - 2 * (_q1sqr + _q2sqr), 2 * (_q0q1 + _q3q2), 2 * (_q0q2 - _q3q1), 0,
		2 * (_q0q1 - _q3q2), 1 - 2 * (_q0sqr + _q2sqr), 2 * (_q1q2 + _q3q0), 0,
		2 * (_q0q2 + _q3q1), 2 * (_q1q2 - _q3q0), 1 - 2 * (_q0sqr + _q1sqr), 0,
		0, 0, 0, 1
	];
}