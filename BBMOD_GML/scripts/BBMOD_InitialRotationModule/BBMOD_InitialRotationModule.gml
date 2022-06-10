/// @func BBMOD_InitialRotationModule([_rotation])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that sets initial rotation of particles.
///
/// @param {Struct.BBMOD_Quaternio} [_rotation] The initial particle rotation.
/// Defaults to an identity quaternion.
///
/// @see BBMOD_EParticle.RotationX
/// @see BBMOD_EParticle.RotationY
/// @see BBMOD_EParticle.RotationZ
/// @see BBMOD_EParticle.RotationW
function BBMOD_InitialRotationModule(_rotation=new BBMOD_Quaternion())
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Quaternion} The initial particle rotation.
	/// Defaults value is a identity quaternion.
	Rotation = _rotation;

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _rotation = Rotation;
		_particles[# BBMOD_EParticle.RotationX, _particleIndex] = _rotation.X;
		_particles[# BBMOD_EParticle.RotationY, _particleIndex] = _rotation.Y;
		_particles[# BBMOD_EParticle.RotationZ, _particleIndex] = _rotation.Z;
		_particles[# BBMOD_EParticle.RotationW, _particleIndex] = _rotation.W;
	};
}
