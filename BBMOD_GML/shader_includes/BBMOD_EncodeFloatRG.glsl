/// @desc Encodes a float into RG components.
/// @param v Float to encode.
/// @return RG components encoding the float.
vec2 BBMOD_EncodeFloatRG(float v)
{
	vec2 enc = vec2(1.0, 255.0) * v;
	enc = fract(enc);
	enc.x -= enc.y * (1.0 / 255.0);
	return enc;
}
