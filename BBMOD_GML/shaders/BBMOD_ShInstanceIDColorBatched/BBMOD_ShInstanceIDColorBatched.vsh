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

attribute vec3 in_Normal;

attribute vec2 in_TextureCoord0;

attribute vec4 in_Color;

attribute vec4 in_TangentW;

attribute float in_Id;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

uniform vec4 bbmod_BatchData[BBMOD_MAX_BATCH_VEC4S];

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
varying vec3 v_vVertex;

varying vec4 v_vColor;

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying vec4 v_vPosition;

varying vec4 v_vPosShadowmap;

varying vec4 v_vInstanceID;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
vec3 QuaternionRotate(vec4 q, vec3 v)
{
	return (v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v));
}

/// @desc Transforms vertex and normal by animation and/or batch data.
///
/// @param vertex Variable to hold the transformed vertex.
/// @param normal Variable to hold the transformed normal.
/// @param tangent Variable to hold the transformed tangent.
/// @param bitangent Variable to hold the transformed bitangent.
void Transform(
	inout vec4 vertex,
	inout vec3 normal,
	inout vec3 tangent,
	inout vec3 bitangent)
{
	vertex = gm_Matrices[MATRIX_WORLD] * vertex;
	normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(normal, 0.0)).xyz);
	tangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(bitangent, 0.0)).xyz);

	int idx = int(in_Id) * 3;
	vec4 posScale = bbmod_BatchData[idx];
	vec4 rot = bbmod_BatchData[idx + 1];

	vertex = vec4(posScale.xyz + (QuaternionRotate(rot, vertex.xyz) * posScale.w), 1.0);
	normal = QuaternionRotate(rot, normal);
	tangent = QuaternionRotate(rot, tangent);
	bitangent = QuaternionRotate(rot, bitangent);

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
	vec4 position = in_Position;
	vec3 normal = in_Normal;
	vec3 tangent = in_TangentW.xyz;
	vec3 bitangent = cross(normal, tangent) * in_TangentW.w;

	Transform(position, normal, tangent, bitangent);

	vec4 positionWVP = gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * position);
	v_vVertex = position.xyz;

	gl_Position = positionWVP;
	v_vPosition = positionWVP;
	v_vColor = vec4(xGammaToLinear(in_Color.rgb), in_Color.a);
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	v_mTBN = mat3(tangent, bitangent, normal);

	v_vInstanceID = bbmod_BatchData[(int(in_Id) * 3) + 2];

}
