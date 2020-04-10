// This is just an example vertex shader to help you get started creating your
// own materials.

// Comment out if the model doesn't have tangent vectors and bitangent signs.
// Don't forget to do this in the fragment shader as well!
#define HAS_TBN

// Comment out if the model doesn't have bone indices and vertex weights.
//#define HAS_BONES

// Define maximum number of bones per model here
//#define MAX_BONES 64

attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
attribute vec4 in_Colour;

#ifdef HAS_TBN
	#define in_TangentW in_TextureCoord1
	attribute vec4 in_TangentW;
	varying mat3 v_mTBN;
#else
	varying vec3 v_vNormal;
#endif

#ifdef HAS_BONES
	#define in_BoneIndex in_TextureCoord2
	#define in_BoneWeight in_TextureCoord3
	attribute vec4 in_BoneIndex;
	attribute vec4 in_BoneWeight;
	uniform mat4 u_mBones[MAX_BONES];
#endif

varying vec3 v_vVertex;
varying vec4 v_vColour;
varying vec2 v_vTexCoord;

void main()
{
#ifdef HAS_BONES
	mat4 boneTransform;
	boneTransform  = u_mBones[int(in_BoneIndex.x)] * in_BoneWeight.x;
	boneTransform += u_mBones[int(in_BoneIndex.y)] * in_BoneWeight.y;
	boneTransform += u_mBones[int(in_BoneIndex.z)] * in_BoneWeight.z;
	boneTransform += u_mBones[int(in_BoneIndex.w)] * in_BoneWeight.w;
	vec4 vertexPos = boneTransform * in_Position;
	vec4 normal = boneTransform * vec4(in_Normal, 0.0);
#else
	vec4 vertexPos = in_Position;
	vec4 normal = vec4(in_Normal, 0.0);
#endif

	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vertexPos;
	v_vVertex = (gm_Matrices[MATRIX_WORLD] * vertexPos).xyz;
	v_vColour = in_Colour;
	v_vTexCoord = in_TextureCoord0;

#ifdef HAS_TBN
	#ifdef HAS_BONES
		vec4 tangent = boneTransform * vec4(in_TangentW.xyz, 0.0);
		vec4 bitangent = boneTransform * vec4(cross(in_Normal, in_TangentW.xyz) * in_TangentW.w, 0.0);
	#else
		vec4 tangent = vec4(in_TangentW.xyz, 0.0);
		vec4 bitangent = vec4(cross(in_Normal, in_TangentW.xyz) * in_TangentW.w, 0.0);
	#endif
	vec3 N = (gm_Matrices[MATRIX_WORLD] * normal).xyz;
	vec3 T = (gm_Matrices[MATRIX_WORLD] * tangent).xyz;
	vec3 B = (gm_Matrices[MATRIX_WORLD] * bitangent).xyz;
	v_mTBN = mat3(T, B, N);
#else
	v_vNormal = normal;
#endif
}