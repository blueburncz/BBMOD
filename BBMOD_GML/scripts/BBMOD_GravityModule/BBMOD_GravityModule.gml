/// @func BBMOD_GravityModule([_gravity])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_gravity]
function BBMOD_GravityModule(_gravity=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Gravity = _gravity ?? BBMOD_VEC3_UP.Scale(-1.0);

	static on_particle_update = function (_particle, _deltaTime) {
		_particle.Acceleration = _particle.Acceleration.Add(Gravity);
	};
}