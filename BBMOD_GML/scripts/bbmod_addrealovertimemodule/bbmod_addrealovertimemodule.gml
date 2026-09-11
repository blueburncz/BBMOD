/// @module Particles

/// @func BBMOD_AddRealOverTimeModule([_property[, _change[, _period]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that adds a value to particles' property
/// over time.
///
/// @param {Real} [_property] The property to add the value to. Use values from
/// {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Real} [_change] The value added over specified period. Defaults to
/// 1.0.
/// @param {Real} [_period] How long in seconds it takes to add the value to the
/// property. Defaults to 1.0.
///
/// @see BBMOD_EParticle.HealthLeft
function BBMOD_AddRealOverTimeModule(
	_property = undefined,
	_change = 1.0,
	_period = 1.0
): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The property to add the value to. Use values from
	/// {@link BBMOD_EParticle} Default value is `undefined`.
	Property = _property;

	/// @var {Real} The value added over {@link BBMOD_AddRealOverTimeModule.Period}.
	/// Default value is 1.0.
	Change = _change;

	/// @var {Real} How long in seconds it takes to add the value to the
	/// property. Defaults to 1.0.
	Period = _period;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_bool, Property != undefined);
		if (Property != undefined) buffer_write(_buffer, buffer_f64, Property);
		buffer_write(_buffer, buffer_f64, Change);
		buffer_write(_buffer, buffer_f64, Period);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Property = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		Change = buffer_read(_buffer, buffer_f64);
		Period = buffer_read(_buffer, buffer_f64);
		return self;
	};

	static on_update = function (_emitter, _deltaTime)
	{
		var _property = Property;
		if (_property != undefined)
		{
			var _y2 = _emitter.ParticlesAlive - 1;
			if (_y2 >= 0)
			{
				ds_grid_add_region(
					_emitter.Particles,
					_property, 0,
					_property, _y2,
					Change * ((_deltaTime * 0.000001) / max(Period, 0.000001)));
			}
		}
	};
}
