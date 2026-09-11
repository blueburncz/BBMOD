/// @module Particles

/// @func BBMOD_AttractorModule([_position[, _relative[, _radius[, _force]]]])
///
/// @extends BBMOD_ParticleModule
///
/// @desc A particle module that attracts/repels particles to/from a given
/// position.
///
/// @param {Struct.BBMOD_Vec3} [_position] The position to attract/repel
/// particles to/from. Defaults to `(0, 0, 0)`.
/// @param {Bool} [_relative] If `true`, then the position is relative to the
/// emitter. Defaults to `true`.
/// @param {Real} [_radius] The radius of the influence. Defaults to 1.0.
/// @param {Real} [_force] The strength of the force. Use negative to repel the
/// particles. Defaults to 1.0.
function BBMOD_AttractorModule(
	_position = new BBMOD_Vec3(),
	_relative = true,
	_radius = 1.0,
	_force = 1.0
): BBMOD_ParticleModule() constructor
{
	static ParticleModule_to_buffer = to_buffer;
	static ParticleModule_from_buffer = from_buffer;

	/// @var {Struct.BBMOD_Vec3} The position to attract/repel particles to/from.
	/// Default value is `(0, 0, 0)`.
	Position = _position;

	/// @var {Bool} If `true`, then {@link BBMOD_AttractorModule.Position} is
	/// relative to the emitter. Default value is `true`.
	Relative = _relative;

	/// @var {Struct.BBMOD_Vec3}
	/// @private
	__positionReal = Position;

	/// @var {Real} The radius of the influence. Defaults to 1.0.
	Radius = _radius;

	/// @var {Real} The strength of the force. Use negative to repel the
	/// particles. Defaults value is 1.0.
	Force = _force;

	static to_buffer = function (_buffer)
	{
		ParticleModule_to_buffer(_buffer);
		Position.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_bool, Relative);
		buffer_write(_buffer, buffer_f64, Radius);
		buffer_write(_buffer, buffer_f64, Force);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		ParticleModule_from_buffer(_buffer);
		Position = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f64);
		Relative = buffer_read(_buffer, buffer_bool);
		Radius = buffer_read(_buffer, buffer_f64);
		Force = buffer_read(_buffer, buffer_f64);
		__positionReal = Position;
		return self;
	};

	static on_update = function (_emitter, _deltaTime)
	{
		// __positionReal = Relative ? _emitter.Position.Add(Position) : Position;
		var _positionRealX, _positionRealY, _positionRealZ;
		if (Relative)
		{
			_positionRealX = _emitter.Position.X + Position.X;
			_positionRealY = _emitter.Position.Y + Position.Y;
			_positionRealZ = _emitter.Position.Z + Position.Z;
		}
		else
		{
			_positionRealX = Position.X;
			_positionRealY = Position.Y;
			_positionRealZ = Position.Z;
		}

		var _particles = _emitter.Particles;
		var _radius = Radius;
		var _force = Force;

		var _particleIndex = 0;
		repeat(_emitter.ParticlesAlive)
		{
			var _mass = _particles[# BBMOD_EParticle.Mass, _particleIndex];
			if (_mass != 0.0)
			{
				var _vecX = _positionRealX
					- _particles[# BBMOD_EParticle.PositionX, _particleIndex];
				var _vecY = _positionRealY
					- _particles[# BBMOD_EParticle.PositionY, _particleIndex];
				var _vecZ = _positionRealZ
					- _particles[# BBMOD_EParticle.PositionZ, _particleIndex];
				var _distance = point_distance_3d(0, 0, 0, _vecX, _vecY, _vecZ);
				if (_distance <= _radius)
				{
					var _scale = (_force * (1.0 - (_distance / _radius))) / _mass;
					_particles[# BBMOD_EParticle.AccelerationX, _particleIndex] +=
						(_vecX / _distance) * _scale;
					_particles[# BBMOD_EParticle.AccelerationY, _particleIndex] +=
						(_vecY / _distance) * _scale;
					_particles[# BBMOD_EParticle.AccelerationZ, _particleIndex] +=
						(_vecZ / _distance) * _scale;
				}
			}
			++_particleIndex;
		}
	};
}
