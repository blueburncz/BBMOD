/// @func BBMOD_InitialVelocityModule([_velocity])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that sets initial velocity of particles.
///
/// @param {Struct.BBMOD_Vec3/Undefined} [_velocity] The initial velocity
/// vector. Defaults to {@link BBMOD_VEC3_UP}.
///
/// @see BBMOD_EParticle.VelocityX
/// @see BBMOD_EParticle.VelocityY
/// @see BBMOD_EParticle.VelocityZ
function BBMOD_InitialVelocityModule(_velocity=BBMOD_VEC3_UP)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3} The initial velocity vector. Default value
	/// is {@link BBMOD_VEC3_UP}.
	Velocity = _velocity;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _velocity = Velocity;
		_particles[# BBMOD_EParticle.VelocityX, _particleIndex] = _velocity.X;
		_particles[# BBMOD_EParticle.VelocityY, _particleIndex] = _velocity.Y;
		_particles[# BBMOD_EParticle.VelocityZ, _particleIndex] = _velocity.Z;
	};
}
