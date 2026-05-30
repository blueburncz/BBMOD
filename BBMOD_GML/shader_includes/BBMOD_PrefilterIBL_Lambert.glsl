// @include BBMOD_Vec3ToOctahedronUV
// @include BBMOD_Hammersley2D
// @include BBMOD_ImportanceSample_Lambert
// @include BBMOD_GammaToLinear

/// @desc Prefilters an octahedral IBL texture for diffuse (Lambert) irradiance
/// using Monte Carlo integration. Intended for offline use only.
/// @param octahedron Octahedral environment map.
/// @param N Normal / sampling direction.
/// @return Prefiltered diffuse irradiance.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 BBMOD_PrefilterIBL_Lambert(sampler2D octahedron, vec3 N)
{
	vec3 prefilteredColor = vec3(0.0);
	const int numSamples = 1024;
	for (int i = 0; i < numSamples; ++i)
	{
		vec2 Xi = BBMOD_Hammersley2D(i, numSamples);
		vec3 L = BBMOD_ImportanceSample_Lambert(Xi, N);
		prefilteredColor += BBMOD_GammaToLinear(
			texture2D(octahedron, BBMOD_Vec3ToOctahedronUV(L)).rgb);
	}
	return prefilteredColor / float(numSamples);
}
