/// @desc Accumulates point light diffuse contribution in the vertex shader
/// (no specular, no shadows).
/// @param position World-space light position.
/// @param range Light attenuation range.
/// @param color Light color (linear, pre-multiplied by intensity).
/// @param vertex World-space vertex position.
/// @param N Surface normal (normalized).
/// @param diffuse Accumulated diffuse light (inout).
void BBMOD_DoPointLightVS(
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
