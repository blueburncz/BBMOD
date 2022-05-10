void DoPointLightVS(
	vec3 position,
	float range,
	vec3 color,
	vec3 vertex,
	vec3 N,
	inout vec3 diffuse)
{
	vec3 L = position - vertex;
	float dist = length(L);
	float att = clamp(1.0 - (dist / range), 0.0, 1.0);
	float NdotL = max(dot(N, normalize(L)), 0.0);
	diffuse += color * NdotL * att;
}
