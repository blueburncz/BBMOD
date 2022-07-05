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

attribute vec3 in_Normal;

attribute vec2 in_TextureCoord0;

attribute vec4 in_TangentW;

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
	normal = in_Normal;

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
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	vec3 tangent = in_TangentW.xyz;
	vec3 bitangent = cross(in_Normal, tangent) * in_TangentW.w;
	normal = normalize((gm_Matrices[MATRIX_WORLD] * vec4(normal, 0.0)).xyz);
	tangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(tangent, 0.0)).xyz);
	bitangent = normalize((gm_Matrices[MATRIX_WORLD] * vec4(bitangent, 0.0)).xyz);
	v_mTBN = mat3(tangent, bitangent, normal);

}
