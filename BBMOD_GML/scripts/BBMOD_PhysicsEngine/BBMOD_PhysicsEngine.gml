/// @module Physics

/// @func BBMOD_PhysicsEngine()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc A struct that serves as the main entry point for the physics engine. It
/// provides methods for creating physics worlds and shapes, as well as other
/// related functionality.
///
/// @see BBMOD_PhysicsShape
/// @see BBMOD_PhysicsWorld
function BBMOD_PhysicsEngine() constructor
{
	/// @func create_physics_world([_info])
	///
	/// @desc Creates a new physics world with the specified information. If no
	/// information is provided, a default physics world will be created.
	///
	/// @param {Struct.BBMOD_PhysicsWorldInfo} [_info] Optional information for
	/// creating the physics world.
	///
	/// @return {Struct.BBMOD_PhysicsWorld} The created physics world.
	static create_physics_world = function (_info = new BBMOD_PhysicsWorldInfo())
	{
		gml_pragma("forceinline");
		var _physicsWorld = new BBMOD_PhysicsWorld();
		_physicsWorld.__id = BBMOD_PhysicsEngine_CreatePhysicsWorld(_info.to_abi());
		return _physicsWorld;
	};

	/// @func create_physics_shape(_info)
	///
	/// @desc Creates a new physics shape with the specified information.
	///
	/// @param {Struct.BBMOD_PhysicsShapeInfo} _info Information for creating
	/// the physics shape.
	///
	/// @return {Struct.BBMOD_PhysicsShape} The created physics shape.
	static create_physics_shape = function (_info)
	{
		gml_pragma("forceinline");

		var _shape = undefined;
		switch (_info.__type)
		{
			case BBMOD_EPhysicsShapeType.Box:
				_shape = new BBMOD_BoxPhysicsShape();
				break;

			case BBMOD_EPhysicsShapeType.Capsule:
				_shape = new BBMOD_CapsulePhysicsShape();
				break;

			case BBMOD_EPhysicsShapeType.Compound:
				_shape = new BBMOD_CompoundPhysicsShape();
				break;

			case BBMOD_EPhysicsShapeType.Cone:
				_shape = new BBMOD_ConePhysicsShape();
				break;

			case BBMOD_EPhysicsShapeType.ConvexHull:
				_shape = new BBMOD_ConvexHullPhysicsShape();
				break;

			case BBMOD_EPhysicsShapeType.Cylinder:
				_shape = new BBMOD_CylinderPhysicsShape();
				break;

			case BBMOD_EPhysicsShapeType.Plane:
				_shape = new BBMOD_PlanePhysicsShape();
				break;

			case BBMOD_EPhysicsShapeType.Sphere:
				_shape = new BBMOD_SpherePhysicsShape();
				break;

			case BBMOD_EPhysicsShapeType.StaticMesh:
				_shape = new BBMOD_StaticMeshPhysicsShape();
				break;

			default:
				bbmod_assert(false, $"Invalid physics shape type {_info.__type}!");
				break;
		}

		_shape.__id = BBMOD_PhysicsEngine_CreatePhysicsShape(_info.to_abi());

		return _shape;
	};

	static destroy = function ()
	{
		gml_pragma("forceinline");
		// TODO: Implement physics engine destruction
		return undefined;
	};
}
