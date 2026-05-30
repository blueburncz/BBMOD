/// @desc Computes a cheap subsurface scattering approximation.
/// @param subsurface Subsurface color (rgb) and thickness/intensity (a).
/// @param eye View direction (normalized, pointing from vertex toward camera).
/// @param normal Surface normal (normalized).
/// @param light Light direction (normalized, pointing toward light source).
/// @param lightColor Light color and intensity.
/// @return Subsurface scattering contribution.
/// @source https://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/
vec3 BBMOD_CheapSubsurface(
	vec4 subsurface, vec3 eye, vec3 normal, vec3 light, vec3 lightColor)
{
	const float fLTPower = 1.0;
	const float fLTScale = 1.0;
	vec3 vLTLight = light + normal;
	float fLTDot = pow(clamp(dot(eye, -vLTLight), 0.0, 1.0), fLTPower) * fLTScale;
	float fLT = fLTDot * subsurface.a;
	return subsurface.rgb * lightColor * fLT;
}
