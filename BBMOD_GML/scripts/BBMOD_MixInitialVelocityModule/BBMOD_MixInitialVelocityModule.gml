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
		_emitter.Particles[# BBMOD_EParticle.VelocityX, _particleId] = lerp(From.X, To.X, random(1.0));
		_emitter.Particles[# BBMOD_EParticle.VelocityY, _particleId] = lerp(From.Y, To.Y, random(1.0));
		_emitter.Particles[# BBMOD_EParticle.VelocityZ, _particleId] = lerp(From.Z, To.Z, random(1.0));
	};
}
