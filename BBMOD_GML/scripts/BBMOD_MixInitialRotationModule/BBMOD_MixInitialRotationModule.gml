/// @func BBMOD_MixInitialRotationModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Quaternion/Undefined} [_from]
/// @param {Struct.BBMOD_Quaternion/Undefined} [_to]
function BBMOD_MixInitialRotationModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Quaternion}
	From = _from ?? new BBMOD_Quaternion();

	/// @var {Struct.BBMOD_Quaternion}
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