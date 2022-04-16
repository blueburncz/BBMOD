/// @func BBMOD_PhysicsModule([_gravity])
/// @extends BBMOD_ParticleModule
/// @desc
/// @param {Struct.BBMOD_Vec3/Undefined} [_gravity]
function BBMOD_PhysicsModule(_gravity=undefined)
	: BBMOD_ParticleModule() constructor
{
	/// @var {Struct.BBMOD_Vec3}
	Gravity = _gravity ?? new BBMOD_Vec3(0.0);

	static on_update_particle = function (_particle, _deltaTime) {
		_deltaTime *= 0.000001;
		with (_particle)
		{
			Velocity = Velocity.Add(other.Gravity.Scale(_deltaTime * _deltaTime));
			Position = Position.Add(Velocity.Scale(_deltaTime));
		}
	};
}
