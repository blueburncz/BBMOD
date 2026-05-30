/// @desc Approximates the environment BRDF look-up for PBR specular lighting.
/// @param roughness Material roughness.
/// @param NdotV Dot product of the surface normal and view direction.
/// @return Approximated BRDF coefficients: x=scale, y=bias applied to f0.
/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
vec2 BBMOD_EnvBRDFApprox(float roughness, float NdotV)
{
	const vec4 c0 = vec4(-1.0, -0.0275, -0.572, 0.022);
	const vec4 c1 = vec4(1.0, 0.0425, 1.04, -0.04);
	vec4 r = (roughness * c0) + c1;
	float a004 = (min(r.x * r.x, exp2(-9.28 * NdotV)) * r.x) + r.y;
	return (vec2(-1.04, 1.04) * a004) + r.zw;
}
