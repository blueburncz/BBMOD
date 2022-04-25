/// @func BBMOD_InitialScaleModule([_scale])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_scale]
function BBMOD_InitialScaleModule(_scale=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Scale = _scale ?? new BBMOD_Vec3(1.0);

	static on_particle_start = function (_particle) {
		_particle.Scale = Scale.Clone();
	};
}
