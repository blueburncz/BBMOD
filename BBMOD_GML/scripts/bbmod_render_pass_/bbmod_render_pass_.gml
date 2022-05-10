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
	/// @member Render pass where instance IDs are rendered into an off-screen
	/// buffer.
	Id,
	/// @member Total number of members of this enum.
	SIZE,
};

/// @var {Enum.BBMOD_ERenderPass}
/// @private
global.__bbmodRenderPass = BBMOD_ERenderPass.Forward;

/// @func bbmod_render_pass_get()
/// @desc Retrieves the current render pass.
/// @return {BBMOD_ERenderPass} The current render pass.
/// @see bbmod_render_pass_set
/// @see BBMOD_ERenderPass
function bbmod_render_pass_get()
{
	gml_pragma("forceinline");
	return global.__bbmodRenderPass;
}

/// @func bbmod_render_pass_set(_pass)
/// @desc Sets the current render pass. Only meshes with materials that have
/// a shader defined for the render pass will be rendered.
/// @param {BBMOD_ERenderPass} _pass The render pass. By default this is set to
/// {@link BBMOD_ERenderPass.Forward}.
/// @see bbmod_render_pass_get
/// @see BBMOD_BaseMaterial.set_shader
/// @see BBMOD_ERenderPass
function bbmod_render_pass_set(_pass)
{
	gml_pragma("forceinline");
	global.__bbmodRenderPass = _pass;
}