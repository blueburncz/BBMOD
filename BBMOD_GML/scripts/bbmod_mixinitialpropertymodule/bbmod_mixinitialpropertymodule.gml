/// @func BBMOD_MixInitialPropertyModule([_property[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that randomly mixes initial value of
/// particles' property between two values.
///
/// @param {Enum.BBMOD_EParticle/Undefined} [_property] The property to set
/// initial value of. Defaults to `undefined`.
/// @param {Real} [_from] The value to mix from. Defaults to 0.0.
/// @param {Real} [_to] The value to mix to. Defaults to `_from`.
///
/// @see BBMOD_EParticle
function BBMOD_MixInitialPropertyModule(_property=undefined, _from=0.0, _to=_from)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Enum.BBMOD_EParticle/undefined} The property to set initial value
	/// of. Default value is `undefined`.
	Property = undefined;

	/// @var {Real} The initial value to mix from. Default value is 0.0.
	From = _from;

	/// @var {Real} The initial value to mix to. Default value is the same as
	/// {@link BBMOD_MixInitialPropertyModule.From}.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		if (Property != undefined)
		{
			_emitter.Particles[# Property, _particleIndex] = lerp(From, To, random(1.0));
		}
	};
}
