// @include BBMOD_Vec3ToOctahedronUV
// @include BBMOD_DecodeRGBM
// @include BBMOD_GammaToLinear
// @include BBMOD_EnvBRDFApprox

/// @desc Samples the specular contribution from a prefiltered octahedral IBL
/// map using the UE4 split-sum approximation.
/// @param ibl Prefiltered IBL texture (8 octahedral roughness levels stacked
///            horizontally; level 0 = lowest roughness).
/// @param texel Texel size of one octahedron face (vec2(1.0/(8*w), 1.0/h)).
/// @param f0 Fresnel reflectance at normal incidence (specular color).
/// @param roughness Material roughness.
/// @param N Surface normal.
/// @param V View direction (normalized, pointing toward camera).
/// @return Specular IBL radiance in linear space.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 BBMOD_SpecularIBL(
	sampler2D ibl, vec2 texel, vec3 f0, float roughness, vec3 N, vec3 V)
{
	float NdotV = clamp(dot(N, V), 0.0, 1.0);
	vec3 R = 2.0 * dot(V, N) * N - V;
	vec2 envBRDF = BBMOD_EnvBRDFApprox(roughness, NdotV);
	const float s = 1.0 / 8.0;
	float r = roughness * 7.0;
	float r2 = floor(r);
	float rDiff = r - r2;
	vec2 uv0 = BBMOD_Vec3ToOctahedronUV(R);
	uv0.x = (r2 + mix(texel.x, 1.0 - texel.x, uv0.x)) * s;
	uv0.y = mix(texel.y, 1.0 - texel.y, uv0.y);
	vec2 uv1 = uv0;
	uv1.x += s;
	vec3 specular = f0 * envBRDF.x + envBRDF.y;
	vec3 col0 = BBMOD_GammaToLinear(BBMOD_DecodeRGBM(texture2D(ibl, uv0))) * specular;
	vec3 col1 = BBMOD_GammaToLinear(BBMOD_DecodeRGBM(texture2D(ibl, uv1))) * specular;
	return mix(col0, col1, rDiff);
}
