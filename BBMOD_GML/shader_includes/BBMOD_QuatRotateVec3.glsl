/// @desc Rotates a 3D vector by a quaternion.
/// @param q Quaternion to rotate by.
/// @param v Vector to rotate.
/// @return Rotated vector.
vec3 BBMOD_QuatRotateVec3(vec4 q, vec3 v)
{
	return (v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v));
}
