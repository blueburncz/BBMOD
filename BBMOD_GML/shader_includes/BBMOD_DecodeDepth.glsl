/// @desc Decodes a linearized depth value from RGB channels.
/// @param c Encoded depth as RGB.
/// @return Decoded linearized depth (0..1 range).
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float BBMOD_DecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}
