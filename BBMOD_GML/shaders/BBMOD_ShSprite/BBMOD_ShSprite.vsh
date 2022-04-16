#pragma include("Uber_VS.xsh", "glsl")
// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//




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
varying float v_fDepth;

varying vec3 v_vLight;

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

	gl_Position = positionWVP;
	v_fDepth = positionWVP.z;
	v_vVertex = (gm_Matrices[MATRIX_WORLD] * position).xyz;
	v_vColor = in_Color;
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	vec3 tangent = vec3(1.0, 0.0, 0.0);
	vec3 bitangent = vec3(0.0, 1.0, 0.0);
	v_mTBN = mat3(gm_Matrices[MATRIX_WORLD]) * mat3(tangent, bitangent, normal);

}
// include("Uber_VS.xsh")
