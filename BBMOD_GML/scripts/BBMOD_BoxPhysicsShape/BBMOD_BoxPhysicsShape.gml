/// @module Physics

function BBMOD_BoxPhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	Size = new BBMOD_Vec3(0.5);

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the sphere shape info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_SpherePhysicsShapeInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		Size.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

function BBMOD_BoxPhysicsShape(): BBMOD_PhysicsShape() constructor {}
