// @define BBMOD_PARTICLES
// @define BBMOD_PBR
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

attribute vec2 in_TextureCoord0;

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
	vec3 batchPosition = bbmod_BatchData[int(in_Id) * 4 + 0].xyz;
	vec4 batchRot = bbmod_BatchData[int(in_Id) * 4 + 1];
	vec4 batchScaleFade = bbmod_BatchData[int(in_Id) * 4 + 2];
	vec3 batchScale = batchScaleFade.xyz;
	vec4 batchColorAlpha = bbmod_BatchData[int(in_Id) * 4 + 3];
	v_vColor.rgb = BBMOD_GammaToLinear(batchColorAlpha.rgb);
	v_vColor.a = batchColorAlpha.a;
	v_fDitherSeed = dot(batchPosition, vec3(12.9898, 78.233, 37.719))
		+ in_Id * 17.0;
	v_fDitherFadeMultiplier = (batchScaleFade.w > 0.0) ? batchScaleFade.w : 1.0;

	vec4 position = in_Position;
	position.xyz *= batchScale;
	position.xyz = BBMOD_QuatRotateVec3(batchRot, position.xyz);
	vec3 normal = BBMOD_QuatRotateVec3(batchRot, vec3(0.0, 0.0, -1.0));

	mat4 W = mat4(
		vec4(1.0, 0.0, 0.0, 0.0),
		vec4(0.0, 1.0, 0.0, 0.0),
		vec4(0.0, 0.0, 1.0, 0.0),
		vec4(0.0, 0.0, 0.0, 1.0));
	W[3].xyz += batchPosition;
	mat4 V = gm_Matrices[MATRIX_VIEW];
	mat4 P = gm_Matrices[MATRIX_PROJECTION];

	W[0][0] = V[0][0]; W[1][0] = -V[0][1]; W[2][0] = V[0][2];
	W[0][1] = V[1][0]; W[1][1] = -V[1][1]; W[2][1] = V[1][2];
	W[0][2] = V[2][0]; W[1][2] = -V[2][1]; W[2][2] = V[2][2];

	mat4 WV = V * W;
	vec4 positionWVP = P * (WV * position);
	v_vVertex = (W * position).xyz;

	gl_Position = positionWVP;
	v_vPosition = positionWVP;

	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	v_vEye.xyz = normalize(-vec3(
		gm_Matrices[MATRIX_VIEW][0][2],
		gm_Matrices[MATRIX_VIEW][1][2],
		gm_Matrices[MATRIX_VIEW][2][2]
	));
	v_vEye.w = (gm_Matrices[MATRIX_PROJECTION][2][3] == 0.0) ? 1.0 : 0.0;

	vec3 tangent = BBMOD_QuatRotateVec3(batchRot, vec3(1.0, 0.0, 0.0));
	vec3 bitangent = BBMOD_QuatRotateVec3(batchRot, vec3(0.0, 1.0, 0.0));
	v_mTBN = mat3(W) * mat3(tangent, bitangent, normal);

	if (bbmod_ShadowmapEnableVS == 1.0)
	{
		v_vPosShadowmap = bbmod_ShadowmapMatrix
			* vec4(v_vVertex + normal * bbmod_ShadowmapNormalOffsetVS, 1.0);
	}
}
// @endinclude
