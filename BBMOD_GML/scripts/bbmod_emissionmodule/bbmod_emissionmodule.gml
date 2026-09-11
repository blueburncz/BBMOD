/// @module Particles

/// @func BBMOD_EmissionModule([_count])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that spawns particles at the start of a particle
/// emitter's life.
///
/// @param {Real} [_count] Number of particles to spawn. Defaults to 1.
function BBMOD_EmissionModule(_count = 1): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} Number of particles to spawn.
	Count = _count;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_f64, Count);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Count = buffer_read(_buffer, buffer_f64);
		return self;
	};

	static on_start = function (_emitter)
	{
		repeat(Count)
		{
			_emitter.spawn_particle();
		}
	};
}
