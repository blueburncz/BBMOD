/// @module Physics

function BBMOD_PhysicsConstraintInfo() constructor
{
	/// @func to_buffer(_buffer)
	///
	/// @desc Writes the physics constraint info into given buffer.
	///
	/// @param {Id.Buffer} The buffer to write the info to.
	///
	/// @return {Struct.BBMOD_PhysicsConstraintInfo} Returns `self`.
	static to_buffer = function (_buffer)
	{
		return self;
	};
}

function BBMOD_PhysicsConstraint() constructor
{
	__id = -1;
}
