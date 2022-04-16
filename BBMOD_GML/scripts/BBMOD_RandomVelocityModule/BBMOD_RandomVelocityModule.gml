/// @func BBMOD_RandomVelocityModule([_min[, _max]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_min]
/// @param {Struct.BBMOD_Vec3/Undefined} [_max]
function BBMOD_RandomVelocityModule(_min=undefined, _max=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Min = _min ?? BBMOD_VEC3_UP;

	/// @var {Struct.BBMOD_Vec3}
	Max = _max ?? Min;

	static on_particle_start = function (_particle) {
		_particle.Velocity = new BBMOD_Vec3(
			lerp(Min.X, Max.X, random(1)),
			lerp(Min.Y, Max.Y, random(1)),
			lerp(Min.Z, Max.Z, random(1)));
	};
}
