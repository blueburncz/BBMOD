/// @enum Enumeration of render passes.
enum BBMOD_ERenderPass
{
	/// @member Render pass where shadow-casting are objects rendered into
	/// shadow maps.
	Shadows,
	/// @member Render pass where opaque objects are rendered into a g-buffer.
	Deferred,
	/// @member Render pass where opaque objects are rendered into the frame
	/// buffer.
	Forward,
	/// @member Render pass where alpha-blended objects are rendered.
	Alpha,
	/// @member Total number of members of this enum.
	SIZE
};

/// @macro {BBMOD_ERenderPass} Render pass where shadow-casting objects are
/// rendered into shadow maps.
/// @deprecated Please use {@link BBMOD_ERenderPass.Shadows} instead.
/// @see BBMOD_ERenderPass
#macro BBMOD_RENDER_SHADOWS BBMOD_ERenderPass.Shadows

/// @macro {BBMOD_ERenderPass} Render pass where opaque objects are rendered
/// into a g-buffer.
/// @deprecated Please use {@link BBMOD_ERenderPass.Deferred} instead.
/// @see BBMOD_ERenderPass
#macro BBMOD_RENDER_DEFERRED BBMOD_ERenderPass.Deferred

/// @macro {BBMOD_ERenderPass} Render pass where opaque objects are rendered
/// into the frame buffer.
/// @deprecated Please use {@link BBMOD_ERenderPass.Forward} instead.
/// @see BBMOD_ERenderPass
#macro BBMOD_RENDER_FORWARD BBMOD_ERenderPass.Forward