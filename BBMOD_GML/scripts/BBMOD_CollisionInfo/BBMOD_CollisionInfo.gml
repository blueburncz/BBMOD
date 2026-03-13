/// @module Physics

/// @func BBMOD_CollisionInfo()
///
/// @desc A struct containing information about a collision between
/// two rigid bodies. This is returned by
/// BBMOD_PhysicsWorld.get_collisions() and represents an active
/// collision pair in the physics world.
///
/// @see BBMOD_PhysicsWorld.get_collisions
function BBMOD_CollisionInfo() constructor
{
	/// @var {Real} The ID of the first rigid body in the collision.
	/// Use this to look up the body if needed.
	Body1Id = -1;

	/// @var {Real} The ID of the second rigid body in the collision.
	/// Use this to look up the body if needed.
	Body2Id = -1;

	/// @var {Real} The number of contact points between the two
	/// bodies. More contact points generally means a larger contact
	/// area.
	ContactCount = 0;

	/// @var {Real} The total accumulated impulse from all contact
	/// points in this collision. Represents the "strength" of the
	/// collision.
	TotalImpulse = 0.0;

	/// @func reset()
	///
	/// @desc Resets all properties to their default values.
	///
	/// @return {Struct.BBMOD_CollisionInfo} Returns `self`.
	static reset = function ()
	{
		gml_pragma("forceinline");
		Body1Id = -1;
		Body2Id = -1;
		ContactCount = 0;
		TotalImpulse = 0.0;
		return self;
	};
}
