// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
// Defines
#if ANIMATED
#define MAX_BONES 64
#endif

#if BATCHED
#define MAX_BATCH_DATA_SIZE 128
#endif

#if !PBR
#define MAX_POINT_LIGHTS 8
#endif

////////////////////////////////////////////////////////////////////////////////
// Attributes
attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
//attribute vec4 in_Color;
attribute vec4 in_TangentW;

#if ANIMATED
attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;
#endif

#if BATCHED
attribute float in_Id;
#endif

////////////////////////////////////////////////////////////////////////////////
// Uniforms
uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

#if ANIMATED
uniform vec4 bbmod_Bones[2 * MAX_BONES];
#endif

#if BATCHED
uniform vec4 bbmod_BatchData[MAX_BATCH_DATA_SIZE];
#endif

#if !PBR
// [(x, y, z, range), (r, g, b, m), ...]
uniform vec4 bbmod_LightPointData[2 * MAX_POINT_LIGHTS];
#endif

#if !OUTPUT_DEPTH && !PBR
uniform float bbmod_ShadowmapEnableVS;     // 1.0 to enable shadows
uniform mat4 bbmod_ShadowmapMatrix;        // WORLD_VIEW_PROJECTION matrix used when rendering shadowmap
uniform float bbmod_ShadowmapArea;         // The area that the shadowmap captures
uniform float bbmod_ShadowmapNormalOffset; // Offsets vertex position by its normal scaled by this value
#endif

////////////////////////////////////////////////////////////////////////////////
// Varyings
varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

#if !OUTPUT_DEPTH && !PBR
varying vec3 v_vLight;
varying vec3 v_vPosShadowmap;
#endif

////////////////////////////////////////////////////////////////////////////////
// Includes
#if !OUTPUT_DEPTH && !PBR
#pragma include("Color.xsh", "glsl")

#pragma include("RGBM.xsh", "glsl")
#endif

#if ANIMATED || BATCHED
vec3 QuaternionRotate(vec4 q, vec3 v)
{
	return (v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v));
}
#endif

#if ANIMATED
vec3 DualQuaternionTransform(vec4 real, vec4 dual, vec3 v)
{
	return (QuaternionRotate(real, v)
		+ 2.0 * (real.w * dual.xyz - dual.w * real.xyz + cross(real.xyz, dual.xyz)));
}
#endif

/// @desc Transforms vertex and normal by animation and/or batch data.
/// @param vertex Variable to hold the transformed vertex.
/// @param normal Variable to hold the transformed normal.
void Transform(out vec4 vertex, out vec4 normal)
{
	vertex = in_Position;
	normal = vec4(in_Normal, 0.0);

#if ANIMATED
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
	normal = vec4(QuaternionRotate(blendReal, normal.xyz), 0.0);
#endif

#if BATCHED
	int idx = int(in_Id) * 2;
	vec4 posScale = bbmod_BatchData[idx];
	vec4 rot = bbmod_BatchData[idx + 1];

	vertex = vec4(posScale.xyz + (QuaternionRotate(rot, vertex.xyz) * posScale.w), 1.0);
	normal = vec4(QuaternionRotate(rot, normal.xyz), 0.0);
#endif
}

////////////////////////////////////////////////////////////////////////////////
// Main
void main()
{
	vec4 position, normal;
	Transform(position, normal);

	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * position;
	v_fDepth = (gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * position).z;
	v_vVertex = (gm_Matrices[MATRIX_WORLD] * position).xyz;
	//v_vColor = in_Color;
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	vec4 tangent = vec4(in_TangentW.xyz, 0.0);
	vec4 bitangent = vec4(cross(in_Normal, in_TangentW.xyz) * in_TangentW.w, 0.0);
	vec3 N = (gm_Matrices[MATRIX_WORLD] * normal).xyz;
	vec3 T = (gm_Matrices[MATRIX_WORLD] * tangent).xyz;
	vec3 B = (gm_Matrices[MATRIX_WORLD] * bitangent).xyz;
	v_mTBN = mat3(T, B, N);

#if !OUTPUT_DEPTH && !PBR
	////////////////////////////////////////////////////////////////////////////
	// Point lights
	N = normalize(N);
	v_vLight = vec3(0.0);

	for (int i = 0; i < MAX_POINT_LIGHTS; ++i)
	{
		Vec4 positionRange = bbmod_LightPointData[i * 2];
		vec3 L = positionRange.xyz - v_vVertex;
		float dist = length(L);
		float att = clamp(1.0 - (dist / positionRange.w), 0.0, 1.0);
		float NdotL = max(dot(N, normalize(L)), 0.0);
		v_vLight += xGammaToLinear(xDecodeRGBM(bbmod_LightPointData[(i * 2) + 1])) * NdotL * att;
	}

	////////////////////////////////////////////////////////////////////////////
	// Vertex position in shadowmap
	if (bbmod_ShadowmapEnableVS == 1.0)
	{
		v_vPosShadowmap = (bbmod_ShadowmapMatrix * vec4(v_vVertex + N * bbmod_ShadowmapNormalOffset, 1.0)).xyz;
		v_vPosShadowmap.xy = v_vPosShadowmap.xy * 0.5 + 0.5;
	#if defined(_YY_HLSL11_) || defined(_YY_PSSL_)
		v_vPosShadowmap.y = 1.0 - v_vPosShadowmap.y;
	#endif
		v_vPosShadowmap.z /= bbmod_ShadowmapArea;
	}
#endif
}
