#if ANIMATED
#define MAX_BONES 64
#elif BATCHED
#define MAX_BATCH_DATA_SIZE 128
#endif

#define in_TangentW in_TextureCoord1

#if ANIMATED
#define in_BoneIndex in_TextureCoord2
#define in_BoneWeight in_TextureCoord3
#elif BATCHED
#define in_Id in_TextureCoord2
#endif

attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
//attribute vec4 in_Color;
attribute vec4 in_TangentW;

#if ANIMATED
attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;
#elif BATCHED
attribute float in_Id;
#endif

varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;

#if ANIMATED
uniform mat4 u_mBones[MAX_BONES];
#elif BATCHED
uniform vec4 u_vData[MAX_BATCH_DATA_SIZE];

#pragma include("Quaternion.xsh", "glsl")
#endif

void main()
{
#if ANIMATED
	mat4 boneTransform = u_mBones[int(in_BoneIndex.x)] * in_BoneWeight.x;
	boneTransform += u_mBones[int(in_BoneIndex.y)] * in_BoneWeight.y;
	boneTransform += u_mBones[int(in_BoneIndex.z)] * in_BoneWeight.z;
	boneTransform += u_mBones[int(in_BoneIndex.w)] * in_BoneWeight.w;
	vec4 vertexPos = boneTransform * in_Position;
	vec4 normal = boneTransform * vec4(in_Normal, 0.0);
#elif BATCHED
	int idx = int(in_Id) * 2;
	vec4 posScale = u_vData[idx];
	vec4 rot = u_vData[idx + 1];
	vec4 vertexPos = vec4(posScale.xyz + (xQuaternionRotate(rot, in_Position).xyz * posScale.w), in_Position.w);
	vec4 normal = vec4(in_Normal, 0.0);
	normal = xQuaternionRotate(rot, normal);
#else
	vec4 vertexPos = in_Position;
	vec4 normal = vec4(in_Normal, 0.0);
#endif

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
