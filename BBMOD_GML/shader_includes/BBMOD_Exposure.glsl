/// @desc Applies camera exposure to a color.
/// @param color The input color.
/// @return Color with exposure applied.
/// @note Requires uniform: bbmod_Exposure.
vec3 BBMOD_Exposure(vec3 color)
{
	return color * bbmod_Exposure * bbmod_Exposure;
}
