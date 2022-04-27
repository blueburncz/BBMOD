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

		var _particlesAlive = _emitter.ParticlesAlive;
		var _particles = _emitter.Particles;
		var _positionRealX = PositionReal.X;
		var _positionRealY = PositionReal.Y;
		var _positionRealZ = PositionReal.Z;
		var _radius = Radius;
		var _force = Force;

		var i = 0;
		repeat (array_length(_particlesAlive))
		{
			var _particleId = _particlesAlive[i++];
			var _vecX = _positionRealX - _particles[# BBMOD_EParticle.PositionX, _particleId];
			var _vecY = _positionRealY - _particles[# BBMOD_EParticle.PositionY, _particleId];
			var _vecZ = _positionRealZ - _particles[# BBMOD_EParticle.PositionZ, _particleId];
			var _distance = sqrt((_vecX * _vecX) + (_vecY * _vecY) + (_vecZ * _vecZ));
			if (_distance <= _radius)
			{
				var _scale = _force * (1.0 - (_distance / _radius));
				_particles[# BBMOD_EParticle.AccelerationX, _particleId] += (_vecX / _distance) * _scale;
				_particles[# BBMOD_EParticle.AccelerationY, _particleId] += (_vecY / _distance) * _scale;
				_particles[# BBMOD_EParticle.AccelerationZ, _particleId] += (_vecZ / _distance) * _scale;
			}
		}
	};
}