// @include BBMOD_Vec3ToOctahedronUV
// @include BBMOD_Hammersley2D
// @include BBMOD_ImportanceSample_GGX
// @include BBMOD_GammaToLinear

/// @desc Prefilters an octahedral IBL texture for GGX specular at a given
/// roughness level using Monte Carlo integration. Intended for offline use only.
/// @param octahedron Octahedral environment map.
/// @param R Reflection direction (used as both N and V for simplicity).
/// @param roughness Target roughness level.
/// @return Prefiltered specular color.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
vec3 BBMOD_PrefilterIBL_GGX(sampler2D octahedron, vec3 R, float roughness)
{
	vec3 N = R;
	vec3 V = R;
	vec3 prefilteredColor = vec3(0.0);
	float totalWeight = 0.0;
	const int numSamples = 1024;
	for (int i = 0; i < numSamples; ++i)
	{
		vec2 Xi = BBMOD_Hammersley2D(i, numSamples);
		vec3 H = BBMOD_ImportanceSample_GGX(Xi, N, roughness);
		vec3 L = 2.0 * dot(V, H) * H - V;
		float NdotL = clamp(dot(N, L), 0.0, 1.0);
		if (NdotL > 0.0)
		{
			prefilteredColor += BBMOD_GammaToLinear(
				texture2D(octahedron, BBMOD_Vec3ToOctahedronUV(L)).rgb) * NdotL;
			totalWeight += NdotL;
		}
	}
	return prefilteredColor / totalWeight;
}
