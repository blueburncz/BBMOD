/// @func BBMOD_ScaleFromHealthModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_from]
/// @param {Struct.BBMOD_Vec3/Undefined} [_to]
function BBMOD_ScaleFromHealthModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	From = _from ?? new BBMOD_Vec3(1.0);

	/// @var {Struct.BBMOD_Vec3}
	To = _to ?? new BBMOD_Vec3();

	static on_update = function (_emitter, _deltaTime) {
		var _particles = _emitter.Particles;
		var _particlesAlive = _emitter.ParticlesAlive;
		var _from = From;
		var _fromX = _from.X;
		var _fromY = _from.Y;
		var _fromZ = _from.Z;
		var _to = To;
		var _toX = _to.X;
		var _toY = _to.Y;
		var _toZ = _to.Z;

		var i = 0;
		repeat (array_length(_particlesAlive))
		{
			var _particleId = _particlesAlive[i++];
			var _factor = clamp(_particles[# BBMOD_EParticle.HealthLeft, _particleId]
				/ _particles[# BBMOD_EParticle.Health, _particleId], 0.0, 1.0);
			_particles[# BBMOD_EParticle.ScaleX, _particleId] = lerp(_fromX, _toX, _factor);
			_particles[# BBMOD_EParticle.ScaleY, _particleId] = lerp(_fromY, _toY, _factor);
			_particles[# BBMOD_EParticle.ScaleZ, _particleId] = lerp(_fromZ, _toZ, _factor);
		}
	};
}
