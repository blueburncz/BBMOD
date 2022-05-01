/// @enum Enumeration of particle properties.
/// @see BBMOD_ParticleEmitter.Particles
enum BBMOD_EParticle
{
	/// @member The ID of the particle, unique within the emitter which spawned
	/// it.
	Id,
	/// @member Whether the particle is alive. If not, then the rest of the data
	/// can be nonsense. All particles within a particle system are dead at the
	/// start.
	IsAlive,
	/// @member The particle's initial health value. Default value is 1.
	Health,
	/// @member The particle's remaining health. The particle dies when this
	/// reaches 0. Default value is 1, same as for {@link BBMOD_EParticle.Health}.
	HealthLeft,
	/// @member The particle's X position in world-space.
	PositionX,
	/// @member The particle's Y position in world-space.
	PositionY,
	/// @member The particle's Z position in world-space.
	PositionZ,
	/// @member The particle's velocity on the X axis.
	VelocityX,
	/// @member The particle's velocity on the Y axis.
	VelocityY,
	/// @member The particle's velocity on the Z axis.
	VelocityZ,
	/// @member The particle's acceleration on the X axis.
	AccelerationX,
	/// @member The particle's acceleration on the Y axis.
	AccelerationY,
	/// @member The particle's acceleration on the Z axis.
	AccelerationZ,
	/// @member Internal use only!
	AccelerationRealX,
	/// @member Internal use only!
	AccelerationRealY,
	/// @member Internal use only!
	AccelerationRealZ,
	/// @member The first component of the particle's quaternion rotation.
	RotationX,
	/// @member The second component of the particle's quaternion rotation.
	RotationY,
	/// @member The third component of the particle's quaternion rotation.
	RotationZ,
	/// @member The fourth component of the particle's quaternion rotation.
	RotationW,
	/// @member The particle's scale on the X axis.
	ScaleX,
	/// @member The particle's scale on the Y axis.
	ScaleY,
	/// @member The particle's scale on the Z axis.
	ScaleZ,
	/// @member The red value of the particle's color.
	ColorR,
	/// @member The green value of the particle's color.
	ColorG,
	/// @member The blue value of the particle's color.
	ColorB,
	/// @member The alpha value of the particle's color.
	ColorA,
	/// @member Total number of members of this enum.
	SIZE
};
