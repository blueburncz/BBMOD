/// @func BBMOD_AddVelocityOverTimeModule([_change[, _period]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_change]
/// @param {Real} [_period]
function BBMOD_AddVelocityOverTimeModule(_change=undefined, _period=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Change = _change ?? new BBMOD_Vec3();

	/// @var {Real}
	Period = _period;

	static on_update = function (_emitter, _deltaTime) {
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			// TODO: Implement BBMOD_AddVelocityOverTimeModule
		}
	};
}