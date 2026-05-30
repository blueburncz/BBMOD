/// @desc Converts octahedron UV coordinates to a world-space direction vector.
/// @param uv UV coordinates on the octahedron map.
/// @return World-space direction vector (not normalized).
/// @source https://gamedev.stackexchange.com/questions/169508/octahedral-impostors-octahedral-mapping
vec3 BBMOD_OctahedronUVToVec3Normalized(vec2 uv)
{
	vec3 position = vec3(2.0 * (uv - 0.5), 0.0);
	vec2 absolute = abs(position.xy);
	position.z = 1.0 - absolute.x - absolute.y;
	if (position.z < 0.0)
	{
		position.xy = sign(position.xy) * vec2(1.0 - absolute.y, 1.0 - absolute.x);
	}
	return position;
}
