/// @desc Computes blended dual quaternion from bone indices and weights.
/// @param blendReal Variable to hold the blended real part of the dual quaternion.
/// @param blendDual Variable to hold the blended dual part of the dual quaternion.
/// @source https://www.cs.utah.edu/~ladislav/kavan07skinning/kavan07skinning.pdf`
/// @source https://www.cs.utah.edu/~ladislav/dq/dqs.cg
void BBMOD_GetBlendDualQuat(out vec4 blendReal, out vec4 blendDual)
{
	ivec4 i = ivec4(in_BoneIndex + 0.5) * 2;
	ivec4 j = i + 1;

	vec4 real0 = bbmod_Bones[i.x];
	vec4 real1 = bbmod_Bones[i.y];
	vec4 real2 = bbmod_Bones[i.z];
	vec4 real3 = bbmod_Bones[i.w];

	vec4 dual0 = bbmod_Bones[j.x];
	vec4 dual1 = bbmod_Bones[j.y];
	vec4 dual2 = bbmod_Bones[j.z];
	vec4 dual3 = bbmod_Bones[j.w];

	// Branchless polarity correction - eliminates GPU branch divergence
	float s1 = sign(dot(real0, real1));
	float s2 = sign(dot(real0, real2));
	float s3 = sign(dot(real0, real3));
	real1 *= s1; dual1 *= s1;
	real2 *= s2; dual2 *= s2;
	real3 *= s3; dual3 *= s3;

	blendReal =
		  real0 * in_BoneWeight.x
		+ real1 * in_BoneWeight.y
		+ real2 * in_BoneWeight.z
		+ real3 * in_BoneWeight.w;

	blendDual =
		  dual0 * in_BoneWeight.x
		+ dual1 * in_BoneWeight.y
		+ dual2 * in_BoneWeight.z
		+ dual3 * in_BoneWeight.w;

	float invLen = inversesqrt(dot(blendReal, blendReal));
	blendReal *= invLen;
	blendDual *= invLen;
}
