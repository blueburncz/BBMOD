/// @func BBMOD_SphereEmissionModule([_radius[, _inside]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Real} [_radius]
/// @param {Bool} [_inside]
function BBMOD_SphereEmissionModule(_radius=0.5, _inside=false)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Real}
	Radius = _radius;

	/// @var {Bool}
	Inside = _inside;

	static on_particle_start = function (_particle) {
		var _offset = new BBMOD_Vec3(
			random_range(-1.0, 1.0),
			random_range(-1.0, 1.0),
			random_range(-1.0, 1.0)
		).Normalize().Scale(Radius);
		if (Inside)
		{
			_offset = _offset.Scale(random(1.0));
		}
		_particle.Position = _particle.Position.Add(_offset);
	};
}