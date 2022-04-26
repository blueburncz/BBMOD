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
	};

	static on_particle_update = function (_particle, _deltaTime) {
		gml_pragma("forceinline");
		var _positionReal = PositionReal;
		var _radius = Radius;
		var _particlePosition = _particle.Position;
		var _particleAcceleration = _particle.Acceleration;
		var _vecX = _positionReal.X - _particlePosition.X;
		var _vecY = _positionReal.Y - _particlePosition.Y;
		var _vecZ = _positionReal.Z - _particlePosition.Z;
		var _distance = sqrt((_vecX * _vecX) + (_vecY * _vecY) + (_vecZ * _vecZ));
		if (_distance <= _radius)
		{
			var _scale = Force * (1.0 - (_distance / _radius));
			_particleAcceleration.Set(
				_particleAcceleration.X + ((_vecX / _distance) * _scale),
				_particleAcceleration.Y + ((_vecY / _distance) * _scale),
				_particleAcceleration.Z + ((_vecZ / _distance) * _scale));
		}
		// Same as:
		//var _vec = PositionReal.Sub(_particle.Position);
		//var _distance = _vec.Length();
		//if (_distance <= Radius)
		//{
		//	_particle.Acceleration = _particle.Acceleration.Add(_vec.Normalize().Scale(Force * (1.0 - (_distance / Radius))));
		//}
	};
}