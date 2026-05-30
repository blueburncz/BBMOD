// @include BBMOD_SpecularD_GGX
// @include BBMOD_SpecularF_Schlick
// @include BBMOD_SpecularG_Schlick
// @include BBMOD_K_Analytic

/// @desc Cook-Torrance microfacet specular BRDF.
/// @param f0 Fresnel reflectance at normal incidence (specular color).
/// @param roughness Material roughness.
/// @param NdotL Dot product of the surface normal and light direction.
/// @param NdotV Dot product of the surface normal and view direction.
/// @param NdotH Dot product of the surface normal and half vector.
/// @param VdotH Dot product of the view direction and half vector.
/// @return Specular BRDF value.
/// @note N = normalize(vertexNormal), L = normalize(light - vertex),
///       V = normalize(camera - vertex), H = normalize(L + V).
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 BBMOD_BRDF(
	vec3 f0, float roughness,
	float NdotL, float NdotV, float NdotH, float VdotH)
{
	vec3 specular = BBMOD_SpecularD_GGX(roughness, NdotH)
		* BBMOD_SpecularF_Schlick(f0, VdotH)
		* BBMOD_SpecularG_Schlick(BBMOD_K_Analytic(roughness), NdotL, NdotV);
	return specular / ((4.0 * NdotL * NdotV) + 0.1);
}
