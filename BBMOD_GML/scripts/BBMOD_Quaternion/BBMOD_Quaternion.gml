/// @func BBMOD_Quaternion([_x, _y, _z, _w])
/// @desc A quaternion.
/// @param {real} [_x] The first component of the quaternion.
/// @param {real} [_y] The second component of the quaternion.
/// @param {real} [_z] The third component of the quaternion.
/// @param {real} [_w] The fourth component of the quaternion.
/// @note If the arguments are not specified, then an identity quaternion
/// is created.
function BBMOD_Quaternion(_x, _y, _z, _w) constructor
{
	var _makeIdentity = (_x == undefined);

	/// @var {real} The first component of the quaternion.
	X = _makeIdentity ? 0.0 : _x;

	/// @var {real} The second component of the quaternion.
	Y = _makeIdentity ? 0.0 : _y;

	/// @var {real} The third component of the quaternion.
	Z = _makeIdentity ? 0.0 : _z;

	/// @var {real} The fourth component of the quaternion.
	W = _makeIdentity ? 1.0 : _w;

	/// @func Add(_q)
	/// @desc Adds quaternions and returns the result as a new quaternion.
	/// @param {BBMOD_Quaternion} _dq The other quaternion.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Add = function (_q) {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			X + _q.X,
			Y + _q.Y,
			Z + _q.Z,
			W + _q.W,
		);
	};

	/// @func Clone()
	/// @desc Creates a clone of the quaternion.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Clone = function () {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(X, Y, Z, W);
	};

	/// @func Conjugate()
	/// @desc Conjugates the quaternion and returns the result as a quaternion.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Conjugate = function () {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(-X, -Y, -Z, W);
	};

	/// @func Copy(_dest)
	/// @desc Copies components of the quaternion into other quaternion.
	/// @param {BBMOD_Quaternion} _dq The destination quaternion.
	/// @return {BBMOD_Quaternion} Returns `self`.
	static Copy = function (_dest) {
		gml_pragma("forceinline");
		_dest.X = X;
		_dest.Y = Y;
		_dest.Z = Z;
		_dest.W = W;
		return self;
	};

	/// @func Dot(_q)
	/// @desc Computes a dot product of two dual quaternions.
	/// @para {BBMOD_Quaternion} _q The other quaternion.
	/// @return {real} The dot product of the quaternions.
	static Dot = function (_q) {
		gml_pragma("forceinline");
		return (
			  X * _q.X
			+ Y * _q.Y
			+ Z * _q.Z
			+ W * _q.W
		);
	};

	/// @func Exp()
	/// @desc Computes an exponential map of the quaternion and returns
	/// the result as a new quaternion.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Exp = function () {
		gml_pragma("forceinline");
		var _length = Length();
		if (_length >= math_get_epsilon())
		{
			var _sinc = Sinc(_length);
			return new BBMOD_Quaternion(
				X * _sinc,
				Y * _sinc,
				Z * _sinc,
				exp(W) * cos(_length),
			);
		}
		return new BBMOD_Quaternion(0.0, 0.0, 0.0, exp(W));
	};

	/// @func FromArray()
	/// @desc Loads quaternion components `[x, y, z, w]` from an array.
	/// @param {real[]} _array The array to read the quaternion components
	/// from.
	/// @param {uint} [_index] The index to start reading the quaternion
	/// components from. Defaults to 0.
	/// @return {BBMOD_Quaternion} Returns `self`.
	static FromArray = function (_array, _index) {
		gml_pragma("forceinline");
		_index = (_index != undefined) ? _index : 0;
		X = _array[_index];
		Y = _array[_index + 1];
		Z = _array[_index + 2];
		W = _array[_index + 3];
		return self;
	};

	/// @func FromAxisAngle(_axis, _angle)
	/// @desc Initializes the quaternion using an axis and an angle.
	/// @param {BBMOD_Vec3} _axis The axis of rotaiton.
	/// @param {real} _angle The rotation angle.
	/// @return {BBMOD_Quaternion} Returns `self`.
	static FromAxisAngle = function (_axis, _angle) {
		gml_pragma("forceinline");
		_angle = -_angle;
		var _sinHalfAngle = dsin(_angle * 0.5);
		X = _axis.X * _sinHalfAngle;
		Y = _axis.Y * _sinHalfAngle;
		Z = _axis.Z * _sinHalfAngle;
		W = dcos(_angle * 0.5);
		return self;
	};

	/// @func FromBuffer()
	/// @desc Loads quaternion components `[x, y, z, w]` from a buffer.
	/// @param {buffer} _buffer The buffer to read the quaternion components
	/// from.
	/// @param {int} [_type] The type of each component. Use one of the `buffer_`
	/// constants, e.g. `buffer_f32`.
	/// @return {BBMOD_Quaternion} Returns `self`.
	static FromBuffer = function (_buffer, _type) {
		gml_pragma("forceinline");
		X = buffer_read(_buffer, _type);
		Y = buffer_read(_buffer, _type);
		Z = buffer_read(_buffer, _type);
		W = buffer_read(_buffer, _type);
		return self;
	};

	/// @func FromLookRotation(_forward, _up)
	/// @desc Initializes the quaternion using a forward and an up vector. These
	/// vectors must not be parallel! If they are, the quaternion will be set to an
	/// identity.
	/// @param {BBMOD_Vec3} _forward The vector facing forward.
	/// @param {BBMOD_Vec3} _up The vector facing up.
	/// @return {BBMOD_Quaternion} Returns `self`.
	static FromLookRotation = function (_forward, _up) {
		gml_pragma("forceinline");

		_forward = _forward.Clone();
		_up = _up.Clone();

		if (!_forward.Orthonormalize(_up))
		{
			X = 0.0;
			Y = 0.0;
			Z = 0.0;
			W = 1.0;
			return self;
		}

		var _right = _up.Cross(_forward);
		var _w = sqrt(1.0 + _right.X + _up.Y + _forward.Z) * 0.5;
		var _w4Recip = 1.0 / (4.0 * _w);

		X = (_up.Z - _forward.Y) * _w4Recip;
		Y = (_forward.X - _right.Z) * _w4Recip;
		Z = (_right.Y - _up.X) * _w4Recip;
		W = _w;
		return self;
	};

	/// @func GetAngle()
	/// @desc Retrieves the rotation angle of the quaternion.
	/// @return {real} The rotation angle.
	static GetAngle = function () {
		gml_pragma("forceinline");
		return radtodeg(arccos(W) * 2.0);
	};

	/// @func GetAxis()
	/// @desc Retrieves the axis of rotation of the quaternion.
	/// @return {BBMOD_Vec3} The axis of rotation.
	static GetAxis = function () {
		gml_pragma("forceinline");
		var _sinThetaInv = 1.0 / sin(arccos(W));
		return new BBMOD_Vec3(
			X * _sinThetaInv,
			Y * _sinThetaInv,
			Z * _sinThetaInv,
		);
	};

	/// @func Inverse()
	/// @desc Computes an inverse of the quaternion and returns the result
	/// as a new quaternion.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Inverse = function () {
		gml_pragma("forceinline");
		return Conjugate().Scale(1.0 / Length());
	};

	/// @func Length()
	/// @desc Computes the length of the quaternion.
	/// @return {real} The length of the quaternion.
	static Length = function () {
		gml_pragma("forceinline");
		return sqrt(
			  X * X
			+ Y * Y
			+ Z * Z
			+ W * W
		);
	};

	/// @func LengthSqr()
	/// @desc Computes a squared length of the quaternion.
	/// @return {real} The squared length of the quaternion.
	static LengthSqr = function () {
		gml_pragma("forceinline");
		return (
			  X * X
			+ Y * Y
			+ Z * Z
			+ W * W
		);
	};

	/// @func Lerp(_q, _s)
	/// @desc Computes a linear interpolation of two quaternions
	/// and returns the result as a new quaternion.
	/// @param {BBMOD_Quaternion} _q The other quaternion.
	/// @param {real} _s The interpolation factor.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Lerp = function (_q, _s) {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			lerp(X, _q.X, _s),
			lerp(Y, _q.Y, _s),
			lerp(Z, _q.Z, _s),
			lerp(W, _q.W, _s),
		);
	};

	/// @func Log()
	/// @desc Computes the logarithm map of the quaternion and returns the
	/// result as a new quaternion.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Log = function () {
		gml_pragma("forceinline");
		var _length = Length();
		var _w = logn(2.71828, _length);
		var _a = arccos(W / _length);
		if (_a >= math_get_epsilon())
		{
			var _mag = 1.0 / _length / Sinc(_a);
			return new BBMOD_Quaternion(
				X * _mag,
				Y * _mag,
				Z * _mag,
				_w,
			);
		}
		return new BBMOD_Quaternion(0.0, 0.0, 0.0, _w);
	};

	/// @func Mul(_q)
	/// @desc Multiplies two quaternions and returns the result as a new
	/// quaternion.
	/// @param {BBMOD_Quaternion} _q The other quaternion.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Mul = function (_q) {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			W * _q.X + X * _q.W + Y * _q.Z - Z * _q.Y,
			W * _q.Y + Y * _q.W + Z * _q.X - X * _q.Z,
			W * _q.Z + Z * _q.W + X * _q.Y - Y * _q.X,
			W * _q.W - X * _q.X - Y * _q.Y - Z * _q.Z,
		);
	};

	/// @func Normalize()
	/// @desc Normalizes the quaternion and returns the result as a new
	/// quaternion.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Normalize = function () {
		gml_pragma("forceinline");
		var _lengthSqr = LengthSqr();
		if (_lengthSqr >= math_get_epsilon())
		{
			return Scale(1.0 / sqrt(_lengthSqr));
		}
		return Clone();
	};

	/// @func Rotate(_v)
	/// @desc Rotates a vector using the quaternion and returns the result
	/// as a new vector.
	/// @param {BBMOD_Vec3} _v The vector to rotate.
	/// @return {BBMOD_Vec3} The created vector.
	static Rotate = function (_v) {
		gml_pragma("forceinline");
		var _q = Normalize();
		var _V = new BBMOD_Quaternion(_v.X, _v.Y, _v.Z, 0.0);
		var _rot = _q.Mul(_V).Mul(_q.Conjugate());
		return new BBMOD_Vec3(_rot.X, _rot.Y, _rot.Z);
	};

	/// @func Scale(_s)
	/// @desc Scales each component of the quaternion by a real value and
	/// returns the result as a new quaternion.
	/// @param {real} _s The value to scale the quaternion by.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Scale = function (_s) {
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			X * _s,
			Y * _s,
			Z * _s,
			W * _s,
		);
	};

	static Sinc = function (_x) {
		gml_pragma("forceinline");
		return (_x >= math_get_epsilon()) ? (sin(_x) / _x) : 1.0;
	};

	/// @func Slerp(_q, _s)
	/// @desc Computes a spherical linear interpolation of two quaternions
	/// and returns the result as a new quaternion.
	/// @param {BBMOD_Quaternion} _dq The other quaternion.
	/// @param {real} _s The interpolation factor.
	/// @return {BBMOD_Quaternion} The created quaternion.
	static Slerp = function (_q, _s) {
		gml_pragma("forceinline");

		var _q10 = X;
		var _q11 = Y;
		var _q12 = Z;
		var _q13 = W;

		var _q20 = _q.X;
		var _q21 = _q.Y;
		var _q22 = _q.Z;
		var _q23 = _q.W;

		var _norm;

		_norm = 1.0 / sqrt(_q10 * _q10
			+ _q11 * _q11
			+ _q12 * _q12
			+ _q13 * _q13);

		_q10 *= _norm;
		_q11 *= _norm;
		_q12 *= _norm;
		_q13 *= _norm;

		_norm = sqrt(_q20 * _q20
			+ _q21 * _q21
			+ _q22 * _q22
			+ _q23 * _q23);

		_q20 *= _norm;
		_q21 *= _norm;
		_q22 *= _norm;
		_q23 *= _norm;

		var _dot = _q10 * _q20
			+ _q11 * _q21
			+ _q12 * _q22
			+ _q13 * _q23;

		if (_dot < 0.0)
		{
			_dot = -_dot;
			_q20 *= -1.0;
			_q21 *= -1.0;
			_q22 *= -1.0;
			_q23 *= -1.0;
		}

		if (_dot > 0.9995)
		{
			return new BBMOD_Quaternion(
				lerp(_q10, _q20, _s),
				lerp(_q11, _q21, _s),
				lerp(_q12, _q22, _s),
				lerp(_q13, _q23, _s),
			);
		}

		var _theta0 = arccos(_dot);
		var _theta = _theta0 * _s;
		var _sinTheta = sin(_theta);
		var _sinTheta0 = sin(_theta0);
		var _s2 = _sinTheta / _sinTheta0;
		var _s1 = cos(_theta) - (_dot * _s2);

		return new BBMOD_Quaternion(
			(_q10 * _s1) + (_q20 * _s2),
			(_q11 * _s1) + (_q21 * _s2),
			(_q12 * _s1) + (_q22 * _s2),
			(_q13 * _s1) + (_q23 * _s2),
		);
	};

	/// @func ToArray([_array[, _index]])
	/// @desc Writes components `[x, y, z, w]` of the quaternion into an array.
	/// @param {real[]} [_array] The destination array. If not defined, a new one
	/// is created.
	/// @param {uint} [_index] The index to start writing to. Defaults to 0.
	/// @return {real[]} Returns the destination array.
	static ToArray = function (_array, _index) {
		gml_pragma("forceinline");
		_array = (_array != undefined) ? _array : array_create(4, 0.0);
		_index = (_index != undefined) ? _index : 0;
		_array[@ _index]     = X;
		_array[@ _index + 1] = Y;
		_array[@ _index + 2] = Z;
		_array[@ _index + 3] = W;
		return _array;
	};

	/// @func ToMatrix([_dest[, _index]])
	/// @desc Converts quaternion into a matrix.
	/// @param {real[]} [_dest] The destination array. If not specified, a new one is
	/// created.
	/// @param {uint} [_index] The starting index in the destination array. Defaults
	/// to 0.
	/// @return {real[]} Returns the destination array.
	static ToMatrix = function (_dest, _index) {
		gml_pragma("forceinline");

		_dest = (_dest != undefined) ? _dest : array_create(16, 0.0);
		_index = (_index != undefined) ? _index : 0;

		var _temp0, _temp1, _temp2;
		var _q0 = X;
		var _q1 = Y;
		var _q2 = Z;
		var _q3 = W;

		_temp0 = _q0 * _q0;
		_temp1 = _q1 * _q1;
		_temp2 = _q2 * _q2;
		_dest[@ _index]      = 1.0 - 2.0 * (_temp1 + _temp2);
		_dest[@ _index + 5]  = 1.0 - 2.0 * (_temp0 + _temp2);
		_dest[@ _index + 10] = 1.0 - 2.0 * (_temp0 + _temp1);

		_temp0 = _q0 * _q1;
		_temp1 = _q3 * _q2;
		_dest[@ _index + 1] = 2.0 * (_temp0 + _temp1);
		_dest[@ _index + 4] = 2.0 * (_temp0 - _temp1);

		_temp0 = _q0 * _q2
		_temp1 = _q3 * _q1;
		_dest[@ _index + 2] = 2.0 * (_temp0 - _temp1);
		_dest[@ _index + 8] = 2.0 * (_temp0 + _temp1);

		_temp0 = _q1 * _q2;
		_temp1 = _q3 * _q0;
		_dest[@ _index + 6] = 2.0 * (_temp0 + _temp1);
		_dest[@ _index + 9] = 2.0 * (_temp0 - _temp1);

		return _dest;
	};
}