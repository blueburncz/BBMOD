/// @module Particles

/// @func BBMOD_MixEmissionModule([_from[, _to]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that spawns random number of particles at the start
/// of a particle emitter's life.
///
/// @param {Real} [_from] The minimum number of particles to spawn. Defaults to 1.
/// @param {Real} [_to] The maximum particles to spawn. Defaults to `_from`.
function BBMOD_MixEmissionModule(_from = 1, _to = _from): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The minimum number of particles to spawn. Default value is 1.
	From = _from;

	/// @var {Real} The maximum particles to spawn. Default value is the same as
	/// {@link BBMOD_MixEmissionModule.From}.
	To = _to;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_f64, From);
		buffer_write(_buffer, buffer_f64, To);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		From = buffer_read(_buffer, buffer_f64);
		To = buffer_read(_buffer, buffer_f64);
		return self;
	};

	static on_start = function (_emitter)
	{
		repeat(irandom_range(From, To))
		{
			_emitter.spawn_particle();
		}
	};
}
