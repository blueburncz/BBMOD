/// @func BBMOD_InitialDragModule([_drag])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_drag]
function BBMOD_InitialDragModule(_drag=0.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Drag = _drag;

	static on_particle_start = function (_emitter, _particleIndex) {
		_emitter.Particles[# BBMOD_EParticle.Drag, _particleIndex] = Drag;
	};
}
