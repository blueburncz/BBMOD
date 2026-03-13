/// @module Physics

/// @func BBMOD_Ragdoll()
///
/// @desc A physics-driven ragdoll system for skeletal animated models. The
/// ragdoll can seamlessly switch between animation playback and physics
/// simulation, making it perfect for character death effects, unconscious
/// states, or physical interactions.
///
/// @note Do not create this directly - use {@link BBMOD_PhysicsWorld.create_ragdoll}
/// instead.
///
/// @example
/// ```gml
/// // Create ragdoll from definition
/// var ragdollInfo = new BBMOD_RagdollInfo(characterModel);
/// // ... add parts ...
/// ragdoll = physicsWorld.create_ragdoll(
///     ragdollInfo,
///     new BBMOD_Matrix().TranslateSelf(x, y, z)
/// );
///
/// // Start in animation mode
/// ragdoll.set_active(false);
///
/// // In Step event - switch to physics on death
/// if (hp <= 0 && !ragdoll.is_active())
/// {
///     ragdoll.sync_to_animation(animationPlayer);
///     ragdoll.set_active(true);
/// }
///
/// // In Draw event
/// if (ragdoll.is_active())
/// {
///     ragdoll.get_transform_array(transformArray);
/// }
/// else
/// {
///     animationPlayer.get_transform_array(transformArray);
/// }
/// model.submit(transformArray);
/// ```
///
/// @see BBMOD_RagdollInfo
/// @see BBMOD_RagdollPartInfo
/// @see BBMOD_PhysicsWorld.create_ragdoll
function BBMOD_Ragdoll() constructor
{
	/// @var {Real} Internal C++ ragdoll ID
	/// @private
	__id = -1;

	/// @var {Struct.BBMOD_PhysicsWorld} The physics world this ragdoll belongs to
	/// @private
	__physicsWorld = undefined;

	/// @var {Struct.BBMOD_Model} The model this ragdoll is for
	/// @private
	__model = undefined;

	/// @var {Array<Real>} Transform array for bone skinning (boneCount * 8)
	/// @private
	__transformArray = undefined;

	/// @var {Bool} Whether ragdoll is currently active (physics-driven)
	/// @private
	__isActive = false;

	/// @func set_active(_active)
	///
	/// @desc Switches the ragdoll between animation and physics mode.
	/// When active (true), the ragdoll is driven by physics simulation.
	/// When inactive (false), the rigid bodies become kinematic and can be
	/// positioned by animation.
	///
	/// @param {Bool} _active True to enable physics mode, false for animation
	/// mode.
	///
	/// @return {Struct.BBMOD_Ragdoll} Returns `self` for method chaining.
	///
	/// @example
	/// ```gml
	/// // Character dies - enable physics
	/// if (hp <= 0)
	/// {
	///     ragdoll.sync_to_animation(animationPlayer); // Match current pose
	///     ragdoll.set_active(true); // Enable physics
	/// }
	///
	/// // Revive character - disable physics
	/// if (revived)
	/// {
	///     ragdoll.set_active(false); // Back to animation
	/// }
	/// ```
	static set_active = function (_active)
	{
		gml_pragma("forceinline");
		BBMOD_Ragdoll_SetActive(__id, _active ? 1.0 : 0.0);
		__isActive = _active;
		return self;
	};

	/// @func is_active()
	///
	/// @desc Checks if the ragdoll is currently in physics mode.
	///
	/// @return {Bool} Returns `true` if in physics mode, `false` if in
	/// animation mode.
	static is_active = function ()
	{
		gml_pragma("forceinline");
		return __isActive;
	};

	/// @func sync_to_animation(_animationPlayer, _worldTransform)
	///
	/// @desc Synchronizes all ragdoll rigid bodies to match the current
	/// animation pose at a specific world position. Call this before switching
	/// from animation to physics mode to ensure a seamless transition without
	/// popping.
	///
	/// @param {Struct.BBMOD_AnimationPlayer} _animationPlayer The animation
	/// player to sync from. The player's current pose will be applied to all
	/// ragdoll rigid bodies.
	/// @param {Struct.BBMOD_Matrix} _worldTransform The world transform matrix
	/// for the animated model. This positions the ragdoll at the correct
	/// location in the world.
	///
	/// @return {Struct.BBMOD_Ragdoll} Returns `self` for method chaining.
	///
	/// @example
	/// ```gml
	/// // Smooth transition from animation to physics
	/// if (trigger_ragdoll)
	/// {
	///     var worldMat = new BBMOD_Matrix().TranslateSelf(x, y, z);
	///     ragdoll.sync_to_animation(animationPlayer, worldMat);
	///     ragdoll.set_active(true); // Enable physics
	/// }
	/// ```
	static sync_to_animation = function (_animationPlayer, _worldTransform)
	{
		gml_pragma("forceinline");

		// Get current animation transforms
		__transformArray = _animationPlayer.get_transform();

		// Update rigid bodies to match animation (GML writes, C++ reads)
		var _scratchBuffer = bbmod_get_scratch_buffer();

		// Write world transform matrix
		for (var i = 0; i < 16; ++i)
		{
			buffer_write(_scratchBuffer, buffer_f64, _worldTransform.Raw[i]);
		}

		// Write transform count and transforms
		buffer_write(_scratchBuffer, buffer_u32, array_length(__transformArray));
		for (var i = 0; i < array_length(__transformArray); ++i)
		{
			buffer_write(_scratchBuffer, buffer_f64, __transformArray[i]);
		}

		BBMOD_Ragdoll_SyncToAnimation(__id, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func get_transform_array(_dest)
	///
	/// @desc Extracts skeletal transforms from the ragdoll's rigid bodies.
	/// Use this to drive the model's animation when in physics mode. The
	/// transforms are automatically converted from physics simulation to
	/// proper skinning matrices.
	///
	/// @param {Array<Real>} _dest Destination array for transforms. Must be
	/// at least `model.BoneCount * 8` elements in size. The array will be
	/// filled with dual quaternion components for each bone.
	///
	/// @return {Struct.BBMOD_Ragdoll} Returns `self` for method chaining.
	///
	/// @example
	/// ```gml
	/// // In Draw event
	/// if (ragdoll.is_active())
	/// {
	///     ragdoll.get_transform_array(transformArray);
	/// }
	/// else
	/// {
	///     animationPlayer.get_transform_array(transformArray);
	/// }
	/// model.submit(transformArray);
	/// ```
	static get_transform_array = function (_dest)
	{
		// C++ now does everything - just read the final transforms
		var _scratchBuffer = bbmod_get_scratch_buffer();
		BBMOD_Ragdoll_GetTransformArray(__id, buffer_get_address(_scratchBuffer));

		buffer_seek(_scratchBuffer, buffer_seek_start, 0);
		var _transformCount = __model.BoneCount * 8;
		for (var i = 0; i < _transformCount; ++i)
		{
			_dest[@ i] = buffer_read(_scratchBuffer, buffer_f64);
		}

		return self;
	};

	/// @func get_root_position()
	///
	/// @desc Gets the world position of the ragdoll's root body part (typically
	/// the pelvis). This is useful when switching from ragdoll back to animation
	/// to move the character to where the ragdoll ended up.
	///
	/// @return {Struct.BBMOD_Vec3} The world position of the root part, or
	/// (0, 0, 0) if the ragdoll has no parts.
	///
	/// @example
	/// ```gml
	/// // Switch back to animation and move character to ragdoll position
	/// if (revive)
	/// {
	///     ragdoll.set_active(false);
	///     var rootPos = ragdoll.get_root_position();
	///     x = rootPos.X;
	///     y = rootPos.Y;
	///     z = rootPos.Z;
	/// }
	/// ```
	static get_root_position = function ()
	{
		gml_pragma("forceinline");
		var _scratchBuffer = bbmod_get_scratch_buffer();
		BBMOD_Ragdoll_GetRootPosition(__id, buffer_get_address(_scratchBuffer));

		buffer_seek(_scratchBuffer, buffer_seek_start, 0);
		return new BBMOD_Vec3(
			buffer_read(_scratchBuffer, buffer_f64),
			buffer_read(_scratchBuffer, buffer_f64),
			buffer_read(_scratchBuffer, buffer_f64)
		);
	};

	/// @func apply_force(_partIndex, _force)
	///
	/// @desc Applies a physical force to a specific ragdoll body part. This
	/// is useful for creating reactive ragdolls that respond to gameplay
	/// events like explosions or impacts.
	///
	/// @param {Real} _partIndex Index of the part to apply force to. This
	/// corresponds to the order parts were added to the ragdoll info.
	/// @param {Struct.BBMOD_Vec3} _force Force vector to apply. The magnitude
	/// determines the strength of the force.
	///
	/// @return {Struct.BBMOD_Ragdoll} Returns `self` for method chaining.
	/// Returns `self` even if the part index is invalid.
	///
	/// @example
	/// ```gml
	/// // Apply explosion force to spine
	/// if (ragdoll.is_active())
	/// {
	///     var forceDir = new BBMOD_Vec3(
	///         x - explosion.x,
	///         y - explosion.y,
	///         z - explosion.z
	///     ).Normalize().Scale(5000);
	///
	///     ragdoll.apply_force(RAGDOLL_PART_SPINE, forceDir);
	/// }
	/// ```
	static apply_force = function (_partIndex, _force)
	{
		gml_pragma("forceinline");
		// GML writes force vector, C++ reads it
		var _scratchBuffer = bbmod_get_scratch_buffer();
		_force.ToBuffer(_scratchBuffer, buffer_f64);
		BBMOD_Ragdoll_ApplyForce(__id, _partIndex, buffer_get_address(_scratchBuffer));
		return self;
	};

	/// @func destroy()
	///
	/// @desc Destroys the ragdoll and frees all associated resources,
	/// including rigid bodies and constraints. The ragdoll should not be used
	/// after calling this method.
	///
	/// @return {Undefined}
	///
	/// @example
	/// ```gml
	/// // In Cleanup event
	/// if (ragdoll != undefined)
	/// {
	///     ragdoll.destroy();
	///     ragdoll = undefined;
	/// }
	/// ```
	static destroy = function ()
	{
		gml_pragma("forceinline");
		if (__id >= 0)
		{
			BBMOD_Ragdoll_Destroy(__id);
			__id = -1;
		}
		return undefined;
	};
}
