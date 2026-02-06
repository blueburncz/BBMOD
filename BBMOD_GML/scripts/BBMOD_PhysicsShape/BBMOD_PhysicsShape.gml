/// @module Physics

/// @enum Enumeration of physics shape types.
enum BBMOD_EPhysicsShapeType
{
	/// @member An invalid shape type. This value is used as a default for
	/// physics shape info, and should be replaced with a valid type before
	/// creating a shape.
	Invalid = -1,
		/// @member A box shape.
		Box,
		/// @member A capsule shape.
		Capsule,
		/// @member A compound shape.
		Compound,
		/// @member A cone shape.
		Cone,
		/// @member A convex hull shape.
		ConvexHull,
		/// @member A cylinder shape.
		Cylinder,
		/// @member A plane shape.
		Plane,
		/// @member A sphere shape.
		Sphere,
		/// @member A static mesh shape.
		StaticMesh,
};

/// @func BBMOD_PhysicsShapeInfo()
///
/// @desc A struct containing the information needed to create a physics shape.
///
/// @see BBMOD_PhysicsEngine.create_physics_shape
/// @see BBMOD_PhysicsShape
function BBMOD_PhysicsShapeInfo() constructor
{
	__type = BBMOD_EPhysicsShapeType.Invalid;

	/// @var {Real} The margin of the physics shape. Default is `0.04`.
	Margin = 0.04;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the physics shape info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_PhysicsShapeInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_s8, __type);
		buffer_write(_buffer, buffer_f64, Margin);
		return self;
	};

	/// @func to_abi()
	///
	/// @desc Converts the physics shape info to a format suitable for passing
	/// to the native physics engine. This is used internally when creating a
	/// shape, and is not intended to be called directly by user code.
	///
	/// @return {Pointer} The address of the buffer containing the physics
	/// shape info.
	static to_abi = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		to_buffer(_scratchBuffer);
		return buffer_get_address(_scratchBuffer);
	};
}

/// @func BBMOD_PhysicsShape()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc A physics shape represents the collision shape of a physics body. It
/// can be shared between multiple physics bodies.
///
/// @see BBMOD_PhysicsEngine.create_physics_shape
function BBMOD_PhysicsShape() constructor
{
	__id = -1;

	/// @func get_type()
	///
	/// @desc Returns the type of this physics shape.
	///
	/// @return {Real} The type of this physics shape.
	///
	/// @see BBMOD_EPhysicsShapeType
	static get_type = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_PhysicsEngine_GetPhysicsShapeType(__id);
	};

	/// @func get_margin()
	///
	/// @desc Returns the margin of this physics shape.
	///
	/// @return {Real} The margin of this physics shape.
	static get_margin = function ()
	{
		gml_pragma("forceinline");
		return BBMOD_PhysicsEngine_GetPhysicsShapeMargin(__id);
	};

	/// @func set_margin(_margin)
	///
	/// @desc Sets the margin of this physics shape.
	///
	/// @param {Real} _margin The new margin of this physics shape.
	///
	/// @return {Struct.BBMOD_PhysicsShape} Returns `self`.
	static set_margin = function (_margin)
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsEngine_SetPhysicsShapeMargin(__id, _margin);
		return self;
	};

	/// @func get_local_scaling()
	///
	/// @desc Returns the local scaling of this physics shape.
	///
	/// @return {Struct.BBMOD_Vec3} The local scaling of this physics shape.
	static get_local_scaling = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		BBMOD_PhysicsEngine_GetPhysicsShapeLocalScaling(__id, buffer_get_address(_scratchBuffer));
		return new BBMOD_Vec3().FromBuffer(_scratchBuffer, buffer_f64);
	};

	/// @func set_local_scaling(_scaling)
	///
	/// @desc Sets the local scaling of this physics shape.
	///
	/// @param {Struct.BBMOD_Vec3} _scaling The new local scaling of this physics shape.
	///
	/// @return {Struct.BBMOD_PhysicsShape} Returns `self`.
	static set_local_scaling = function (_scaling)
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer(buffer_sizeof(buffer_f64) * 3);
		_scaling.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_PhysicsEngine_SetPhysicsShapeLocalScaling(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	static destroy = function ()
	{
		gml_pragma("forceinline");
		BBMOD_PhysicsEngine_DestroyPhysicsShape(__id);
		__id = -1;
		return undefined;
	};
}
