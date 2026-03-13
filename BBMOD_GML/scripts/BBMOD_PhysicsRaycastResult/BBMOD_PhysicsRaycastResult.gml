/// @module Physics

/// @func BBMOD_PhysicsRaycastResult()
///
/// @desc A structure for holding raycast result data from the
/// physics system. Used by {@link BBMOD_PhysicsWorld.raycast}.
///
/// @see BBMOD_PhysicsWorld.raycast
function BBMOD_PhysicsRaycastResult() constructor
{
	/// @var {Bool} Whether the ray hit anything.
	Hit = false;

	/// @var {Struct.BBMOD_Vec3} The world position where the ray hit.
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The normal vector at the collision
	/// point.
	Normal = new BBMOD_Vec3();

	/// @var {Real} The fraction along the ray where the hit occurred
	/// (0-1). 0 means the hit was at the ray start, 1 means at the ray
	/// end.
	Fraction = 0.0;

	/// @var {Real} The ID of the hit rigid body. Use this to look up
	/// the body from your own tracking system. Returns -1 if no rigid
	/// body was hit.
	BodyId = -1;

	/// @func reset()
	///
	/// @desc Resets properties to their default values.
	///
	/// @return {Struct.BBMOD_PhysicsRaycastResult} Returns `self`.
	static reset = function ()
	{
		gml_pragma("forceinline");
		Hit = false;
		Position.Set(0, 0, 0);
		Normal.Set(0, 0, 0);
		Fraction = 0.0;
		BodyId = -1;
		return self;
	};
}
