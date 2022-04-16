//#pragma include("Uber_VS.xsh", "glsl")
// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

// Maximum number of vec4 uniforms for dynamic batch data
#define MAX_BATCH_DATA_SIZE 64

// Maximum number of point lights
#define MAX_POINT_LIGHTS 8

////////////////////////////////////////////////////////////////////////////////
//
// Attributes
//
attribute vec4 in_Position;
attribute vec2 in_TextureCoord0;
attribute vec2 in_Id;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//
uniform vec2 bbmod_TextureOffset;
uniform vec2 bbmod_TextureScale;

uniform vec4 bbmod_BatchData[3 * MAX_BATCH_DATA_SIZE];

// [(x, y, z, range), (r, g, b, m), ...]
uniform vec4 bbmod_LightPointData[2 * MAX_POINT_LIGHTS];

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
varying vec3 v_vVertex;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	vec3 batchPosition = bbmod_BatchData[int(in_Id) * 3 + 0].xyz;
	vec3 batchScale = bbmod_BatchData[int(in_Id) * 3 + 1].xyz;
	//vec3 batchColor = xDecodeRGBM(bbmod_BatchData[int(in_Id) * 3 + 2]);

	vec4 position = in_Position;
	//position.x *= length(gm_Matrices[MATRIX_WORLD][0].xyz);
	//position.y *= length(gm_Matrices[MATRIX_WORLD][1].xyz);
	//position.z *= length(gm_Matrices[MATRIX_WORLD][2].xyz);
	position.xyz *= batchScale;

	mat4 W = gm_Matrices[MATRIX_WORLD];
	W[3].xyz += batchPosition;
	mat4 V = gm_Matrices[MATRIX_VIEW];
	mat4 P = gm_Matrices[MATRIX_PROJECTION];

	W[0][0] = V[0][0]; W[1][0] = V[0][1]; W[2][0] = V[0][2];
	W[0][1] = V[1][0]; W[1][1] = V[1][1]; W[2][1] = V[1][2];
	W[0][2] = V[2][0]; W[1][2] = V[2][1]; W[2][2] = V[2][2];

	mat4 WV = V * W;

	vec4 positionW = (W * position);
	vec4 positionWV = (WV * position);
	vec4 positionWVP = (P * (WV * position));

	gl_Position = positionWVP;
	v_fDepth    = positionWVP.z;
	v_vVertex   = positionW.xyz;
	v_vTexCoord = in_TextureCoord0;

	vec3 N = (W * vec4(0.0, 0.0, -1.0, 0.0)).xyz;
	vec3 T = (W * vec4(1.0, 0.0, 0.0, 0.0)).xyz;
	vec3 B = (W * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	v_mTBN = mat3(T, B, N);

}
// include("Uber_VS.xsh")
