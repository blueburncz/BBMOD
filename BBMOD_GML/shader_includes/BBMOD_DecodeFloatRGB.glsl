/// @desc Decodes a float from RGB components.
/// @param rgb RGB components encoding the float.
/// @return Decoded float value.
float BBMOD_DecodeFloatRGB(vec3 rgb)
{
	return dot(rgb, vec3(1.0, 1.0 / 255.0, 1.0 / 65025.0));
}
