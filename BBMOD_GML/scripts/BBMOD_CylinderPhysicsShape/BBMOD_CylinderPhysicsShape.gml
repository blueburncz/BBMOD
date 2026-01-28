/// @module Physics

function BBMOD_CylinderPhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	Radius = 1;
	Height = 1;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the cylinder shape info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_CylinderPhysicsShapeInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		buffer_write(_buffer, buffer_f64, Radius);
		buffer_write(_buffer, buffer_f64, Height);
		return self;
	};
}

function BBMOD_CylinderPhysicsShape(): BBMOD_PhysicsShape() constructor
{
}

// X

function BBMOD_CylinderXPhysicsShapeInfo(): BBMOD_CylinderPhysicsShapeInfo() constructor
{
}

function BBMOD_CylinderXPhysicsShape(): BBMOD_CylinderPhysicsShape() constructor
{
}

// Y

function BBMOD_CylinderYPhysicsShapeInfo(): BBMOD_CylinderPhysicsShapeInfo() constructor
{
}

function BBMOD_CylinderYPhysicsShape(): BBMOD_CylinderPhysicsShape() constructor
{
}

// Z

function BBMOD_CylinderZPhysicsShapeInfo(): BBMOD_CylinderPhysicsShapeInfo() constructor
{
}

function BBMOD_CylinderZPhysicsShape(): BBMOD_CylinderPhysicsShape() constructor
{
}
