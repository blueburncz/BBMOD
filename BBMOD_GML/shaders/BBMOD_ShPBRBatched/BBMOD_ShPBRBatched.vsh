#pragma include("Uber_VS.xsh", "glsl")
// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
// Defines

#define MAX_BATCH_DATA_SIZE 128


////////////////////////////////////////////////////////////////////////////////
// Attributes
attribute vec4 in_Position;

attribute vec3 in_Normal;

attribute vec2 in_TextureCoord0;


attribute vec4 in_TangentW;


attribute float in_Id;

////////////////////////////////////////////////////////////////////////////////
// Uniforms
uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;


uniform vec4 bbmod_BatchData[MAX_BATCH_DATA_SIZE];



////////////////////////////////////////////////////////////////////////////////
// Varyings
varying vec3 v_vVertex;


varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;


////////////////////////////////////////////////////////////////////////////////
// Includes

vec3 QuaternionRotate(vec4 q, vec3 v)
{
	return (v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v));
}


/// @desc Transforms vertex and normal by animation and/or batch data.
/// @param vertex Variable to hold the transformed vertex.
/// @param normal Variable to hold the transformed normal.
void Transform(out vec4 vertex, out vec4 normal)
{
	vertex = in_Position;
	normal = vec4(in_Normal, 0.0);


	int idx = int(in_Id) * 2;
	vec4 posScale = bbmod_BatchData[idx];
	vec4 rot = bbmod_BatchData[idx + 1];

	vertex = vec4(posScale.xyz + (QuaternionRotate(rot, vertex.xyz) * posScale.w), 1.0);
	normal = vec4(QuaternionRotate(rot, normal.xyz), 0.0);
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
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	vec4 tangent = vec4(in_TangentW.xyz, 0.0);
	vec4 bitangent = vec4(cross(in_Normal, in_TangentW.xyz) * in_TangentW.w, 0.0);
	vec3 N = (gm_Matrices[MATRIX_WORLD] * normal).xyz;
	vec3 T = (gm_Matrices[MATRIX_WORLD] * tangent).xyz;
	vec3 B = (gm_Matrices[MATRIX_WORLD] * bitangent).xyz;
	v_mTBN = mat3(T, B, N);

}
// include("Uber_VS.xsh")
