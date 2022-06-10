/// @func BBMOD_MixInitialVelocityModule([_from[, _to]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that randomly sets initial velocity vector of
/// particles.
///
/// @param {Struct.BBMOD_Vec3} [_from] A vector of minimum values for each
/// component of the velocity vector. Defaults to {@link BBMOD_VEC3_UP}.
/// @param {Struct.BBMOD_Vec3} [_to] A vector of maximum values for each
/// component of the velocity vector. Defaults to `_from`.
///
/// @example
/// The following code creates a particle module that sets the X component
/// of initial velocity randomly between -1 and 1, the Y component randomly
/// between -2 and 2, and the Z component randomly between -3 and 3.
/// ```gml
/// var _mixInitialVelocityModule = new BBMOD_MixInitialVelocityModule();
/// _mixInitialVelocityModule.From = new BBMOD_Vec3(-1.0, -2.0, -3.0);
/// _mixInitialVelocityModule.To = new BBMOD_Vec3(1.0, 2.0, 3.0);
/// ```
///
/// @see BBMOD_EParticle.VelocityX
/// @see BBMOD_EParticle.VelocityY
/// @see BBMOD_EParticle.VelocityZ
function BBMOD_MixInitialVelocityModule(_from=BBMOD_VEC3_UP, _to=_from.Clone())
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3} A vector of minimum values for each
	/// component of the velocity vector. Default value is {@link BBMOD_VEC3_UP}.
	From = _from;

	/// @var {Struct.BBMOD_Vec3} A vector of maximum values for each
	/// component of the velocity vector. Default value is the same as
	/// {@link BBMOD_MixInitialVelocityModule.From}.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _from = From;
		var _to = To;
		_particles[# BBMOD_EParticle.VelocityX, _particleIndex] = lerp(_from.X, _to.X, random(1.0));
		_particles[# BBMOD_EParticle.VelocityY, _particleIndex] = lerp(_from.Y, _to.Y, random(1.0));
		_particles[# BBMOD_EParticle.VelocityZ, _particleIndex] = lerp(_from.Z, _to.Z, random(1.0));
	};
}
