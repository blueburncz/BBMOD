/// @func BBMOD_Collider()
/// @desc Base struct for colliders.
/// @see BBMOD_AABBCollider
/// @see BBMOD_PlaneCollider
/// @see BBMOD_SphereCollider
function BBMOD_Collider() constructor
{
	/// @func GetClosestPoint(_point)
	/// @desc Retrieves a point on the surface of the collider that is closest
	/// to the point specified.
	/// @param {Struct.BBMOD_Vec3} _point The point to get the closest point to.
	/// @return {Struct.BBMOD_Vec3} A point on the surface of the collider that
	/// is closest to the point specified.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static GetClosestPoint = function (_point) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func TestAABB(_aabb)
	/// @desc Tests whether the collider intersects with an AABB.
	/// @param {Struct.BBMOD_AABBCollider} _aabb The AABB to check intersection
	/// with.
	/// @return {Bool} Returns `true` if the colliders intersect.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static TestAABB = function (_aabb) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func TestPlane(_plane)
	/// @desc Tests whether the collider intersects with a plane.
	/// @param {Struct.BBMOD_PlaneCollider} _plane The plane to check intersection
	/// with.
	/// @return {Bool} Returns `true` if the colliders intersect.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static TestPlane = function (_plane) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func TestPoint(_point)
	/// @desc Tests whether the collider intersects with a point.
	/// @param {Struct.BBMOD_Vec3} _point The point to check intersection with.
	/// @return {Bool} Returns `true` if the colliders intersect.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static TestPoint = function (_point) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func TestSphere(_sphere)
	/// @desc Tests whether the collider intersects with a sphere.
	/// @param {Struct.BBMOD_SphereCollider} _sphere The sphere to check
	/// intersection with.
	/// @return {Bool} Returns `true` if the colliders intersect.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static TestSphere = function (_sphere) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func Raycast(_ray)
	/// @desc Casts a ray against the collider.
	/// @param {Struct.BBMOD_Ray} _ray The ray to cast.
	/// @param {Struct.BBMOD_RaycastResult/Undefined} [_result] Where to store
	/// additional raycast info to.
	/// @return {Bool} Returns `true` if the ray hits the collider.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	/// @see BBMOD_RaycastResult
	/// @see BBMOD_Ray.Raycast
	static Raycast = function (_ray, _result=undefined) {
		throw new BBMOD_NotImplementedException();
	};
}