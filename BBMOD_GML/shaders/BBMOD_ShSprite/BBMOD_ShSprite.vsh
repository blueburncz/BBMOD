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

////////////////////////////////////////////////////////////////////////////////
//
// Attributes
//
attribute vec4 in_Position;

attribute vec2 in_TextureCoord0;

attribute vec4 in_Color;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//
uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
varying vec3 v_vVertex;

varying vec4 v_vColor;

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying vec4 v_vPosition;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//

/// @desc Transforms vertex and normal by animation and/or batch data.
/// @param vertex Variable to hold the transformed vertex.
/// @param normal Variable to hold the transformed normal.
void Transform(out vec4 vertex, out vec3 normal)
{
	vertex = in_Position;
	normal = vec3(0.0, 0.0, 1.0);

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
	vec4 position;
	vec3 normal;
	Transform(position, normal);

	vec4 positionWVP = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * position;
	v_vVertex = (gm_Matrices[MATRIX_WORLD] * position).xyz;

	gl_Position = positionWVP;
	v_vPosition = positionWVP;
	v_vColor = in_Color;
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	vec3 tangent = vec3(1.0, 0.0, 0.0);
	vec3 bitangent = vec3(0.0, 1.0, 0.0);
	normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(normal, 0.0)).xyz);
	tangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(bitangent, 0.0)).xyz);
	v_mTBN = mat3(tangent, bitangent, normal);

}
