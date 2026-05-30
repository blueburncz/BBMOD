/// @desc Approximate GGX normal distribution function (UE4 mobile version).
/// Cheaper than BBMOD_SpecularD_GGX; uses exp2 approximation.
/// @param roughness Material roughness.
/// @param RdotL Dot product of the reflection vector and light direction.
/// @return Approximate NDF value.
/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
float BBMOD_SpecularD_Approx(float roughness, float RdotL)
{
	float a = roughness * roughness;
	float a2 = a * a;
	float rcp_a2 = 1.0 / a2;
	float c = (0.72134752 * rcp_a2) + 0.39674113;
	return (rcp_a2 * exp2((c * RdotL) - c));
}
