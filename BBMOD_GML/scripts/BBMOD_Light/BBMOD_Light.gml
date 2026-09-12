/// @module Core

/// @func BBMOD_Light()
///
/// @implements {BBMOD_IDestructible}
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
		| (1 << BBMOD_ERenderPass.Alpha)
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

	/// @var {Asset.GMSprite} Sprite used for the editor icon.
	EditorIconSprite = BBMOD_SprParticle;

	/// @var {Real} Subimage used for the editor icon.
	EditorIconIndex = 0;

	/// @var {Real} Priority used when editor icons overlap.
	EditorPickPriority = 0;

	/// @var {Real} Distance at which the editor icon starts fading.
	EditorIconFadeStart = 100.0;

	/// @var {Real} Distance at which the editor icon is hidden.
	EditorIconFadeEnd = 120.0;

	/// @var {Struct.BBMOD_Vec3} World-space editor icon offset.
	EditorOffset = new BBMOD_Vec3();

	/// @var {Real} Editor transform capabilities.
	EditorFlags = BBMOD_EEditorFlag.Translate
		| BBMOD_EEditorFlag.Rotate
		| BBMOD_EEditorFlag.Scale;

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

	static to_buffer = function (_buffer)
	{
		buffer_write(_buffer, buffer_bool, Enabled);
		buffer_write(_buffer, buffer_u32, RenderPass);
		Position.ToBuffer(_buffer, buffer_f64);
		buffer_write(_buffer, buffer_bool, AffectLightmaps);
		buffer_write(_buffer, buffer_bool, CastShadows);
		buffer_write(_buffer, buffer_u32, ShadowmapResolution);
		buffer_write(_buffer, buffer_u32, Frameskip);
		buffer_write(_buffer, buffer_bool, Static);
		buffer_write(_buffer, buffer_bool, NeedsUpdate);
		return self;
	};

	static from_buffer = function (_buffer)
	{
		Enabled = buffer_read(_buffer, buffer_bool);
		RenderPass = buffer_read(_buffer, buffer_u32);
		Position = new BBMOD_Vec3().FromBuffer(_buffer, buffer_f64);
		AffectLightmaps = buffer_read(_buffer, buffer_bool);
		CastShadows = buffer_read(_buffer, buffer_bool);
		ShadowmapResolution = buffer_read(_buffer, buffer_u32);
		Frameskip = buffer_read(_buffer, buffer_u32);
		Static = buffer_read(_buffer, buffer_bool);
		NeedsUpdate = buffer_read(_buffer, buffer_bool);
		__frameskipCurrent = 0;
		return self;
	};

	/// @func destroy()
	///
	/// @desc Destroys the light.
	///
	/// @return {Undefined} Always returns `undefined`.
	static destroy = function ()
	{
		return undefined;
	};
}
