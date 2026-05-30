// @include BBMOD_DecodeDepth
// @include BBMOD_InterleavedGradientNoise
// @include BBMOD_VogelDiskSample

/// @desc Samples a shadow map and returns the shadow factor.
/// Requires uniform: bbmod_ShadowmapBias, bbmod_ShadowmapArea.
/// Requires define: SHADOWMAP_SAMPLE_COUNT (e.g. 12).
/// @param shadowMap Shadow map texture.
/// @param texel Shadow map texel size (vec2(1/w, 1/h)).
/// @param uv Shadow map UV coordinates.
/// @param compareZ Normalized depth to compare against (0..1).
/// @return Shadow factor in [0, 1]; 1 = fully in shadow.
float BBMOD_ShadowMap(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
	if (clamp(uv.xy, vec2(0.0), vec2(1.0)) != uv.xy)
	{
		return 0.0;
	}
	float shadow = 0.0;
	float noise = 6.28318530718
		* BBMOD_InterleavedGradientNoise(gl_FragCoord.xy);
	float bias = bbmod_ShadowmapBias / bbmod_ShadowmapArea;
	for (int i = 0; i < SHADOWMAP_SAMPLE_COUNT; ++i)
	{
		vec2 uv2 = uv
			+ BBMOD_VogelDiskSample(i, SHADOWMAP_SAMPLE_COUNT, noise)
			* texel * 4.0;
		float depth = BBMOD_DecodeDepth(texture2D(shadowMap, uv2).rgb);
		if (bias != 0.0)
		{
			shadow += clamp((compareZ - depth) / bias, 0.0, 1.0);
		}
		else
		{
			shadow += step(depth, compareZ);
		}
	}
	return (shadow / float(SHADOWMAP_SAMPLE_COUNT));
}
