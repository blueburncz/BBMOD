#pragma include("Fog.xsh")
#pragma include("Exposure.xsh")
#pragma include("TonemapReinhard.xsh")
#pragma include("GammaCorrect.xsh")
#if defined(X_PARTICLES)
#pragma include("Projecting.xsh")
#pragma include("DepthEncoding.xsh")
#endif
#pragma include("MetallicMaterial.xsh")

void UnlitShader(Material material, float depth)
{
	gl_FragColor.rgb = material.Base;
	gl_FragColor.rgb += material.Emissive;
	gl_FragColor.a = material.Opacity;
	// Soft particles
#if defined(X_PARTICLES)
	if (bbmod_SoftDistance > 0.0)
	{
		float sceneDepth = xDecodeDepth(texture2D(bbmod_GBuffer, xUnproject(v_vPosition)).rgb) * bbmod_ZFar;
		float softness = clamp((sceneDepth - v_vPosition.z) / bbmod_SoftDistance, 0.0, 1.0);
		gl_FragColor.a *= softness;
	}
#endif
	Fog(depth);

	if (bbmod_HDR == 0.0)
	{
		Exposure();
		TonemapReinhard();
		GammaCorrect();
	}
}
