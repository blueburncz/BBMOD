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

		for (var _particleId = _emitter.System.ParticleCount - 1; _particleId >= 0; --_particleId)
		{
			var _vecX = PositionReal.X - _particles[# BBMOD_EParticle.PositionX, _particleId];
			var _vecY = PositionReal.Y - _particles[# BBMOD_EParticle.PositionY, _particleId];
			var _vecZ = PositionReal.Z - _particles[# BBMOD_EParticle.PositionZ, _particleId];
			var _distance = sqrt((_vecX * _vecX) + (_vecY * _vecY) + (_vecZ * _vecZ));
			if (_distance <= Radius)
			{
				var _scale = Force * (1.0 - (_distance / Radius));
				_particles[# BBMOD_EParticle.AccelerationX, _particleId] += (_vecX / _distance) * _scale;
				_particles[# BBMOD_EParticle.AccelerationY, _particleId] += (_vecY / _distance) * _scale;
				_particles[# BBMOD_EParticle.AccelerationZ, _particleId] += (_vecZ / _distance) * _scale;
			}
		}
	};
}