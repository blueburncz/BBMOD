/// @func BBMOD_MixInitialVelocityModule([_from[, _to]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_from]
/// @param {Struct.BBMOD_Vec3/Undefined} [_to]
function BBMOD_MixInitialVelocityModule(_from=undefined, _to=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	From = _from ?? BBMOD_VEC3_UP;

	/// @var {Struct.BBMOD_Vec3}
	To = _to ?? From;

	static on_particle_start = function (_particle) {
		_particle.Velocity = new BBMOD_Vec3(
			lerp(From.X, To.X, random(1.0)),
			lerp(From.Y, To.Y, random(1.0)),
			lerp(From.Z, To.Z, random(1.0)));
	};
}
