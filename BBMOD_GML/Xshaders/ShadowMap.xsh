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
	for (int i = 0; i < SHADOWMAP_SAMPLE_COUNT; ++i)
	{
		vec2 uv2 = uv + VogelDiskSample(i, SHADOWMAP_SAMPLE_COUNT, noise) * texel * 4.0;
		shadow += step(xDecodeDepth(texture2D(shadowMap, uv2).rgb), compareZ);
	}
	return (shadow / float(SHADOWMAP_SAMPLE_COUNT));
}
