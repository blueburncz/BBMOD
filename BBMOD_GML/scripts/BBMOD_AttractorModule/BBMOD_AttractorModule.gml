/// @func BBMOD_AttractorModule([_position[, _relative[, _radius[, _force]]]])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_position]
/// @param {Bool} [_relative]
/// @param {Real} [_radius]
/// @param {Real} [_force]
function BBMOD_AttractorModule(_position=undefined, _relative=true, _radius=1.0, _force=1.0)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Position = _position ?? new BBMOD_Vec3();

	/// @var {Bool}
	Relative = _relative;

	/// @var {Struct.BBMOD_Vec3}
	/// @private
	PositionReal = Position;

	/// @var {Real}
	Radius = _radius;

	/// @var {Real}
	Force = _force;

	static on_update = function (_emitter, _deltaTime) {
		PositionReal = Relative ? _emitter.Position.Add(Position) : Position;

		var _particles = _emitter.Particles;
		var _positionRealX = PositionReal.X;
		var _positionRealY = PositionReal.Y;
		var _positionRealZ = PositionReal.Z;
		var _radius = Radius;
		var _force = Force;

		var _particleIndex = 0;
		repeat (_emitter.ParticlesAlive)
		{
			var _mass = _particles[# BBMOD_EParticle.Mass, _particleIndex];
			if (_mass != 0.0)
			{
				var _vecX = _positionRealX - _particles[# BBMOD_EParticle.PositionX, _particleIndex];
				var _vecY = _positionRealY - _particles[# BBMOD_EParticle.PositionY, _particleIndex];
				var _vecZ = _positionRealZ - _particles[# BBMOD_EParticle.PositionZ, _particleIndex];
				var _distance = sqrt((_vecX * _vecX) + (_vecY * _vecY) + (_vecZ * _vecZ));
				if (_distance <= _radius)
				{
					var _scale = (_force * (1.0 - (_distance / _radius))) / _mass;
					_particles[# BBMOD_EParticle.AccelerationX, _particleIndex] += (_vecX / _distance) * _scale;
					_particles[# BBMOD_EParticle.AccelerationY, _particleIndex] += (_vecY / _distance) * _scale;
					_particles[# BBMOD_EParticle.AccelerationZ, _particleIndex] += (_vecZ / _distance) * _scale;
				}
			}
			++_particleIndex;
		}
	};
}
