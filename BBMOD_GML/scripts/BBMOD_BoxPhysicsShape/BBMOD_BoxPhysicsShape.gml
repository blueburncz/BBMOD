/// @module Physics

/// @func BBMOD_BoxPhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics
/// box shape.
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_BoxPhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsShapeType.Box;

	/// @var {Struct.BBMOD_Vec3} The size of the box shape. Default is
	/// a vector with all components set to `1.0`.
	Size = new BBMOD_Vec3(1.0);

	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		Size.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

/// @func BBMOD_BoxPhysicsShape()
///
/// @desc A box physics shape that represents a rectangular prism collision
/// shape.
///
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_BoxPhysicsShape(): BBMOD_PhysicsShape() constructor {}
