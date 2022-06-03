#pragma include("Material.xsh")
#if defined(X_PBR)
#pragma include("CheapSubsurface.xsh")
#pragma include("SpecularGGX.xsh")
#else
#pragma include("SpecularBlinnPhong.xsh")
#endif

void DoDirectionalLightPS(
	vec3 direction,
	vec3 color,
	vec3 vertex,
	vec3 N,
	vec3 V,
	Material m,
	inout vec3 diffuse,
	inout vec3 specular,
	inout vec3 subsurface)
{
	vec3 L = normalize(-direction);
	float NdotL = max(dot(N, L), 0.0);
	color *= NdotL;
	diffuse += color;
#if defined(X_PBR)
	specular += color * SpecularGGX(m, N, V, L);
	subsurface += xCheapSubsurface(m.Subsurface, V, N, L, color);
#else
	specular += color * SpecularBlinnPhong(m, N, V, L);
#endif
}
