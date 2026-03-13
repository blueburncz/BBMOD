/// @module Physics

/// @func BBMOD_CompoundPhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics
/// compound shape.
///
/// @example
/// ```gml
/// // Create a compound shape (use add_child_shape after creation)
/// var _compoundInfo = new BBMOD_CompoundPhysicsShapeInfo();
/// var _compoundShape = physicsEngine.create_physics_shape(_compoundInfo);
///
/// // See add_child_shape() method for example of adding child shapes
/// ```
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld.create_physics_shape
/// @see BBMOD_CompoundPhysicsShape.add_child_shape
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
	///
	/// @example
	/// ```gml
	/// // Create a dumbbell shape with two spheres connected by a cylinder
	/// var _compoundInfo = new BBMOD_CompoundPhysicsShapeInfo();
	/// var _compoundShape = physicsEngine.create_physics_shape(_compoundInfo);
	///
	/// // Create child shapes
	/// var _sphereInfo = new BBMOD_SpherePhysicsShapeInfo();
	/// _sphereInfo.Radius = 0.3;
	/// var _sphere1 = physicsEngine.create_physics_shape(_sphereInfo);
	/// var _sphere2 = physicsEngine.create_physics_shape(_sphereInfo);
	///
	/// var _cylinderInfo = new BBMOD_CylinderPhysicsShapeInfo();
	/// _cylinderInfo.Radius = 0.1;
	/// _cylinderInfo.Height = 1.0;
	/// var _cylinder = physicsEngine.create_physics_shape(_cylinderInfo);
	///
	/// // Add child shapes at different positions
	/// var _leftTransform = new BBMOD_Matrix().Translate(-0.5, 0, 0);
	/// var _rightTransform = new BBMOD_Matrix().Translate(0.5, 0, 0);
	/// var _centerTransform = new BBMOD_Matrix();
	///
	/// _compoundShape.add_child_shape(_sphere1, _leftTransform);
	/// _compoundShape.add_child_shape(_sphere2, _rightTransform);
	/// _compoundShape.add_child_shape(_cylinder, _centerTransform);
	/// ```
	static add_child_shape = function (_childShape, _childTransform)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 16);
		_childTransform.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_PhysicsShape_AddChildShape(__id, _childShape.__id, buffer_get_address(_scratchBuffer));
		return self;
	};
}
