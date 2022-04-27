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

	static on_particle_start = function (_emitter, _particleId) {
		var _offsetX = random_range(-1.0, 1.0);
		var _offsetY = random_range(-1.0, 1.0);
		var _offsetZ = random_range(-1.0, 1.0);
		var _scale = (Inside ? random(Radius) : Radius)
			/ point_distance_3d(0.0, 0.0, 0.0, _offsetX, _offsetY, _offsetZ);
		var _particles = _emitter.Particles;

		_particles[# BBMOD_EParticle.PositionX, _particleId] += _offsetX * _scale;
		_particles[# BBMOD_EParticle.PositionY, _particleId] += _offsetY * _scale;
		_particles[# BBMOD_EParticle.PositionZ, _particleId] += _offsetZ * _scale;
	};
}