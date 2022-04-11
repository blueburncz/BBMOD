/// @func BBMOD_Ray(_origin, _direction)
/// @desc A ray used to raycast colliders.
/// @param {Struct.BBMOD_Vec3} _origin The ray's origin.
/// @param {Struct.BBMOD_Vec3} _direction The ray's direction. Should be
/// normalized!
/// @see BBMOD_Collider.Raycast
function BBMOD_Ray(_origin, _direction) constructor
{
	/// @var {Struct.BBMOD_Vec3} The ray's origin.
	Origin = _origin;

	/// @var {Struct.BBMOD_Vec3} The ray's direction. Should be normalized!
	Direction = _direction;

	/// @func Raycast(_collider[, _result])
	/// @desc Casts the ray against a collider.
	/// @param {Struct.BBMOD_Collider} _collider The collider to cast the ray
	/// against.
	/// @param {Struct.BBMOD_RaycastResult/Undefined} [_result] Where to store
	/// additional raycast info to.
	/// @return {Bool} Returns `true` if the ray hits the collider.
	/// @throws {BBMOD_NotImplementedException} If the collider does not
	/// implement method `Raycast`.
	/// @note This is the same as calling `_collider.Raycast(_ray, _result)`!
	/// @see BBMOD_RaycastResult
	/// @see BBMOD_Collider.Raycast
	static Raycast = function (_collider, _result=undefined) {
		gml_pragma("forceinline");
		return _collider.Raycast(self, _result);
	};
}