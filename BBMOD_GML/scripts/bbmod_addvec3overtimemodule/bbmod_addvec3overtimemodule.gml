/// @module Particles

/// @func BBMOD_AddVec3OverTimeModule([_property[, _change[, _period]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A universal particle module that adds a value to three consecutive
/// particle properties over time.
///
/// @param {Real} [_property] The first of the three consecutive properties. Use
/// values from {@link BBMOD_EParticle}. Defaults to `undefined`.
/// @param {Struct.BBMOD_Vec3} [_change] The value added over specified period.
/// Defaults to `(1.0, 1.0, 1.0)`.
/// @param {Real} [_period] How long in seconds it takes to add the value to the
/// properties. Defaults to 1.0.
///
/// @see BBMOD_EParticle.HealthLeft
function BBMOD_AddVec3OverTimeModule(
	_property = undefined,
	_change = new BBMOD_Vec3(1.0),
	_period = 1.0
): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Real} The first of the three consecutive properties. Use values
	/// from {@link BBMOD_EParticle}. Default value is `undefined`.
	Property = _property;

	/// @var {Struct.BBMOD_Vec3} The value added over
	/// {@link BBMOD_AddVec3OverTimeModule.Period}. Default value is
	/// `(1.0, 1.0, 1.0)`.
	Change = _change;

	/// @var {Real} How long in seconds it takes to add the value to the
	/// properties. Defaults to 1.0.
	Period = _period;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		buffer_write(_buffer, buffer_bool, Property != undefined);
		if (Property != undefined) buffer_write(_buffer, buffer_f64, Property);
		Change.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_f64, Period);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Property = buffer_read(_buffer, buffer_bool)
			? buffer_read(_buffer, buffer_f64) : undefined;
		Change = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f64);
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
				var _factor = ((_deltaTime * 0.000001) / max(Period, 0.000001));
				var _change = Change;
				var _changeX = _change.X * _factor;
				var _changeY = _change.Y * _factor;
				var _changeZ = _change.Z * _factor;
				ds_grid_add_region(_emitter.Particles, _property, 0, _property, _y2, _changeX);
				ds_grid_add_region(_emitter.Particles, _property + 1, 0, _property + 1, _y2, _changeY);
				ds_grid_add_region(_emitter.Particles, _property + 2, 0, _property + 2, _y2, _changeZ);
			}
		}
	};
}
