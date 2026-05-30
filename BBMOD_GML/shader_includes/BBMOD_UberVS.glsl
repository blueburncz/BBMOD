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

// @if !defined(BBMOD_2D) && !defined(BBMOD_PARTICLES)
attribute vec3 in_Normal;
// @endif

// @if defined(BBMOD_2D) && !defined(BBMOD_COLOR)
attribute vec4 in_Colour;
// @endif

attribute vec2 in_TextureCoord0;

// @if defined(BBMOD_LIGHTMAP)
attribute vec2 in_TextureCoord1;
// @endif

// @if defined(BBMOD_COLOR) && !defined(BBMOD_2D)
attribute vec4 in_Colour;
// @endif

// @if !defined(BBMOD_2D) && !defined(BBMOD_PARTICLES)
attribute vec4 in_TangentW;
// @endif

// @if defined(BBMOD_ANIMATED)
attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;
// @endif

// @if defined(BBMOD_BATCHED) || defined(BBMOD_PARTICLES)
attribute float in_Id;
// @endif

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

// @if defined(BBMOD_TERRAIN)
uniform mat4 bbmod_NormalMatrix;
// @endif

uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

// @if defined(BBMOD_ANIMATED)
uniform vec4 bbmod_Bones[2 * BBMOD_MAX_BONES];
// @endif

// @if defined(BBMOD_BATCHED) || defined(BBMOD_PARTICLES)
uniform vec4 bbmod_BatchData[BBMOD_MAX_BATCH_VEC4S];
// @endif

uniform float bbmod_DitherSeed;
uniform float bbmod_DitherFade;

// @if defined(BBMOD_PBR) && !defined(BBMOD_OUTPUT_DEPTH) && !defined(BBMOD_2D)
// 1.0 to enable shadows.
uniform float bbmod_ShadowmapEnableVS;
// WORLD_VIEW_PROJECTION matrix used when rendering the shadow map.
uniform mat4 bbmod_ShadowmapMatrix;
// Offsets vertex position by its normal scaled by this value.
uniform float bbmod_ShadowmapNormalOffsetVS;
// @endif

// @include BBMOD_Varyings
// @include BBMOD_Transform
// @include BBMOD_GammaToLinear

////////////////////////////////////////////////////////////////////////////////
//
// Main
//

void main()
{
// @if defined(BBMOD_PARTICLES)
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
// @else
	vec4 position = in_Position;
// @if !defined(BBMOD_2D)
	vec3 normal = in_Normal;
	vec3 tangent = in_TangentW.xyz;
	vec3 bitangent = cross(normal, tangent) * in_TangentW.w;
// @else
	vec3 normal = vec3(0.0, 0.0, 1.0);
	vec3 tangent = vec3(1.0, 0.0, 0.0);
	vec3 bitangent = vec3(0.0, 1.0, 0.0);
// @endif

	BBMOD_Transform(position, normal, tangent, bitangent);

	vec4 positionWVP = gm_Matrices[MATRIX_PROJECTION]
		* (gm_Matrices[MATRIX_VIEW] * position);
	v_vVertex = position.xyz;

// @if defined(BBMOD_BATCHED)
	v_fDitherFadeMultiplier = bbmod_BatchData[(int(in_Id) * 4) + 3].w;
	v_fDitherSeed = dot(bbmod_BatchData[(int(in_Id) * 4) + 2],
		vec4(1.0, 17.0, 37.0, 73.0));
// @else
	v_fDitherFadeMultiplier = bbmod_DitherFade;
	v_fDitherSeed = bbmod_DitherSeed;
// @endif
// @endif

	gl_Position = positionWVP;
	v_vPosition = positionWVP;

// @if defined(BBMOD_COLOR) || defined(BBMOD_2D)
	v_vColor = vec4(BBMOD_GammaToLinear(in_Colour.rgb), in_Colour.a);
// @endif

	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

// @if defined(BBMOD_LIGHTMAP)
	v_vTexCoord2 = in_TextureCoord1;
// @endif

// @if defined(BBMOD_PBR)
	v_vEye.xyz = normalize(-vec3(
		gm_Matrices[MATRIX_VIEW][0][2],
		gm_Matrices[MATRIX_VIEW][1][2],
		gm_Matrices[MATRIX_VIEW][2][2]
	));
	v_vEye.w = (gm_Matrices[MATRIX_PROJECTION][2][3] == 0.0) ? 1.0 : 0.0;
// @endif

// @if defined(BBMOD_PARTICLES)
	vec3 tangent = BBMOD_QuatRotateVec3(batchRot, vec3(1.0, 0.0, 0.0));
	vec3 bitangent = BBMOD_QuatRotateVec3(batchRot, vec3(0.0, 1.0, 0.0));
	v_mTBN = mat3(W) * mat3(tangent, bitangent, normal);
// @else
	v_mTBN = mat3(tangent, bitangent, normal);
// @endif

// @if defined(BBMOD_TERRAIN)
	v_vSplatmapCoord = in_TextureCoord0;
// @endif

// @if defined(BBMOD_ID) && defined(BBMOD_BATCHED)
	v_vInstanceID = bbmod_BatchData[(int(in_Id) * 4) + 2];
// @endif

// @if defined(BBMOD_PBR) && !defined(BBMOD_OUTPUT_DEPTH) && !defined(BBMOD_2D)
	if (bbmod_ShadowmapEnableVS == 1.0)
	{
		v_vPosShadowmap = bbmod_ShadowmapMatrix
			* vec4(v_vVertex + normal * bbmod_ShadowmapNormalOffsetVS, 1.0);
	}
// @endif
}
