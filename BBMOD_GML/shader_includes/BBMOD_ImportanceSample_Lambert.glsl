// @include BBMOD_ImportanceSample

/// @desc Importance samples a Lambert (diffuse) BRDF.
/// @param Xi 2D uniform sample (e.g. from BBMOD_Hammersley2D).
/// @param N Surface normal.
/// @return Importance sampled world-space direction.
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
vec3 BBMOD_ImportanceSample_Lambert(vec2 Xi, vec3 N)
{
	float phi = 2.0 * 3.14159265359 * Xi.y;
	float cosTheta = sqrt(1.0 - Xi.x);
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	return BBMOD_ImportanceSample(phi, cosTheta, sinTheta, N);
}
