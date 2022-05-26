/// @func BBMOD_CollisionEventModule([_callback])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Function/Undefined} [_callback]
function BBMOD_CollisionEventModule(_callback=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Function/Undefined}
	Callback = _callback;

	static on_update = function (_emitter, _deltaTime) {
		var _callback = Callback;
		if (!_callback)
		{
			return;
		}
		var _particles = _emitter.Particles;
		var _particleIndex = 0;
		repeat (_emitter.ParticlesAlive)
		{
			if (_particles[# BBMOD_EParticle.HasCollided, _particleIndex])
			{
				_callback(_emitter, _particleIndex);
			}
			++_particleIndex;
		}
	};
}