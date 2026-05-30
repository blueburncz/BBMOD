// @define BBMOD_OUTPUT_GBUFFER
// @define BBMOD_PBR
// @define BBMOD_COLOR
// @define BBMOD_ANIMATED
// @define BBMOD_EMISSIVE
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

attribute vec4 in_Colour;

attribute vec4 in_TangentW;

attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

uniform vec4 bbmod_Bones[2 * BBMOD_MAX_BONES];

uniform float bbmod_DitherSeed;
uniform float bbmod_DitherFade;

// 1.0 to enable shadows.
uniform float bbmod_ShadowmapEnableVS;
// WORLD_VIEW_PROJECTION matrix used when rendering the shadow map.
uniform mat4 bbmod_ShadowmapMatrix;
// Offsets vertex position by its normal scaled by this value.
uniform float bbmod_ShadowmapNormalOffsetVS;

varying vec3 v_vVertex;

varying vec4 v_vColor;

varying vec2 v_vTexCoord;

varying mat3 v_mTBN;
varying vec4 v_vPosition;
varying float v_fDitherSeed;
varying float v_fDitherFadeMultiplier;

varying vec4 v_vPosShadowmap;

varying vec4 v_vEye;
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

	vertex = gm_Matrices[MATRIX_WORLD] * vertex;
	normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(normal, 0.0)).xyz);
	tangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(bitangent, 0.0)).xyz);
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

	v_fDitherFadeMultiplier = bbmod_DitherFade;
	v_fDitherSeed = bbmod_DitherSeed;

	gl_Position = positionWVP;
	v_vPosition = positionWVP;

	v_vColor = vec4(BBMOD_GammaToLinear(in_Colour.rgb), in_Colour.a);

	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	v_vEye.xyz = normalize(-vec3(
		gm_Matrices[MATRIX_VIEW][0][2],
		gm_Matrices[MATRIX_VIEW][1][2],
		gm_Matrices[MATRIX_VIEW][2][2]
	));
	v_vEye.w = (gm_Matrices[MATRIX_PROJECTION][2][3] == 0.0) ? 1.0 : 0.0;

	v_mTBN = mat3(tangent, bitangent, normal);

	if (bbmod_ShadowmapEnableVS == 1.0)
	{
		v_vPosShadowmap = bbmod_ShadowmapMatrix
			* vec4(v_vVertex + normal * bbmod_ShadowmapNormalOffsetVS, 1.0);
	}
}
// @endinclude
