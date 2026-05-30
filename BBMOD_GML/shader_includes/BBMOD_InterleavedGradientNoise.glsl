/// @desc Computes interleaved gradient noise for shadow map filtering.
/// @param positionScreen Screen-space position (e.g. gl_FragCoord.xy).
/// @return Noise value in [0, 1).
/// @source https://www.gamedev.net/tutorials/programming/graphics/contact-hardening-soft-shadows-made-fast-r4906/
float BBMOD_InterleavedGradientNoise(vec2 positionScreen)
{
	vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	return fract(magic.z * fract(dot(positionScreen, magic.xy)));
}
