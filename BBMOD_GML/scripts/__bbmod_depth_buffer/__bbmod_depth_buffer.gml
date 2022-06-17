/// @macro {Struct.BBMOD_BaseShader} Depth shader for static models.
///
/// @example
/// Following code enables casting shadows for a custom material
/// (requires a {@link BBMOD_Renderer} with enabled shadows).
/// ```gml
/// material = BBMOD_MATERIAL_DEFAULT.clone()
///     .set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH);
/// ```
///
/// @see BBMOD_SHADER_DEPTH_ANIMATED
/// @see BBMOD_SHADER_DEPTH_BATCHED
/// @see BBMOD_ERenderPass.Shadows
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_DEPTH __bbmod_shader_depth()

/// @macro {Struct.BBMOD_BaseShader} Depth shader for animated models with bones.
///
/// @example
/// Following code enables casting shadows for a custom material
/// (requires a {@link BBMOD_Renderer} with enabled shadows).
/// ```gml
/// material = BBMOD_MATERIAL_DEFAULT_ANIMATED.clone()
///     .set_shader(BBMOD_ERenderPass.Shadows, BBMOD_MATERIAL_DEFAULT_ANIMATED);
/// ```
///
/// @see BBMOD_SHADER_DEPTH
/// @see BBMOD_SHADER_DEPTH_BATCHED
/// @see BBMOD_ERenderPass.Shadows
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_DEPTH_ANIMATED __bbmod_shader_depth_animated()

/// @macro {Struct.BBMOD_BaseShader} Depth shader for dynamically batched models.
///
/// @example
/// Following code enables casting shadows for a custom material
/// (requires a {@link BBMOD_Renderer} with enabled shadows).
/// ```gml
/// material = BBMOD_MATERIAL_DEFAULT_BATCHED.clone()
///     .set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEPTH_BATCHED);
/// ```
///
/// @see BBMOD_SHADER_DEPTH
/// @see BBMOD_SHADER_DEPTH_ANIMATED
/// @see BBMOD_ERenderPass.Shadows
/// @see BBMOD_BaseShader
/// @see BBMOD_DynamicBatch
#macro BBMOD_SHADER_DEPTH_BATCHED __bbmod_shader_depth_batched()

function __bbmod_shader_depth()
{
	static _shader = new BBMOD_BaseShader(BBMOD_ShDepth, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_depth_animated()
{
	static _shader = new BBMOD_BaseShader(BBMOD_ShDepthAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}

function __bbmod_shader_depth_batched()
{
	static _shader = new BBMOD_BaseShader(BBMOD_ShDepthBatched, BBMOD_VFORMAT_DEFAULT_BATCHED);
	return _shader;
}
