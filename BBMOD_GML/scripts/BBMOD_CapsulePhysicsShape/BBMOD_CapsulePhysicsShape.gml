/// @module Physics

function BBMOD_CapsulePhysicsShapeInfo(): BBMOD_PhysicsShapeInfo() constructor
{
	static PhysicsShapeInfo_to_buffer = to_buffer;

	Radius = 1;
	Height = 1;

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the capsule shape info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_CapsulePhysicsShapeInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		PhysicsShapeInfo_to_buffer(_buffer);
		buffer_write(_buffer, buffer_f64, Radius);
		buffer_write(_buffer, buffer_f64, Height);
		return self;
	};
}

function BBMOD_CapsulePhysicsShape(): BBMOD_PhysicsShape() constructor
{
}

// X

function BBMOD_CapsuleXPhysicsShapeInfo(): BBMOD_CapsulePhysicsShapeInfo() constructor
{
}

function BBMOD_CapsuleXPhysicsShape(): BBMOD_CapsulePhysicsShape() constructor
{
}

// Y

function BBMOD_CapsuleYPhysicsShapeInfo(): BBMOD_CapsulePhysicsShapeInfo() constructor
{
}

function BBMOD_CapsuleYPhysicsShape(): BBMOD_CapsulePhysicsShape() constructor
{
}

// Z

function BBMOD_CapsuleZPhysicsShapeInfo(): BBMOD_CapsulePhysicsShapeInfo() constructor
{
}

function BBMOD_CapsuleZPhysicsShape(): BBMOD_CapsulePhysicsShape() constructor
{
}
