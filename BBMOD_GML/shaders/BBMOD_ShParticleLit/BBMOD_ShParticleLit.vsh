// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

// Maximum number of bones of animated models
#define MAX_BONES 128
// Maximum number of vec4 uniforms for dynamic batch data
#define MAX_BATCH_DATA_SIZE 192

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

uniform vec4 bbmod_BatchData[MAX_BATCH_DATA_SIZE];

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
varying vec3 v_vVertex;

varying vec4 v_vColor;

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying vec4 v_vPosition;

varying vec3 v_vPosShadowmap;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
vec3 QuaternionRotate(vec4 q, vec3 v)
{
	return (v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v));
}

#define X_GAMMA 2.2

/// @desc Converts gamma space color to linear space.
vec3 xGammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(X_GAMMA));
}

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
}

/// @desc Gets color's luminance.
float xLuminance(vec3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
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

	mat4 W;
	W[3][3] = 1.0;
	W[3].xyz += batchPosition;
	mat4 V = gm_Matrices[MATRIX_VIEW];
	mat4 P = gm_Matrices[MATRIX_PROJECTION];

	W[0][0] = V[0][0]; W[1][0] = -V[0][1]; W[2][0] = V[0][2];
	W[0][1] = V[1][0]; W[1][1] = -V[1][1]; W[2][1] = V[1][2];
	W[0][2] = V[2][0]; W[1][2] = -V[2][1]; W[2][2] = V[2][2];

	mat4 WV = V * W;
	vec4 positionWVP = (P * (WV * position));
	v_vVertex = (W * position).xyz;

	gl_Position = positionWVP;
	v_vPosition = positionWVP;
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	vec3 tangent = QuaternionRotate(batchRot, vec3(1.0, 0.0, 0.0));
	vec3 bitangent = QuaternionRotate(batchRot, vec3(0.0, 1.0, 0.0));
	v_mTBN = mat3(W) * mat3(tangent, bitangent, normal);

	////////////////////////////////////////////////////////////////////////////
	// Vertex position in shadowmap
	if (bbmod_ShadowmapEnableVS == 1.0)
	{
		vec4 temp = bbmod_ShadowmapMatrix
			* vec4(v_vVertex + normal * bbmod_ShadowmapNormalOffset, 1.0);
		v_vPosShadowmap = temp.xyz;
		v_vPosShadowmap.xy /= temp.w;
		v_vPosShadowmap.xy = v_vPosShadowmap.xy * 0.5 + 0.5;
	#if defined(_YY_HLSL11_) || defined(_YY_PSSL_)
		v_vPosShadowmap.y = 1.0 - v_vPosShadowmap.y;
	#endif
		v_vPosShadowmap.z /= bbmod_ShadowmapAreaVS;
	}
}
