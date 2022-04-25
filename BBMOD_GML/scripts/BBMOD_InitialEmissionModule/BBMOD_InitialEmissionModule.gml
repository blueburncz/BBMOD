/// @func BBMOD_InitialEmissionModule([_count])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_count]
function BBMOD_InitialEmissionModule(_count=1)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Count = _count;

	static on_start = function (_emitter) {
		repeat (Count)
		{
			_emitter.spawn_particle();
		}
	};
}
