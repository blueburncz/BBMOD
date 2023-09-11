#pragma include("Material.xsh")
#if defined(X_PBR) && !defined(X_TERRAIN) && !defined(X_LIGHTMAP) && !defined(X_PARTICLES)
#    pragma include("CheapSubsurface.xsh")
#endif
#if defined(X_PBR) && !defined(X_PARTICLES)
#    pragma include("SpecularGGX.xsh")
#else
#    pragma include("SpecularBlinnPhong.xsh")
#endif

void DoPointLightPS(
	vec3 position,
	float range,
	vec3 color,
	float shadow,
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
	att *= att;
	float NdotL = max(dot(N, L), 0.0);
#if defined(X_PBR) && !defined(X_TERRAIN) && !defined(X_LIGHTMAP) && !defined(X_PARTICLES)
	subsurface += xCheapSubsurface(m.Subsurface, V, N, L, color);
#endif
	color *= (1.0 - shadow) * NdotL * att;
	diffuse += color;
#if defined(X_PBR) && !defined(X_PARTICLES)
	specular += color * SpecularGGX(m, N, V, L);
#else
	specular += color * SpecularBlinnPhong(m, N, V, L);
#endif
}
