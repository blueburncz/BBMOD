// @include BBMOD_Vec3ToOctahedronUV
// @include BBMOD_DecodeRGBM
// @include BBMOD_GammaToLinear

/// @desc Samples the diffuse (irradiance) contribution from a prefiltered
/// octahedral IBL map.
/// @param ibl Prefiltered IBL texture (8 octahedral levels stacked horizontally;
///            level 0 = diffuse irradiance, levels 1-7 = specular roughness).
/// @param texel Texel size of one octahedron face (vec2(1.0/(8*w), 1.0/h)).
/// @param N Surface normal.
/// @return Diffuse IBL radiance in linear space.
vec3 BBMOD_DiffuseIBL(sampler2D ibl, vec2 texel, vec3 N)
{
	const float s = 1.0 / 8.0;
	const float r2 = 7.0;
	vec2 uv0 = BBMOD_Vec3ToOctahedronUV(N);
	uv0.x = (r2 + mix(texel.x, 1.0 - texel.x, uv0.x)) * s;
	uv0.y = mix(texel.y, 1.0 - texel.y, uv0.y);
	return BBMOD_GammaToLinear(BBMOD_DecodeRGBM(texture2D(ibl, uv0)));
}
