#pragma include("Material.xsh")
#pragma include("BRDF.xsh")

vec3 SpecularGGX(Material m, vec3 N, vec3 V, vec3 L)
{
	vec3 H = normalize(L + V);
	float NdotL = max(dot(N, L), 0.0);
	float NdotV = max(dot(N, V), 0.0);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);
	return xBRDF(m.Specular, m.Roughness, NdotL, NdotV, NdotH, VdotH);
}
