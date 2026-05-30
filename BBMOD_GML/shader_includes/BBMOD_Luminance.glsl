/// @desc Gets the luminance of an RGB color.
/// @param rgb Input color.
/// @return Luminance value.
float BBMOD_Luminance(vec3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}
