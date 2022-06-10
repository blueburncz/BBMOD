/// @func BBMOD_HeightKillModule([_min[, _max[, _relative]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that kills all particles that have Z position less
/// than a minimum value or greater than a maximum value.
///
/// @param {Real/Undefined} [_min] The minimum Z position that a particle needs
/// to have or it is killed. Use `undefined` if you do not want to use a minimum
/// value. Defaults to `undefined`.
/// @param {Real/Undefined} [_max] The maximum Z position that a particle needs
/// to have or it is killed. Use `undefined` if you do not want to use a maximum
/// value. Defaults to `undefined`.
/// @param {Bool} [_relative] If `true`, then the Z position is relative to the
/// emitter. Defaults to `true`.
///
/// @see BBMOD_EParticle.PositionZ
function BBMOD_HeightKillModule(_min=undefined, _max=undefined, _relative=true)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real/Undefined} The minimum Z position that a particle needs to
	/// have or it is killed. Use `undefined` if you do not want to use a minimum
	/// value. Default value is `undefined`.
	Min = _min;

	/// @var {Real/Undefined} The maximum Z position that a particle needs to
	/// have or it is killed. Use `undefined` if you do not want to use a maximum
	/// value. Default value is `undefined`.
	Max = _max;

	/// @var {Bool} If `true`, then the Z position is relative to the emitter.
	/// Defaults to `true`.
	Relative = _relative;

	// TODO: Implement BBMOD_HeightKillModule
}
