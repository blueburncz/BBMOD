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
		var _particles = _emitter.Particles;
		var _from = From;
		var _to = To;
		var _factor = random(1.0);
		_particles[# BBMOD_EParticle.ScaleX, _particleId] = lerp(_from.X, _to.X, _factor);
		_particles[# BBMOD_EParticle.ScaleY, _particleId] = lerp(_from.Y, _to.Y, _factor);
		_particles[# BBMOD_EParticle.ScaleZ, _particleId] = lerp(_from.Z, _to.Z, _factor);
	};
}
