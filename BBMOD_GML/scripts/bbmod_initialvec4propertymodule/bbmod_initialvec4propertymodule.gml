/// @func BBMOD_InitialVec4PropertyModule([_property[, _value]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that sets initial value of four consecutive
/// particle properties.
///
/// @param {Enum.BBMOD_EParticle/Undefined} [_property] The first property.
/// Defaults to `undefined`.
/// @param {Struct.BBMOD_Vec4} [_value] The initial value of the properties.
/// Defaults to `(0.0, 0.0, 0.0, 0.0).
///
/// @see BBMOD_EParticle
function BBMOD_InitialVec4PropertyModule(_property=undefined, _value=new BBMOD_Vec4())
	: BBMOD_ParticleModule() constructor
{
	/// @var {Enum.BBMOD_EParticle/undefined} The first property. Default value
	/// is `undefined`.
	Property = undefined;

	/// @var {Struct.BBMOD_Vec4} The initial value of the properties. Default
	/// value is `(0.0, 0.0, 0.0, 0.0).
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
