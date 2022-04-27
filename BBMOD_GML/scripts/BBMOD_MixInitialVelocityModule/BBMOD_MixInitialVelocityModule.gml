/// @func BBMOD_MixInitialVelocityModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_from]
/// @param {Struct.BBMOD_Vec3/Undefined} [_to]
function BBMOD_MixInitialVelocityModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	From = _from ?? BBMOD_VEC3_UP;

	/// @var {Struct.BBMOD_Vec3}
	To = _to ?? From;

	static on_particle_start = function (_emitter, _particleId) {
		var _particles = _emitter.Particles;
		var _from = From;
		var _to = To;
		_particles[# BBMOD_EParticle.VelocityX, _particleId] = lerp(_from.X, _to.X, random(1.0));
		_particles[# BBMOD_EParticle.VelocityY, _particleId] = lerp(_from.Y, _to.Y, random(1.0));
		_particles[# BBMOD_EParticle.VelocityZ, _particleId] = lerp(_from.Z, _to.Z, random(1.0));
	};
}
