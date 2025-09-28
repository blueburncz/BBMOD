#pragma include("Material.xsh")
#if defined(X_PBR) && !defined(X_TERRAIN) && !defined(X_LIGHTMAP) && !defined(X_PARTICLES)
#    pragma include("CheapSubsurface.xsh")
#endif
#if defined(X_PBR) && !defined(X_PARTICLES)
#    pragma include("BRDF.xsh")
#endif

void DoCommonLightPS(
	vec3 color,
	float shadow,
	float att,
	vec3 N,
	vec3 V,
	vec3 L,
	Material m,
	inout vec3 diffuse,
	inout vec3 specular,
	inout vec3 subsurface)
{
	float NdotL = max(dot(N, L), 0.0);
	vec3 H = normalize(L + V);
	float NdotV = max(dot(N, V), 0.0);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);

#if defined(X_PBR) && !defined(X_TERRAIN) && !defined(X_LIGHTMAP) && !defined(X_PARTICLES)
	subsurface += xCheapSubsurface(m.Subsurface, V, N, L, color);
#endif

	color *= (1.0 - shadow) * NdotL * att;

#if defined(X_PBR) && !defined(X_PARTICLES)
	float D = xSpecularD_GGX(m.Roughness, NdotH);
	vec3 F = xSpecularF_Schlick(m.Specular, VdotH);
	float G = xSpecularG_Schlick(xK_Analytic(m.Roughness), NdotL, NdotH);
	specular += color * ((D * F * G) / ((4.0 * NdotL * NdotV) + 0.1));
#else
	vec3 F = m.Specular + (1.0 - m.Specular) * pow(1.0 - VdotH, 5.0);
	float G = 0.25;
	float A = m.SpecularPower / log(2.0);
	float blinnPhong = exp2(A * NdotH - A);
	float blinnNormalization = (m.SpecularPower + 8.0) / 8.0;
	float D = blinnPhong * blinnNormalization;
	specular += color * (D * F * G);
#endif

	diffuse += color * (vec3(1.0) - F);
}
