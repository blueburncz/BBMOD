#pragma include("Default_VS.xsh", "glsl")
#define MAX_BONES 64

#define in_TangentW in_TextureCoord1

#define in_BoneIndex in_TextureCoord2
#define in_BoneWeight in_TextureCoord3

attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
//attribute vec4 in_Colour;
attribute vec4 in_TangentW;

attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;

varying vec3 v_vVertex;
//varying vec4 v_vColour;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;

uniform mat4 u_mBones[MAX_BONES];

void main()
{
	mat4 boneTransform = u_mBones[int(in_BoneIndex.x)] * in_BoneWeight.x;
	boneTransform += u_mBones[int(in_BoneIndex.y)] * in_BoneWeight.y;
	boneTransform += u_mBones[int(in_BoneIndex.z)] * in_BoneWeight.z;
	boneTransform += u_mBones[int(in_BoneIndex.w)] * in_BoneWeight.w;
	vec4 vertexPos = boneTransform * in_Position;
	vec4 normal = boneTransform * vec4(in_Normal, 0.0);

	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vertexPos;
	v_vVertex = (gm_Matrices[MATRIX_WORLD] * vertexPos).xyz;
	//v_vColour = in_Colour;
	v_vTexCoord = in_TextureCoord0;

	vec4 tangent = vec4(in_TangentW.xyz, 0.0);
	vec4 bitangent = vec4(cross(in_Normal, in_TangentW.xyz) * in_TangentW.w, 0.0);
	vec3 N = (gm_Matrices[MATRIX_WORLD] * normal).xyz;
	vec3 T = (gm_Matrices[MATRIX_WORLD] * tangent).xyz;
	vec3 B = (gm_Matrices[MATRIX_WORLD] * bitangent).xyz;
	v_mTBN = mat3(T, B, N);
}
// include("Default_VS.xsh")
