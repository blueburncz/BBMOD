/// @desc Converts a world-space direction vector to UV coordinates on an
/// octahedron map.
/// @param dir Sampling direction vector in world-space.
/// @return UV coordinates on the octahedron map.
/// @source https://gamedev.stackexchange.com/questions/169508/octahedral-impostors-octahedral-mapping
vec2 BBMOD_Vec3ToOctahedronUV(vec3 dir)
{
	vec3 octant = sign(dir);
	float sum = dot(dir, octant);
	vec3 octahedron = dir / sum;
	if (octahedron.z < 0.0)
	{
		vec3 absolute = abs(octahedron);
		octahedron.xy = octant.xy * vec2(1.0 - absolute.y, 1.0 - absolute.x);
	}
	return octahedron.xy * 0.5 + 0.5;
}
