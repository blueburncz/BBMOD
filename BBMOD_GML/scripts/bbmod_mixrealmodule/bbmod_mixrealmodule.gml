/// @module Particles

/// @func BBMOD_MixRealModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that randomly mixes initial value of
/// particles' property between two values when they are spawned.
///
/// @param {Real} [_property] The property to set initial value of. Use values
/// from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Real} [_from] The value to mix from. Defaults to 0.0.
/// @param {Real} [_to] The value to mix to. Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixRealModule(_property = undefined, _from = 0.0, _to = _from): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The property to set initial value of. Use values from
	/// {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Real} The initial value to mix from. Default value is 0.0.
	From = _from;

	/// @var {Real} The initial value to mix to. Default value is the same as
	/// {@link BBMOD_MixRealModule.From}.
	To = _to;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_bool, Property != undefined);
		if (Property != undefined) buffer_write(_buffer, buffer_f64, Property);
		buffer_write(_buffer, buffer_f64, From);
		buffer_write(_buffer, buffer_f64, To);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Property = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		From = buffer_read(_buffer, buffer_f64);
		To = buffer_read(_buffer, buffer_f64);
		return self;
	};

	static on_particle_start = function (_emitter, _particleIndex)
	{
		if (Property != undefined)
		{
			_emitter.Particles[# Property, _particleIndex] = lerp(From, To, random(1.0));
		}
	};
}
