/// @desc Roughness remapping for image-based lights, used in Schlick-GGX
/// geometric attenuation.
/// @param roughness Material roughness.
/// @return Remapped k value.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float BBMOD_K_IBL(float roughness)
{
	return (roughness * roughness) * 0.5;
}
