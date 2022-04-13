/// @func BBMOD_ParticleModule()
/// @desc
/// @see BBMOD_ParticleSystem
function BBMOD_ParticleModule() constructor
{
	/// @var {Bool} If `true` then the module is enabled. Defaults value
	/// is `true`.
	Enabled = true;

	/// @func update(_emitter, _deltaTime)
	/// @desc Applies module to a particle emitter.
	/// @param {Struct.BBMOD_ParticleEmitter} _emitter
	/// @param {Real} _deltaTime
	/// @return {Struct.BBMOD_ParticleModule}
	/// @note This should not be called when the module is not enabled!
	static update = function (_emitter, _deltaTime) {
		return self;
	};
}