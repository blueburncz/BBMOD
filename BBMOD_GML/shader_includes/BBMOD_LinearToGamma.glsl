/// @desc Converts linear space color to gamma space.
/// @param rgb Color in linear space.
/// @return Color in gamma space.
vec3 BBMOD_LinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / 2.2));
}
