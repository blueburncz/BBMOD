/// @module Physics

/// @func BBMOD_PhysicsEngine()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc
function BBMOD_PhysicsEngine() constructor
{
	/// @func create_physics_world([_info])
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_PhysicsWorldInfo} [_info]
	///
	/// @return {Struct.BBMOD_PhysicsWorld}
	static create_physics_world = function (_info = new BBMOD_PhysicsWorldInfo())
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _physicsWorld = new BBMOD_PhysicsWorld();
		_physicsWorld.__id = BBMOD_PhysicsEngine_CreatePhysicsWorld(buffer_get_address(_scratchBuffer));
		return _physicsWorld;
	};

	/// @func create_box_shape(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_BoxPhysicsShapeInfo} _info
	///
	/// @return {Struct.BBMOD_BoxPhysicsShape}
	static create_box_shape = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _shape = new BBMOD_BoxPhysicsShape();
		_shape.__id = BBMOD_PhysicsEngine_CreateBoxShape(buffer_get_address(_scratchBuffer));
		return _shape;
	};

	/// @func create_capsule_x_shape(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_CapsuleXPhysicsShapeInfo} _info
	///
	/// @return {Struct.BBMOD_CapsuleXPhysicsShape}
	static create_capsule_x_shape = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _shape = new BBMOD_CapsuleXPhysicsShape();
		_shape.__id = BBMOD_PhysicsEngine_CreateCapsuleXShape(buffer_get_address(_scratchBuffer));
		return _shape;
	};

	/// @func create_capsule_y_shape(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_CapsuleYPhysicsShapeInfo} _info
	///
	/// @return {Struct.BBMOD_CapsuleYPhysicsShape}
	static create_capsule_y_shape = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _shape = new BBMOD_CapsuleYPhysicsShape();
		_shape.__id = BBMOD_PhysicsEngine_CreateCapsuleYShape(buffer_get_address(_scratchBuffer));
		return _shape;
	};

	/// @func create_capsule_z_shape(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_CapsuleZPhysicsShapeInfo} _info
	///
	/// @return {Struct.BBMOD_CapsuleZPhysicsShape}
	static create_capsule_z_shape = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _shape = new BBMOD_CapsuleZPhysicsShape();
		_shape.__id = BBMOD_PhysicsEngine_CreateCapsuleZShape(buffer_get_address(_scratchBuffer));
		return _shape;
	};

	/// @func create_cone_x_shape(_radius, _height)
	///
	/// @desc
	///
	/// @param {Real} _radius
	/// @param {Real} _height
	///
	/// @return {Struct.BBMOD_ConeXPhysicsShape}
	static create_cone_x_shape = function (_radius, _height)
	{
		gml_pragma("forceinline");
		var _shape = new BBMOD_ConePhysicsShape();
		_shape.__id = BBMOD_PhysicsEngine_CreateConeXShape(_radius, _height);
		return _shape;
	};

	/// @func create_cone_y_shape(_radius, _height)
	///
	/// @desc
	///
	/// @param {Real} _radius
	/// @param {Real} _height
	///
	/// @return {Struct.BBMOD_ConeYPhysicsShape}
	static create_cone_y_shape = function (_radius, _height)
	{
		gml_pragma("forceinline");
		var _shape = new BBMOD_ConeYPhysicsShape();
		_shape.__id = BBMOD_PhysicsEngine_CreateConeYShape(_radius, _height);
		return _shape;
	};

	/// @func create_cone_z_shape(_radius, _height)
	///
	/// @desc
	///
	/// @param {Real} _radius
	/// @param {Real} _height
	///
	/// @return {Struct.BBMOD_ConeZPhysicsShape}
	static create_cone_z_shape = function (_radius, _height)
	{
		gml_pragma("forceinline");
		var _shape = new BBMOD_ConeZPhysicsShape();
		_shape.__id = BBMOD_PhysicsEngine_CreateConeZShape(_radius, _height);
		return _shape;
	};

	/// @func create_sphere_shape(_info)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_SpherePhysicsShapeInfo} _info
	///
	/// @return {Struct.BBMOD_SpherePhysicsShape}
	static create_sphere_shape = function (_info)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_info.to_buffer(_scratchBuffer);
		var _shape = new BBMOD_SpherePhysicsShape();
		_shape.__id = BBMOD_PhysicsEngine_CreateSphereShape(buffer_get_address(_scratchBuffer));
		return _shape;
	};

	static destroy = function ()
	{
		gml_pragma("forceinline");
		return undefined;
	};
}
