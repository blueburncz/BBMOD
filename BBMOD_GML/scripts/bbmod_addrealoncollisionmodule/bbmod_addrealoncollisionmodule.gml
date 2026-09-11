/// @module Particles

/// @func BBMOD_AddRealOnCollisionModule([_property[, _change]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that adds a value to particles' property
/// when they have a collision.
///
/// @param {Real} [_property] The property to add the value to. Use values from
/// {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Real} [_change] The value to add to particles' health. Defaults
/// to 1.0.
///
/// @see BBMOD_EParticle.HasCollided
function BBMOD_AddRealOnCollisionModule(_property = undefined, _change = 1.0): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The property to add the value to. Use values from
	/// {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Real} The value to add on collision. Default value is 1.0.
	Change = _change;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_bool, Property != undefined);
		if (Property != undefined) buffer_write(_buffer, buffer_f64, Property);
		buffer_write(_buffer, buffer_f64, Change);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Property = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		Change = buffer_read(_buffer, buffer_f64);
		return self;
	};

	static on_update = function (_emitter, _deltaTime)
	{
		if (Property != undefined)
		{
			var _y2 = _emitter.ParticlesAlive - 1;
			if (_y2 >= 0)
			{
				var _particles = _emitter.Particles;
				var _gridCompute = _emitter.GridCompute;

				ds_grid_set_region(
					_gridCompute,
					0, 0,
					0, _y2,
					Change);

				ds_grid_multiply_grid_region(
					_gridCompute,
					_particles,
					BBMOD_EParticle.HasCollided, 0,
					BBMOD_EParticle.HasCollided, _y2,
					0, 0);

				ds_grid_add_grid_region(
					_particles,
					_gridCompute,
					0, 0,
					0, _y2,
					Property, 0);
			}
		}
	};
}
