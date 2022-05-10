/// @func BBMOD_MixInitialEmissionModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_from]
/// @param {Real} [_to]
function BBMOD_MixInitialEmissionModule(_from=1, _to=_from)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	From = _from;

	/// @var {Real}
	To = _to;

	static on_start = function (_emitter) {
		repeat (irandom_range(From, To))
		{
			_emitter.spawn_particle();
		}
	};
}
