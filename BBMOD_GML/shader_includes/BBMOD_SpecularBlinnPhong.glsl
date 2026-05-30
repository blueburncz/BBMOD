// @include BBMOD_Material

/// @desc Evaluates Blinn-Phong specular for a light direction.
/// @param m Material properties.
/// @param N Surface normal (normalized).
/// @param V View direction (normalized, pointing toward camera).
/// @param L Light direction (normalized, pointing toward light).
/// @return Specular value.
vec3 BBMOD_SpecularBlinnPhong(BBMOD_Material m, vec3 N, vec3 V, vec3 L)
{
	vec3 H = normalize(L + V);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);
	vec3 fresnel = m.Specular + (1.0 - m.Specular) * pow(1.0 - VdotH, 5.0);
	float visibility = 0.25;
	float A = m.SpecularPower / log(2.0);
	float blinnPhong = exp2(A * NdotH - A);
	float blinnNormalization = (m.SpecularPower + 8.0) / 8.0;
	float normalDistribution = blinnPhong * blinnNormalization;
	return fresnel * visibility * normalDistribution;
}
