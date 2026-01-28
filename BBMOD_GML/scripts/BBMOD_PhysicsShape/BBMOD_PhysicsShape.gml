/// @module Physics

function BBMOD_PhysicsShapeInfo() constructor
{
	Margin = 0.04;
	Transform = new BBMOD_Matrix();

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the physics shape info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_PhysicsShapeInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_f64, Margin);
		Transform.ToBuffer(_buffer, buffer_f64);
		return self;
	};
}

function BBMOD_PhysicsShape() constructor
{
	__id = -1;
}
