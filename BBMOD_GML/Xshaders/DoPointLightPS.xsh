#pragma include("Material.xsh")
#if defined(X_PBR)
#if !defined(X_TERRAIN)
#pragma include("CheapSubsurface.xsh")
#endif
#pragma include("SpecularGGX.xsh")
#else
#pragma include("SpecularBlinnPhong.xsh")
#endif

void DoPointLightPS(
	vec3 position,
	float range,
	vec3 color,
	vec3 vertex,
	vec3 N,
	vec3 V,
	Material m,
	inout vec3 diffuse,
	inout vec3 specular,
	inout vec3 subsurface)
{
	vec3 L = position - vertex;
	float dist = length(L);
	L = normalize(L);
	float att = clamp(1.0 - (dist / range), 0.0, 1.0);
	float NdotL = max(dot(N, L), 0.0);
#if defined(X_PBR) && !defined(X_TERRAIN)
	subsurface += xCheapSubsurface(m.Subsurface, V, N, L, color);
#endif
	color *= NdotL * att;
	diffuse += color;
#if defined(X_PBR)
	specular += color * SpecularGGX(m, N, V, L);
#else
	specular += color * SpecularBlinnPhong(m, N, V, L);
#endif
}
