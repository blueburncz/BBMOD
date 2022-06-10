/// @func BBMOD_InitialPropertyModule([_property[, _value]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that sets initial value of particles'
/// property.
///
/// @param {Enum.BBMOD_EParticle/Undefined} [_property] The property to set
/// initial value of. Defaults to `undefined`.
/// @param {Real} [_value] The initial value of the property. Defaults to 0.0.
///
/// @see BBMOD_EParticle
function BBMOD_InitialPropertyModule(_property=undefined, _value=0.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Enum.BBMOD_EParticle/undefined} The property to set initial value
	/// of. Default value is `undefined`.
	Property = undefined;

	/// @var {Real} The initial value of the property. Defaults to 0.0.
	Value = _value;

	static on_particle_start = function (_emitter, _particleIndex) {
		if (Property != undefined)
		{
			_emitter.Particles[# Property, _particleIndex] = Value;
		}
	};
}
