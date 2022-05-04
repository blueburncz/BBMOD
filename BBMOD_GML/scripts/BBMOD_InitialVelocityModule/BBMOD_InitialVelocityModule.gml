/// @func BBMOD_InitialVelocityModule([_velocity])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_velocity]
function BBMOD_InitialVelocityModule(_velocity=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Velocity = _velocity ?? BBMOD_VEC3_UP;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _velocity = Velocity;
		_particles[# BBMOD_EParticle.VelocityX, _particleIndex] = _velocity.X;
		_particles[# BBMOD_EParticle.VelocityY, _particleIndex] = _velocity.Y;
		_particles[# BBMOD_EParticle.VelocityZ, _particleIndex] = _velocity.Z;
	};
}
