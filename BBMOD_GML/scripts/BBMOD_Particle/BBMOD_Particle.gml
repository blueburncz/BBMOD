/// @func BBMOD_Particle(_id)
/// @param {Real} _id
function BBMOD_Particle(_id) constructor
{
	/// @var {Real}
	/// @readonly
	Id = _id;

	/// @var {Bool}
	IsAlive = false;

	/// @var {Struct.BBMOD_Vec3}
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3}
	Scale = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Color}
	Color = BBMOD_C_WHITE;
}