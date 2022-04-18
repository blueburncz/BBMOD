#pragma include("Material.xsh", "glsl")

#pragma include("SpecularBlinnPhong.xsh", "glsl")

void DoPointLightPS(
	vec3 position,
	float range,
	vec3 color,
	vec3 vertex,
	vec3 N,
	vec3 V,
	Material m,
	inout vec3 diffuse,
	inout vec3 specular)
{
	vec3 L = position - vertex;
	float dist = length(L);
	L = normalize(L);
	float att = clamp(1.0 - (dist / range), 0.0, 1.0);
	float NdotL = max(dot(N, L), 0.0);
	color *= NdotL * att;
	diffuse += color;
	specular += color * SpecularBlinnPhong(m, N, V, L);
}
