/// @module Particles

/// @func BBMOD_MixQuaternionModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that randomly mixes particles' quaternion
/// property when they are spawned.
///
/// @param {Real} [_property] The first of the four consecutive properties that
/// together form a quaternion. Use values from {@link BBMOD_EParticle}. Defaults
/// to `undefined`.
/// @param {Struct.BBMOD_Quaternion} [_from] The quaternion to mix from. Defaults to
/// an identity quaternion.
/// @param {Struct.BBMOD_Quaternion} [_to] The quaternion to mix to. Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixQuaternionModule(
	_property = undefined,
	_from = new BBMOD_Quaternion(),
	_to = _from.Clone()
): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The first of the four consecutive properties that together
	/// form a quaternion. Use values from {@link BBMOD_EParticle}. Default value
	/// is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Quaternion} The quaternion to mix from. Default value is
	/// an identity quaternion.
	From = _from;

	/// @var {Struct.BBMOD_Quaternion} The quaternion to mix to. Default value is the
	/// same as {@link BBMOD_MixQuaternionModule.From}.
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
		From = new BBMOD_Quaternion().FromBuffer(_buffer, buffer_f64);
		To = new BBMOD_Quaternion().FromBuffer(_buffer, buffer_f64);
		return self;
	};

	static on_particle_start = function (_emitter, _particleIndex)
	{
		if (Property != undefined)
		{
			var _quat = From.Slerp(To, random(1.0));
			_emitter.Particles[# Property, _particleIndex] = _quat.X;
			_emitter.Particles[# Property + 1, _particleIndex] = _quat.Y;
			_emitter.Particles[# Property + 2, _particleIndex] = _quat.Z;
			_emitter.Particles[# Property + 3, _particleIndex] = _quat.W;
		}
	};
}
