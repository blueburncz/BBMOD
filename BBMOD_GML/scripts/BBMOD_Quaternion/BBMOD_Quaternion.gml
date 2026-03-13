/// @module Base

/// @func BBMOD_Quaternion([_x, _y, _z, _w])
///
/// @desc A quaternion.
///
/// @param {Real} [_x] The first component of the quaternion. Defaults to 0.
/// @param {Real} [_y] The second component of the quaternion. Defaults to 0.
/// @param {Real} [_z] The third component of the quaternion. Defaults to 0.
/// @param {Real} [_w] The fourth component of the quaternion. Defaults to 1.
///
/// @note If you leave the arguments to their default values, then an identity
/// quaternion is created.
function BBMOD_Quaternion(_x = 0.0, _y = 0.0, _z = 0.0, _w = 1.0) constructor
{
	/// @var {Real} The first component of the quaternion.
	X = _x;

	/// @var {Real} The second component of the quaternion.
	Y = _y;

	/// @var {Real} The third component of the quaternion.
	Z = _z;

	/// @var {Real} The fourth component of the quaternion.
	W = _w;

	/// @func Add(_q)
	///
	/// @desc Adds quaternions and returns the result as a new quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Add = function (_q)
	{
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			X + _q.X,
			Y + _q.Y,
			Z + _q.Z,
			W + _q.W
		);
	};

	/// @func AddSelf(_q)
	///
	/// @desc Adds quaternions and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static AddSelf = function (_q)
	{
		gml_pragma("forceinline");
		X += _q.X;
		Y += _q.Y;
		Z += _q.Z;
		W += _q.W;
		return self;
	};

	/// @func Clone()
	///
	/// @desc Creates a clone of the quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Clone = function ()
	{
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(X, Y, Z, W);
	};

	/// @func Conjugate()
	///
	/// @desc Conjugates the quaternion and returns the result as a quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Conjugate = function ()
	{
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(-X, -Y, -Z, W);
	};

	/// @func ConjugateSelf()
	///
	/// @desc Conjugates the quaternion and stores the result into `self`.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static ConjugateSelf = function ()
	{
		gml_pragma("forceinline");
		X = -X;
		Y = -Y;
		Z = -Z;
		// W = W;
		return self;
	};

	/// @func Copy(_dest)
	///
	/// @desc Copies components of the quaternion into other quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _dest The destination quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static Copy = function (_dest)
	{
		gml_pragma("forceinline");
		_dest.X = X;
		_dest.Y = Y;
		_dest.Z = Z;
		_dest.W = W;
		return self;
	};

	/// @func Dot(_q)
	///
	/// @desc Computes a dot product of two dual quaternions.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	///
	/// @return {Real} The dot product of the quaternions.
	static Dot = function (_q)
	{
		gml_pragma("forceinline");
		return (
			X * _q.X
			+ Y * _q.Y
			+ Z * _q.Z
			+ W * _q.W
		);
	};

	/// @func Equals(_q)
	///
	/// @desc Checks whether this quaternion equals to quaternion `_q`.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The quaternion to compare to.
	///
	/// @return {Bool} Returns `true` if the two quaternions are equal.
	static Equals = function (_q)
	{
		gml_pragma("forceinline");
		return (
			X == _q.X
			&& Y == _q.Y
			&& Z == _q.Z
			&& W == _q.W
		);
	};

	/// @func Exp()
	///
	/// @desc Computes an exponential map of the quaternion and returns
	/// the result as a new quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Exp = function ()
	{
		gml_pragma("forceinline");
		var _length = sqrt(X * X + Y * Y + Z * Z + W * W);
		if (_length > math_get_epsilon())
		{
			var _expW = exp(W);
			var _sinc = sin(_length) / _length;
			return new BBMOD_Quaternion(
				X * _sinc * _expW,
				Y * _sinc * _expW,
				Z * _sinc * _expW,
				_expW * cos(_length)
			);
		}
		return new BBMOD_Quaternion(0.0, 0.0, 0.0, exp(W));
	};

	/// @func ExpSelf()
	///
	/// @desc Computes an exponential map of the quaternion and stores the
	/// result into `self`.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static ExpSelf = function ()
	{
		gml_pragma("forceinline");
		var _length = sqrt(X * X + Y * Y + Z * Z + W * W);
		if (_length > math_get_epsilon())
		{
			var _expW = exp(W);
			var _sinc = sin(_length) / _length;
			X *= _sinc * _expW;
			Y *= _sinc * _expW;
			Z *= _sinc * _expW;
			W = _expW * cos(_length);
			return self;
		}
		X = 0.0;
		Y = 0.0;
		Z = 0.0;
		W = exp(W);
		return self;
	};

	/// @func FromArray(_array[, _index])
	///
	/// @desc Loads quaternion components `(x, y, z, w)` from an array.
	///
	/// @param {Array<Real>} _array The array to read the quaternion components
	/// from.
	/// @param {Real} [_index] The index to start reading the quaternion
	/// components from. Defaults to 0.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static FromArray = function (_array, _index = 0)
	{
		gml_pragma("forceinline");
		X = _array[_index];
		Y = _array[_index + 1];
		Z = _array[_index + 2];
		W = _array[_index + 3];
		return self;
	};

	/// @func FromAxisAngle(_axis, _angle)
	///
	/// @desc Initializes the quaternion using an axis and an angle.
	///
	/// @param {Struct.BBMOD_Vec3} _axis The axis of rotation.
	///
	/// @param {Real} _angle The rotation angle.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static FromAxisAngle = function (_axis, _angle)
	{
		gml_pragma("forceinline");
		_angle = -_angle;
		var _sinHalfAngle = dsin(_angle * 0.5);
		X = _axis.X * _sinHalfAngle;
		Y = _axis.Y * _sinHalfAngle;
		Z = _axis.Z * _sinHalfAngle;
		W = dcos(_angle * 0.5);
		return self;
	};

	/// @func FromBuffer(_buffer, _type)
	///
	/// @desc Loads quaternion components `(x, y, z, w)` from a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to read the quaternion components
	/// from.
	///
	/// @param {Constant.BufferDataType} [_type] The type of each component.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static FromBuffer = function (_buffer, _type)
	{
		gml_pragma("forceinline");
		X = buffer_read(_buffer, _type);
		Y = buffer_read(_buffer, _type);
		Z = buffer_read(_buffer, _type);
		W = buffer_read(_buffer, _type);
		return self;
	};

	/// @func FromEuler(_x, _y, _z)
	///
	/// @desc Initializes the quaternion using euler angles.
	///
	/// @param {Real} _x The rotation around the X axis (in degrees).
	/// @param {Real} _y The rotation around the Y axis (in degrees).
	/// @param {Real} _z The rotation around the Z axis (in degrees).
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	///
	/// @note The order of rotations is YXZ, same as in the `matrix_build`
	/// function.
	static FromEuler = function (_x, _y, _z)
	{
		gml_pragma("forceinline");

		_x = -_x * 0.5;
		_y = -_y * 0.5;
		_z = -_z * 0.5;

		var _q1Sin, _q1Cos, _temp;
		var _qX, _qY, _qZ, _qW;

		_q1Sin = dsin(_z);
		_q1Cos = dcos(_z);

		_temp = dsin(_x);

		_qX = _q1Cos * _temp;
		_qY = _q1Sin * _temp;

		_temp = dcos(_x);

		_qZ = _q1Sin * _temp;
		_qW = _q1Cos * _temp;

		_q1Sin = dsin(_y);
		_q1Cos = dcos(_y);

		X = _qX * _q1Cos - _qZ * _q1Sin;
		Y = _qW * _q1Sin + _qY * _q1Cos;
		Z = _qZ * _q1Cos + _qX * _q1Sin;
		W = _qW * _q1Cos - _qY * _q1Sin;

		return self;
	};

	/// @func FromLookRotation(_forward, _up)
	///
	/// @desc Initializes the quaternion using a forward and an up vector. These
	/// vectors must not be parallel! If they are, the quaternion will be set to an
	/// identity.
	///
	/// @param {Struct.BBMOD_Vec3} _forward The vector facing forward.
	/// @param {Struct.BBMOD_Vec3} _up The vector facing up.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static FromLookRotation = function (_forward, _up)
	{
		gml_pragma("forceinline");

		var _fx = _forward.X;
		var _fy = _forward.Y;
		var _fz = _forward.Z;
		var _eps = math_get_epsilon();

		var _fLenSqr = _fx * _fx + _fy * _fy + _fz * _fz;
		if (_fLenSqr <= _eps)
		{
			X = 0.0;
			Y = 0.0;
			Z = 0.0;
			W = 1.0;
			return self;
		}
		var _fInvLen = 1.0 / sqrt(_fLenSqr);
		_fx *= _fInvLen;
		_fy *= _fInvLen;
		_fz *= _fInvLen;

		var _ux = _up.X;
		var _uy = _up.Y;
		var _uz = _up.Z;

		var _dotUF = _ux * _fx + _uy * _fy + _uz * _fz;
		_ux -= _fx * _dotUF;
		_uy -= _fy * _dotUF;
		_uz -= _fz * _dotUF;

		var _uLenSqr = _ux * _ux + _uy * _uy + _uz * _uz;
		if (_uLenSqr <= _eps)
		{
			X = 0.0;
			Y = 0.0;
			Z = 0.0;
			W = 1.0;
			return self;
		}
		var _uInvLen = 1.0 / sqrt(_uLenSqr);
		_ux *= _uInvLen;
		_uy *= _uInvLen;
		_uz *= _uInvLen;

		var _rightX = _uy * _fz - _uz * _fy;
		var _rightY = _uz * _fx - _ux * _fz;
		var _rightZ = _ux * _fy - _uy * _fx;

		var _trace = 1.0 + _rightX + _uy + _fz;
		if (_trace < _eps)
		{
			// Trace is too small, use alternative computation
			_trace = max(_trace, 0.0001);
		}
		var _w = sqrt(_trace) * 0.5;
		if (abs(_w) < _eps)
		{
			// W is too small, use fallback
			_w = _eps;
		}
		var _w4Recip = 1.0 / (4.0 * _w);

		X = (_uz - _fy) * _w4Recip;
		Y = (_fx - _rightZ) * _w4Recip;
		Z = (_rightY - _ux) * _w4Recip;
		W = _w;
		return self;
	};

	/// @func GetAngle()
	///
	/// @desc Retrieves the rotation angle of the quaternion.
	///
	/// @return {Real} The rotation angle.
	static GetAngle = function ()
	{
		gml_pragma("forceinline");
		return radtodeg(arccos(clamp(W, -1.0, 1.0)) * 2.0);
	};

	/// @func GetAxis()
	///
	/// @desc Retrieves the axis of rotation of the quaternion.
	///
	/// @return {Struct.BBMOD_Vec3} The axis of rotation.
	static GetAxis = function ()
	{
		gml_pragma("forceinline");
		var _sinTheta = sin(arccos(clamp(W, -1.0, 1.0)));
		if (abs(_sinTheta) < math_get_epsilon())
		{
			// Rotation angle is 0 or 180 degrees, axis is undefined
			return new BBMOD_Vec3(0.0, 0.0, 1.0);
		}
		var _sinThetaInv = 1.0 / _sinTheta;
		return new BBMOD_Vec3(
			X * _sinThetaInv,
			Y * _sinThetaInv,
			Z * _sinThetaInv
		);
	};

	/// @func Inverse()
	///
	/// @desc Computes an inverse of the quaternion and returns the result
	/// as a new quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Inverse = function ()
	{
		gml_pragma("forceinline");
		var _lenSqr = X * X + Y * Y + Z * Z + W * W;
		var _invLenSqr = 1.0 / _lenSqr;
		return new BBMOD_Quaternion(
			-X * _invLenSqr,
			-Y * _invLenSqr,
			-Z * _invLenSqr,
			W * _invLenSqr
		);
	};

	/// @func InverseSelf()
	///
	/// @desc Computes an inverse of the quaternion and stores the result into
	/// `self`.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static InverseSelf = function ()
	{
		gml_pragma("forceinline");
		var _invLenSqr = 1.0 / (X * X + Y * Y + Z * Z + W * W);
		X = -X * _invLenSqr;
		Y = -Y * _invLenSqr;
		Z = -Z * _invLenSqr;
		W *= _invLenSqr;
		return self;
	};

	/// @func Length()
	///
	/// @desc Computes the length of the quaternion.
	///
	/// @return {Real} The length of the quaternion.
	static Length = function ()
	{
		gml_pragma("forceinline");
		return sqrt(
			X * X
			+ Y * Y
			+ Z * Z
			+ W * W
		);
	};

	/// @func LengthSqr()
	///
	/// @desc Computes a squared length of the quaternion.
	///
	/// @return {Real} The squared length of the quaternion.
	static LengthSqr = function ()
	{
		gml_pragma("forceinline");
		return (
			X * X
			+ Y * Y
			+ Z * Z
			+ W * W
		);
	};

	/// @func Lerp(_q, _s)
	///
	/// @desc Computes a linear interpolation of two quaternions
	/// and returns the result as a new quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	/// @param {Real} _s The interpolation factor.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Lerp = function (_q, _s)
	{
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			lerp(X, _q.X, _s),
			lerp(Y, _q.Y, _s),
			lerp(Z, _q.Z, _s),
			lerp(W, _q.W, _s)
		);
	};

	/// @func LerpSelf(_q, _s)
	///
	/// @desc Computes a linear interpolation of two quaternions and stores the
	/// result into `self`.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	/// @param {Real} _s The interpolation factor.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static LerpSelf = function (_q, _s)
	{
		gml_pragma("forceinline");
		X = lerp(X, _q.X, _s);
		Y = lerp(Y, _q.Y, _s);
		Z = lerp(Z, _q.Z, _s);
		W = lerp(W, _q.W, _s);
		return self;
	};

	/// @func Log()
	///
	/// @desc Computes the logarithm map of the quaternion and returns the
	/// result as a new quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Log = function ()
	{
		gml_pragma("forceinline");
		var _length = sqrt(X * X + Y * Y + Z * Z + W * W);
		if (_length < math_get_epsilon())
		{
			// Zero quaternion, return zero
			return new BBMOD_Quaternion(0.0, 0.0, 0.0, -infinity);
		}
		var _w = logn(2.71828, _length);
		var _a = arccos(clamp(W / _length, -1.0, 1.0));
		if (_a > math_get_epsilon())
		{
			var _mag = _a / (_length * sin(_a));
			return new BBMOD_Quaternion(
				X * _mag,
				Y * _mag,
				Z * _mag,
				_w
			);
		}
		return new BBMOD_Quaternion(0.0, 0.0, 0.0, _w);
	};

	/// @func LogSelf()
	///
	/// @desc Computes the logarithm map of the quaternion and stores the result
	/// into `self`.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static LogSelf = function ()
	{
		gml_pragma("forceinline");
		var _length = sqrt(X * X + Y * Y + Z * Z + W * W);
		if (_length < math_get_epsilon())
		{
			// Zero quaternion, return zero
			X = 0.0;
			Y = 0.0;
			Z = 0.0;
			W = -infinity;
			return self;
		}
		var _w = logn(2.71828, _length);
		var _a = arccos(clamp(W / _length, -1.0, 1.0));
		if (_a > math_get_epsilon())
		{
			var _mag = _a / (_length * sin(_a));
			X *= _mag;
			Y *= _mag;
			Z *= _mag;
			W = _w;
			return self;
		}
		X = 0.0;
		Y = 0.0;
		Z = 0.0;
		W = _w;
		return self;
	};

	/// @func Mul(_q)
	///
	/// @desc Multiplies two quaternions and returns the result as a new
	/// quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Mul = function (_q)
	{
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			W * _q.X + X * _q.W + Y * _q.Z - Z * _q.Y,
			W * _q.Y + Y * _q.W + Z * _q.X - X * _q.Z,
			W * _q.Z + Z * _q.W + X * _q.Y - Y * _q.X,
			W * _q.W - X * _q.X - Y * _q.Y - Z * _q.Z
		);
	};

	/// @func MulSelf(_q)
	///
	/// @desc Multiplies two quaternions and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static MulSelf = function (_q)
	{
		gml_pragma("forceinline");
		var _x = W * _q.X + X * _q.W + Y * _q.Z - Z * _q.Y;
		var _y = W * _q.Y + Y * _q.W + Z * _q.X - X * _q.Z;
		var _z = W * _q.Z + Z * _q.W + X * _q.Y - Y * _q.X;
		var _w = W * _q.W - X * _q.X - Y * _q.Y - Z * _q.Z;
		X = _x;
		Y = _y;
		Z = _z;
		W = _w;
		return self;
	};

	/// @func Normalize()
	///
	/// @desc Normalizes the quaternion and returns the result as a new
	/// quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Normalize = function ()
	{
		gml_pragma("forceinline");
		var _lengthSqr = X * X + Y * Y + Z * Z + W * W;
		if (_lengthSqr > math_get_epsilon())
		{
			var _invLen = 1.0 / sqrt(_lengthSqr);
			return new BBMOD_Quaternion(
				X * _invLen,
				Y * _invLen,
				Z * _invLen,
				W * _invLen
			);
		}
		return new BBMOD_Quaternion(X, Y, Z, W);
	};

	/// @func NormalizeSelf()
	///
	/// @desc Normalizes the quaternion and stores the result into `self`.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self.
	static NormalizeSelf = function ()
	{
		gml_pragma("forceinline");
		var _lengthSqr = X * X + Y * Y + Z * Z + W * W;
		if (_lengthSqr > math_get_epsilon())
		{
			var _invLen = 1.0 / sqrt(_lengthSqr);
			X *= _invLen;
			Y *= _invLen;
			Z *= _invLen;
			W *= _invLen;
		}
		return self;
	};

	/// @func Rotate(_v)
	///
	/// @desc Rotates a vector using the quaternion and returns the result
	/// as a new vector.
	///
	/// @param {Struct.BBMOD_Vec3} _v The vector to rotate.
	///
	/// @return {Struct.BBMOD_Vec3} The created vector.
	///
	/// @note For best performance, the quaternion should be normalized.
	/// Normalizes the quaternion internally if needed.
	static Rotate = function (_v)
	{
		gml_pragma("forceinline");

		// Normalize first
		var _lenSqr = X * X + Y * Y + Z * Z + W * W;
		var _qx = X;
		var _qy = Y;
		var _qz = Z;
		var _qw = W;

		if (abs(_lenSqr - 1.0) > math_get_epsilon())
		{
			var _invLen = 1.0 / sqrt(_lenSqr);
			_qx *= _invLen;
			_qy *= _invLen;
			_qz *= _invLen;
			_qw *= _invLen;
		}

		// Optimized rotation: v' = v + q.w * t + cross(q.xyz, t)
		// where t = 2 * cross(q.xyz, v)
		var _vx = _v.X;
		var _vy = _v.Y;
		var _vz = _v.Z;

		// t = 2 * cross(q.xyz, v)
		var _tx = 2.0 * (_qy * _vz - _qz * _vy);
		var _ty = 2.0 * (_qz * _vx - _qx * _vz);
		var _tz = 2.0 * (_qx * _vy - _qy * _vx);

		// v' = v + q.w * t + cross(q.xyz, t)
		return new BBMOD_Vec3(
			_vx + _qw * _tx + (_qy * _tz - _qz * _ty),
			_vy + _qw * _ty + (_qz * _tx - _qx * _tz),
			_vz + _qw * _tz + (_qx * _ty - _qy * _tx)
		);
	};

	/// @func RotateOther(_v)
	///
	/// @desc Rotates a vector using the quaternion and stores the result into
	/// the vector.
	///
	/// @param {Struct.BBMOD_Vec3} _v The vector to rotate.
	///
	/// @return {Struct.BBMOD_Vec3} Returns vector `_v`.
	///
	/// @note For best performance, the quaternion should be normalized.
	/// Normalizes the quaternion internally if needed.
	static RotateOther = function (_v)
	{
		gml_pragma("forceinline");

		// Normalize first
		var _lenSqr = X * X + Y * Y + Z * Z + W * W;
		var _qx = X;
		var _qy = Y;
		var _qz = Z;
		var _qw = W;

		if (abs(_lenSqr - 1.0) > math_get_epsilon())
		{
			var _invLen = 1.0 / sqrt(_lenSqr);
			_qx *= _invLen;
			_qy *= _invLen;
			_qz *= _invLen;
			_qw *= _invLen;
		}

		// Optimized rotation: v' = v + q.w * t + cross(q.xyz, t)
		// where t = 2 * cross(q.xyz, v)
		var _vx = _v.X;
		var _vy = _v.Y;
		var _vz = _v.Z;

		// t = 2 * cross(q.xyz, v)
		var _tx = 2.0 * (_qy * _vz - _qz * _vy);
		var _ty = 2.0 * (_qz * _vx - _qx * _vz);
		var _tz = 2.0 * (_qx * _vy - _qy * _vx);

		// v' = v + q.w * t + cross(q.xyz, t)
		_v.X = _vx + _qw * _tx + (_qy * _tz - _qz * _ty);
		_v.Y = _vy + _qw * _ty + (_qz * _tx - _qx * _tz);
		_v.Z = _vz + _qw * _tz + (_qx * _ty - _qy * _tx);

		return _v;
	};

	/// @func Scale(_s)
	///
	/// @desc Scales each component of the quaternion by a real value and
	/// returns the result as a new quaternion.
	///
	/// @param {Real} _s The value to scale the quaternion by.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Scale = function (_s)
	{
		gml_pragma("forceinline");
		return new BBMOD_Quaternion(
			X * _s,
			Y * _s,
			Z * _s,
			W * _s
		);
	};

	/// @func ScaleSelf(_s)
	///
	/// @desc Scales each component of the quaternion by a real value and
	/// stores the result into `self`.
	///
	/// @param {Real} _s The value to scale the quaternion by.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static ScaleSelf = function (_s)
	{
		gml_pragma("forceinline");
		X *= _s;
		Y *= _s;
		Z *= _s;
		W *= _s;
		return self;
	};

	static Sinc = function (_x)
	{
		gml_pragma("forceinline");
		return (_x > math_get_epsilon()) ? (sin(_x) / _x) : 1.0;
	};

	/// @func Slerp(_q, _s)
	///
	/// @desc Computes a spherical linear interpolation of two quaternions
	/// and returns the result as a new quaternion.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	/// @param {Real} _s The interpolation factor.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static Slerp = function (_q, _s)
	{
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

		_norm = 1.0 / sqrt(_q20 * _q20
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
				lerp(_q13, _q23, _s)
			);
		}

		var _theta0 = arccos(_dot);
		var _theta = _theta0 * _s;
		var _sinTheta = sin(_theta);
		var _sinTheta0 = sin(_theta0);
		if (abs(_sinTheta0) < math_get_epsilon())
		{
			// Fallback to linear interpolation
			return new BBMOD_Quaternion(
				lerp(_q10, _q20, _s),
				lerp(_q11, _q21, _s),
				lerp(_q12, _q22, _s),
				lerp(_q13, _q23, _s)
			);
		}
		var _s2 = _sinTheta / _sinTheta0;
		var _s1 = cos(_theta) - (_dot * _s2);

		return new BBMOD_Quaternion(
			(_q10 * _s1) + (_q20 * _s2),
			(_q11 * _s1) + (_q21 * _s2),
			(_q12 * _s1) + (_q22 * _s2),
			(_q13 * _s1) + (_q23 * _s2)
		);
	};

	/// @func SlerpSelf(_q, _s)
	///
	/// @desc Computes a spherical linear interpolation of two quaternions
	/// and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_Quaternion} _q The other quaternion.
	/// @param {Real} _s The interpolation factor.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static SlerpSelf = function (_q, _s)
	{
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

		_norm = 1.0 / sqrt(_q20 * _q20
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
			X = lerp(_q10, _q20, _s);
			Y = lerp(_q11, _q21, _s);
			Z = lerp(_q12, _q22, _s);
			W = lerp(_q13, _q23, _s);
			return self;
		}

		var _theta0 = arccos(_dot);
		var _theta = _theta0 * _s;
		var _sinTheta = sin(_theta);
		var _sinTheta0 = sin(_theta0);
		if (abs(_sinTheta0) < math_get_epsilon())
		{
			// Fallback to linear interpolation
			X = lerp(_q10, _q20, _s);
			Y = lerp(_q11, _q21, _s);
			Z = lerp(_q12, _q22, _s);
			W = lerp(_q13, _q23, _s);
			return self;
		}
		var _s2 = _sinTheta / _sinTheta0;
		var _s1 = cos(_theta) - (_dot * _s2);

		X = (_q10 * _s1) + (_q20 * _s2);
		Y = (_q11 * _s1) + (_q21 * _s2);
		Z = (_q12 * _s1) + (_q22 * _s2);
		W = (_q13 * _s1) + (_q23 * _s2);
		return self;
	};

	/// @func ToArray([_array[, _index]])
	///
	/// @desc Writes components `(x, y, z, w)` of the quaternion into an array.
	///
	/// @param {Array<Real>} [_array] The destination array. If not defined, a
	/// new one is created.
	/// @param {Real} [_index] The index to start writing to. Defaults to 0.
	///
	/// @return {Array<Real>} Returns the destination array.
	static ToArray = function (_array = undefined, _index = 0)
	{
		gml_pragma("forceinline");
		_array ??= array_create(4, 0.0);
		_array[@ _index] = X;
		_array[@ _index + 1] = Y;
		_array[@ _index + 2] = Z;
		_array[@ _index + 3] = W;
		return _array;
	};

	/// @func ToBuffer(_buffer, _type)
	///
	/// @desc Writes the quaternion into a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the quaternion to.
	/// @param {Constant.BufferDataType} _type The type of each component.
	///
	/// @return {Struct.BBMOD_Quaternion} Returns `self`.
	static ToBuffer = function (_buffer, _type)
	{
		gml_pragma("forceinline");
		buffer_write(_buffer, _type, X);
		buffer_write(_buffer, _type, Y);
		buffer_write(_buffer, _type, Z);
		buffer_write(_buffer, _type, W);
		return self;
	};

	/// @func ToEuler([_array[, _index]])
	///
	/// @desc Retrieves euler angles from the quaternion.
	///
	/// @param {Array<Real>} [_array] An array to write the X,Y,Z angles to.
	/// If `undefined`, a new one is created.
	///
	/// @param {Real} [_index] The index to start writing at.
	///
	/// @return {Array<Real>} The destination array.
	static ToEuler = function (_array = undefined, _index = 0)
	{
		gml_pragma("forceinline");

		_array ??= array_create(3, 0.0);

		var _x = X;
		var _y = Y;
		var _z = Z;
		var _w = W;
		var _m6 = 2.0 * (_y * _z + _w * _x);

		var _thetaX;
		var _thetaY;
		var _thetaZ;

		if (_m6 < 1.0)
		{
			if (_m6 > -1.0)
			{
				_thetaX = arcsin(-_m6);
				_thetaY = arctan2(2.0 * (_x * _z - _w * _y), 1.0 - 2.0 * (_x * _x + _y * _y));
				_thetaZ = arctan2(2.0 * (_x * _y - _w * _z), 1.0 - 2.0 * (_x * _x + _z * _z));
			}
			else
			{
				_thetaX = pi * 0.5;
				_thetaY = -arctan2(-2.0 * (_x * _y + _w * _z), 1.0 - 2.0 * (_y * _y + _z * _z));
				_thetaZ = 0.0;
			}
		}
		else
		{
			_thetaX = -pi * 0.5;
			_thetaY = arctan2(-2.0 * (_x * _y + _w * _z), 1.0 - 2.0 * (_y * _y + _z * _z));
			_thetaZ = 0.0;
		}

		_array[@ _index] = (360.0 + radtodeg(_thetaX)) mod 360.0;
		_array[@ _index + 1] = (360.0 + radtodeg(_thetaY)) mod 360.0;
		_array[@ _index + 2] = (360.0 + radtodeg(_thetaZ)) mod 360.0;

		return _array;
	};

	/// @func ToMatrix([_dest[, _index]])
	///
	/// @desc Converts quaternion into a matrix.
	///
	/// @param {Array<Real>} [_dest] The destination array. If not specified, a
	/// new one is created.
	/// @param {Real} [_index] The starting index in the destination array.
	/// Defaults to 0.
	///
	/// @return {Array<Real>} Returns the destination array.
	static ToMatrix = function (_dest = undefined, _index = 0)
	{
		gml_pragma("forceinline");

		_dest ??= matrix_build_identity();

		var _temp0, _temp1, _temp2;
		var _q0 = X;
		var _q1 = Y;
		var _q2 = Z;
		var _q3 = W;

		_temp0 = _q0 * _q0;
		_temp1 = _q1 * _q1;
		_temp2 = _q2 * _q2;
		_dest[@ _index] = 1.0 - 2.0 * (_temp1 + _temp2);
		_dest[@ _index + 5] = 1.0 - 2.0 * (_temp0 + _temp2);
		_dest[@ _index + 10] = 1.0 - 2.0 * (_temp0 + _temp1);

		_temp0 = _q0 * _q1;
		_temp1 = _q3 * _q2;
		_dest[@ _index + 1] = 2.0 * (_temp0 + _temp1);
		_dest[@ _index + 4] = 2.0 * (_temp0 - _temp1);

		_temp0 = _q0 * _q2;
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
