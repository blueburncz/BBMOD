/// @module Particles

/// @func BBMOD_SphereEmissionModule([_radius[, _inside]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that positions spawned particles into a sphere
/// shape.
///
/// @param {Real} [_radius] The radius of the sphere. Defaults to 0.5.
/// @param {Bool} [_inside] Whether the particles can be spawned inside the
/// sphere.
/// Defaults to `true`.
///
/// @see BBMOD_EParticle.PositionX
/// @see BBMOD_EParticle.PositionY
/// @see BBMOD_EParticle.PositionZ
function BBMOD_SphereEmissionModule(_radius = 0.5, _inside = true): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The radius of the sphere. Default value is 0.5.
	Radius = _radius;

	/// @var {Bool} If `true`, then the particles can be spawned inside the sphere.
	/// Default value is `true`.
	Inside = _inside;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_f64, Radius);
		buffer_write(_buffer, buffer_bool, Inside);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Radius = buffer_read(_buffer, buffer_f64);
		Inside = buffer_read(_buffer, buffer_bool);
		return self;
	};

	static on_particle_start = function (_emitter, _particleIndex)
	{
		var _offsetX = random_range(-1.0, 1.0);
		var _offsetY = random_range(-1.0, 1.0);
		var _offsetZ = random_range(-1.0, 1.0);
		var _scale = (Inside ? random(Radius) : Radius)
			/ point_distance_3d(0.0, 0.0, 0.0, _offsetX, _offsetY, _offsetZ);
		var _particles = _emitter.Particles;

		_particles[# BBMOD_EParticle.PositionX, _particleIndex] += _offsetX * _scale;
		_particles[# BBMOD_EParticle.PositionY, _particleIndex] += _offsetY * _scale;
		_particles[# BBMOD_EParticle.PositionZ, _particleIndex] += _offsetZ * _scale;
	};
}
