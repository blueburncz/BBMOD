/// @func BBMOD_ScaleFromHealthModule([_from[, _to]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that controls scale of particles based on their
/// health.
///
/// @param {Struct.BBMOD_Vec3} [_from] The scale of particles when they have
/// full health. Defaults to `(1.0, 1.0, 1.0)`.
/// @param {Struct.BBMOD_Vec3} [_to] The scale of particles when they have no
/// health left. Defaults to `(0.0, 0.0, 0.0)`.
///
/// @see BBMOD_EParticle.ScaleX
/// @see BBMOD_EParticle.ScaleY
/// @see BBMOD_EParticle.ScaleZ
/// @see BBMOD_EParticle.HealthLeft
function BBMOD_ScaleFromHealthModule(_from=new BBMOD_Vec3(1.0), _to=new BBMOD_Vec3())
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3} The scale of particles when they have
	/// full health. Default value is `(1.0, 1.0, 1.0)`.
	From = _from;

	/// @var {Struct.BBMOD_Vec3} The scale of particles when they have no
	/// health left. Default value is `(0.0, 0.0, 0.0)`.
	To = _to;

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
