/// @module Particles

/// @func BBMOD_MixRealFromHealthModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that mixes value of particles'
/// property between two values based on their remaining health.
///
/// @param {Real} [_property] The property to set initial value of. Use values
/// from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Real} [_from] The value when the particle has full health.
/// Defaults to 0.0.
/// @param {Real} [_to] The value when the particle has no health left.
/// Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixRealFromHealthModule(
	_property=undefined,
	_from=0.0,
	_to=_from
) : BBMOD_ParticleModule() constructor
{
	/// @var {Real} The property to set initial value of. Use values from
	/// {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Real} The value when the particle has full health. Default value
	/// is 0.0.
	From = _from;

	/// @var {Real} The value when the particle has no health left. Default value
	/// is the same as {@link BBMOD_MixRealFromHealthModule.From}.
	To = _to;

	static on_update = function (_emitter, _deltaTime)
	{
		var _property = Property;
		if (_property != undefined)
		{
			var _to = To;
			var _from = From;
			var _particles = _emitter.Particles;

			var _particleIndex = 0;
			repeat (_emitter.ParticlesAlive)
			{
				var _factor = clamp(_particles[# BBMOD_EParticle.HealthLeft, _particleIndex]
					/ _particles[# BBMOD_EParticle.Health, _particleIndex], 0.0, 1.0);
				_particles[# _property, _particleIndex] = lerp(_to, _from, _factor);
				++_particleIndex;
			}
		}
	};
}
