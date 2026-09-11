/// @module Particles

/// @func BBMOD_MixVec2FromHealthModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that mixes values of particles' two
/// consecutive properties between two values based on their remaining health.
///
/// @param {Real} [_property] The first of the two consecutive properties. Use
/// values from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Struct.BBMOD_Vec2} [_from] The value when the particle has full health.
/// Defaults to `(0, 0)`.
/// @param {Struct.BBMOD_Vec2} [_to] The value when the particle has no health left.
/// Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixVec2FromHealthModule(
	_property = undefined,
	_from = new BBMOD_Vec2(),
	_to = _from.Clone()
): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The first of the two consecutive properties. Use values from
	/// {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Vec2} The value when the particle has full health.
	/// Default value is `(0, 0)`.
	From = _from;

	/// @var {Struct.BBMOD_Vec2} The value when the particle has no health left.
	/// Default value is the same as {@link BBMOD_MixVec2FromHealthModule.From}.
	To = _to;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_bool, Property != undefined);
		if (Property != undefined) buffer_write(_buffer, buffer_f64, Property);
		From.ToBuffer(_buffer, buffer_f64);
		To.ToBuffer(_buffer, buffer_f64);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Property = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		From = new BBMOD_Vec2().FromBuffer(_buffer, buffer_f64);
		To = new BBMOD_Vec2().FromBuffer(_buffer, buffer_f64);
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
			var _from = From;
			var _fromX = _from.X;
			var _fromY = _from.Y;
			var _particles = _emitter.Particles;

			var _particleIndex = 0;
			repeat(_emitter.ParticlesAlive)
			{
				var _factor = clamp(_particles[# BBMOD_EParticle.HealthLeft, _particleIndex]
					/ _particles[# BBMOD_EParticle.Health, _particleIndex], 0.0, 1.0);
				_particles[# _property, _particleIndex] = lerp(_toX, _fromX, _factor);
				_particles[# _property + 1, _particleIndex] = lerp(_toY, _fromY, _factor);
				++_particleIndex;
			}
		}
	};
}
