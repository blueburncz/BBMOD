#pragma include("Material.xsh")
#pragma include("DoCommonLightPS.xsh")

void DoDirectionalLightPS(
	vec3 direction,
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
	vec3 L = normalize(-direction);

	DoCommonLightPS(
		color,
		shadow,
		1.0,
		N,
		V,
		L,
		m,
		diffuse,
		specular,
		subsurface);
}
