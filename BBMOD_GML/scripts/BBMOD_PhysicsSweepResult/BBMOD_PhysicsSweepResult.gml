/// @module Physics

/// @func BBMOD_PhysicsSweepResult()
///
/// @desc A structure for holding shape sweep (cast) result data from
/// the physics system. Used by {@link BBMOD_PhysicsWorld.shape_sweep}.
///
/// @see BBMOD_PhysicsWorld.shape_sweep
function BBMOD_PhysicsSweepResult() constructor
{
	/// @var {Bool} Whether the sweep hit anything.
	Hit = false;

	/// @var {Struct.BBMOD_Vec3} The world position where the sweep
	/// hit.
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The normal vector at the collision
	/// point.
	Normal = new BBMOD_Vec3();

	/// @var {Real} The fraction along the sweep where the hit occurred
	/// (0-1). 0 means the hit was at the sweep start, 1 means at the
	/// sweep end.
	Fraction = 0.0;

	/// @var {Real} The ID of the hit rigid body. Use this to look up
	/// the body from your own tracking system. Returns -1 if no rigid
	/// body was hit.
	BodyId = -1;

	/// @func reset()
	///
	/// @desc Resets properties to their default values.
	///
	/// @return {Struct.BBMOD_PhysicsSweepResult} Returns `self`.
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
