/// @desc GGX normal distribution function.
/// @param roughness Material roughness.
/// @param NdotH Dot product of the surface normal and half vector.
/// @return NDF value.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float BBMOD_SpecularD_GGX(float roughness, float NdotH)
{
	float r = roughness * roughness * roughness * roughness;
	float a = NdotH * NdotH * (r - 1.0) + 1.0;
	return r / (3.14159265359 * a * a);
}
