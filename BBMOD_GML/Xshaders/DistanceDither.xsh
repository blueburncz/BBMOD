float xDistanceDitherNoise(vec2 positionScreen, float seed)
{
	vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(dot(positionScreen + vec2(seed * 13.13, seed * 7.31), magic.xy)));
}

void xApplyDistanceDither(float seed, float fadeMultiplier)
{
	if (bbmod_DitherEnable <= 0.0)
	{
		return;
	}

	float fade = clamp(fadeMultiplier, 0.0, 1.0);

	if (fade <= 0.0)
	{
		discard;
	}

	float threshold = xDistanceDitherNoise(gl_FragCoord.xy, seed);
	if (threshold > fade)
	{
		discard;
	}
}
