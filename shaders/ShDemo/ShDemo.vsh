#define in_TangentBitangentSign in_TextureCoord1

attribute vec4 in_Position;             // (xyzw)
attribute vec3 in_Normal;               // (xyz)
attribute vec2 in_TextureCoord0;        // (uv)
attribute vec4 in_Colour;               // (rgba)
attribute vec4 in_TangentBitangentSign; // (tangent.xyz, bitangentSign)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat3 v_mTBN;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	vec3 N = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	vec3 T = (gm_Matrices[MATRIX_WORLD] * vec4(in_TangentBitangentSign.xyz, 0.0)).xyz;
	vec3 B = (gm_Matrices[MATRIX_WORLD] * vec4(
		cross(in_Normal, in_TangentBitangentSign.xyz) * in_TangentBitangentSign.w, 0.0)).xyz;
	v_mTBN = mat3(T, B, N);
	v_vColour = in_Colour;
	v_vTexcoord = in_TextureCoord0;
}