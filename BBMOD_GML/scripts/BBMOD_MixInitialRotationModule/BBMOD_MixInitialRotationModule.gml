/// @func BBMOD_MixInitialRotationModule([_from[, _to]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that randomly mixes particles' initial rotation.
///
/// @param {Struct.BBMOD_Quaternion} [_from] The rotation to mix from. Defaults
/// to an identity quaternion.
/// @param {Struct.BBMOD_Quaternion} [_to] The rotation to mix to. Defaults to
/// `_from`.
///
/// @see BBMOD_EParticle.RotationX
/// @see BBMOD_EParticle.RotationY
/// @see BBMOD_EParticle.RotationZ
/// @see BBMOD_EParticle.RotationW
function BBMOD_MixInitialRotationModule(_from=new BBMOD_Quaternion(), _to=_from.clone())
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Quaternion} The rotation to mix from. Default value
	/// is an identity quaternion.
	From = _from;

	/// @var {Struct.BBMOD_Quaternion} The rotation to mix to. Default value is
	/// the same as {@link BBMOD_MixInitialRotationModule.From}.
	To = _to ?? _from.clone();

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _quat = From.Slerp(To, random(1.0));
		_particles[# BBMOD_EParticle.RotationX, _particleIndex] = _quat.X;
		_particles[# BBMOD_EParticle.RotationY, _particleIndex] = _quat.Y;
		_particles[# BBMOD_EParticle.RotationZ, _particleIndex] = _quat.Z;
		_particles[# BBMOD_EParticle.RotationW, _particleIndex] = _quat.W;
	};
}
