/// @func BBMOD_SetQuaternionModule([_property[, _value]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that sets initial value of particles'
/// quaternion property when they are spawned.
///
/// @param {Enum.BBMOD_EParticle/Undefined} [_property] The first of the four
/// properties that together form a quaternion. Defaults to `undefined`.
/// @param {Struct.BBMOD_Quaternion} [_value] The initial value of the quaternion
/// property. Defaults to an identity quaternion.
///
/// @see BBMOD_EParticle
function BBMOD_SetQuaternionModule(_property=undefined, _value=new BBMOD_Quaternion())
	: BBMOD_ParticleModule() constructor
{
	/// @var {Enum.BBMOD_EParticle/Undefined} The first of the four properties
	/// that together form a quaternion. Defaults to `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Quaternion} The initial value of the quaternion property.
	/// Default value is an idenitity quaternion.
	Value = _value;

	static on_particle_start = function (_emitter, _particleIndex) {
		if (Property != undefined)
		{
			var _value = Value;
			_emitter.Particles[# Property, _particleIndex]     = _value.X;
			_emitter.Particles[# Property + 1, _particleIndex] = _value.Y;
			_emitter.Particles[# Property + 2, _particleIndex] = _value.Z;
			_emitter.Particles[# Property + 3, _particleIndex] = _value.W;
		}
	};
}
