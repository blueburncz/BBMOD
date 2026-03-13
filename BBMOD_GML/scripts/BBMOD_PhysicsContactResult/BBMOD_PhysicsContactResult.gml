/// @module Physics

/// @func BBMOD_PhysicsContactResult()
///
/// @desc A structure for holding contact point data from the physics
/// system. Contains information about a single contact point between
/// two rigid bodies.
///
/// @see BBMOD_PhysicsWorld.get_contact_points
function BBMOD_PhysicsContactResult() constructor
{
	/// @var {Struct.BBMOD_Vec3} The contact point position on body A
	/// in world space.
	PositionOnA = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The contact point position on body B
	/// in world space.
	PositionOnB = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The contact normal vector pointing
	/// from B to A.
	Normal = new BBMOD_Vec3();

	/// @var {Real} The penetration depth (negative means separation).
	Depth = 0.0;

	/// @var {Real} The normal impulse applied at this contact point.
	Impulse = 0.0;

	/// @func reset()
	///
	/// @desc Resets properties to their default values.
	///
	/// @return {Struct.BBMOD_PhysicsContactResult} Returns `self`.
	static reset = function ()
	{
		gml_pragma("forceinline");
		PositionOnA.Set(0, 0, 0);
		PositionOnB.Set(0, 0, 0);
		Normal.Set(0, 0, 0);
		Depth = 0.0;
		Impulse = 0.0;
		return self;
	};
}
