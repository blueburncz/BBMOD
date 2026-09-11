/// @module Particles

/// @func BBMOD_MixRealOverTimeModule([_property[, _from[, _to[, _duration]]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that mixes value of particles'
/// property between two values based on their time alive.
///
/// @param {Real} [_property] The property to set initial value of. Use values
/// from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Real} [_from] The value when the particle has full health.
/// Defaults to 0.0.
/// @param {Real} [_to] The value when the particle has no health left.
/// Defaults to `_from`.
/// @param {Real} [_duration] How long in seconds it takes to mix between the
/// two values. Defaults to 1.0.
///
/// @see BBMOD_EParticle
function BBMOD_MixRealOverTimeModule(
	_property = undefined,
	_from = 0.0,
	_to = _from,
	_duration = 1.0
): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The property to set initial value of. Use values from
	/// {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Real} The value when the particle has full health. Default value
	/// is 0.0.
	From = _from;

	/// @var {Real} The value when the particle has no health left. Default value
	/// is the same as {@link BBMOD_MixRealOverTimeModule.From}.
	To = _to;

	/// @var {Real} How long in seconds it takes to mix between the two values.
	/// Default value is 1.0.
	Duration = _duration;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_bool, Property != undefined);
		if (Property != undefined) buffer_write(_buffer, buffer_f64, Property);
		buffer_write(_buffer, buffer_f64, From);
		buffer_write(_buffer, buffer_f64, To);
		buffer_write(_buffer, buffer_f64, Duration);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Property = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		From = buffer_read(_buffer, buffer_f64);
		To = buffer_read(_buffer, buffer_f64);
		Duration = buffer_read(_buffer, buffer_f64);
		return self;
	};

	static on_update = function (_emitter, _deltaTime)
	{
		var _property = Property;
		if (_property != undefined)
		{
			var _to = To;
			var _from = From;
			var _particles = _emitter.Particles;
			var _duration = Duration;

			var _particleIndex = 0;
			repeat(_emitter.ParticlesAlive)
			{
				var _factor = clamp(_particles[# BBMOD_EParticle.TimeAlive, _particleIndex] / _duration,
					0.0, 1.0);
				_particles[# _property, _particleIndex] = lerp(_to, _from, _factor);
				++_particleIndex;
			}
		}
	};
}
