/// @module Physics

/// @func BBMOD_CompoundPhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics
/// compound shape.
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_CompoundPhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	__type = BBMOD_EPhysicsShapeType.Compound;

	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		return self;
	};
}

/// @func BBMOD_CompoundPhysicsShape()
///
/// @desc A compound physics shape that can contain multiple child shapes.
///
/// @see BBMOD_PhysicsWorld.create_physics_shape
function BBMOD_CompoundPhysicsShape(): BBMOD_PhysicsShape() constructor
{
	/// @func add_child_shape(_childShape, _childTransform)
	///
	/// @desc Adds a child shape to this physics shape. This is only applicable
	/// to compound shapes, and will be ignored for other shape types.
	///
	/// @param {Struct.BBMOD_PhysicsShape} _childShape The child shape to add to
	/// this physics shape.
	/// @param {Struct.BBMOD_Matrix} _childTransform The transform of the child
	/// shape relative to this physics shape.
	///
	/// @return {Struct.BBMOD_CompoundPhysicsShape} Returns `self`.
	static add_child_shape = function (_childShape, _childTransform)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 16);
		_childTransform.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_PhysicsShape_AddChildShape(__id, _childShape.__id, buffer_get_address(_scratchBuffer));
		return self;
	};
}
