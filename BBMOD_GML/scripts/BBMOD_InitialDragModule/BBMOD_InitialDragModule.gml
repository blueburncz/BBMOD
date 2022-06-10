/// @func BBMOD_InitialDragModule([_drag])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that sets an initial value of particles' drag
/// physics property.
///
/// @param {Real} [_drag] The initial value of the drag property. Defaults
/// to 0.0.
///
/// @see BBMOD_EParticle.Drag
function BBMOD_InitialDragModule(_drag=0.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real} The initial value of the drag property. Default value is
	/// 0.0.
	Drag = _drag;

	static on_particle_start = function (_emitter, _particleIndex) {
		_emitter.Particles[# BBMOD_EParticle.Drag, _particleIndex] = Drag;
	};
}
