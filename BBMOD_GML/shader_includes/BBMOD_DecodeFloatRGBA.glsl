/// @desc Decodes a float from RGBA components.
/// @param rgba RGBA components encoding the float.
/// @return Decoded float value.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float BBMOD_DecodeFloatRGBA(vec4 rgba)
{
	return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}
