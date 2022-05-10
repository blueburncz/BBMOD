/// @func BBMOD_InitialRotationModule([_rotation])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Quaternion/Undefined} [_rotation]
function BBMOD_InitialRotationModule(_rotation=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Quaternion}
	Rotation = _rotation ?? new BBMOD_Quaternion();

	static on_particle_start = function (_emitter, _particleIndex) {
		var _particles = _emitter.Particles;
		var _rotation = Rotation;
		_particles[# BBMOD_EParticle.RotationX, _particleIndex] = _rotation.X;
		_particles[# BBMOD_EParticle.RotationY, _particleIndex] = _rotation.Y;
		_particles[# BBMOD_EParticle.RotationZ, _particleIndex] = _rotation.Z;
		_particles[# BBMOD_EParticle.RotationW, _particleIndex] = _rotation.W;
	};
}