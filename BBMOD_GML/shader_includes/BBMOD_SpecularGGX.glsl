// @include BBMOD_BRDF
// @include BBMOD_Material

/// @desc Evaluates Cook-Torrance GGX specular for a light direction.
/// @param m Material properties.
/// @param N Surface normal (normalized).
/// @param V View direction (normalized, pointing toward camera).
/// @param L Light direction (normalized, pointing toward light).
/// @return Specular BRDF value.
vec3 BBMOD_SpecularGGX(BBMOD_Material m, vec3 N, vec3 V, vec3 L)
{
	vec3 H = normalize(L + V);
	float NdotL = max(dot(N, L), 0.0);
	float NdotV = max(dot(N, V), 0.0);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);
	return BBMOD_BRDF(m.Specular, m.Roughness, NdotL, NdotV, NdotH, VdotH);
}
