/// @module Particles

/// @func BBMOD_MixVec3OverTimeModule([_property[, _from[, _to[, _duration]]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that mixes values of particles' three
/// consecutive properties between two values based on their time alive.
///
/// @param {Real} [_property] The first of the three consecutive properties. Use
/// values from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Struct.BBMOD_Vec3} [_from] The value when the particle has full health.
/// Defaults to `(0, 0, 0)`.
/// @param {Struct.BBMOD_Vec3} [_to] The value when the particle has no health left.
/// Defaults to `_from`.
/// @param {Real} [_duration] How long in seconds it takes to mix between the
/// two values. Defaults to 1.0.
///
/// @see BBMOD_EParticle
function BBMOD_MixVec3OverTimeModule(
	_property = undefined,
	_from = new BBMOD_Vec3(),
	_to = _from.Clone(),
	_duration = 1.0
): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The first of the three consecutive properties. Use values
	/// from {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Vec3} The value when the particle has full health. Default
	/// value is `(0, 0, 0)`.
	From = _from;

	/// @var {Struct.BBMOD_Vec3} The value when the particle has no health left. Default
	/// value is the same as {@link BBMOD_MixVec3OverTimeModule.From}.
	To = _to;

	/// @var {Real} How long in seconds it takes to mix between the two values.
	/// Default value is 1.0.
	Duration = _duration;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_bool, Property != undefined);
		if (Property != undefined) buffer_write(_buffer, buffer_f64, Property);
		From.ToBuffer(_buffer, buffer_f64);
		To.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_f64, Duration);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Property = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		From = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f64);
		To = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f64);
		Duration = buffer_read(_buffer, buffer_f64);
		return self;
	};

	static on_update = function (_emitter, _deltaTime)
	{
		var _property = Property;
		if (_property != undefined)
		{
			var _to = To;
			var _toX = _to.X;
			var _toY = _to.Y;
			var _toZ = _to.Z;
			var _from = From;
			var _fromX = _from.X;
			var _fromY = _from.Y;
			var _fromZ = _from.Z;
			var _particles = _emitter.Particles;
			var _duration = Duration;

			var _particleIndex = 0;
			repeat(_emitter.ParticlesAlive)
			{
				var _factor = clamp(_particles[# BBMOD_EParticle.TimeAlive, _particleIndex] / _duration,
					0.0, 1.0);
				_particles[# _property, _particleIndex] = lerp(_toX, _fromX, _factor);
				_particles[# _property + 1, _particleIndex] = lerp(_toY, _fromY, _factor);
				_particles[# _property + 2, _particleIndex] = lerp(_toZ, _fromZ, _factor);
				++_particleIndex;
			}
		}
	};
}
