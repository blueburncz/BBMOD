#pragma include("Default_VS.xsh", "glsl")
#define MAX_BATCH_DATA_SIZE 128

#define in_TangentW in_TextureCoord1

#define in_Id in_TextureCoord2

attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
//attribute vec4 in_Color;
attribute vec4 in_TangentW;

attribute float in_Id;

varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;

uniform vec4 u_vData[MAX_BATCH_DATA_SIZE];

/// @desc Multiplies quaternions q1 and q2.
vec4 xQuaternionMultiply(vec4 _q1, vec4 _q2)
{
	float _q10 = _q1.x;
	float _q11 = _q1.y;
	float _q12 = _q1.z;
	float _q13 = _q1.w;
	float _q20 = _q2.x;
	float _q21 = _q2.y;
	float _q22 = _q2.z;
	float _q23 = _q2.w;

	vec4 q = vec4(0.0, 0.0, 0.0, 0.0);

	q.x = _q11 * _q22 - _q12 * _q21
		+ _q13 * _q20 + _q10 * _q23;
	q.y = _q12 * _q20 - _q10 * _q22
		+ _q13 * _q21 + _q11 * _q23;
	q.z = _q10 * _q21 - _q11 * _q20
		+ _q13 * _q22 + _q12 * _q23;
	q.w = _q13 * _q23 - _q10 * _q20
		- _q11 * _q21 - _q12 * _q22;

	return q;
}

/// @desc Rotates vector v by quaternion q.
vec4 xQuaternionRotate(vec4 q, vec4 v)
{
	q = normalize(q);
	vec4 V = vec4(v.x, v.y, v.z, 0.0);
	vec4 conjugate = vec4(-q.x, -q.y, -q.z, q.w);
	vec4 rot = xQuaternionMultiply(q, V);
	rot = xQuaternionMultiply(rot, conjugate);
	return rot;
}

void main()
{
	int idx = int(in_Id) * 2;
	vec4 posScale = u_vData[idx];
	vec4 rot = u_vData[idx + 1];
	vec4 vertexPos = vec4(posScale.xyz + (xQuaternionRotate(rot, in_Position).xyz * posScale.w), in_Position.w);
	vec4 normal = vec4(in_Normal, 0.0);
	normal = xQuaternionRotate(rot, normal);

	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vertexPos;
	v_vVertex = (gm_Matrices[MATRIX_WORLD] * vertexPos).xyz;
	//v_vColor = in_Color;
	v_vTexCoord = in_TextureCoord0;

	vec4 tangent = vec4(in_TangentW.xyz, 0.0);
	vec4 bitangent = vec4(cross(in_Normal, in_TangentW.xyz) * in_TangentW.w, 0.0);
	vec3 N = (gm_Matrices[MATRIX_WORLD] * normal).xyz;
	vec3 T = (gm_Matrices[MATRIX_WORLD] * tangent).xyz;
	vec3 B = (gm_Matrices[MATRIX_WORLD] * bitangent).xyz;
	v_mTBN = mat3(T, B, N);
}
// include("Default_VS.xsh")
