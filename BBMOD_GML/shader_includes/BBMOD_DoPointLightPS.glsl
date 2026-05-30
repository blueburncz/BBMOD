// @include BBMOD_Material
// @if defined(BBMOD_SUBSURFACE)
// @include BBMOD_CheapSubsurface
// @endif
// @include BBMOD_SpecularGGX
// @include BBMOD_SpecularBlinnPhong

/// @desc Accumulates point light contribution to diffuse, specular, and
/// subsurface outputs.
/// @param position World-space light position.
/// @param range Light attenuation range.
/// @param color Light color (linear, pre-multiplied by intensity).
/// @param shadow Shadow factor in [0, 1]; 1 = fully in shadow.
/// @param vertex World-space vertex position.
/// @param N Surface normal (normalized).
/// @param V View direction (normalized, pointing toward camera).
/// @param m Material properties.
/// @param diffuse Accumulated diffuse light (inout).
/// @param specular Accumulated specular light (inout).
// @if defined(BBMOD_SUBSURFACE)
/// @param subsurface Accumulated subsurface light (inout).
// @endif
void BBMOD_DoPointLightPS(
	vec3 position,
	float range,
	vec3 color,
	float shadow,
	vec3 vertex,
	vec3 N,
	vec3 V,
	BBMOD_Material m,
	inout vec3 diffuse,
	inout vec3 specular
// @if defined(BBMOD_SUBSURFACE)
	,
	inout vec3 subsurface
// @endif
	)
{
	vec3 L = position - vertex;
	float dist = length(L);
	L = normalize(L);
	float att = clamp(1.0 - (dist / range), 0.0, 1.0);
	att *= att;
	float NdotL = max(dot(N, L), 0.0);
// @if defined(BBMOD_SUBSURFACE) && defined(BBMOD_PBR) && !defined(BBMOD_TERRAIN) && !defined(BBMOD_LIGHTMAP)
	subsurface += BBMOD_CheapSubsurface(m.Subsurface, V, N, L, color);
// @endif
	color *= (1.0 - shadow) * NdotL * att;
	diffuse += color;
// @if defined(BBMOD_PBR) && !defined(BBMOD_PARTICLES)
	specular += color * BBMOD_SpecularGGX(m, N, V, L);
// @else
	specular += color * BBMOD_SpecularBlinnPhong(m, N, V, L);
// @endif
}
