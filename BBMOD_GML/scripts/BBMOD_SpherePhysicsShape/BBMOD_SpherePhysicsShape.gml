/// @module Physics

function BBMOD_SpherePhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	Radius = 0.5;

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
		buffer_write(_buffer, buffer_f64, Radius);
		return self;
	};
}

function BBMOD_SpherePhysicsShape(): BBMOD_PhysicsShape() constructor {}
