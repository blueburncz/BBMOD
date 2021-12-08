/// @macro {BBMOD_Vec3} A shorthand for `new BBMOD_Vec3(1, 0, 0)`.
/// @see BBMOD_VEC3_RIGHT
/// @see BBMOD_VEC3_UP
/// @see BBMOD_Vec3
#macro BBMOD_VEC3_FORWARD new BBMOD_Vec3(1.0, 0.0, 0.0)

/// @macro {BBMOD_Vec3} A shorthand for `new BBMOD_Vec3(0, 1, 0)`.
/// @see BBMOD_VEC3_FORWARD
/// @see BBMOD_VEC3_UP
/// @see BBMOD_Vec3
#macro BBMOD_VEC3_RIGHT new BBMOD_Vec3(0.0, 1.0, 0.0)

/// @macro {BBMOD_Vec3} A shorthand for `new BBMOD_Vec3(0, 0, 1)`.
/// @see BBMOD_VEC3_RIGHT
/// @see BBMOD_VEC3_FORWARD
/// @see BBMOD_Vec3
#macro BBMOD_VEC3_UP new BBMOD_Vec3(0.0, 0.0, 1.0)

/// @func BBMOD_Vec3([_x[, _y, _z]])
/// @desc A 3D vector.
/// @param {real} [_x] The first component of the vector. Defaults to 0.
/// @param {real} [_y] The second component of the vector. Defaults to `_x`.
/// @param {real} [_z] The third component of the vector. Defaults to `_x`.
/// @see BBMOD_Vec2
/// @see BBMOD_Vec4
function BBMOD_Vec3(_x, _y, _z) constructor
{
	/// @var {real} The first component of the vector.
	X = (_x != undefined) ? _x : 0.0;

	/// @var {real} The second component of the vector.
	Y = (_y != undefined) ? _y : X;

	/// @var {real} The third component of the vector.
	Z = (_z != undefined) ? _z : X;

	/// @func Abs()
	/// @desc Creates a new vector where each component is equal to the absolute
	/// value of the original component.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec3(-1.0, 2.0, -3.0).Abs() // => BBMOD_Vec3(1.0, 2.0, 3.0)
	/// ```
	static Abs = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			abs(X),
			abs(Y),
			abs(Z),
		);
	};

	/// @func Add(_v)
	/// @desc Adds vectors and returns the result as a new vector.
	/// @param {BBMOD_Vec3} _v The other vector.
	/// @return {BBMOD_Vec3} The created vector.
	static Add = function (_v) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			X + _v.X,
			Y + _v.Y,
			Z + _v.Z,
		);
	};

	/// @func Ceil()
	/// @desc Applies function `ceil` to each component of the vector and returns
	/// the result as a new vector.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec3(0.2, 1.6, 2.4).Ceil() // => BBMOD_Vec3(1.0, 2.0, 3.0)
	/// ```
	static Ceil = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			ceil(X),
			ceil(Y),
			ceil(Z),
		);
	};

	/// @func ClampLength(_min, _max)
	/// @desc Clamps the length of the vector between `_min` and `_max` and
	/// returns the result as a new vector.
	/// @param {real} _min The minimum length of the vector.
	/// @param {real} _max The maximum length of the vector.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec3(3.0, 0.0, 0.0).ClampLength(1.0, 5.0) // => BBMOD_Vec3(3.0, 0.0, 0.0)
	/// new BBMOD_Vec3(3.0, 0.0, 0.0).ClampLength(4.0, 5.0) // => BBMOD_Vec3(4.0, 0.0, 0.0)
	/// new BBMOD_Vec3(3.0, 0.0, 0.0).ClampLength(1.0, 2.0) // => BBMOD_Vec3(2.0, 0.0, 0.0)
	/// ```
	static ClampLength = function (_min, _max) {
		gml_pragma("forceinline");
		var _length = sqrt(
			  X * X
			+ Y * Y
			+ Z * Z
		);
		var _newLength = clamp(_length, _min, _max);
		return new BBMOD_Vec3(
			(X / _length) * _newLength,
			(Y / _length) * _newLength,
			(Z / _length) * _newLength,
		);
	};

	/// @func Clone()
	/// @desc Creates a clone of the vector.
	/// @return {BBMOD_Vec3} The creted vector.
	static Clone = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			X,
			Y,
			Z,
		);
	};

	/// @func Copy(_dest)
	/// @desc Copies components of the vector to the `_dest` vector.
	/// @param {BBMOD_Vec3} _dest The destination vector.
	/// @return {BBMOD_Vec3} Returns `self`.
	/// @example
	/// ```gml
	/// var _v1 = new BBMOD_Vec3(1.0, 2.0, 3.0);
	/// var _v2 = new BBMOD_Vec3(4.0, 5.0, 6.0);
	/// show_debug_message(_v2) // Prints { X: 4.0, Y: 5.0, Z: 6.0 }
	/// _v1.Copy(_v2);
	/// show_debug_message(_v2) // Prints { X: 1.0, Y: 2.0, Z: 3.0 }
	/// ```
	static Copy = function (_dest) {
		gml_pragma("forceinline");
		_dest.X = X;
		_dest.Y = Y;
		_dest.Z = Z;
		return self;
	};

	/// @func Cross(_v)
	/// @desc Computes a cross product of this vector and vector `_v` and returns
	/// the result as a new vector.
	/// @param {BBMOD_Vec3} The other vector.
	/// @return {BBMOD_Vec3} The created vector.
	static Cross = function (_v) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			Y * _v.Z - Z * _v.Y,
			Z * _v.X - X * _v.Z,
			X * _v.Y - Y * _v.X,
		);
	};

	/// @func Dot(_v)
	/// @desc Computes the dot product of this vector and vector `_v`.
	/// @param {BBMOD_Vec3} _v The other vector.
	/// @return {real} The dot product of this vector and vector `_v`.
	static Dot = function (_v) {
		gml_pragma("forceinline");
		return (
			  X * _v.X
			+ Y * _v.Y
			+ Z * _v.Z
		);
	};

	/// @func Equals(_v)
	/// @desc Checks whether this vectors equals to vector `_v`.
	/// @param {BBMOD_Vec3} _v The vector to compare to.
	/// @return {bool} Returns `true` if the two vectors are equal.
	static Equals = function (_v) {
		gml_pragma("forceinline");
		return (
			   X == _v.X
			&& Y == _v.Y
			&& Z == _v.Z
		);
	};

	/// @func Floor()
	/// @desc Applies function `floor` to each component of the vector and returns
	/// the result as a new vector.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec3(0.2, 1.6, 2.4).Floor() // => BBMOD_Vec3(0.0, 1.0, 2.0)
	/// ```
	static Floor = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			floor(X),
			floor(Y),
			floor(Z),
		);
	};

	/// @func Frac()
	/// @desc Applies function `frac` to each component of the vector and returns
	/// the result as a new vector.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec3(0.2, 1.6, 2.4).Frac() // => BBMOD_Vec3(0.2, 0.6, 0.4)
	/// ```
	static Frac = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			frac(X),
			frac(Y),
			frac(Z),
		);
	};

	/// @func FromArray(_array[, _index])
	/// @desc Loads vector components from an array.
	/// @param {real[]} _array The array to read the components from.
	/// @param {uint} [_index] The index to start reading the vector components
	/// from. Defaults to 0.
	/// @return {BBMOD_Vec3} Returns `self`.
	static FromArray = function (_array, _index) {
		gml_pragma("forceinline");
		_index = (_index != undefined) ? _index : 0;
		X = _array[_index];
		Y = _array[_index + 1];
		Z = _array[_index + 2];
		return self;
	};

	/// @func FromBarycentric(_v1, _v2, _v3, _f, _g)
	/// @desc Computes the vector components using a formula
	/// `_v1 + _f * (_v2 - _v1) + _g * (_v3 - _v1)`.
	/// @param {BBMOD_Vec3} _v1 The first point of a triangle.
	/// @param {BBMOD_Vec3} _v2 The second point of a triangle.
	/// @param {BBMOD_Vec3} _v3 The third point of a triangle.
	/// @param {real} _f The weighting factor between `_v1` and `_v2`.
	/// @param {real} _g The weighting factor between `_v1` and `_v3`.
	/// @return {BBMOD_Vec3} Returns `self`.
	static FromBarycentric = function (_v1, _v2, _v3, _f, _g) {
		gml_pragma("forceinline");
		var _v1X = _v1.X;
		var _v1Y = _v1.Y;
		var _v1Z = _v1.Z;
		X = _v1X + _f * (_v2.X - _v1X) + _g * (_v3.X - _v1X);
		Y = _v1Y + _f * (_v2.Y - _v1Y) + _g * (_v3.Y - _v1Y);
		Z = _v1Z + _f * (_v2.Z - _v1Z) + _g * (_v3.Z - _v1Z);
		return self;
	};

	/// @func FromBuffer(_buffer, _type)
	/// @desc Loads vector components from a buffer.
	/// @param {buffer} _buffer The buffer to read the components from.
	/// @param {int} _type The type of each component. Use one of the `buffer_`
	/// constants, e.g. `buffer_f32`.
	/// @return {BBMOD_Vec3} Returns `self`.
	static FromBuffer = function (_buffer, _type) {
		gml_pragma("forceinline");
		X = buffer_read(_buffer, _type);
		Y = buffer_read(_buffer, _type);
		Z = buffer_read(_buffer, _type);
		return self;
	};

	/// @func Length()
	/// @desc Computes the length of the vector.
	/// @return {real} The length of the vector.
	static Length = function () {
		gml_pragma("forceinline");
		return sqrt(
			  X * X
			+ Y * Y
			+ Z * Z
		);
	};

	/// @func LengthSqr()
	/// @desc Computes a squared length of the vector.
	/// @return {real} The squared length of the vector.
	static LengthSqr = function () {
		gml_pragma("forceinline");
		return (
			  X * X
			+ Y * Y
			+ Z * Z
		);
	};

	/// @func Lerp(_v, _amount)
	/// @desc Linearly interpolates between vector `_v` by the given amount.
	/// @param {BBMOD_Vec3} _v The vector to interpolate with.
	/// @param {real} _amount The interpolation factor.
	static Lerp = function (_v, _amount) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			lerp(X, _v.X, _amount),
			lerp(Y, _v.Y, _amount),
			lerp(Z, _v.Z, _amount),
		);
	};

	/// @func MaxComponent()
	/// @desc Computes the greatest component of the vector.
	/// @return {real} The greates component of the vector.
	static MaxComponent = function () {
		gml_pragma("forceinline");
		return max(
			X,
			Y,
			Z,
		);
	};

	/// @func Maximize(_v)
	/// @desc Creates a new vector where each component is the maximum component
	/// from this vector and vector `_v`.
	/// @param {BBMOD_Vec3} _v The other vector.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// var _v1 = new BBMOD_Vec3(1.0, 4.0, 5.0);
	/// var _v2 = new BBMOD_Vec3(2.0, 3.0, 6.0);
	/// var _vMax = _v1.Maximize(_v2); // Equals to BBMOD_Vec3(2.0, 4.0, 6.0)
	/// ```
	static Maximize = function (_v) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			max(X, _v.X),
			max(Y, _v.Y),
			max(Z, _v.Z),
		);
	};

	/// @func MinComponent()
	/// @desc Computes the smallest component of the vector.
	/// @return {real} The smallest component of the vector.
	static MinComponent = function () {
		gml_pragma("forceinline");
		return min(
			X,
			Y,
			Z,
		);
	};

	/// @func Minimize(_v)
	/// @desc Creates a new vector where each component is the minimum component
	/// from this vector and vector `_v`.
	/// @param {BBMOD_Vec3} _v The other vector.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// var _v1 = new BBMOD_Vec3(1.0, 4.0, 5.0);
	/// var _v2 = new BBMOD_Vec3(2.0, 3.0, 6.0);
	/// var _vMin = _v1.Minimize(_v2); // Equals to BBMOD_Vec3(1.0, 3.0, 5.0)
	/// ```
	static Minimize = function (_v) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			min(X, _v.X),
			min(Y, _v.Y),
			min(Z, _v.Z),
		);
	};

	/// @func Mul(_v)
	/// @desc Multiplies the vector with vector `_v` and returns the result
	/// as a new vector.
	/// @param {BBMOD_Vec3} _v The other vector.
	/// @return {BBMOD_Vec3} The created vector.
	static Mul = function (_v) {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			X * _v.X,
			Y * _v.Y,
			Z * _v.Z,
		);
	};

	/// @func Normalize()
	/// @desc Normalizes the vector and returns the result as a new vector.
	/// @return {BBMOD_Vec3} The created vector.
	static Normalize = function () {
		gml_pragma("forceinline");
		var _lengthSqr = (
			  X * X
			+ Y * Y
			+ Z * Z
		);
		if (_lengthSqr >= math_get_epsilon())
		{
			var _n = 1.0 / sqrt(_lengthSqr);
			return new BBMOD_Vec3(
				X * _n,
				Y * _n,
				Z * _n,
			);
		}
		return new BBMOD_Vec3(
			X,
			Y,
			Z,
		);
	};

	/// @func Orthonormalize(_v)
	/// @desc Orthonormalizes the vectors in-place using the Gram–Schmidt process.
	/// @param {BBMOD_Vec3} _v The other vector.
	/// @return {bool} Returns `true` if the vectors were orthonormalized.
	static Orthonormalize = function (_v) {
		gml_pragma("forceinline");

		var _v1 = Normalize();
		var _proj = _v1.Scale(_v.Dot(_v1));
		var _v2 = _v.Sub(_proj);

		if (_v2.Length() <= 0.0)
		{
			return false;
		}

		_v1.Copy(self);
		_v2.Normalize().Copy(_v);

		return true;
	};

	/// @func Reflect(_v)
	/// @desc Reflects the vector from vector `_v` and returns the result
	/// as a new vector.
	/// @param {BBMOD_Vec3} _v The vector to reflect from.
	/// @return {BBMOD_Vec3} The created vector.
	static Reflect = function (_v) {
		gml_pragma("forceinline");
		var _dot2 = (
			  X * _v.X
			+ Y * _v.Y
			+ Z * _v.Z
		) * 2.0;
		return new BBMOD_Vec3(
			X - (_dot2 * _v.X),
			Y - (_dot2 * _v.Y),
			Z - (_dot2 * _v.Z),
		);
	};

	/// @func Round()
	/// @desc Applies function `round` to each component of the vector and returns
	/// the result as a new vector.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec3(0.2, 1.6, 2.4).Round() // => BBMOD_Vec3(0.0, 2.0, 2.0)
	/// ```
	static Round = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec3(
			round(X),
			round(Y),
			round(Z),
		);
	};

	/// @func Scale(_s)
	/// @desc Scales each component of the vector by `_s` and returns the result
	/// as a new vector.
	/// @param {real} _s The value to scale the components by.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec3(1.0, 2.0, 3.0).Scale(2.0) // => BBMOD_Vec3(2.0, 4.0, 6.0)
	/// ```
	static Scale = function (_s) {
		gml_pragma("forceinline")
		return new BBMOD_Vec3(
			X * _s,
			Y * _s,
			Z * _s,
		);
	};

	/// @func Set([_x[, _y, _z]])
	/// @desc Sets vector components in-place.
	/// @param {real} [_x] The new value of the first component. Defaults to 0.
	/// @param {real} [_y] The new value of the second component. Defaults to `_x`.
	/// @param {real} [_z] The new value of the third component. Defaults to `_x`.
	/// @return {BBMOD_Vec3} Returns `self`.
	static Set = function (_x, _y, _z) {
		gml_pragma("forceinline");
		X = (_x != undefined) ? _x : 0.0;
		Y = (_y != undefined) ? _y : X;
		Z = (_z != undefined) ? _z : X;
		return self;
	};

	/// @func SetIndex(_index, _value)
	/// @desc Sets vector component in-place.
	/// @param {uint} _index The index of the component, starting at 0.
	/// @param {real} _value The new value of the component.
	/// @return {BBMOD_Vec3} Returns `self`.
	/// @throws {BBMOD_OutOfRangeException} If the given index is out of range
	/// of possible values.
	static SetIndex = function (_index, _value) {
		gml_pragma("forceinline");
		switch (_index)
		{
		case 0:
			X = _value;
			break;

		case 1:
			Y = _value;
			break;

		case 2:
			Z = _value;
			break;

		default:
			throw new BBMOD_OutOfRangeException();
			break;
		}
		return self;
	};

	/// @func Sub(_v)
	/// @desc Subtracts vector `_v` from this vector and returns the result
	/// as a new vector.
	/// @param {BBMOD_Vec3} _v The vector to subtract from this one.
	/// @return {BBMOD_Vec3} The created vector.
	/// @example
	/// ```gml
	/// var _v1 = new BBMOD_Vec3(1.0, 2.0, 3.0);
	/// var _v2 = new BBMOD_Vec3(4.0, 5.0, 6.0);
	/// var _v3 = _v1.Sub(_v2); // Equals to BBMOD_Vec3(-3.0, -3.0, -3.0)
	/// ```
	static Sub = function (_v) {
		gml_pragma("forceinline")
		return new BBMOD_Vec3(
			X - _v.X,
			Y - _v.Y,
			Z - _v.Z,
		);
	};

	/// @func ToArray([_array[, _index]])
	/// @desc Writes the components of the vector into the target array.
	/// @param {real[]} [_array] The array to write to. If not specified
	/// a new one of required size is created.
	/// @param {uint} [_index] The starting index within the target array.
	/// Defaults to 0.
	/// @return {real[]} The target array.
	static ToArray = function (_array, _index) {
		gml_pragma("forceinline");
		_array = (_array != undefined) ? _array : array_create(3, 0.0);
		_index = (_index != undefined) ? _index : 0;
		_array[@ _index]     = X;
		_array[@ _index + 1] = Y;
		_array[@ _index + 2] = Z;
		return _array;
	};

	/// @func ToBuffer(_buffer, _type)
	/// @desc Writes the components of the vector into the buffer.
	/// @param {buffer} _buffer The buffer to write to.
	/// @param {int} _type The type of the components. Use one of the `buffer_`
	/// constants, e.g. `buffer_f32`.
	/// @return {BBMOD_Vec3} Returns `self`.
	static ToBuffer = function (_buffer, _type) {
		gml_pragma("forceinline");
		buffer_write(_buffer, _type, X);
		buffer_write(_buffer, _type, Y);
		buffer_write(_buffer, _type, Z);
		return self;
	};

	/// @func Transform(_matrix)
	/// @desc Transforms vector `[X, Y, Z, 1.0]` by a matrix and returns the result
	/// as a new vector.
	/// @param {real[16]} _matrix The matrix to transform the vector by.
	/// @return {BBMOD_Vec3} The created vector.
	static Transform = function (_matrix) {
		gml_pragma("forceinline")
		var _res = matrix_transform_vertex(_matrix, X, Y, Z);
		return new BBMOD_Vec3(
			_res[0],
			_res[1],
			_res[2],
		);
	};
}