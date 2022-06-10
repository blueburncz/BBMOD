/// @func BBMOD_InitialScaleModule([_scale])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that sets initial scale of particles.
///
/// @param {Struct.BBMOD_Vec3} [_scale] The initial scale of particles.
/// Defaults to `(1.0, 1.0, 1.0)`.
///
/// @see BBMOD_EParticle.ScaleX
/// @see BBMOD_EParticle.ScaleY
/// @see BBMOD_EParticle.ScaleZ
function BBMOD_InitialScaleModule(_scale=new BBMOD_Vec3(1.0))
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3} The initial scale of particles.
	/// Default value is `(1.0, 1.0, 1.0)`.
	Scale = _scale;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _scale = Scale;
		_particles[# BBMOD_EParticle.ScaleX, _particleIndex] = _scale.X;
		_particles[# BBMOD_EParticle.ScaleY, _particleIndex] = _scale.Y;
		_particles[# BBMOD_EParticle.ScaleZ, _particleIndex] = _scale.Z;
	};
}
