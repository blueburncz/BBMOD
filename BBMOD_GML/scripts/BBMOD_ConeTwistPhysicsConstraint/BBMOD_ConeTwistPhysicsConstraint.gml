/// @module Physics

/// @func BBMOD_ConeTwistPhysicsConstraintInfo()
///
/// @desc A struct containing the information needed to create a cone twist
/// physics constraint.
///
/// @example
/// ```gml
/// // Create two bodies to connect with a ball-socket joint
/// var _bodyAInfo = new BBMOD_RigidBodyInfo();
/// _bodyAInfo.Shape = boxShape;
/// _bodyAInfo.Mass = 10.0;
/// _bodyAInfo.Position = new BBMOD_Vec3(0, 0, 5);
/// var _bodyA = physicsWorld.create_rigid_body(_bodyAInfo);
///
/// var _bodyBInfo = new BBMOD_RigidBodyInfo();
/// _bodyBInfo.Shape = boxShape;
/// _bodyBInfo.Mass = 10.0;
/// _bodyBInfo.Position = new BBMOD_Vec3(0, 0, 3);
/// var _bodyB = physicsWorld.create_rigid_body(_bodyBInfo);
///
/// // Create a cone twist (ball-socket) constraint
/// var _coneTwistInfo = new BBMOD_ConeTwistPhysicsConstraintInfo();
/// _coneTwistInfo.RigidBody1 = _bodyA;
/// _coneTwistInfo.RigidBody2 = _bodyB;
/// // Frames can be set to orient the joint axes
/// _coneTwistInfo.Frame1 = new BBMOD_Matrix();
/// _coneTwistInfo.Frame2 = new BBMOD_Matrix();
/// var _joint = physicsWorld.create_constraint(_coneTwistInfo);
/// ```
///
/// @see BBMOD_PhysicsConstraint
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_ConeTwistPhysicsConstraintInfo(): BBMOD_PhysicsConstraintInfo() constructor
{
	static PhysicsConstraint_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsConstraintType.ConeTwist;

	// @var {Struct.BBMOD_Matrix} The frame of the first rigid body in the
	/// constraint. Default is the identity matrix.
	Frame1 = new BBMOD_Matrix();

	/// @var {Struct.BBMOD_Matrix} The frame of the second rigid body in the
	/// constraint. Default is the identity matrix.
	Frame2 = new BBMOD_Matrix();

	static to_buffer = function (_buffer)
	{
		PhysicsConstraint_to_buffer(_buffer);
		Frame1.ToBuffer(_buffer, buffer_f64);
		Frame2.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

/// @func BBMOD_ConeTwistPhysicsConstraint()
///
/// @desc A cone twist physics constraint that constrains two rigid bodies to
/// rotate around a common point while allowing for a limited cone of motion.
/// This constraint is also known as a "spherical" or "ball and socket"
/// constraint.
///
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_ConeTwistPhysicsConstraint(): BBMOD_PhysicsConstraint() constructor
{
	__type = BBMOD_EPhysicsConstraintType.ConeTwist;
	__id = -1;
	__physicsWorld = undefined;
}
