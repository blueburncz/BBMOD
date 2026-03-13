/// @desc Decodes RGBM encoded HDR color.
/// @param rgbm RGBM encoded color (RGB in rgb channels, multiplier in alpha).
/// @return Decoded HDR color.
/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec3 BBMOD_DecodeRGBM(vec4 rgbm)
{
	return 6.0 * rgbm.rgb * rgbm.a;
}
