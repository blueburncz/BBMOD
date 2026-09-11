/// @module Particles

/// @func BBMOD_GravityModule([_gravity])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that applies gravity force to particles.
/// 
/// @param {Struct.BBMOD_Vec3} [_gravity] The gravity vector. Defaults to
/// `(0, 0, -9.8)`.
function BBMOD_GravityModule(_gravity = BBMOD_VEC3_UP.Scale(-9.8)): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Struct.BBMOD_Vec3} The gravity vector. Default value is
	/// `(0, 0, -9.8)`.
	Gravity = _gravity;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		Gravity.ToBuffer(_buffer, buffer_f64);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Gravity = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f64);
		return self;
	};

	static on_update = function (_emitter, _deltaTime)
	{
		var _y2 = _emitter.ParticlesAlive - 1;
		if (_y2 >= 0)
		{
			var _particles = _emitter.Particles;
			var _gravity = Gravity;

			ds_grid_add_region(
				_particles,
				BBMOD_EParticle.AccelerationX, 0,
				BBMOD_EParticle.AccelerationX, _y2,
				_gravity.X);

			ds_grid_add_region(
				_particles,
				BBMOD_EParticle.AccelerationY, 0,
				BBMOD_EParticle.AccelerationY, _y2,
				_gravity.Y);

			ds_grid_add_region(
				_particles,
				BBMOD_EParticle.AccelerationZ, 0,
				BBMOD_EParticle.AccelerationZ, _y2,
				_gravity.Z);
		}
	};
}
