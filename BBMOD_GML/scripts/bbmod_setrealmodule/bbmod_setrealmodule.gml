/// @module Particles

/// @func BBMOD_SetRealModule([_property[, _value]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that sets initial value of particles'
/// property when they are spawned.
///
/// @param {Real} [_property] The property to set initial value of. Use values
/// from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Real} [_value] The initial value of the property. Defaults to 0.0.
///
/// @see BBMOD_EParticle
function BBMOD_SetRealModule(_property = undefined, _value = 0.0): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The property to set initial value of. Use values from
	/// {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Real} The initial value of the property. Defaults to 0.0.
	Value = _value;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_bool, Property != undefined);
		if (Property != undefined)
		{
			buffer_write(_buffer, buffer_f64, Property);
		}
		buffer_write(_buffer, buffer_f64, Value);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Property = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		Value = buffer_read(_buffer, buffer_f64);
		return self;
	};

	static on_particle_start = function (_emitter, _particleIndex)
	{
		if (Property != undefined)
		{
			_emitter.Particles[# Property, _particleIndex] = Value;
		}
	};
}
