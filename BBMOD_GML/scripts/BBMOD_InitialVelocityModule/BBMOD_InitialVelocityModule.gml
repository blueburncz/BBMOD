/// @func BBMOD_InitialVelocityModule([_velocity])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_velocity]
function BBMOD_InitialVelocityModule(_velocity=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Velocity = _velocity ?? BBMOD_VEC3_UP;

	static on_particle_start = function (_particle) {
		_particle.Velocity = Velocity.Clone();
	};
}
