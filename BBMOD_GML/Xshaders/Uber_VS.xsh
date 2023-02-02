// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

// Maximum number of bones of animated models
#define BBMOD_MAX_BONES 128
// Maximum number of vec4 uniforms for dynamic batch data
#define BBMOD_MAX_BATCH_VEC4S 192

////////////////////////////////////////////////////////////////////////////////
//
// Attributes
//
attribute vec4 in_Position;

#if !defined(X_2D) && !defined(X_PARTICLES)
attribute vec3 in_Normal;
#endif

attribute vec2 in_TextureCoord0;
#if defined(X_LIGHTMAP)
attribute vec2 in_TextureCoord1;
#endif

#if defined(X_2D)
attribute vec4 in_Color;
#endif

#if !defined(X_2D) && !defined(X_PARTICLES)
attribute vec4 in_TangentW;
#endif

#if defined(X_ANIMATED)
attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;
#endif

#if defined(X_BATCHED) || defined(X_PARTICLES)
attribute float in_Id;
#endif

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//
#if defined(X_TERRAIN)
uniform mat4 bbmod_NormalMatrix;
#endif

uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

#if defined(X_ANIMATED)
uniform vec4 bbmod_Bones[2 * BBMOD_MAX_BONES];
#endif

#if defined(X_BATCHED) || defined(X_PARTICLES)
uniform vec4 bbmod_BatchData[BBMOD_MAX_BATCH_VEC4S];
#endif

#if defined(X_PBR) && !defined(X_OUTPUT_DEPTH) && !defined(X_2D)
// 1.0 to enable shadows
uniform float bbmod_ShadowmapEnableVS;
// WORLD_VIEW_PROJECTION matrix used when rendering shadowmap
uniform mat4 bbmod_ShadowmapMatrix;
// Offsets vertex position by its normal scaled by this value
uniform float bbmod_ShadowmapNormalOffset;
#endif

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
#pragma include("Varyings.xsh")

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
#if defined(X_PARTICLES)
#pragma include("QuaternionRotate.xsh")
#else
#pragma include("Transform.xsh")
#endif

#if defined(X_2D) || defined(X_PARTICLES)
#pragma include("Color.xsh")
#endif

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
#if defined(X_PARTICLES)
	vec3 batchPosition = bbmod_BatchData[int(in_Id) * 4 + 0].xyz;
	vec4 batchRot = bbmod_BatchData[int(in_Id) * 4 + 1];
	vec3 batchScale = bbmod_BatchData[int(in_Id) * 4 + 2].xyz;
	vec4 batchColorAlpha = bbmod_BatchData[int(in_Id) * 4 + 3];
	v_vColor.rgb = xGammaToLinear(batchColorAlpha.rgb);
	v_vColor.a = batchColorAlpha.a;

	vec4 position = in_Position;
	position.xyz *= batchScale;
	position.xyz = QuaternionRotate(batchRot, position.xyz);
	vec3 normal = QuaternionRotate(batchRot, vec3(0.0, 0.0, -1.0));

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
	vec4 positionWVP = (P * (WV * position));
	v_vVertex = (W * position).xyz;
#else // X_PARTICLES
	vec4 position = in_Position;
#if !defined(X_2D)
	vec3 normal = in_Normal;
	vec3 tangent = in_TangentW.xyz;
	vec3 bitangent = cross(normal, tangent) * in_TangentW.w;
#else
	vec3 normal = vec3(0.0, 0.0, 1.0);
	vec3 tangent = vec3(1.0, 0.0, 0.0);
	vec3 bitangent = vec3(0.0, 1.0, 0.0);
#endif

	Transform(position, normal, tangent, bitangent);

	vec4 positionWVP = gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * position);
	v_vVertex = position.xyz;
#endif // !X_PARTICLES

	gl_Position = positionWVP;
	v_vPosition = positionWVP;
#if defined(X_2D)
	v_vColor = in_Color;
#endif
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;
#if defined(X_LIGHTMAP)
	v_vTexCoord2 = in_TextureCoord1;
#endif

#if defined(X_PBR)
	v_vEye.xyz = normalize(-vec3(
		gm_Matrices[MATRIX_VIEW][0][2],
		gm_Matrices[MATRIX_VIEW][1][2],
		gm_Matrices[MATRIX_VIEW][2][2]
	));
	v_vEye.w = (gm_Matrices[MATRIX_PROJECTION][2][3] == 0.0) ? 1.0 : 0.0;
#endif

#if defined(X_PARTICLES)
	vec3 tangent = QuaternionRotate(batchRot, vec3(1.0, 0.0, 0.0));
	vec3 bitangent = QuaternionRotate(batchRot, vec3(0.0, 1.0, 0.0));
	v_mTBN = mat3(W) * mat3(tangent, bitangent, normal);
#else
	v_mTBN = mat3(tangent, bitangent, normal);
#endif

#if defined(X_TERRAIN)
	v_vSplatmapCoord = in_TextureCoord0;
#endif

#if defined(X_ID) && defined(X_BATCHED)
	v_vInstanceID = bbmod_BatchData[(int(in_Id) * 3) + 2];
#endif

#if defined(X_PBR) && !defined(X_OUTPUT_DEPTH) && !defined(X_2D)
	////////////////////////////////////////////////////////////////////////////
	// Vertex position in shadowmap
	if (bbmod_ShadowmapEnableVS == 1.0)
	{
		v_vPosShadowmap = bbmod_ShadowmapMatrix
			* vec4(v_vVertex + normal * bbmod_ShadowmapNormalOffset, 1.0);
	}
#endif
}
