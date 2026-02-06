/// @module Physics

/// @enum Enumeration of physics constraint types.
enum BBMOD_EPhysicsConstraintType
{
	/// @member An invalid constraint type. This value is used as a default for
	/// physics constraint info, and should be replaced with a valid type before
	/// creating a constraint.
	Invalid = -1,
		/// @member A constraint that allows two bodies to rotate around a common
		/// point, but not to translate relative to each other.
		ConeTwist,
		/// @member A constraint that allows two bodies to rotate around a common
		/// point, but not to translate relative to each other. Similar to
		/// `ConeTwist`, but with more limited rotation.
		Hinge,
		/// @member A constraint that allows two bodies to maintain a fixed
		/// distance from each other.
		Point,
		/// @member A constraint that allows six degrees of freedom between
		/// two bodies.
		SixDOF,
		/// @member A constraint that allows one body to slide along a single
		/// axis relative to another body.
		Slider,
};

/// @func BBMOD_PhysicsConstraintInfo()
///
/// @desc A struct containing the information needed to create a physics
/// constraint.
///
/// @see BBMOD_PhysicsConstraint
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_PhysicsConstraintInfo() constructor
{
	__type = BBMOD_EPhysicsConstraintType.Invalid;

	/// @var {Struct.BBMOD_RigidBody} The first rigid body connected by the
	/// constraint
	RigidBody1 = undefined;

	/// @var {Struct.BBMOD_RigidBody} The second rigid body connected by the
	/// constraint. Optional for all types except of `SixDOF`. Default is
	/// `undefined`.
	RigidBody2 = undefined;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the physics constraint info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_PhysicsConstraintInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_f64, __type);
		buffer_write(_buffer, buffer_f64, RigidBody1.__id);
		buffer_write(_buffer, buffer_f64, (RigidBody2 != undefined) ? RigidBody2.__id : -1);
		return self;
	};

	/// @func to_abi()
	///
	/// @desc Converts the physics constraint info to a format suitable for
	/// passing to the native physics engine. This is used internally when
	/// creating a constraint, and is not intended to be called directly by user
	/// code.
	///
	/// @return {Pointer} The address of the buffer containing the physics
	/// constraint info.
	static to_abi = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		to_buffer(_scratchBuffer);
		return buffer_get_address(_scratchBuffer);
	};
}

/// @func BBMOD_PhysicsConstraint()
///
/// @desc A physics constraint that can be added to a physics world.
///
/// @see BBMOD_PhysicsWorld.create_constraint
function BBMOD_PhysicsConstraint() constructor
{
	__type = BBMOD_EPhysicsConstraintType.Invalid;
	__id = -1;
	__physicsWorld = undefined;
}
