/// @func BBMOD_RandomScaleModule([_min[, _max]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_min]
/// @param {Struct.BBMOD_Vec3/Undefined} [_max]
function BBMOD_RandomScaleModule(_min=undefined, _max=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Min = _min ?? new BBMOD_Vec3(1.0);

	/// @var {Struct.BBMOD_Vec3}
	Max = _max ?? Min;

	static on_start_particle = function (_particle) {
		_particle.Scale = Min.Lerp(Max, random(1.0));
	};
}
