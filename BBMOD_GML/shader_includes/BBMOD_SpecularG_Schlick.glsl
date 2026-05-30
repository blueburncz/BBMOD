/// @desc Schlick-GGX geometric attenuation (Smith approximation).
/// @param k Remapped roughness (use BBMOD_K_Analytic or BBMOD_K_IBL).
/// @param NdotL Dot product of the surface normal and light direction.
/// @param NdotV Dot product of the surface normal and view direction.
/// @return Geometric attenuation factor.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float BBMOD_SpecularG_Schlick(float k, float NdotL, float NdotV)
{
	return (NdotL / (NdotL * (1.0 - k) + k))
		* (NdotV / (NdotV * (1.0 - k) + k));
}
