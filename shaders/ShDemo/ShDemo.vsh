#define in_TangentW   in_TextureCoord1
#define in_BoneIndex  in_TextureCoord2
#define in_BoneWeight in_TextureCoord3

attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
attribute vec4 in_Colour;
attribute vec4 in_TangentW;
attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;

uniform mat4 u_mBones[32];

varying vec3 vVertex;
varying vec4 vColour;
varying vec2 vTexCoord;
varying mat3 vTBN;

void main()
{
	mat4 boneTransform;
	boneTransform  = u_mBones[int(in_BoneIndex.x)] * in_BoneWeight.x;
	boneTransform += u_mBones[int(in_BoneIndex.y)] * in_BoneWeight.y;
	boneTransform += u_mBones[int(in_BoneIndex.z)] * in_BoneWeight.z;
	boneTransform += u_mBones[int(in_BoneIndex.w)] * in_BoneWeight.w;

	vec4 vertexPos = boneTransform * in_Position;

	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vertexPos;
	vVertex     = (gm_Matrices[MATRIX_WORLD] * vertexPos).xyz;
	vColour     = in_Colour;
	vTexCoord   = in_TextureCoord0;

	vec4 normal    = boneTransform * vec4(in_Normal, 0.0);
	vec4 tangent   = boneTransform * vec4(in_TangentW.xyz, 0.0);
	vec4 bitangent = boneTransform * vec4(cross(in_Normal, in_TangentW.xyz) * in_TangentW.w, 0.0);

	vec3 N = (gm_Matrices[MATRIX_WORLD] * normal).xyz;
	vec3 T = (gm_Matrices[MATRIX_WORLD] * tangent).xyz;
	vec3 B = (gm_Matrices[MATRIX_WORLD] * bitangent).xyz;

	vTBN = mat3(T, B, N);
}