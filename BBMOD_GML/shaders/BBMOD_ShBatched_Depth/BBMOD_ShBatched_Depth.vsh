// @define BBMOD_OUTPUT_DEPTH
// @define BBMOD_BATCHED
// @include BBMOD_UberVS

// FIXME: Temporary fix!
precision highp float;

/// @macro {Real} Maximum number of bones per animated model.
#define BBMOD_MAX_BONES 128

/// @macro {Real} Maximum number of vec4 uniforms for dynamic batch data.
#define BBMOD_MAX_BATCH_VEC4S 192

////////////////////////////////////////////////////////////////////////////////
//
// Attributes
//

attribute vec4 in_Position;

attribute vec3 in_Normal;

attribute vec2 in_TextureCoord0;

attribute vec4 in_TangentW;

attribute float in_Id;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

uniform vec4 bbmod_BatchData[BBMOD_MAX_BATCH_VEC4S];

uniform float bbmod_DitherSeed;
uniform float bbmod_DitherFade;

varying vec3 v_vVertex;

varying vec2 v_vTexCoord;

varying mat3 v_mTBN;
varying vec4 v_vPosition;
varying float v_fDitherSeed;
varying float v_fDitherFadeMultiplier;
/// @desc Rotates a 3D vector by a quaternion.
/// @param q Quaternion to rotate by.
/// @param v Vector to rotate.
/// @return Rotated vector.
vec3 BBMOD_QuatRotateVec3(vec4 q, vec3 v)
{
	return (v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v));
}
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
	vertex = gm_Matrices[MATRIX_WORLD] * vertex;
	normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(normal, 0.0)).xyz);
	tangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(bitangent, 0.0)).xyz);

	int idx = int(in_Id) * 4;
	vec4 posScale = bbmod_BatchData[idx];
	vec4 rot = bbmod_BatchData[idx + 1];
	vertex = vec4(
		posScale.xyz + (BBMOD_QuatRotateVec3(rot, vertex.xyz) * posScale.w), 1.0);
	normal = BBMOD_QuatRotateVec3(rot, normal);
	tangent = BBMOD_QuatRotateVec3(rot, tangent);
	bitangent = BBMOD_QuatRotateVec3(rot, bitangent);

}
/// @desc Converts gamma space color to linear space.
/// @param rgb Color in gamma space.
/// @return Color in linear space.
vec3 BBMOD_GammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(2.2));
}

////////////////////////////////////////////////////////////////////////////////
//
// Main
//

void main()
{
	vec4 position = in_Position;
	vec3 normal = in_Normal;
	vec3 tangent = in_TangentW.xyz;
	vec3 bitangent = cross(normal, tangent) * in_TangentW.w;

	BBMOD_Transform(position, normal, tangent, bitangent);

	vec4 positionWVP = gm_Matrices[MATRIX_PROJECTION]
		* (gm_Matrices[MATRIX_VIEW] * position);
	v_vVertex = position.xyz;

	v_fDitherFadeMultiplier = bbmod_BatchData[(int(in_Id) * 4) + 3].w;
	v_fDitherSeed = dot(bbmod_BatchData[(int(in_Id) * 4) + 2],
		vec4(1.0, 17.0, 37.0, 73.0));

	gl_Position = positionWVP;
	v_vPosition = positionWVP;

	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	v_mTBN = mat3(tangent, bitangent, normal);

}
// @endinclude
