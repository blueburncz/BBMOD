/// @func BBMOD_SetVec2Module([_property[, _value]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that sets initial value of two consecutive
/// particle properties when it is spawned.
///
/// @param {Enum.BBMOD_EParticle/Undefined} [_property] The first property.
/// Defaults to `undefined`.
/// @param {Struct.BBMOD_Vec2} [_value] The initial value of the properties.
/// Defaults to `(0.0, 0.0).
///
/// @see BBMOD_EParticle
function BBMOD_SetVec2Module(_property=undefined, _value=new BBMOD_Vec2())
	: BBMOD_ParticleModule() constructor
{
	/// @var {Enum.BBMOD_EParticle/undefined} The first property. Default value
	/// is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Vec2} The initial value of the properties. Default
	/// value is `(0.0, 0.0).
	Value = _value;

	static on_particle_start = function (_emitter, _particleIndex) {
		if (Property != undefined)
		{
			var _value = Value;
			_emitter.Particles[# Property, _particleIndex]     = _value.X;
			_emitter.Particles[# Property + 1, _particleIndex] = _value.Y;
		}
	};
}
