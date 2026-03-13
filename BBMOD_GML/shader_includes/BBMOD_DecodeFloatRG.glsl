/// @desc Decodes a float from RG components.
/// @param rg RG components encoding the float.
/// @return Decoded float value.
float BBMOD_DecodeFloatRG(vec2 rg)
{
	return dot(rg, vec2(1.0, 1.0 / 255.0));
}
