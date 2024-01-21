/// @module Core

/// @macro {Struct.BBMOD_Matrix} A read-only globally allocated identity matrix.
#macro BBMOD_MATRIX_IDENTITY __bbmod_matrix_get_idenitity()

/// @func __bbmod_matrix_get_idenitity()
///
/// @return {Struct.BBMOD_Matrix}
///
/// @private
function __bbmod_matrix_get_idenitity()
{
	gml_pragma("forceinline");
	static _matrix = new BBMOD_Matrix();
	return _matrix;
}

/// @func BBMOD_Matrix([_raw])
///
/// @desc A matrix.
///
/// @param {Array<Real>} [_raw] A raw GameMaker matrix. If `undefined`, then an
/// identity matrix is created.
function BBMOD_Matrix(_raw=undefined) constructor
{
	/// @var {Array<Real>} The underlying GameMaker matrix.
	Raw = _raw ?? matrix_build_identity();

	/// @func Copy(_dest)
	///
	/// @desc Copies the matrix to another matrix.
	///
	/// @param {Struct.BBMOD_Matrix} _dest The destination matrix.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static Copy = function (_dest)
	{
		gml_pragma("forceinline");
		array_copy(_dest.Raw, 0, Raw, 0, 16);
		return self;
	};

	/// @func Clone()
	///
	/// @desc Creates a clone of the matrix.
	///
	/// @return {Struct.BBMOD_Matrix} The clone of the matrix.
	static Clone = function ()
	{
		var _clone = new BBMOD_Matrix();
		Copy(_clone);
		return _clone;
	};

	/// @func Set(_index, _value)
	///
	/// @desc Sets matrix value at specific index.
	///
	/// @param {Real} _index The index to change the value at.
	/// @param {Real} _value The new value.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static Set = function (_index, _value)
	{
		gml_pragma("forceinline");
		Raw[@ _index] = _value;
		return self;
	};

	/// @func FromArray(_array[, _index])
	///
	/// @desc Initializes the matrix from an array.
	///
	/// @param {Array<Real>} _array The array to read values from.
	///
	/// @param {Real} [_index] The index to start reading at. Defaults to 0.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static FromArray = function (_array, _index=0)
	{
		gml_pragma("forceinline");
		array_copy(Raw, 0, _array, _index, 16);
		return self;
	};

	/// @func ToArray([_array[, _index]])
	///
	/// @desc Writes the matrix into an array.
	///
	/// @param {Array<Real>} [_array] The array to write the matrix to. If
	/// `undefined`, then a new one is created.
	/// @param {Real} [_index] The index to start writing at. Defaults to 0.
	///
	/// @return {Array<Real>} The destination array.
	static ToArray = function (_array=undefined, _index=0)
	{
		gml_pragma("forceinline");
		_array ??= array_create(16, 0.0);
		array_copy(_array, _index, Raw, 0, 16);
		return _array;
	};

	/// @func FromBuffer(_buffer, _type)
	///
	/// @desc Initializes the matrix from a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to read values from.
	/// @param {Constant.BufferDataType} _type The type of values. Use one of
	/// the `buffer_` constants.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static FromBuffer = function (_buffer, _type)
	{
		gml_pragma("forceinline");
		var _index = 0;
		repeat (16)
		{
			Raw[_index++] = buffer_read(_buffer, _type);
		}
		return self;
	};

	/// @func ToBuffer(_buffer, _type)
	///
	/// @desc Writes the matrix into a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write to.
	/// @param {Real} _type The type of values. Use one of the `buffer_` constants.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static ToBuffer = function (_buffer, _type)
	{
		gml_pragma("forceinline");
		var _index = 0;
		repeat (16)
		{
			buffer_write(_buffer, _type, Raw[_index++]);
		}
		return self;
	};

	/// @func FromColumns(_c1, _c2, _c3, _c4)
	///
	/// @desc Initializes the matrix from columns.
	///
	/// @param {Struct.BBMOD_Vec4} _c1 A vector containing the first column.
	/// @param {Struct.BBMOD_Vec4} _c2 A vector containing the second column.
	/// @param {Struct.BBMOD_Vec4} _c3 A vector containing the third column.
	/// @param {Struct.BBMOD_Vec4} _c4 A vector containing the fourth column.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static FromColumns = function (_c1, _c2, _c3, _c4)
	{
		gml_pragma("forceinline");
		Raw = [
			_c1.X, _c2.X, _c3.X, _c4.X,
			_c1.Y, _c2.Y, _c3.Y, _c4.Y,
			_c1.Z, _c2.Z, _c3.Z, _c4.Z,
			_c1.W, _c2.W, _c3.W, _c4.W,
		];
		return self;
	};

	/// @func FromRows(_r1, _r2, _r3, _r4)
	///
	/// @desc Initializes the matrix from rows.
	///
	/// @param {Struct.BBMOD_Vec4} _r1 A vector containing the first row.
	/// @param {Struct.BBMOD_Vec4} _r2 A vector containing the second row.
	/// @param {Struct.BBMOD_Vec4} _r3 A vector containing the third row.
	/// @param {Struct.BBMOD_Vec4} _r4 A vector containing the fourth row.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static FromRows = function (_r1, _r2, _r3, _r4)
	{
		gml_pragma("forceinline");
		Raw = [
			_r1.X, _r1.Y, _r1.Z, _r1.W,
			_r2.X, _r2.Y, _r2.Z, _r2.W,
			_r3.X, _r3.Y, _r3.Z, _r3.W,
			_r4.X, _r4.Y, _r4.Z, _r4.W,
		];
		return self;
	};

	/// @func FromLookAt(_from, _to, _up)
	///
	/// @desc Initializes a look-at matrix.
	///
	/// @param {Struct.BBMOD_Vec3} _from The position of the camera.
	/// @param {Struct.BBMOD_Vec3} _to The position where the camera is looking at.
	/// @param {Struct.BBMOD_Vec3} _up The direction up.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static FromLookAt = function (_from, _to, _up)
	{
		gml_pragma("forceinline");
		Raw = matrix_build_lookat(
			_from.X, _from.Y, _from.Z,
			_to.X, _to.Y, _to.Z,
			_up.X, _up.Y, _up.Z);
		return self;
	};

	/// @func FromWorld()
	///
	/// @desc Initializes the matrix using the current world matrix.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static FromWorld = function ()
	{
		gml_pragma("forceinline");
		Raw = matrix_get(matrix_world);
		return self;
	};

	/// @func FromView()
	///
	/// @desc Initializes the matrix using the current view matrix.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static FromView = function ()
	{
		gml_pragma("forceinline");
		Raw = matrix_get(matrix_view);
		return self;
	};

	/// @func FromProjection()
	///
	/// @desc Initializes the matrix using the current projection matrix.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static FromProjection = function ()
	{
		gml_pragma("forceinline");
		Raw = matrix_get(matrix_projection);
		return self;
	};

	/// @func FromWorldViewProjection()
	///
	/// @desc Initializes the matrix using the current `world * view * projection`
	/// matrix.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static FromWorldViewProjection = function ()
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(
			matrix_multiply(matrix_get(matrix_world), matrix_get(matrix_view)),
			matrix_get(matrix_projection));
		return self;
	};

	/// @func ApplyWorld()
	///
	/// @desc Changes the current world matrix to this one.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static ApplyWorld = function ()
	{
		gml_pragma("forceinline");
		matrix_set(matrix_world, Raw);
		return self;
	};

	/// @func ApplyView()
	///
	/// @desc Changes the view world matrix to this one.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static ApplyView = function ()
	{
		gml_pragma("forceinline");
		matrix_set(matrix_view, Raw);
		return self;
	};

	/// @func ApplyProjection()
	///
	/// @desc Changes the current projeciton matrix to this one.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static ApplyProjection = function ()
	{
		gml_pragma("forceinline");
		matrix_set(matrix_projection, Raw);
		return self;
	};

	/// @func ToEuler([_array[, _index]])
	///
	/// @desc Retrieves euler angles from the matrix.
	///
	/// @param {Array<Real>} [_array] An array to write the X,Y,Z angles to.
	/// If `undefined`, a new one is created.
	///
	/// @param {Real} [_index] The index to start writing at.
	///
	/// @return {Array<Real>} The destination array.
	static ToEuler = function (_array=undefined, _index=0)
	{
		gml_pragma("forceinline");

		_array ??= array_create(3, 0.0);

		var _thetaX, _thetaY, _thetaZ;
		var _m = Raw;
		var _m6 = _m[6];

		if (_m6 < 1.0)
		{
			if (_m6 > -1.0)
			{
				_thetaX = arcsin(-_m6);
				_thetaY = arctan2(_m[2], _m[10]);
				_thetaZ = arctan2(_m[4], _m[5]);
			}
			else
			{
				_thetaX = pi * 0.5;
				_thetaY = -arctan2(-_m[1], _m[0]);
				_thetaZ = 0.0;
			}
		}
		else
		{
			_thetaX = -pi * 0.5;
			_thetaY = arctan2(-_m[1], _m[0]);
			_thetaZ = 0.0;
		}

		_array[@ _index]     = (360.0 + radtodeg(_thetaX)) mod 360.0;
		_array[@ _index + 1] = (360.0 + radtodeg(_thetaY)) mod 360.0;
		_array[@ _index + 2] = (360.0 + radtodeg(_thetaZ)) mod 360.0;

		return _array;
	};

	/// @func Determinant()
	///
	/// @desc Computes the determinant of the matrix.
	///
	/// @return {Real} The determinant.
	static Determinant = function ()
	{
		gml_pragma("forceinline");
		var _m   = Raw;
		var _m0  = _m[ 0];
		var _m1  = _m[ 1];
		var _m2  = _m[ 2];
		var _m3  = _m[ 3];
		var _m4  = _m[ 4];
		var _m5  = _m[ 5];
		var _m6  = _m[ 6];
		var _m7  = _m[ 7];
		var _m8  = _m[ 8];
		var _m9  = _m[ 9];
		var _m10 = _m[10];
		var _m11 = _m[11];
		var _m12 = _m[12];
		var _m13 = _m[13];
		var _m14 = _m[14];
		var _m15 = _m[15];
		return (0.0
			+ (_m3 * _m6 *  _m9 * _m12) - (_m2 * _m7 *  _m9 * _m12) - (_m3 * _m5 * _m10 * _m12) + (_m1 * _m7 * _m10 * _m12)
			+ (_m2 * _m5 * _m11 * _m12) - (_m1 * _m6 * _m11 * _m12) - (_m3 * _m6 *  _m8 * _m13) + (_m2 * _m7 *  _m8 * _m13)
			+ (_m3 * _m4 * _m10 * _m13) - (_m0 * _m7 * _m10 * _m13) - (_m2 * _m4 * _m11 * _m13) + (_m0 * _m6 * _m11 * _m13)
			+ (_m3 * _m5 *  _m8 * _m14) - (_m1 * _m7 *  _m8 * _m14) - (_m3 * _m4 *  _m9 * _m14) + (_m0 * _m7 *  _m9 * _m14)
			+ (_m1 * _m4 * _m11 * _m14) - (_m0 * _m5 * _m11 * _m14) - (_m2 * _m5 *  _m8 * _m15) + (_m1 * _m6 *  _m8 * _m15)
			+ (_m2 * _m4 *  _m9 * _m15) - (_m0 * _m6 *  _m9 * _m15) - (_m1 * _m4 * _m10 * _m15) + (_m0 * _m5 * _m10 * _m15));
	};

	/// @func Inverse()
	///
	/// @desc Creates a matrix that is inverse to this one.
	///
	/// @return {Struct.BBMOD_Matrix} The inverse matrix.
	static Inverse = function ()
	{
		gml_pragma("forceinline");
		return Clone().InverseSelf();
	};

	/// @func InverseSelf()
	///
	/// @desc Computes a matrix that is inverse to this one and stores it into
	/// `self`.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static InverseSelf = function ()
	{
		gml_pragma("forceinline");

		var _m   = Raw;
		var _m0  = _m[ 0];
		var _m1  = _m[ 1];
		var _m2  = _m[ 2];
		var _m3  = _m[ 3];
		var _m4  = _m[ 4];
		var _m5  = _m[ 5];
		var _m6  = _m[ 6];
		var _m7  = _m[ 7];
		var _m8  = _m[ 8];
		var _m9  = _m[ 9];
		var _m10 = _m[10];
		var _m11 = _m[11];
		var _m12 = _m[12];
		var _m13 = _m[13];
		var _m14 = _m[14];
		var _m15 = _m[15];

		var _determinant = (0.0
			+ (_m3 * _m6 *  _m9 * _m12) - (_m2 * _m7 *  _m9 * _m12) - (_m3 * _m5 * _m10 * _m12) + (_m1 * _m7 * _m10 * _m12)
			+ (_m2 * _m5 * _m11 * _m12) - (_m1 * _m6 * _m11 * _m12) - (_m3 * _m6 *  _m8 * _m13) + (_m2 * _m7 *  _m8 * _m13)
			+ (_m3 * _m4 * _m10 * _m13) - (_m0 * _m7 * _m10 * _m13) - (_m2 * _m4 * _m11 * _m13) + (_m0 * _m6 * _m11 * _m13)
			+ (_m3 * _m5 *  _m8 * _m14) - (_m1 * _m7 *  _m8 * _m14) - (_m3 * _m4 *  _m9 * _m14) + (_m0 * _m7 *  _m9 * _m14)
			+ (_m1 * _m4 * _m11 * _m14) - (_m0 * _m5 * _m11 * _m14) - (_m2 * _m5 *  _m8 * _m15) + (_m1 * _m6 *  _m8 * _m15)
			+ (_m2 * _m4 *  _m9 * _m15) - (_m0 * _m6 *  _m9 * _m15) - (_m1 * _m4 * _m10 * _m15) + (_m0 * _m5 * _m10 * _m15));

		var _s = 1.0 / _determinant;

		Raw = [
			_s * ((_m6 * _m11 * _m13) - (_m7 * _m10 * _m13) + (_m7 * _m9 * _m14) - (_m5 * _m11 * _m14) - (_m6 * _m9 * _m15) + (_m5 * _m10 * _m15)),
			_s * ((_m3 * _m10 * _m13) - (_m2 * _m11 * _m13) - (_m3 * _m9 * _m14) + (_m1 * _m11 * _m14) + (_m2 * _m9 * _m15) - (_m1 * _m10 * _m15)),
			_s * ((_m2 *  _m7 * _m13) - (_m3 *  _m6 * _m13) + (_m3 * _m5 * _m14) - (_m1 *  _m7 * _m14) - (_m2 * _m5 * _m15) + (_m1 *  _m6 * _m15)),
			_s * ((_m3 *  _m6 *  _m9) - (_m2 *  _m7 *  _m9) - (_m3 * _m5 * _m10) + (_m1 *  _m7 * _m10) + (_m2 * _m5 * _m11) - (_m1 *  _m6 * _m11)),
			_s * ((_m7 * _m10 * _m12) - (_m6 * _m11 * _m12) - (_m7 * _m8 * _m14) + (_m4 * _m11 * _m14) + (_m6 * _m8 * _m15) - (_m4 * _m10 * _m15)),
			_s * ((_m2 * _m11 * _m12) - (_m3 * _m10 * _m12) + (_m3 * _m8 * _m14) - (_m0 * _m11 * _m14) - (_m2 * _m8 * _m15) + (_m0 * _m10 * _m15)),
			_s * ((_m3 *  _m6 * _m12) - (_m2 *  _m7 * _m12) - (_m3 * _m4 * _m14) + (_m0 *  _m7 * _m14) + (_m2 * _m4 * _m15) - (_m0 *  _m6 * _m15)),
			_s * ((_m2 *  _m7 *  _m8) - (_m3 *  _m6 *  _m8) + (_m3 * _m4 * _m10) - (_m0 *  _m7 * _m10) - (_m2 * _m4 * _m11) + (_m0 *  _m6 * _m11)),
			_s * ((_m5 * _m11 * _m12) - (_m7 *  _m9 * _m12) + (_m7 * _m8 * _m13) - (_m4 * _m11 * _m13) - (_m5 * _m8 * _m15) + (_m4 *  _m9 * _m15)),
			_s * ((_m3 *  _m9 * _m12) - (_m1 * _m11 * _m12) - (_m3 * _m8 * _m13) + (_m0 * _m11 * _m13) + (_m1 * _m8 * _m15) - (_m0 *  _m9 * _m15)),
			_s * ((_m1 *  _m7 * _m12) - (_m3 *  _m5 * _m12) + (_m3 * _m4 * _m13) - (_m0 *  _m7 * _m13) - (_m1 * _m4 * _m15) + (_m0 *  _m5 * _m15)),
			_s * ((_m3 *  _m5 *  _m8) - (_m1 *  _m7 *  _m8) - (_m3 * _m4 *  _m9) + (_m0 *  _m7 *  _m9) + (_m1 * _m4 * _m11) - (_m0 *  _m5 * _m11)),
			_s * ((_m6 *  _m9 * _m12) - (_m5 * _m10 * _m12) - (_m6 * _m8 * _m13) + (_m4 * _m10 * _m13) + (_m5 * _m8 * _m14) - (_m4 *  _m9 * _m14)),
			_s * ((_m1 * _m10 * _m12) - (_m2 *  _m9 * _m12) + (_m2 * _m8 * _m13) - (_m0 * _m10 * _m13) - (_m1 * _m8 * _m14) + (_m0 *  _m9 * _m14)),
			_s * ((_m2 *  _m5 * _m12) - (_m1 *  _m6 * _m12) - (_m2 * _m4 * _m13) + (_m0 *  _m6 * _m13) + (_m1 * _m4 * _m14) - (_m0 *  _m5 * _m14)),
			_s * ((_m1 *  _m6 *  _m8) - (_m2 *  _m5 *  _m8) + (_m2 * _m4 *  _m9) - (_m0 *  _m6 *  _m9) - (_m1 * _m4 * _m10) + (_m0 *  _m5 * _m10)),
		];

		return self;
	};

	/// @func Mul(_matrix, ...)
	///
	/// @desc Multiplies matrices and returns the result as a new matrix.
	///
	/// @param {Struct.BBMOD_Matrix} _matrix The first matrix to multiply with.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	///
	/// @example
	/// ```gml
	/// var _world = new BBMOD_Matrix().FromWorld();
	/// var _view = new BBMOD_Matrix().FromView();
	/// var _projection = new BBMOD_Matrix().FromProjection();
	/// var _worldViewProjection = _world.Mul(_view, _projection);
	/// ```
	/// Please note that this example only shows that you can pass multiple
	/// matrices to this method. If you would actually like to get the
	/// `world * view * projection` matrix, you can simply call
	/// {@link BBMOD_Matrix.FromWorldViewProjection}.
	static Mul = function (_matrix)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		var _raw = matrix_multiply(Raw, _matrix.Raw);
		var _index = 1;
		repeat (argument_count - 1)
		{
			_raw = matrix_multiply(_raw, argument[_index++]);
		}
		_res.Raw = _raw;
		return _res;
	};

	/// @func MulSelf(_matrix, ...)
	///
	/// @desc Multiplies matrices and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_Matrix} _matrix The first matrix to multiply with.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _world = new BBMOD_Matrix().FromWorld();
	/// var _view = new BBMOD_Matrix().FromView();
	/// var _projection = new BBMOD_Matrix().FromProjection();
	/// var _worldViewProjection = _world.Mul(_view, _projection);
	/// ```
	/// Please note that this example only shows that you can pass multiple
	/// matrices to this method. If you would actually like to get the
	/// `world * view * projection` matrix, you can simply call
	/// {@link BBMOD_Matrix.FromWorldViewProjection}.
	static MulSelf = function (_matrix)
	{
		gml_pragma("forceinline");
		var _raw = matrix_multiply(Raw, _matrix.Raw);
		var _index = 1;
		repeat (argument_count - 1)
		{
			_raw = matrix_multiply(_raw, argument[_index++]);
		}
		Raw = _raw;
		return self;
	};

	/// @func MulComponentwise(_matrix)
	///
	/// @desc Multiplies each component of the matrix with corresponding
	/// component of other matrix and returns the result as a new matrix.
	///
	/// @param {Struct.BBMOD_Matrix} _matrix The matrix to multiply componentwise
	/// with.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static MulComponentwise = function (_matrix)
	{
		gml_pragma("forceinline");
		return Clone().MulComponentwiseSelf(_matrix);
	};

	/// @func MulComponentwiseSelf(_matrix)
	///
	/// @desc Multiplies each component of the matrix with corresponding
	/// component of other matrix and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_Matrix} _matrix The matrix to multiply componentwise
	/// with.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static MulComponentwiseSelf = function (_matrix)
	{
		gml_pragma("forceinline");
		var _selfRaw = Raw;
		var _otherRaw = _matrix.Raw;
		var _index = 0;
		repeat (16)
		{
			_selfRaw[@ _index] *= _otherRaw[_index];
			++_index;
		}
		return self;
	};

	/// @func AddComponentwise(_matrix)
	///
	/// @desc Adds each component of the matrix to corresponding component of
	/// other matrix and returns the result as a new matrix.
	///
	/// @param {Struct.BBMOD_Matrix} _matrix The matrix to add componentwise with.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static AddComponentwise = function (_matrix)
	{
		gml_pragma("forceinline");
		return Clone().AddComponentwiseSelf(_matrix);
	};

	/// @func AddComponentwiseSelf(_matrix)
	///
	/// @desc Adds each component of the matrix to corresponding component of
	/// other matrix and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_Matrix} _matrix The matrix to add componentwise with.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static AddComponentwiseSelf = function (_matrix)
	{
		gml_pragma("forceinline");
		var _selfRaw = Raw;
		var _otherRaw = _matrix.Raw;
		var _index = 0;
		repeat (16)
		{
			_selfRaw[@ _index] += _otherRaw[_index];
			++_index;
		}
		return self;
	};

	/// @func SubComponentwise(_matrix)
	///
	/// @desc Subtracts each component of a matrix from corresponding component
	/// of this matrix and returns the result as a new matrix.
	///
	/// @param {Struct.BBMOD_Matrix} _matrix The matrix that subtracts
	/// componentwise from this one.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static SubComponentwise = function (_matrix)
	{
		gml_pragma("forceinline");
		return Clone().SubComponentwiseSelf(_matrix);
	};

	/// @func SubComponentwiseSelf(_matrix)
	///
	/// @desc Subtracts each component of a matrix from corresponding component
	/// of this matrix and stores the result into `self`.
	///
	/// @param {Struct.BBMOD_Matrix} _matrix The matrix that subtracts
	/// componentwise from this one.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static SubComponentwiseSelf = function (_matrix)
	{
		gml_pragma("forceinline");
		var _selfRaw = Raw;
		var _otherRaw = _matrix.Raw;
		var _index = 0;
		repeat (16)
		{
			_selfRaw[@ _index] -= _otherRaw[_index];
			++_index;
		}
		return self;
	};

	/// @func Transform(_vector)
	///
	/// @desc Transforms a vector by the matrix and returns the result as a new
	/// vector.
	///
	/// @param {Struct.BBMOD_Vec4} _vector The vector to transform.
	///
	/// @return {Struct.BBMOD_Vec4} The tranformed vector.
	static Transform = function (_vector)
	{
		gml_pragma("forceinline");
		return _vector.Transform(Raw);
	};

	/// @func TransformOther(_vector)
	///
	/// @desc Transforms a vector by the matrix and stores the result into the
	/// vector.
	///
	/// @param {Struct.BBMOD_Vec4} _vector The vector to transform.
	///
	/// @return {Struct.BBMOD_Vec4} The vector `_v`.
	static TransformOther = function (_vector)
	{
		gml_pragma("forceinline");
		return _vector.TransformSelf(Raw);
	};

	/// @func Transpose()
	///
	/// @desc Creates a transpose of this matrix.
	///
	/// @return {Struct.BBMOD_Matrix} The transposed matrix.
	static Transpose = function ()
	{
		gml_pragma("forceinline");
		return Clone().Transpose();
	};

	/// @func TransposeSelf()
	///
	/// @desc Transposes this matrix in-place.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static TransposeSelf = function ()
	{
		gml_pragma("forceinline");
		var _m = Raw;
		Raw = [
			_m[0], _m[4], _m[ 8], _m[12],
			_m[1], _m[5], _m[ 9], _m[13],
			_m[2], _m[6], _m[10], _m[14],
			_m[3], _m[7], _m[11], _m[15],
		];
		return self;
	};

	/// @func Translate(_x[, _y, _z])
	///
	/// @desc Translates the matrix and returns the result as a new matrix.
	///
	/// @param {Real, Struct.BBMOD_Vec3} _x Translation on the X axis or a
	/// vector with translations on all axes.
	/// @param {Real} [_y] Translation on the Y axis. Use `undefined` if `_x` is
	/// a vector. Defaults to `undefined`.
	/// @param {Real} [_z] Translation on the Z axis. Use `undefined` if `_x` is
	/// a vector. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static Translate = function (_x, _y=undefined, _z=undefined)
	{
		gml_pragma("forceinline");
		return Clone().TranslateSelf(_x, _y, _z);
	};

	/// @func TranslateSelf(_x[, _y, _z])
	///
	/// @desc Translates the matrix and stores the result into `self`.
	///
	/// @param {Real, Struct.BBMOD_Vec3} _x Translation on the X axis or a
	/// vector with translations on all axes.
	/// @param {Real} [_y] Translation on the Y axis. Use `undefined` if `_x` is
	/// a vector. Defaults to `undefined`.
	/// @param {Real} [_z] Translation on the Z axis. Use `undefined` if `_x` is
	/// a vector. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static TranslateSelf = function (_x, _y=undefined, _z=undefined)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			is_struct(_x)
				? matrix_build(_x.X, _x.Y, _x.Z, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
				: matrix_build(_x, _y, _z, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return self;
	};

	/// @func TranslateX(_x)
	///
	/// @desc Translates the matrix on the X axis and returns the result as a
	/// new matrix.
	///
	/// @param {Real} _x Translation on the X axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static TranslateX = function (_x)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(_x, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func TranslateXSelf(_x)
	///
	/// @desc Translates the matrix on the X axis and stores the result into
	/// `self`.
	///
	/// @param {Real} _x Translation on the X axis.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static TranslateXSelf = function (_x)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			matrix_build(_x, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return self;
	};

	/// @func TranslateY(_y)
	///
	/// @desc Translates the matrix on the Y axis and returns the result as a
	/// new matrix.
	///
	/// @param {Real} _y Translation on the Y axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static TranslateY = function (_y)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, _y, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};
	
	/// @func TranslateYSelf(_y)
	///
	/// @desc Translates the matrix on the Y axis and stores the result into
	/// `self`.
	///
	/// @param {Real} _y Translation on the Y axis.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static TranslateYSelf = function (_y)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			matrix_build(0.0, _y, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return self;
	};

	/// @func TranslateZ(_z)
	///
	/// @desc Translates the matrix on the Z axis and returns the result as a
	/// new matrix.
	///
	/// @param {Real} _z Translation on the Z axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static TranslateZ = function (_z)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, _z, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func TranslateZSelf(_z)
	///
	/// @desc Translates the matrix on the Z axis and stores the result into
	/// `self`.
	///
	/// @param {Real} _z Translation on the Z axis.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static TranslateZSelf = function (_z)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, _z, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return self;
	};

	/// @func RotateEuler(_x[, _y, _z])
	///
	/// @desc Rotates the matrix using euler angles and returns the result as a
	/// new matrix.
	///
	/// @param {Real, Struct.BBMOD_Vec3} _x Rotation on the X axis or a vector
	/// with rotations on all axes.
	/// @param {Real} [_y] Rotation on the Y axis. Use `undefined` if `_x` is a
	/// vector. Defaults to `undefined`.
	/// @param {Real} [_z] Rotation on the Z axis. Use `undefined` if `_x` is a
	/// vector. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	///
	/// @note The order of rotations is YXZ, same as in `matrix_build`.
	static RotateEuler = function (_x, _y=undefined, _z=undefined)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			is_struct(_x)
				? matrix_build(0.0, 0.0, 0.0, _x.X, _x.Y, _x.Z, 1.0, 1.0, 1.0)
				: matrix_build(0.0, 0.0, 0.0, _x, _y, _z, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func RotateEulerSelf(_x[, _y, _z])
	///
	/// @desc Rotates the matrix using euler angles and stores the result into
	/// `self`.
	///
	/// @param {Real, Struct.BBMOD_Vec3} _x Rotation on the X axis or a vector
	/// with rotations on all axes.
	/// @param {Real} [_y] Rotation on the Y axis. Use `undefined` if `_x` is a
	/// vector. Defaults to `undefined`.
	/// @param {Real} [_z] Rotation on the Z axis. Use `undefined` if `_x` is a
	/// vector. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	///
	/// @note The order of rotations is YXZ, same as in `matrix_build`.
	static RotateEulerSelf = function (_x, _y=undefined, _z=undefined)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			is_struct(_x)
				? matrix_build(0.0, 0.0, 0.0, _x.X, _x.Y, _x.Z, 1.0, 1.0, 1.0)
				: matrix_build(0.0, 0.0, 0.0, _x, _y, _z, 1.0, 1.0, 1.0));
		return self;
	};

	/// @func RotateQuat(_quat)
	///
	/// @desc Rotates the matrix using a quaternion and returns the result as a
	/// new matrix.
	///
	/// @param {Struct.BBMOD_Quaternion} _quat The quaternion to rotate the
	/// matrix with.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static RotateQuat = function (_quat)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw, _quat.ToMatrix());
		return _res;
	};

	/// @func RotateQuatSelf(_quat)
	///
	/// @desc Rotates the matrix using a quaternion and stores the result into
	/// `self`.
	///
	/// @param {Struct.BBMOD_Quaternion} _quat The quaternion to rotate the
	/// matrix with.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static RotateQuatSelf = function (_quat)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw, _quat.ToMatrix());
		return self;
	};

	/// @func RotateX(_x)
	///
	/// @desc Rotates the matrix on the X axis and returns the result as a new
	/// matrix.
	///
	/// @param {Real} _x Rotation on the X axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static RotateX = function (_x)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, _x, 0.0, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func RotateXSelf(_x)
	///
	/// @desc Rotates the matrix on the X axis and stores the result into `self`.
	///
	/// @param {Real} _x Rotation on the X axis.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static RotateXSelf = function (_x)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, _x, 0.0, 0.0, 1.0, 1.0, 1.0));
		return self;
	};

	/// @func RotateY(_y)
	///
	/// @desc Rotates the matrix on the Y axis and returns the result as a new
	/// matrix.
	///
	/// @param {Real} _y Rotation on the Y axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static RotateY = function (_y)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, _y, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func RotateYSelf(_y)
	///
	/// @desc Rotates the matrix on the Y axis and stores the result into `self`.
	///
	/// @param {Real} _y Rotation on the Y axis.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static RotateYSelf = function (_y)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, _y, 0.0, 1.0, 1.0, 1.0));
		return self;
	};

	/// @func RotateZ(_z)
	///
	/// @desc Rotates the matrix on the Z axis and returns the result as a new
	/// matrix.
	///
	/// @param {Real} _z Rotation on the Z axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static RotateZ = function (_z)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, _z, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func RotateZSelf(_z)
	///
	/// @desc Rotates the matrix on the Z axis and stores the result into `self`.
	///
	/// @param {Real} _z Rotation on the Z axis.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static RotateZSelf = function (_z)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, _z, 1.0, 1.0, 1.0));
		return self;
	};

	/// @func Scale(_x[, _y, _z])
	///
	/// @desc Scales the matrix and returns the result as a new matrix.
	///
	/// @param {Real, Struct.BBMOD_Vec3} _x Scale on the X axis or a vector with
	/// scale on all axes.
	/// @param {Real} [_y] Scale on the Y axis. Use `undefined` if `_x` is a
	/// vector. Defaults to `undefined`.
	/// @param {Real} [_z] Scale on the Z axis. Use `undefined` if `_x` is a
	/// vector. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static Scale = function (_x, _y=undefined, _z=undefined)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			is_struct(_x)
				? matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _x.X, _x.Y, _x.Z)
				: matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _x, _y, _z));
		return _res;
	};

	/// @func Scale(_x[, _y, _z])
	///
	/// @desc Scales the matrix and returns the stores the result into `self`.
	///
	/// @param {Real, Struct.BBMOD_Vec3} _x Scale on the X axis or a vector with
	/// scale on all axes.
	/// @param {Real} [_y] Scale on the Y axis. Use `undefined` if `_x` is a
	/// vector. Defaults to `undefined`.
	/// @param {Real} [_z] Scale on the Z axis. Use `undefined` if `_x` is a
	/// vector. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static ScaleSelf = function (_x, _y=undefined, _z=undefined)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			is_struct(_x)
				? matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _x.X, _x.Y, _x.Z)
				: matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _x, _y, _z));
		return self;
	};

	/// @func ScaleComponentwise(_s)
	///
	/// @desc Scales each component of the matrix and returns the result as a
	/// new matrix.
	///
	/// @param {Real} _s The value to scale the components with.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static ScaleComponentwise = function (_s)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		var _selfRaw = Raw;
		var _index = 0;
		repeat (16)
		{
			_res.Raw[@ _index] = _selfRaw[_index] * _s;
			++_index;
		}
		return _res;
	};

	/// @func ScaleComponentwiseSelf(_s)
	///
	/// @desc Scales each component of the matrix and stores the result into
	/// `self`.
	///
	/// @param {Real} _s The value to scale the components with.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static ScaleComponentwiseSelf = function (_s)
	{
		gml_pragma("forceinline");
		var _selfRaw = Raw;
		var _index = 0;
		repeat (16)
		{
			_selfRaw[@ _index] *= _s;
			++_index;
		}
		return self;
	};

	/// @func ScaleX(_x)
	///
	/// @desc Scales the matrix on the X axis and returns the result as a new
	/// matrix.
	///
	/// @param {Real} _x Scale on the X axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static ScaleX = function (_x)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _x, 1.0, 1.0));
		return _res;
	};

	/// @func ScaleXSelf(_x)
	///
	/// @desc Scales the matrix on the X axis and stores the result into `self`.
	///
	/// @param {Real} _x Scale on the X axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static ScaleXSelf = function (_x)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _x, 1.0, 1.0));
		return self;
	};

	/// @func ScaleY(_y)
	///
	/// @desc Scales the matrix on the Y axis and returns the result as a new
	/// matrix.
	///
	/// @param {Real} _y Scale on the Y axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static ScaleY = function (_y)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, _y, 1.0));
		return _res;
	};

	/// @func ScaleYSelf(_y)
	///
	/// @desc Scales the matrix on the Y axis and stores the result into `self`.
	///
	/// @param {Real} _y Scale on the Y axis.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static ScaleYSelf = function (_y)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, _y, 1.0));
		return self;
	};

	/// @func ScaleZ(_z)
	///
	/// @desc Scales the matrix on the Z axis and returns the result as a new
	/// matrix.
	///
	/// @param {Real} _z Scale on the Z axis.
	///
	/// @return {Struct.BBMOD_Matrix} The resulting matrix.
	static ScaleZ = function (_z)
	{
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, _z));
		return _res;
	};

	/// @func ScaleZSelf(_z)
	///
	/// @desc Scales the matrix on the Z axis and stores the result into `self`.
	///
	/// @param {Real} _z Scale on the Z axis.
	///
	/// @return {Struct.BBMOD_Matrix} Returns `self`.
	static ScaleZSelf = function (_z)
	{
		gml_pragma("forceinline");
		Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, _z));
		return self;
	};
}

/// @func bbmod_matrix_build_normalmatrix(_m[, _dest[, _index]])
///
/// @desc Creates a matrix using which you can safely transform normal vectors.
///
/// @param {Array<Real>} _m A matrix to build the normal matrix from.
/// @param {Array} [_dest] An array to store the resulting matrix to. Defaults
/// to a new array empty array.
/// @param {Real} [_index] An index to start writing the result at. Defaults to
/// 0.
///
/// @return {Array} The destination array.
function bbmod_matrix_build_normalmatrix(_m, _dest=[], _index=0)
{
	gml_pragma("forceinline");

	var _m0  = _m[ 0];
	var _m1  = _m[ 1];
	var _m2  = _m[ 2];
	var _m4  = _m[ 4];
	var _m5  = _m[ 5];
	var _m6  = _m[ 6];
	var _m8  = _m[ 8];
	var _m9  = _m[ 9];
	var _m10 = _m[10];

	var _determinant = (0.0
		+ _m0 * ((_m5 * _m10) - (_m6 *  _m9))
		+ _m4 * ((_m9 *  _m2) - (_m1 * _m10))
		+ _m8 * ((_m1 *  _m6) - (_m5 *  _m2)));

	var _s = 1.0 / _determinant;

	_dest[@ _index + 0]  = _s * ((_m5 * _m10) - (_m6 *  _m9));
	_dest[@ _index + 1]  = _s * ((_m8 *  _m6) - (_m4 * _m10));
	_dest[@ _index + 2]  = _s * ((_m4 *  _m9) - (_m8 *  _m5));
	_dest[@ _index + 3]  = 0.0;
	_dest[@ _index + 4]  = _s * ((_m9 *  _m2) - (_m1 * _m10));
	_dest[@ _index + 5]  = _s * ((_m0 * _m10) - (_m8 *  _m2));
	_dest[@ _index + 6]  = _s * ((_m1 *  _m8) - (_m0 *  _m9));
	_dest[@ _index + 7]  = 0.0;
	_dest[@ _index + 8]  = _s * ((_m1 * _m6) - (_m2 * _m5));
	_dest[@ _index + 9]  = _s * ((_m2 * _m4) - (_m0 * _m6));
	_dest[@ _index + 10] = _s * ((_m0 * _m5) - (_m1 * _m4));
	_dest[@ _index + 11] = 0.0;
	_dest[@ _index + 12] = 0.0;
	_dest[@ _index + 13] = 0.0;
	_dest[@ _index + 14] = 0.0;
	_dest[@ _index + 15] = 1.0;

	return _dest;
}
