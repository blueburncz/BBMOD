// @include BBMOD_EncodeDepth

/// @desc Outputs an encoded depth value for shadow map generation.
/// Writes directly to gl_FragColor.
/// Requires uniform: bbmod_ZFar.
/// @param depth Scene depth (view-space Z or distance from camera).
void BBMOD_DepthShader(float depth)
{
	gl_FragColor.rgb = BBMOD_EncodeDepth(depth / bbmod_ZFar);
	gl_FragColor.a = 1.0;
}
