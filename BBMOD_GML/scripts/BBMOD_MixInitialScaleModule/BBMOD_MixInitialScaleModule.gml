/// @func BBMOD_MixInitialScaleModule([_from[, _to]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that randomly sets initial particle scale.
///
/// @param {Struct.BBMOD_Vec3} [_from] The minimum particle scale.
/// Defaults to `(1.0, 1.0, 1.0)`.
/// @param {Struct.BBMOD_Vec3} [_to] The maximum particle scale.
/// Defaults to `_from`.
///
/// @see BBMOD_EParticle.ScaleX
/// @see BBMOD_EParticle.ScaleY
/// @see BBMOD_EParticle.ScaleZ
function BBMOD_MixInitialScaleModule(_from=new BBMOD_Vec3(1.0), _to=_from.Clone())
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3} The minimum particle scale.
	/// Default value is `(1.0, 1.0, 1.0)`.
	From = _from;

	/// @var {Struct.BBMOD_Vec3} The maximum particle scale. Default value is
	/// the same as {@link BBMOD_MixInitialScaleModule.From}.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _from = From;
		var _to = To;
		var _factor = random(1.0);
		_particles[# BBMOD_EParticle.ScaleX, _particleIndex] = lerp(_from.X, _to.X, _factor);
		_particles[# BBMOD_EParticle.ScaleY, _particleIndex] = lerp(_from.Y, _to.Y, _factor);
		_particles[# BBMOD_EParticle.ScaleZ, _particleIndex] = lerp(_from.Z, _to.Z, _factor);
	};
}
