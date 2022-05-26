/// @func BBMOD_InitialScaleModule([_scale])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_scale]
function BBMOD_InitialScaleModule(_scale=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Scale = _scale ?? new BBMOD_Vec3(1.0);

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _scale = Scale;
		_particles[# BBMOD_EParticle.ScaleX, _particleIndex] = _scale.X;
		_particles[# BBMOD_EParticle.ScaleY, _particleIndex] = _scale.Y;
		_particles[# BBMOD_EParticle.ScaleZ, _particleIndex] = _scale.Z;
	};
}
