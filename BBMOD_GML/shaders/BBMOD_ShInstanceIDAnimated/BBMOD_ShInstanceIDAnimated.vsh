#pragma include("Uber_VS.xsh")
// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

// Maximum number of bones of animated models
#define MAX_BONES 64
// Maximum number of vec4 uniforms for dynamic batch data
#define MAX_BATCH_DATA_SIZE 128
// Maximum number of point lights
#define MAX_POINT_LIGHTS 8

////////////////////////////////////////////////////////////////////////////////
//
// Attributes
//
attribute vec4 in_Position;

attribute vec3 in_Normal;

attribute vec2 in_TextureCoord0;

attribute vec4 in_TangentW;

attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//
uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

uniform vec4 bbmod_Bones[2 * MAX_BONES];

// 1.0 to enable shadows
uniform float bbmod_ShadowmapEnableVS;
// WORLD_VIEW_PROJECTION matrix used when rendering shadowmap
uniform mat4 bbmod_ShadowmapMatrix;
// The area that the shadowmap captures
uniform float bbmod_ShadowmapAreaVS;
// Offsets vertex position by its normal scaled by this value
uniform float bbmod_ShadowmapNormalOffset;

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
#pragma include("Varyings.xsh")
varying vec3 v_vVertex;

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

varying vec3 v_vPosShadowmap;

// include("Varyings.xsh")

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
#pragma include("Transform.xsh")
#pragma include("QuaternionRotate.xsh")
vec3 QuaternionRotate(vec4 q, vec3 v)
{
	return (v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v));
}
// include("QuaternionRotate.xsh")

vec3 DualQuaternionTransform(vec4 real, vec4 dual, vec3 v)
{
	return (QuaternionRotate(real, v)
		+ 2.0 * (real.w * dual.xyz - dual.w * real.xyz + cross(real.xyz, dual.xyz)));
}

/// @desc Transforms vertex and normal by animation and/or batch data.
/// @param vertex Variable to hold the transformed vertex.
/// @param normal Variable to hold the transformed normal.
void Transform(out vec4 vertex, out vec3 normal)
{
	vertex = in_Position;
	normal = in_Normal;

	// Source:
	// https://www.cs.utah.edu/~ladislav/kavan07skinning/kavan07skinning.pdf
	// https://www.cs.utah.edu/~ladislav/dq/dqs.cg
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

	vertex = vec4(DualQuaternionTransform(blendReal, blendDual, vertex.xyz), 1.0);
	normal = QuaternionRotate(blendReal, normal);

}
// include("Transform.xsh")

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	vec4 position;
	vec3 normal;
	Transform(position, normal);

	vec4 positionWVP = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * position;
	v_vVertex = (gm_Matrices[MATRIX_WORLD] * position).xyz;

	gl_Position = positionWVP;
	v_fDepth = positionWVP.z;
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	vec3 tangent = in_TangentW.xyz;
	vec3 bitangent = cross(in_Normal, tangent) * in_TangentW.w;
	normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(normal, 0.0)).xyz);
	tangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(bitangent, 0.0)).xyz);
	v_mTBN = mat3(tangent, bitangent, normal);

	////////////////////////////////////////////////////////////////////////////
	// Vertex position in shadowmap
	if (bbmod_ShadowmapEnableVS == 1.0)
	{
		v_vPosShadowmap = (bbmod_ShadowmapMatrix
			* vec4(v_vVertex + normal * bbmod_ShadowmapNormalOffset, 1.0)).xyz;
		v_vPosShadowmap.xy = v_vPosShadowmap.xy * 0.5 + 0.5;
	#if defined(_YY_HLSL11_) || defined(_YY_PSSL_)
		v_vPosShadowmap.y = 1.0 - v_vPosShadowmap.y;
	#endif
		v_vPosShadowmap.z /= bbmod_ShadowmapAreaVS;
	}
}
// include("Uber_VS.xsh")

