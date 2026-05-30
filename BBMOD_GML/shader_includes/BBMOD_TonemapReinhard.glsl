/// @desc Applies Reinhard tonemapping to a color.
/// @param color The input color in HDR.
/// @return Tonemapped color in LDR.
vec3 BBMOD_TonemapReinhard(vec3 color)
{
	return color / (vec3(1.0) + color);
}
