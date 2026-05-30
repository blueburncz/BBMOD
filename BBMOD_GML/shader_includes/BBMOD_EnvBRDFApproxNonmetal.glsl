/// @desc Approximates the environment BRDF for non-metallic (dielectric)
/// surfaces. Equivalent to BBMOD_EnvBRDFApprox with f0=0.04.
/// @param roughness Material roughness.
/// @param NdotV Dot product of the surface normal and view direction.
/// @return Approximated BRDF scalar value.
/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
float BBMOD_EnvBRDFApproxNonmetal(float roughness, float NdotV)
{
	const vec2 c0 = vec2(-1.0, -0.0275);
	const vec2 c1 = vec2(1.0, 0.0425);
	vec2 r = (roughness * c0) + c1;
	return (min(r.x * r.x, exp2(-9.28 * NdotV)) * r.x) + r.y;
}
