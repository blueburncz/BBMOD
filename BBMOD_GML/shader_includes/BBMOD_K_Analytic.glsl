/// @desc Roughness remapping for analytic (direct) lights, used in
/// Schlick-GGX geometric attenuation.
/// @param roughness Material roughness.
/// @return Remapped k value.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float BBMOD_K_Analytic(float roughness)
{
	float r1 = roughness + 1.0;
	return (r1 * r1) * 0.125;
}
