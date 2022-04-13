/// @func BBMOD_Particle(_id)
/// @desc
/// @param {Real} _id The ID of the particle.
function BBMOD_Particle(_id) constructor
{
	/// @var {Real} The ID of the particle.
	/// @readonly
	Id = _id;

	/// @var {Real} The initial health of the particle. Default value is 1.
	Health = 1.0;

	/// @var {Real} The current health of the particle. The particle should
	/// die when this reaches 0.
	HealthLeft = Health;

	/// @var {Bool} If `true` then the particle is alive. Default value
	/// is `false`.
	IsAlive = false;

	/// @var {Struct.BBMOD_Vec3} The world-space position of the particle.
	/// Default value is `0, 0, 0`.
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} Added to the particle's position on update.
	/// Default value is `0, 0, 0`.
	Velocity = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Quaternion} The particle's rotation.
	Rotation = new BBMOD_Quaternion();

	/// @var {Struct.BBMOD_Vec3} The scale of the particle mesh.
	/// Default value is `1, 1, 1`.
	Scale = new BBMOD_Vec3(1.0);

	/// @var {Struct.BBMOD_Color} The color of the particle. Default value is
	/// {@link BBMOD_C_WHITE}.
	Color = BBMOD_C_WHITE;

	/// @func write_data(_array, _index)
	/// @desc
	/// @param {Array<Real>} _array
	/// @param {Real} _index
	/// @return {Struct.BBMOD_Particle} Returns `self`.
	static write_data = function (_array, _index) {
		gml_pragma("forceinline");
		if (IsAlive)
		{
			Position.ToArray(_array, _index);
			// TODO: Pass particle rotation to shaders
			Color.ToRGBM(_array, _index + 8);
		}
		Scale.Scale(IsAlive ? 1.0 : 0.0).ToArray(_array, _index + 4);
		return self;
	};
}