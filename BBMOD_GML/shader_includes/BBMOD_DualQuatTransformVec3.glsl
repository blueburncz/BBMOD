/// @desc Transforms a 3D vector by a dual quaternion.
/// @param real Real part of the dual quaternion.
/// @param dual Dual part of the dual quaternion.
/// @param v 3D vector to transform.
/// @return Transformed 3D vector.
vec3 BBMOD_DualQuatTransformVec3(vec4 real, vec4 dual, vec3 v)
{
	return (v + 2.0 * cross(real.xyz, cross(real.xyz, v) + real.w * v)
		+ 2.0 * (real.w * dual.xyz - dual.w * real.xyz + cross(real.xyz, dual.xyz)));
}
