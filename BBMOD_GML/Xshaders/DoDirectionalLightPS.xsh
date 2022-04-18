#pragma include("Material.xsh", "glsl")

#pragma include("SpecularBlinnPhong.xsh", "glsl")

void DoDirectionalLightPS(
	vec3 direction,
	vec3 color,
	vec3 vertex,
	vec3 N,
	vec3 V,
	Material m,
	inout vec3 diffuse,
	inout vec3 specular)
{
	vec3 L = normalize(-direction);
	float NdotL = max(dot(N, L), 0.0);
	color *= NdotL;
	diffuse += color;
	specular += color * SpecularBlinnPhong(m, N, V, L);
}
