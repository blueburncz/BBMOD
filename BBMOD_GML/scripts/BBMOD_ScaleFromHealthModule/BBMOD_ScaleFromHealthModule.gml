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
		var _from = From;
		var _fromX = _from.X;
		var _fromY = _from.Y;
		var _fromZ = _from.Z;
		var _to = To;
		var _toX = _to.X;
		var _toY = _to.Y;
		var _toZ = _to.Z;

		var _particleIndex = 0;
		repeat (_emitter.ParticlesAlive)
		{
			var _factor = clamp(_particles[# BBMOD_EParticle.HealthLeft, _particleIndex]
				/ _particles[# BBMOD_EParticle.Health, _particleIndex], 0.0, 1.0);
			_particles[# BBMOD_EParticle.ScaleX, _particleIndex] = lerp(_toX, _fromX, _factor);
			_particles[# BBMOD_EParticle.ScaleY, _particleIndex] = lerp(_toY, _fromY, _factor);
			_particles[# BBMOD_EParticle.ScaleZ, _particleIndex] = lerp(_toZ, _fromZ, _factor);
			++_particleIndex;
		}
	};
}
