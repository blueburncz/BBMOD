/// @module Core

/// @func BBMOD_DualQuaternion([_x, _y, _z, _w, _dx, _dy, _dz, _dw])
///
/// @desc A dual quaternion.
///
/// @param {Real} [_x] The first component of the real part of the dual
/// quaternion. Defaults to 0.
/// @param {Real} [_y] The second component of the real part of the dual
/// quaternion. Defaults to 0.
/// @param {Real} [_z] The third component of the real part of the dual
/// quaternion. Defaults to 0.
/// @param {Real} [_w] The fourth component of the real part of the dual
/// quaternion. Defaults to 1.
/// @param {Real} [_dx] The first component of the dual part of the dual
/// quaternion. Defaults to 0.
/// @param {Real} [_dy] The second component of the dual part of the dual
/// quaternion. Defaults to 0.
/// @param {Real} [_dz] The third component of the dual part of the dual
/// quaternion. Defaults to 0.
/// @param {Real} [_dw] The fourth component of the dual part of the dual
/// quaternion. Defaults to 0.
///
/// @note If you leave all the arguments to their default values, an identity
/// dual quaternion is created.
function BBMOD_DualQuaternion(
	_x=0.0, _y=0.0, _z=0.0, _w=1.0,
	_dx=0.0, _dy=0.0, _dz=0.0, _dw=0.0) constructor
{
	/// @var {Struct.BBMOD_Quaternion} The real part of the dual quaternion.
	Real = new BBMOD_Quaternion(_x, _y, _z, _w);

	/// @var {Struct.BBMOD_Quaternion} The dual part of the dual quaternion.
	Dual = new BBMOD_Quaternion(_dx, _dy, _dz, _dw);

	/// @func Add(_dq)
	///
	/// @desc Adds dual quaternions and returns the result as a new dual
	/// quaternion.
	///
	/// @param {Struct.BBMOD_DualQuaternion} _dq The other dual quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Add = function (_dq)
	{
		gml_pragma("forceinline");
		return new BBMOD_DualQuaternion()
			.FromRealDual(
				Real.Add(_dq.Real),
				Dual.Add(_dq.Dual));
	};

	/// @func AddSelf(_dq)
	///
	/// @desc Adds dual quaternions and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_DualQuaternion} _dq The other dual quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static AddSelf = function (_dq)
	{
		gml_pragma("forceinline");
		Real.AddSelf(_dq.Real);
		Dual.AddSelf(_dq.Dual);
		return self;
	};

	/// @func Clone()
	///
	/// @desc Creates a clone of the dual quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Clone = function ()
	{
		gml_pragma("forceinline");
		var _dq = new BBMOD_DualQuaternion();
		_dq.Real = Real;
		_dq.Dual = Dual;
		return _dq;
	};

	/// @func Conjugate()
	///
	/// @desc Conjugates the dual quaternion and returns the result as a new
	/// dual quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Conjugate = function ()
	{
		gml_pragma("forceinline");
		return new BBMOD_DualQuaternion()
			.FromRealDual(
				Real.Conjugate(),
				Dual.Conjugate());
	};

	/// @func Copy(_dq)
	///
	/// @desc Copies components of the dual quaternion into other dual
	/// quaternion.
	///
	/// @param {Struct.BBMOD_DualQuaternion} _dest The destination dual
	/// quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static Copy = function (_dest)
	{
		gml_pragma("forceinline");
		_dest.Real = Real;
		_dest.Dual = Dual;
		return self;
	};

	/// @func Dot(_dq)
	///
	/// @desc Computes a dot product of two dual quaternions.
	///
	/// @param {Struct.BBMOD_DualQuaternion} _dq The other dual quaternion.
	///
	/// @return {Real} The dot product of the dual quaternions.
	static Dot = function (_dq)
	{
		gml_pragma("forceinline");
		return Real.Dot(_dq.Real);
	};

	/// @func Exp()
	///
	/// @desc Computes an exponential map of the dual quaternion and returns
	/// the result as a new dual quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Exp = function ()
	{
		gml_pragma("forceinline");
		var _real = Real.Exp();
		return new BBMOD_DualQuaternion()
			.FromRealDual(
				_real,
				_real.Mul(Dual));
	};

	/// @func ExpSelf()
	///
	/// @desc Computes an exponential map of the dual quaternion and stores the
	/// result into `self`.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static ExpSelf = function ()
	{
		gml_pragma("forceinline");
		var _real = Real.Exp();
		return FromRealDual(
			_real,
			_real.Mul(Dual));
	};

	/// @func FromArray(_array[, _index])
	///
	/// @desc Loads dual quaternion components `(rX, rY, rZ, rW, dX, dY, dZ, dW)`
	/// from an array.
	///
	/// @param {Array<Real>} _array The array to read the dual quaternion
	/// components from.
	/// @param {Real} [_index] The index to start reading the dual quaternion
	/// components from. Defaults to 0.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static FromArray = function (_array, _index=0)
	{
		gml_pragma("forceinline");
		Real = Real.FromArray(_array, _index);
		Dual = Dual.FromArray(_array, _index + 4);
		return self;
	};

	/// @func FromBuffer(_buffer, _type)
	///
	/// @desc Loads dual quaternion components `(rX, rY, rZ, rW, dX, dY, dZ, dW)`
	/// from a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to read the dual quaternion
	/// components from.
	///
	/// @param {Constant.BufferDataType} [_type] The type of each component.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static FromBuffer = function (_buffer, _type)
	{
		gml_pragma("forceinline");
		Real = Real.FromBuffer(_buffer, _type);
		Dual = Dual.FromBuffer(_buffer, _type);
		return self;
	};

	/// @func FromRealDual(_real, _dual)
	///
	/// @desc Initializes the dual quaternion using real and dual part.
	///
	/// @param {Struct.BBMOD_Quaternion} _real The real part of the dual
	/// quaternion.
	/// @param {Struct.BBMOD_Quaternion} _dual The dual part of the dual
	/// quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static FromRealDual = function (_real, _dual)
	{
		gml_pragma("forceinline");
		Real = _real.Normalize();
		Dual = _dual;
		return self;
	};

	/// @func FromTranslationRotation(_t, _r)
	///
	/// @desc Initializes the dual quaternion from translation and rotation
	/// (quaternion).
	///
	/// @param {Struct.BBMOD_Vec3} _t The translation.
	///
	/// @param {Struct.BBMOD_Quaternion} _r The rotation.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static FromTranslationRotation = function (_t, _r)
	{
		gml_pragma("forceinline");

		Real = _r.Normalize();

		//Dual = new BBMOD_Quaternion(_t.X, _t.Y, _t.Z, 0).Mul(Real).Scale(0.5);
		var _realX = Real.X;
		var _realY = Real.Y;
		var _realZ = Real.Z;
		var _realW = Real.W;

		var _tX = _t.X;
		var _tY = _t.Y;
		var _tZ = _t.Z;
		// var _tW = 0;

		Dual.X = (_tY * _realZ - _tZ * _realY
			/*+ _tW * _realX*/ + _tX * _realW) * 0.5;
		Dual.Y = (_tZ * _realX - _tX * _realZ
			/*+ _tW * _realY*/ + _tY * _realW) * 0.5;
		Dual.Z = (_tX * _realY - _tY * _realX
			/*+ _tW * _realZ*/ + _tZ * _realW) * 0.5;
		Dual.W = (/*_tW * _realW*/ - _tX * _realX
			- _tY * _realY - _tZ * _realZ) * 0.5;

		return self;
	};

	/// @func GetRotation()
	///
	/// @desc Extracts rotation (quaternion) from dual quaternion.
	///
	/// @return {Struct.BBMOD_Quaternion} The created quaternion.
	static GetRotation = function ()
	{
		gml_pragma("forceinline");
		return Real.Clone();
	};

	/// @func GetTranslation()
	///
	/// @desc Extracts translation (vec3) from dual quaternion.
	///
	/// @return {Struct.BBMOD_Vec3} The created vector.
	static GetTranslation = function ()
	{
		gml_pragma("forceinline");

		// Dual.Scale(2.0)
		var _q10 = Dual.X * 2.0;
		var _q11 = Dual.Y * 2.0;
		var _q12 = Dual.Z * 2.0;
		var _q13 = Dual.W * 2.0;

		// Real.Conjugate()
		var _q20 = -Real.X;
		var _q21 = -Real.Y;
		var _q22 = -Real.Z;
		var _q23 =  Real.W;

		//return Dual.Scale(2.0).Mul(Real.Conjugate());
		return new BBMOD_Vec3(
			_q13 * _q20 + _q10 * _q23 + _q11 * _q22 - _q12 * _q21,
			_q13 * _q21 + _q11 * _q23 + _q12 * _q20 - _q10 * _q22,
			_q13 * _q22 + _q12 * _q23 + _q10 * _q21 - _q11 * _q20
		);
	};

	/// @func Log()
	///
	/// @desc Computes the logarithm map of the dual quaternion and returns the
	/// result as a new dual quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Log = function ()
	{
		gml_pragma("forceinline");
		var _scale = 1.0 / Real.Length();
		return new BBMOD_DualQuaternion()
			.FromRealDual(
				Real.Log(),
				Real.Conjugate().Mul(Dual).Scale(_scale * _scale));
	};

	/// @func LogSelf()
	///
	/// @desc Computes the logarithm map of the dual quaternion and stores the
	/// result into `self`.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static LogSelf = function ()
	{
		gml_pragma("forceinline");
		var _scale = 1.0 / Real.Length();
		return FromRealDual(
			Real.Log(),
			Real.Clone().ConjugateSelf().MulSelf(Dual).ScaleSelf(_scale * _scale));
	};

	/// @func Mul(_dq)
	///
	/// @desc Multiplies two dual quaternions and returns the result as a new
	/// dual quaternion.
	///
	/// @param {Struct.BBMOD_DualQuaternion} _dq The other dual quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Mul = function (_dq)
	{
		gml_pragma("forceinline");

		var _dq1r0 = Real.X;
		var _dq1r1 = Real.Y;
		var _dq1r2 = Real.Z;
		var _dq1r3 = Real.W;
		var _dq1d0 = Dual.X;
		var _dq1d1 = Dual.Y;
		var _dq1d2 = Dual.Z;
		var _dq1d3 = Dual.W;
		var _dq2r0 = _dq.Real.X;
		var _dq2r1 = _dq.Real.Y;
		var _dq2r2 = _dq.Real.Z;
		var _dq2r3 = _dq.Real.W;
		var _dq2d0 = _dq.Dual.X;
		var _dq2d1 = _dq.Dual.Y;
		var _dq2d2 = _dq.Dual.Z;
		var _dq2d3 = _dq.Dual.W;

		var _res = new BBMOD_DualQuaternion();

		_res.Real.X = (_dq2r3 * _dq1r0 + _dq2r0 * _dq1r3 + _dq2r1 * _dq1r2 - _dq2r2 * _dq1r1);
		_res.Real.Y = (_dq2r3 * _dq1r1 + _dq2r1 * _dq1r3 + _dq2r2 * _dq1r0 - _dq2r0 * _dq1r2);
		_res.Real.Z = (_dq2r3 * _dq1r2 + _dq2r2 * _dq1r3 + _dq2r0 * _dq1r1 - _dq2r1 * _dq1r0);
		_res.Real.W = (_dq2r3 * _dq1r3 - _dq2r0 * _dq1r0 - _dq2r1 * _dq1r1 - _dq2r2 * _dq1r2);

		_res.Dual.X = (_dq2d3 * _dq1r0 + _dq2d0 * _dq1r3 + _dq2d1 * _dq1r2 - _dq2d2 * _dq1r1)
			+ (_dq2r3 * _dq1d0 + _dq2r0 * _dq1d3 + _dq2r1 * _dq1d2 - _dq2r2 * _dq1d1);
		_res.Dual.Y = (_dq2d3 * _dq1r1 + _dq2d1 * _dq1r3 + _dq2d2 * _dq1r0 - _dq2d0 * _dq1r2)
			+ (_dq2r3 * _dq1d1 + _dq2r1 * _dq1d3 + _dq2r2 * _dq1d0 - _dq2r0 * _dq1d2);
		_res.Dual.Z = (_dq2d3 * _dq1r2 + _dq2d2 * _dq1r3 + _dq2d0 * _dq1r1 - _dq2d1 * _dq1r0)
			+ (_dq2r3 * _dq1d2 + _dq2r2 * _dq1d3 + _dq2r0 * _dq1d1 - _dq2r1 * _dq1d0);
		_res.Dual.W = (_dq2d3 * _dq1r3 - _dq2d0 * _dq1r0 - _dq2d1 * _dq1r1 - _dq2d2 * _dq1r2)
			+ (_dq2r3 * _dq1d3 - _dq2r0 * _dq1d0 - _dq2r1 * _dq1d1 - _dq2r2 * _dq1d2);

		return _res;
	};

	/// @func MulSelf(_dq)
	///
	/// @desc Multiplies two dual quaternions and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_DualQuaternion} _dq The other dual quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static MulSelf = function (_dq)
	{
		gml_pragma("forceinline");

		var _dq1r0 = Real.X;
		var _dq1r1 = Real.Y;
		var _dq1r2 = Real.Z;
		var _dq1r3 = Real.W;
		var _dq1d0 = Dual.X;
		var _dq1d1 = Dual.Y;
		var _dq1d2 = Dual.Z;
		var _dq1d3 = Dual.W;
		var _dq2r0 = _dq.Real.X;
		var _dq2r1 = _dq.Real.Y;
		var _dq2r2 = _dq.Real.Z;
		var _dq2r3 = _dq.Real.W;
		var _dq2d0 = _dq.Dual.X;
		var _dq2d1 = _dq.Dual.Y;
		var _dq2d2 = _dq.Dual.Z;
		var _dq2d3 = _dq.Dual.W;

		Real.X = (_dq2r3 * _dq1r0 + _dq2r0 * _dq1r3 + _dq2r1 * _dq1r2 - _dq2r2 * _dq1r1);
		Real.Y = (_dq2r3 * _dq1r1 + _dq2r1 * _dq1r3 + _dq2r2 * _dq1r0 - _dq2r0 * _dq1r2);
		Real.Z = (_dq2r3 * _dq1r2 + _dq2r2 * _dq1r3 + _dq2r0 * _dq1r1 - _dq2r1 * _dq1r0);
		Real.W = (_dq2r3 * _dq1r3 - _dq2r0 * _dq1r0 - _dq2r1 * _dq1r1 - _dq2r2 * _dq1r2);

		Dual.X = (_dq2d3 * _dq1r0 + _dq2d0 * _dq1r3 + _dq2d1 * _dq1r2 - _dq2d2 * _dq1r1)
			+ (_dq2r3 * _dq1d0 + _dq2r0 * _dq1d3 + _dq2r1 * _dq1d2 - _dq2r2 * _dq1d1);
		Dual.Y = (_dq2d3 * _dq1r1 + _dq2d1 * _dq1r3 + _dq2d2 * _dq1r0 - _dq2d0 * _dq1r2)
			+ (_dq2r3 * _dq1d1 + _dq2r1 * _dq1d3 + _dq2r2 * _dq1d0 - _dq2r0 * _dq1d2);
		Dual.Z = (_dq2d3 * _dq1r2 + _dq2d2 * _dq1r3 + _dq2d0 * _dq1r1 - _dq2d1 * _dq1r0)
			+ (_dq2r3 * _dq1d2 + _dq2r2 * _dq1d3 + _dq2r0 * _dq1d1 - _dq2r1 * _dq1d0);
		Dual.W = (_dq2d3 * _dq1r3 - _dq2d0 * _dq1r0 - _dq2d1 * _dq1r1 - _dq2d2 * _dq1r2)
			+ (_dq2r3 * _dq1d3 - _dq2r0 * _dq1d0 - _dq2r1 * _dq1d1 - _dq2r2 * _dq1d2);

		return self;
	};

	/// @func Normalize()
	///
	/// @desc Normalizes the dual quaternion and returns the result as a new
	/// dual quaternion.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Normalize = function ()
	{
		gml_pragma("forceinline");
		var _dq = Clone();
		var _mag = Real.Dot(Real);
		if (_mag > math_get_epsilon())
		{
			_dq.Real = _dq.Real.Scale(1.0 / _mag);
			_dq.Dual = _dq.Dual.Scale(1.0 / _mag);
		}
		return _dq;
	};

	/// @func NormalizeSelf()
	///
	/// @desc Normalizes the dual quaternion and stores the result into `self`.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static NormalizeSelf = function ()
	{
		gml_pragma("forceinline");
		var _mag = Real.Dot(Real);
		if (_mag > math_get_epsilon())
		{
			Real.ScaleSelf(1.0 / _mag);
			Dual.ScaleSelf(1.0 / _mag);
		}
		return self;
	};

	/// @func Pow(_p)
	///
	/// @desc Computes the power of the dual quaternion raised to a real number
	/// and returns the result as a new dual quaternion.
	///
	/// @param {Real} _p The power value.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Pow = function (_p)
	{
		gml_pragma("forceinline");
		return Log().Scale(_p).Exp();
	};

	/// @func PowSelf(_p)
	///
	/// @desc Computes the power of the dual quaternion raised to a real number
	/// and stores the result into `self`.
	///
	/// @param {Real} _p The power value.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static PowSelf = function (_p)
	{
		gml_pragma("forceinline");
		return LogSelf().ScaleSelf(_p).ExpSelf();
	};

	/// @func Rotate(_v)
	///
	/// @desc Rotates a vector using the dual quaternion and returns the result
	/// as a new vector.
	///
	/// @param {Struct.BBMOD_Vec3} _v The vector to rotate.
	///
	/// @return {Struct.BBMOD_Vec3} The created vector.
	static Rotate = function (_v)
	{
		gml_pragma("forceinline");
		return Real.Rotate(_v);
	};

	/// @func RotateOther(_v)
	///
	/// @desc Rotates a vector using the dual quaternion and stores the result
	/// into the vector,
	///
	/// @param {Struct.BBMOD_Vec3} _v The vector to rotate.
	///
	/// @return {Struct.BBMOD_Vec3} Returns vector `_v`.
	static RotateOther = function (_v)
	{
		gml_pragma("forceinline");
		return Real.RotateOter(_v);
	};

	/// @func Scale(_s)
	///
	/// @desc Scales each component of the dual quaternion by a real value and
	/// returns the result as a new dual quaternion.
	///
	/// @param {Real} _s The value to scale the dual quaternion by.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Scale = function (_s)
	{
		gml_pragma("forceinline");
		var _dq = new BBMOD_DualQuaternion();
		_dq.Real = Real.Scale(_s);
		_dq.Dual = Dual.Scale(_s);
		return _dq;
	};

	/// @func ScaleSelf(_s)
	///
	/// @desc Scales each component of the dual quaternion by a real value and
	/// stores the result into `self`.
	///
	/// @param {Real} _s The value to scale the dual quaternion by.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static ScaleSelf = function (_s)
	{
		gml_pragma("forceinline");
		Real.ScaleSelf(_s);
		Dual.ScaleSelf(_s);
		return self;
	};

	/// @func Sclerp(_dq, _s)
	///
	/// @desc Computes a screw linear interpolation of two dual quaternions
	/// and returns the result as a new dual quaternion.
	///
	/// @param {Struct.BBMOD_DualQuaternion} _dq The other dual quaternion.
	/// @param {Real} _s The interpolation factor.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The created dual quaternion.
	static Sclerp = function (_dq, _s)
	{
		gml_pragma("forceinline");
		return _dq.Clone().MulSelf(Conjugate()).PowSelf(_s).MulSelf(self)
			.NormalizeSelf();
	};

	/// @func SclerpSelf(_dq, _s)
	///
	/// @desc Computes a screw linear interpolation of two dual quaternions
	/// and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_DualQuaternion} _dq The other dual quaternion.
	/// @param {Real} _s The interpolation factor.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static SclerpSelf = function (_dq, _s)
	{
		gml_pragma("forceinline");
		_dq.Clone().MulSelf(Conjugate()).PowSelf(_s).MulSelf(self)
			.NormalizeSelf().Copy(self);
		return self;
	};

	/// @func ToArray([_array[, _index]])
	///
	/// @desc Writes components `(rX, rY, rZ, rW, dX, dY, dZ, dW)` of the dual
	/// quaternion into an array.
	///
	/// @param {Array<Real>} [_array] The destination array. If not defined, a
	/// new one is created.
	///
	/// @param {Real} [_index] The index to start writing to. Defaults to 0.
	///
	/// @return {Array<Real>} Returns the destination array.
	static ToArray = function (_array=undefined, _index=0)
	{
		gml_pragma("forceinline");
		_array ??= array_create(8, 0.0);
		Real.ToArray(_array, _index);
		Dual.ToArray(_array, _index + 4);
		return _array;
	};

	/// @func ToBuffer(_buffer, _type)
	///
	/// @desc Writes components `(rX, rY, rZ, rW, dX, dY, dZ, dW)` of the dual
	/// quaternion into a buffer.
	///
	/// @param {Id.Buffer} _buffer The destination buffer.
	/// @param {Constant.BufferDataType} _type The type of each component.
	///
	/// @return {Struct.BBMOD_DualQuaternion} Returns `self`.
	static ToBuffer = function (_buffer, _type)
	{
		gml_pragma("forceinline");
		Real.ToBuffer(_buffer, _type);
		Dual.ToBuffer(_buffer, _type);
		return self;
	};

	/// @func ToMatrix([_dest[, _index]])
	///
	/// @desc Converts dual quaternion into a matrix.
	///
	/// @param {Array<Real>} [_dest] The destination array. If not specified,
	/// a new one is created.
	/// @param {Real} [_index] The starting index in the destination array.
	/// Defaults to 0.
	///
	/// @return {Array<Real>} Returns the destination array.
	static ToMatrix = function (_dest=undefined, _index=0)
	{
		gml_pragma("forceinline");

		_dest ??= array_create(16, 0.0);

		// Rotation
		Real.ToMatrix(_dest, _index);
		_dest[@ _index + 3] = 0.0;
		_dest[@ _index + 7] = 0.0;
		_dest[@ _index + 11] = 0.0;

		// Translation
		var _translation = GetTranslation();
		_dest[@ _index + 12] = _translation.X;
		_dest[@ _index + 13] = _translation.Y;
		_dest[@ _index + 14] = _translation.Z;
		_dest[@ _index + 15] = 1.0;

		return _dest;
	};

	/// @func Transform(_v)
	///
	/// @desc Translates and rotates a vector using the dual quaternion
	/// and returns the result as a new vector.
	///
	/// @param {Struct.BBMOD_Vec3} _v The vector to transform.
	///
	/// @return {Struct.BBMOD_Vec3} The created vector.
	static Transform = function (_v)
	{
		gml_pragma("forceinline");
		return GetTranslation().AddSelf(Real.Rotate(_v));
	};

	/// @func TransformOther(_v)
	///
	/// @desc Translates and rotates a vector using the dual quaternion
	/// and stores the result into the vector.
	///
	/// @param {Struct.BBMOD_Vec3} _v The vector to transform.
	///
	/// @return {Struct.BBMOD_Vec3} Returns vector `_v`.
	static TransformOther = function (_v)
	{
		gml_pragma("forceinline");
		GetTranslation().AddSelf(Real.Rotate(_v)).Copy(_v);
		return _v;
	};
}

/// @func __bbmod_dquat_mul_array(_dq1, _dq1Index, _dq2, _dq2Index, _dest, _destIndex)
///
/// @desc Multiplies two dual quaternions stored in arrays and writes the result
/// into the destination array.
///
/// @param {Array<Real>} _dq1 An array containing the first dual quaternion.
/// @param {Real} _dq1Index The starting index of the first dual quaternion.
/// @param {Array<Real>} _dq2 An array containing the second dual quaternion.
/// @param {Real} _dq2Index The starting index of the second dual quaternion.
/// @param {Array<Real>} _dest The destination array.
/// @param {Real} _destIndex The index to start writing to within the
/// destination array.
///
/// @note The arguments can overlap, as the input values are stored into local
/// variables before the multiplication.
///
/// @private
function __bbmod_dquat_mul_array(_dq1, _dq1Index, _dq2, _dq2Index, _dest, _destIndex)
{
	gml_pragma("forceinline");

	var _dq1r0 = _dq1[_dq1Index + 0];
	var _dq1r1 = _dq1[_dq1Index + 1];
	var _dq1r2 = _dq1[_dq1Index + 2];
	var _dq1r3 = _dq1[_dq1Index + 3];
	var _dq1d0 = _dq1[_dq1Index + 4];
	var _dq1d1 = _dq1[_dq1Index + 5];
	var _dq1d2 = _dq1[_dq1Index + 6];
	var _dq1d3 = _dq1[_dq1Index + 7];
	var _dq2r0 = _dq2[_dq2Index + 0];
	var _dq2r1 = _dq2[_dq2Index + 1];
	var _dq2r2 = _dq2[_dq2Index + 2];
	var _dq2r3 = _dq2[_dq2Index + 3];
	var _dq2d0 = _dq2[_dq2Index + 4];
	var _dq2d1 = _dq2[_dq2Index + 5];
	var _dq2d2 = _dq2[_dq2Index + 6];
	var _dq2d3 = _dq2[_dq2Index + 7];

	_dest[@ _destIndex]     = (_dq2r3 * _dq1r0 + _dq2r0 * _dq1r3 + _dq2r1 * _dq1r2 - _dq2r2 * _dq1r1);
	_dest[@ _destIndex + 1] = (_dq2r3 * _dq1r1 + _dq2r1 * _dq1r3 + _dq2r2 * _dq1r0 - _dq2r0 * _dq1r2);
	_dest[@ _destIndex + 2] = (_dq2r3 * _dq1r2 + _dq2r2 * _dq1r3 + _dq2r0 * _dq1r1 - _dq2r1 * _dq1r0);
	_dest[@ _destIndex + 3] = (_dq2r3 * _dq1r3 - _dq2r0 * _dq1r0 - _dq2r1 * _dq1r1 - _dq2r2 * _dq1r2);

	_dest[@ _destIndex + 4] = (_dq2d3 * _dq1r0 + _dq2d0 * _dq1r3 + _dq2d1 * _dq1r2 - _dq2d2 * _dq1r1)
		+ (_dq2r3 * _dq1d0 + _dq2r0 * _dq1d3 + _dq2r1 * _dq1d2 - _dq2r2 * _dq1d1);
	_dest[@ _destIndex + 5] = (_dq2d3 * _dq1r1 + _dq2d1 * _dq1r3 + _dq2d2 * _dq1r0 - _dq2d0 * _dq1r2)
		+ (_dq2r3 * _dq1d1 + _dq2r1 * _dq1d3 + _dq2r2 * _dq1d0 - _dq2r0 * _dq1d2);
	_dest[@ _destIndex + 6] = (_dq2d3 * _dq1r2 + _dq2d2 * _dq1r3 + _dq2d0 * _dq1r1 - _dq2d1 * _dq1r0)
		+ (_dq2r3 * _dq1d2 + _dq2r2 * _dq1d3 + _dq2r0 * _dq1d1 - _dq2r1 * _dq1d0);
	_dest[@ _destIndex + 7] = (_dq2d3 * _dq1r3 - _dq2d0 * _dq1r0 - _dq2d1 * _dq1r1 - _dq2d2 * _dq1r2)
		+ (_dq2r3 * _dq1d3 - _dq2r0 * _dq1d0 - _dq2r1 * _dq1d1 - _dq2r2 * _dq1d2);
}
