#pragma include("Material.xsh")
#pragma include("DoCommonLightPS.xsh")

void DoSpotLightPS(
	vec3 position,
	float range,
	vec3 color,
	float shadow,
	vec3 direction,
	float dcosInner,
	float dcosOuter,
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
	float theta = dot(L, normalize(-direction));
	float epsilon = dcosInner - dcosOuter;
	float intensity = clamp((theta - dcosOuter) / epsilon, 0.0, 1.0);

	
	DoCommonLightPS(
		color,
		shadow,
		att * intensity,
		N,
		V,
		L,
		m,
		diffuse,
		specular,
		subsurface);
}
