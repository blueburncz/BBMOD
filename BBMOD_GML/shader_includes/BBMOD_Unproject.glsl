/// @desc Gets screen-space UV coordinates for a clip-space point.
/// @param p A point in clip space (transformed by projection matrix, not
///          normalized).
/// @return UV coordinates on the screen.
vec2 BBMOD_Unproject(vec4 p)
{
	vec2 uv = p.xy / p.w;
	uv = uv * 0.5 + 0.5;
#if defined(_YY_HLSL11_) || defined(_YY_PSSL_)
	uv.y = 1.0 - uv.y;
#endif
	return uv;
}
