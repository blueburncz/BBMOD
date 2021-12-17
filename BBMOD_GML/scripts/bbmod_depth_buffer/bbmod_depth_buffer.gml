/// @macro {BBMOD_BaseShader} Depth shader for static models.
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_DEPTH __bbmod_shader_depth()

/// @macro {BBMOD_BaseShader} Depth shader for animated models with bones.
/// @see BBMOD_BaseShader
#macro BBMOD_SHADER_DEPTH_ANIMATED __bbmod_shader_depth_animated()

/// @macro {BBMOD_BaseShader} Depth shader for dynamically batched models.
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