/// @func BBMOD_MixInitialScaleModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_from]
/// @param {Struct.BBMOD_Vec3/Undefined} [_to]
function BBMOD_MixInitialScaleModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	From = _from ?? new BBMOD_Vec3(1.0);

	/// @var {Struct.BBMOD_Vec3}
	To = _to ?? _from;

	static on_particle_start = function (_emitter, _particleId) {
		var _factor = random(1.0);
		_emitter.Particles[# BBMOD_EParticle.ScaleX, _particleId] = lerp(From.X, To.X, _factor);
		_emitter.Particles[# BBMOD_EParticle.ScaleY, _particleId] = lerp(From.Y, To.Y, _factor);
		_emitter.Particles[# BBMOD_EParticle.ScaleZ, _particleId] = lerp(From.Z, To.Z, _factor);
	};
}
