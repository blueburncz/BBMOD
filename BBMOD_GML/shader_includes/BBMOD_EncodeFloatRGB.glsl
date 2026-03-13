/// @desc Encodes a float into RGB components.
/// @param v Float to encode.
/// @return RGB components encoding the float.
vec3 BBMOD_EncodeFloatRGB(float v)
{
	vec3 enc = vec3(1.0, 255.0, 65025.0) * v;
	enc = fract(enc);
	enc.xy -= enc.yz * (1.0 / 255.0);
	return enc;
}
