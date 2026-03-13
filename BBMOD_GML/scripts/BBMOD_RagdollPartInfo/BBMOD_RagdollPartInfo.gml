/// @module Physics

/// @func BBMOD_RagdollPartInfo()
///
/// @desc A struct containing information for creating a ragdoll body part.
/// This defines the collision shape, mass, and constraints for a single bone
/// in a ragdoll system.
///
/// @see BBMOD_RagdollInfo
/// @see BBMOD_Ragdoll
function BBMOD_RagdollPartInfo() constructor
{
	/// @var {String} Display name for this ragdoll part (used in UI)
	Name = "";

	/// @var {Bool} Whether this part is expanded in the UI editor
	Expand = false;

	/// @var {Struct.BBMOD_Node} The bone this ragdoll part is attached to.
	/// This must be a bone node from the model's skeleton.
	Bone = undefined;

	/// @var {Real} The physics shape type for this body part. Use one of the
	/// BBMOD_EPhysicsShapeType or EPhysicsShape constants.
	/// Default is Capsule, which works well for limbs.
	Type = BBMOD_EPhysicsShapeType.Capsule;

	/// @var {Real} The up axis for capsule/cone/cylinder shapes. Use one of
	/// the BBMOD_EAxis or EAxis constants. Default is Y (vertical).
	Direction = BBMOD_EAxis.Y;

	/// @var {Struct.BBMOD_Vec3} Offset of the collision shape from the bone's
	/// origin. Use this to position the shape correctly relative to the bone.
	Offset = new BBMOD_Vec3(0, 0, 0);

	/// @var {Struct.BBMOD_Vec3} Size of the collision shape:
	/// - Box: Half-extents (width, height, depth)
	/// - Sphere: X component is radius (Y and Z ignored)
	/// - Capsule: X is radius, Y is cylinder height (excluding caps)
	/// - Cone/Cylinder: Similar to capsule
	Size = new BBMOD_Vec3(0.1, 0.1, 0.1);

	/// @var {Real} Mass of this body part in kg. Higher mass makes the part
	/// harder to move. Typical values: 5-15 kg for limbs, 12-25 kg for torso.
	Mass = 1.0;

	/// @var {Struct.BBMOD_Node} The parent bone to connect this part to with
	/// a constraint. Set to `undefined` for root parts (no constraint).
	ConnectedToBone = undefined;

	/// @var {Struct.BBMOD_Vec3} Angular lower limits for the constraint in
	/// degrees (X, Y, Z rotation). Negative values allow rotation in that
	/// direction. For example, (-90, 0, 0) allows 90 degrees of backward bend.
	LowerLimit = new BBMOD_Vec3(-45, -45, -45);

	/// @var {Struct.BBMOD_Vec3} Angular upper limits for the constraint in
	/// degrees (X, Y, Z rotation). Positive values allow rotation in that
	/// direction. For example, (90, 0, 0) allows 90 degrees of forward bend.
	UpperLimit = new BBMOD_Vec3(45, 45, 45);
}
