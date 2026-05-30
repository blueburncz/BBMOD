// @include BBMOD_QuatRotateVec3
// @include BBMOD_DualQuatTransformVec3

/// @desc Transforms vertex position and TBN vectors by animation and/or batch
/// data. Must be called in the vertex shader.
/// Compile-time defines: BBMOD_ANIMATED, BBMOD_BATCHED, BBMOD_TERRAIN.
/// Required uniforms (conditional):
///   BBMOD_BATCHED:  bbmod_BatchData[]
///   BBMOD_ANIMATED: bbmod_Bones[]
///   BBMOD_TERRAIN:  bbmod_NormalMatrix
/// Required attributes (conditional):
///   BBMOD_ANIMATED: in_BoneIndex, in_BoneWeight
///   BBMOD_BATCHED:  in_Id
/// @param vertex Vertex position (inout).
/// @param normal Vertex normal (inout).
/// @param tangent Vertex tangent (inout).
/// @param bitangent Vertex bitangent (inout).
void BBMOD_Transform(
	inout vec4 vertex,
	inout vec3 normal,
	inout vec3 tangent,
	inout vec3 bitangent)
{
// @if defined(BBMOD_BATCHED)
	vertex = gm_Matrices[MATRIX_WORLD] * vertex;
	normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(normal, 0.0)).xyz);
	tangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(bitangent, 0.0)).xyz);
// @endif

// @if defined(BBMOD_ANIMATED)
	ivec4 i = ivec4(in_BoneIndex) * 2;
	ivec4 j = i + 1;

	vec4 real0 = bbmod_Bones[i.x];
	vec4 real1 = bbmod_Bones[i.y];
	vec4 real2 = bbmod_Bones[i.z];
	vec4 real3 = bbmod_Bones[i.w];

	vec4 dual0 = bbmod_Bones[j.x];
	vec4 dual1 = bbmod_Bones[j.y];
	vec4 dual2 = bbmod_Bones[j.z];
	vec4 dual3 = bbmod_Bones[j.w];

	if (dot(real0, real1) < 0.0) { real1 *= -1.0; dual1 *= -1.0; }
	if (dot(real0, real2) < 0.0) { real2 *= -1.0; dual2 *= -1.0; }
	if (dot(real0, real3) < 0.0) { real3 *= -1.0; dual3 *= -1.0; }

	vec4 blendReal =
		  real0 * in_BoneWeight.x
		+ real1 * in_BoneWeight.y
		+ real2 * in_BoneWeight.z
		+ real3 * in_BoneWeight.w;

	vec4 blendDual =
		  dual0 * in_BoneWeight.x
		+ dual1 * in_BoneWeight.y
		+ dual2 * in_BoneWeight.z
		+ dual3 * in_BoneWeight.w;

	float len = length(blendReal);
	blendReal /= len;
	blendDual /= len;

	vertex = vec4(
		BBMOD_DualQuatTransformVec3(blendReal, blendDual, vertex.xyz), 1.0);
	normal = BBMOD_QuatRotateVec3(blendReal, normal);
	tangent = BBMOD_QuatRotateVec3(blendReal, tangent);
	bitangent = BBMOD_QuatRotateVec3(blendReal, bitangent);
// @endif

// @if defined(BBMOD_BATCHED)
	int idx = int(in_Id) * 4;
	vec4 posScale = bbmod_BatchData[idx];
	vec4 rot = bbmod_BatchData[idx + 1];
	vertex = vec4(
		posScale.xyz + (BBMOD_QuatRotateVec3(rot, vertex.xyz) * posScale.w), 1.0);
	normal = BBMOD_QuatRotateVec3(rot, normal);
	tangent = BBMOD_QuatRotateVec3(rot, tangent);
	bitangent = BBMOD_QuatRotateVec3(rot, bitangent);
// @endif

// @if !defined(BBMOD_BATCHED)
	vertex = gm_Matrices[MATRIX_WORLD] * vertex;
// @if defined(BBMOD_TERRAIN)
	normal = normalize((bbmod_NormalMatrix * vec4(normal, 0.0)).xyz);
	tangent = normalize((bbmod_NormalMatrix * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((bbmod_NormalMatrix * vec4(bitangent, 0.0)).xyz);
// @else
	normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(normal, 0.0)).xyz);
	tangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(bitangent, 0.0)).xyz);
// @endif
// @endif
}
