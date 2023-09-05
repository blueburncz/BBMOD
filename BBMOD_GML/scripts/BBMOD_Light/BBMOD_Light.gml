/// @module Core

/// @func BBMOD_Light()
///
/// @desc Base class for lights.
function BBMOD_Light() constructor
{
	/// @var {Bool} Use `false` to disable the light. Defaults to `true` (the
	/// light is enabled).
	Enabled = true;

	/// @var {Real} Bitwise OR of 1 << render pass in which the light is enabled.
	/// By default this is {@link BBMOD_ERenderPass.Forward}
	/// and {@link BBMOD_ERenderPass.ReflectionCapture}, which means the light
	/// is visible only in the forward render pass and during capture of
	/// reflection probes.
	///
	/// @example
	/// ```gml
	/// flashlight = new BBMOD_SpotLight();
	/// // Make the flashlight visible only in the forward render pass
	/// flashlight.RenderPass = (1 << BBMOD_ERenderPass.Forward);
	/// ```
	///
	/// @see BBMOD_ERenderPass
	RenderPass = (1 << BBMOD_ERenderPass.Forward)
		| (1 << BBMOD_ERenderPass.ReflectionCapture);

	/// @var {Struct.BBMOD_Vec3} The position of the light.
	Position = new BBMOD_Vec3();

	/// @var {Bool} If `true` then the light affects also materials with baked
	/// lightmaps. Defaults to `true`.
	AffectLightmaps = true;

	/// @var {Bool} If `true` then the light should casts shadows. This may
	/// not be implemented for all types of lights! Defaults to `false`.
	CastShadows = false;

	/// @var {Real} The resolution of the shadowmap surface. Must be power of 2.
	/// Defaults to 512.
	ShadowmapResolution = 512;

	/// @var {Real} Number of frames to skip between individual updates of the
	/// light's shadowmap. Default value is 0, which means no frame skipping.
	Frameskip = 0;

	/// @var {Real}
	/// @private
	__frameskipCurrent = 0;

	/// @var {Bool} If `true` then the light's shadowmap is captured only once
	/// or when requested via setting the {@link BBMOD_Light.NeedsUpdate} property
	/// to `true`.
	Static = false;

	/// @var {Bool} If `true` and the light is static, its shadowmap needs to be
	/// updated.
	/// @note This is automatically reset to `false` when the shadowmap is updated.
	/// @see BBMOD_Light.Static
	NeedsUpdate = true;

	/// @var {Function}
	/// @private
	__getZFar = undefined;

	/// @var {Function}
	/// @private
	__getViewMatrix = undefined;

	/// @var {Function}
	/// @private
	__getProjMatrix = undefined;

	/// @var {Function}
	/// @private
	__getShadowmapMatrix = undefined;
}
