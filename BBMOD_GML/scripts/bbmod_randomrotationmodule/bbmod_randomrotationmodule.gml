/// @module Particles

/// @func BBMOD_RandomRotationModule([_axis[, _from[, _to]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that randomly sets particles' rotation on their spawn.
///
/// @param {Struct.BBMOD_Vec3} [_axis] The axis of rotation. Defaults to
/// {@link BBMOD_VEC3_UP}.
/// @param {Real} [_from] The minimum angle of rotation. Defaults to 0.
/// @param {Real} [_to] The maximum angle of rotation. Defaults to 360.
///
/// @see BBMOD_EParticle.RotationX
/// @see BBMOD_EParticle.RotationY
/// @see BBMOD_EParticle.RotationZ
/// @see BBMOD_EParticle.RotationW
function BBMOD_RandomRotationModule(_axis = BBMOD_VEC3_UP, _from = 0.0, _to = 360.0): BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3} The axis of rotation. Default value is
	/// {@link BBMOD_VEC3_UP}.
	Axis = _axis;

	/// @var {Real} The minimum angle of rotation. Default value is 0.
	From = _from;

	/// @var {Real} The maximum angle of rotation. Default value is 360.
	To = _to;

	static on_particle_start = function (_emitter, _particleIndex)
	{
		// var _rotation = new BBMOD_Quaternion().FromAxisAngle(Axis, random_range(From, To));
		// Inlined to eliminate allocation
		var _angle = -random_range(From, To);
		var _sinHalfAngle = dsin(_angle * 0.5);
		var _rotX = Axis.X * _sinHalfAngle;
		var _rotY = Axis.Y * _sinHalfAngle;
		var _rotZ = Axis.Z * _sinHalfAngle;
		var _rotW = dcos(_angle * 0.5);
		_emitter.Particles[# BBMOD_EParticle.RotationX, _particleIndex] = _rotX;
		_emitter.Particles[# BBMOD_EParticle.RotationY, _particleIndex] = _rotY;
		_emitter.Particles[# BBMOD_EParticle.RotationZ, _particleIndex] = _rotZ;
		_emitter.Particles[# BBMOD_EParticle.RotationW, _particleIndex] = _rotW;
	};
}
