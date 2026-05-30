// @include BBMOD_Material
// @include BBMOD_Fog
// @include BBMOD_Exposure
// @include BBMOD_TonemapReinhard
// @include BBMOD_GammaCorrect
// @include BBMOD_DecodeDepth
// @include BBMOD_Unproject

/// @desc Unlit shading pass. Writes the final color to gl_FragColor.
/// Requires uniforms: bbmod_HDR, bbmod_ZFar,
///   bbmod_FogColor, bbmod_FogIntensity, bbmod_FogStart, bbmod_FogRcpRange,
///   bbmod_LightAmbientUp, bbmod_LightAmbientDown, bbmod_LightDirectionalColor.
/// @param material Unpacked material properties.
/// @param depth View-space depth of the fragment.
void BBMOD_UnlitShader(BBMOD_Material material, float depth)
{
	gl_FragColor.rgb = material.Base;

// @if defined(BBMOD_EMISSIVE)
	gl_FragColor.rgb += material.Emissive;
// @endif

	gl_FragColor.a = material.Opacity;

// @if defined(BBMOD_PARTICLES)
	if (bbmod_SoftDistance > 0.0)
	{
		float sceneDepth = BBMOD_DecodeDepth(
			texture2D(bbmod_GBuffer,
				BBMOD_Unproject(v_vPosition)).rgb) * bbmod_ZFar;
		float softness = clamp(
			(sceneDepth - v_vPosition.z) / bbmod_SoftDistance, 0.0, 1.0);
		gl_FragColor.a *= softness;
	}
// @endif

	gl_FragColor.rgb = BBMOD_Fog(gl_FragColor.rgb, depth);

	if (bbmod_HDR == 0.0)
	{
		gl_FragColor.rgb = BBMOD_Exposure(gl_FragColor.rgb);
		gl_FragColor.rgb = BBMOD_TonemapReinhard(gl_FragColor.rgb);
		gl_FragColor.rgb = BBMOD_GammaCorrect(gl_FragColor.rgb);
	}
}
