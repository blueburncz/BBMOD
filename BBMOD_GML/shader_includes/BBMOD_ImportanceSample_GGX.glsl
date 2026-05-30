// @include BBMOD_ImportanceSample

/// @desc Importance samples a GGX specular BRDF.
/// @param Xi 2D uniform sample (e.g. from BBMOD_Hammersley2D).
/// @param N Surface normal.
/// @param roughness Material roughness.
/// @return Importance sampled world-space direction.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 BBMOD_ImportanceSample_GGX(vec2 Xi, vec3 N, float roughness)
{
	float a = roughness * roughness;
	float phi = 2.0 * 3.14159265359 * Xi.x;
	float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a * a - 1.0) * Xi.y));
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	return BBMOD_ImportanceSample(phi, cosTheta, sinTheta, N);
}
