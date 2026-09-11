/// @module Particles

/// @func BBMOD_SetQuaternionModule([_property[, _value]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that sets initial value of particles'
/// quaternion property when they are spawned.
///
/// @param {Real} [_property] The first of the four properties that together
/// form a quaternion. Use values from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Struct.BBMOD_Quaternion} [_value] The initial value of the quaternion
/// property. Defaults to an identity quaternion.
///
/// @see BBMOD_EParticle
function BBMOD_SetQuaternionModule(
	_property = undefined,
	_value = new BBMOD_Quaternion()
): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The first of the four properties that together form a
	/// quaternion. Use values from {@link BBMOD_EParticle}. Defaults to `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Quaternion} The initial value of the quaternion property.
	/// Default value is an identity quaternion.
	Value = _value;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_bool, Property != undefined);
		if (Property != undefined) buffer_write(_buffer, buffer_f64, Property);
		Value.ToBuffer(_buffer, buffer_f64);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Property = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		Value = new BBMOD_Quaternion().FromBuffer(_buffer, buffer_f64);
		return self;
	};

	static on_particle_start = function (_emitter, _particleIndex)
	{
		if (Property != undefined)
		{
			var _value = Value;
			_emitter.Particles[# Property, _particleIndex] = _value.X;
			_emitter.Particles[# Property + 1, _particleIndex] = _value.Y;
			_emitter.Particles[# Property + 2, _particleIndex] = _value.Z;
			_emitter.Particles[# Property + 3, _particleIndex] = _value.W;
		}
	};
}
