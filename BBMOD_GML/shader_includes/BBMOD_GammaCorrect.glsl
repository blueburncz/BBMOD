// @include BBMOD_LinearToGamma

/// @desc Converts a linear-space color to gamma space (gamma correction).
/// @param color Input color in linear space.
/// @return Color in gamma space.
vec3 BBMOD_GammaCorrect(vec3 color)
{
	return BBMOD_LinearToGamma(color);
}
