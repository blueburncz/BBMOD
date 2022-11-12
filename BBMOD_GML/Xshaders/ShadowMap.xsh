#pragma include("DepthEncoding.xsh")
#pragma include("InterleavedGradientNoise.xsh")
#pragma include("VogelDiskSample.xsh")

float ShadowMap(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
	if (clamp(uv.xy, vec2(0.0), vec2(1.0)) != uv.xy)
	{
		return 0.0;
	}
	float shadow = 0.0;
	float noise = 6.28 * InterleavedGradientNoise(gl_FragCoord.xy);
	float bias = bbmod_ShadowmapBias / bbmod_ShadowmapArea;
	for (int i = 0; i < SHADOWMAP_SAMPLE_COUNT; ++i)
	{
		vec2 uv2 = uv + VogelDiskSample(i, SHADOWMAP_SAMPLE_COUNT, noise) * texel * 4.0;
		float depth = xDecodeDepth(texture2D(shadowMap, uv2).rgb);
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
