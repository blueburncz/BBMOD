#include "bbmod.hpp"
#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <fstream>
#include <iostream>
#include <filesystem>
#include <map>

#define FILE_WRITE_DATA(f, d) \
	(f).write(reinterpret_cast<const char*>(&(d)), sizeof(d))

#define FILE_WRITE_VEC2(f, v) \
	do \
	{ \
		FILE_WRITE_DATA(f, (v).x); \
		FILE_WRITE_DATA(f, (v).y); \
	} \
	while (false)

#define FILE_WRITE_VEC3(f, v) \
	do \
	{ \
		FILE_WRITE_VEC2(f, v); \
		FILE_WRITE_DATA(f, (v).z); \
	} \
	while (false)

#define FILE_WRITE_VEC4(f, v) \
	do \
	{ \
		FILE_WRITE_VEC3(f, v); \
		FILE_WRITE_DATA(f, (v).w); \
	} \
	while (false)

#define FILE_WRITE_MATRIX(f, m) \
	do \
	{ \
		FILE_WRITE_DATA(f, (m).a1); \
		FILE_WRITE_DATA(f, (m).a2); \
		FILE_WRITE_DATA(f, (m).a3); \
		FILE_WRITE_DATA(f, (m).a4); \
		FILE_WRITE_DATA(f, (m).b1); \
		FILE_WRITE_DATA(f, (m).b2); \
		FILE_WRITE_DATA(f, (m).b3); \
		FILE_WRITE_DATA(f, (m).b4); \
		FILE_WRITE_DATA(f, (m).c1); \
		FILE_WRITE_DATA(f, (m).c2); \
		FILE_WRITE_DATA(f, (m).c3); \
		FILE_WRITE_DATA(f, (m).c4); \
		FILE_WRITE_DATA(f, (m).d1); \
		FILE_WRITE_DATA(f, (m).d2); \
		FILE_WRITE_DATA(f, (m).d3); \
		FILE_WRITE_DATA(f, (m).d4); \
	} \
	while (false)

/** String comparator. */
struct StringCompare
{
	bool operator()(char const* a, char const* b) const
	{
		return std::strcmp(a, b) < 0;
	}
};

////////////////////////////////////////////////////////////////////////////////
// FIXME: These were originally members and methods of a custom scene class.
// Making globals was just a quick temporary solution.

float gNextNodeId = 0.0f;
std::map<double, aiNode*> gIndexDoubleToNode;
std::map<aiNode*, double> gIndexNodeToDouble;

/** Node has a mesh or has a child node with a mesh. */
std::map<aiNode*, bool> gIndexNodeHasMesh;

/** Node is a bone or has a bone child node. */
std::map<aiNode*, bool> gIndexNodeHasBone;

float gNextBoneId = 0.0f;
std::map<const char*, float, StringCompare> gIndexBoneNameToIndex;
std::map<const char*, aiBone*, StringCompare> gIndexBoneNameToBone;

size_t GetNodeMesh(double id, size_t index)
{
	return gIndexDoubleToNode.at(id)->mMeshes[index];
}

size_t GetNodeChildCount(double id)
{
	return gIndexDoubleToNode.at(id)->mNumChildren;
}

double GetNodeChild(double id, size_t index)
{
	return gIndexNodeToDouble.at(gIndexDoubleToNode.at(id)->mChildren[index]);
}

////////////////////////////////////////////////////////////////////////////////

/** Encodes color into a single integer as ARGB. */
uint32_t EncodeColor(const aiColor4D& color)
{
	return (uint32_t)(
		((uint32_t)(color.a * 255.0f) << 24) |
		((uint32_t)(color.r * 255.0f) << 16) |
		((uint32_t)(color.g * 255.0f) << 8) |
		((uint32_t)(color.b * 255.0f)));
}

/** Returns cross product of vectors v1 and v2. */
aiVector3D Vec3Cross(const aiVector3D& v1, const aiVector3D& v2)
{
	aiVector3D res;
	res.x = v1.y * v2.z - v1.z * v2.y;
	res.y = v1.z * v2.x - v1.x * v2.z;
	res.z = v1.x * v2.y - v1.y * v2.x;
	return res;
}

/** Returns dot product of vectors v1 and v2. */
float Vec3Dot(const aiVector3D& v1, const aiVector3D& v2)
{
	return (v1.x * v2.x
		+ v1.y * v2.y
		+ v1.z * v2.z);
}

/** Returns bitangent sign. */
float GetBitangentSign(
	const aiVector3D& normal,
	const aiVector3D& tangent,
	const aiVector3D& bitangent)
{
	aiVector3D cross = Vec3Cross(normal, tangent);
	float dot = Vec3Dot(cross, bitangent);
	return (dot < 0.0f) ? -1.0f : 1.0f;
}

/** Returns number of vertices of a mesh. */
inline uint32_t GetMeshVertexCount(const aiMesh* mesh)
{
	return (mesh->mNumFaces * 3);
}

/**
 * Writes a mesh into a BBMOD version 0 file.
 *
 * Format:
 *  * Vertex (3x f32)
 *  * [Normal (3x f32)]
 *  * [UV (2x f32)]
 *  * Color (uint32)
 *  * [Tangent (3x f32)]
 *  * [Bitangent sign (f32)]
 */
void MeshToBBMOD_0(aiMesh* mesh, std::ofstream& fout)
{
	uint32_t faceCount = mesh->mNumFaces;
	aiColor4D cWhite(1.0f, 1.0f, 1.0f, 1.0f);

	for (unsigned int i = 0; i < faceCount; ++i)
	{
		aiFace& face = mesh->mFaces[i];
		for (unsigned int f = 0; f < face.mNumIndices; ++f)
		{
			unsigned int idx = face.mIndices[f];

			// Vertex position
			aiVector3D& vertex = mesh->mVertices[idx];
			FILE_WRITE_VEC3(fout, vertex);

			// Normals
			aiVector3D* normal = nullptr;
			if (mesh->HasNormals())
			{
				normal = &(mesh->mNormals[idx]);
				FILE_WRITE_VEC3(fout, *normal);
			}

			// Texture coords
			if (mesh->HasTextureCoords(0))
			{
				aiVector3D& texture = mesh->mTextureCoords[0][idx];
				FILE_WRITE_VEC2(fout, texture);
			}

			// Color
			aiColor4D& color = (mesh->HasVertexColors(0))
				? mesh->mColors[0][idx]
				: cWhite;
			uint32_t vertexColor = EncodeColor(color);
			FILE_WRITE_DATA(fout, vertexColor);

			if (normal && mesh->HasTangentsAndBitangents())
			{
				// Tangent
				aiVector3D& tangent = mesh->mTangents[idx];
				FILE_WRITE_VEC3(fout, tangent);

				// Bitangent sign
				aiVector3D& bitangent = mesh->mBitangents[idx];
				float sign = GetBitangentSign(*normal, tangent, bitangent);
				FILE_WRITE_DATA(fout, sign);
			}
		}
	}
}

/**
 * Writes a BBMOD version 0 header into a file.
 *
 * Format:
 *  * Version (uint8, always 0)
 *  * HasVertices (bool, always true)
 *  * HasNormals (bool)
 *  * HasTextureCoords (bool)
 *  * HasVertexColors (bool, always true)
 *  * HasTangentW (bool)
 *  * VertexCount (uint32)
 */
void WriteHeader_0(
	bool hasNormals,
	bool hasTextureCoords,
	bool hasTangentW,
	uint32_t vertexCount,
	std::ofstream& fout)
{
	uint8_t version = 0;
	FILE_WRITE_DATA(fout, version);

	bool hasVertices = true;
	FILE_WRITE_DATA(fout, hasVertices);

	FILE_WRITE_DATA(fout, hasNormals);

	FILE_WRITE_DATA(fout, hasTextureCoords);

	bool hasVertexColors = true;
	FILE_WRITE_DATA(fout, hasVertexColors);

	FILE_WRITE_DATA(fout, hasTangentW);

	FILE_WRITE_DATA(fout, vertexCount);
}

/**
 * Writes the scene into a version 0 BBMOD file.
 *
 * In this version, all meshes are pretransformed and merged into one.
 * Animations are not supported.
 */
int SceneToBBMOD_0(const char* fin, std::ofstream& fout)
{
	Assimp::Importer* importer = new Assimp::Importer();

	const aiScene* scene = importer->ReadFile(fin, 0
		| aiProcessPreset_TargetRealtime_Quality
		| aiProcess_PreTransformVertices
		//| aiProcess_TransformUVCoords
		//| aiProcess_OptimizeGraph
		//| aiProcess_OptimizeMeshes
	);

	if (!scene)
	{
		delete importer;
		return BBMOD_ERR_LOAD_FAILED;
	}

	bool first = true;
	uint32_t vertexCount = 0;

	for (size_t i = 0; i < scene->mNumMeshes; ++i)
	{
		vertexCount += GetMeshVertexCount(scene->mMeshes[i]);
	}

	for (size_t i = 0; i < scene->mNumMeshes; ++i)
	{
		aiMesh* mesh = scene->mMeshes[i];
		if (first)
		{
			WriteHeader_0(mesh->HasNormals(), mesh->HasTextureCoords(0),
				mesh->HasTangentsAndBitangents(), vertexCount, fout);
			first = false;
		}
		MeshToBBMOD_0(mesh, fout);
	}

	delete importer;
	return BBMOD_SUCCESS;
}

bool BuildIndices(const aiScene* scene, aiNode* node)
{
	// Has mesh index
	bool hasMesh = (node->mNumMeshes > 0);
	gIndexNodeHasMesh[node] = hasMesh;

	if (hasMesh)
	{
		aiNode* current = node->mParent;
		while (current)
		{
			gIndexNodeHasMesh[current] = true;
			current = current->mParent;
		}
	}

	// Bone index
	bool hasBone = false;

	for (uint32_t i = 0; i < node->mNumMeshes; ++i)
	{
		aiMesh* mesh = scene->mMeshes[node->mMeshes[i]];

		hasBone |= (mesh->mNumBones > 0);

		for (uint32_t j = 0; j < mesh->mNumBones; ++j)
		{
			aiBone* bone = mesh->mBones[j];
			const char* name = bone->mName.C_Str();

			auto it = gIndexBoneNameToIndex.find(name);
			if (it == gIndexBoneNameToIndex.end())
			{
				gIndexBoneNameToIndex[name] = gNextBoneId++;
				gIndexBoneNameToBone[name] = bone;
			}
		}
	}

	gIndexNodeHasBone[node] = hasBone;

	if (hasBone)
	{
		aiNode* current = node->mParent;
		while (current)
		{
			gIndexNodeHasBone[current] = true;
			current = current->mParent;
		}
	}

	// Node index
	double id = gNextNodeId++;
	gIndexDoubleToNode[id] = node;
	gIndexNodeToDouble[node] = id;
	for (size_t i = 0; i < node->mNumChildren; ++i)
	{
		BuildIndices(scene, node->mChildren[i]);
	}
	return true;
}


/**
 * Writes a BBMOD version 1 header into a file.
 *
 * Format:
 *  * Version (uint8, always 1)
 *  * HasVertices (bool, always true)
 *  * HasNormals (bool)
 *  * HasTextureCoords (bool)
 *  * HasVertexColors (bool, always true)
 *  * HasTangentW (bool)
 *  * HasBones (bool)
 */
void WriteHeader_1(
	bool hasNormals,
	bool hasTextureCoords,
	bool hasTangentW,
	bool hasBones,
	std::ofstream& fout)
{
	uint8_t version = 1;
	FILE_WRITE_DATA(fout, version);

	bool hasVertices = true;
	FILE_WRITE_DATA(fout, hasVertices);

	FILE_WRITE_DATA(fout, hasNormals);

	FILE_WRITE_DATA(fout, hasTextureCoords);

	bool hasVertexColors = true;
	FILE_WRITE_DATA(fout, hasVertexColors);

	FILE_WRITE_DATA(fout, hasTangentW);

	FILE_WRITE_DATA(fout, hasBones);
}

/**
 * Writes a mesh into a BBMOD version 1 file.
 *
 * Format:
 *  * Material index (uint32)
 *  * Vertex count (uint32)
 *  * For each vertex:
 *     * Position (3x f32)
 *     * [Normal (3x f32)]
 *     * [UV (2x f32)]
 *     * Color (uint32)
 *     * [Tangent (3x f32)]
 *     * [Bitangent sign (f32)]
 *     * [Bone indices (4x f32)]
 *     * [Bone weights (4x f32)]
 */
void MeshToBBMOD_1(
	aiMesh* mesh,
	aiMatrix4x4& matrix,
	bool forceBonesAndWeights,
	std::ofstream& fout)
{
	uint32_t faceCount = mesh->mNumFaces;
	aiColor4D cWhite(1.0f, 1.0f, 1.0f, 1.0f);

	uint32_t material = mesh->mMaterialIndex;
	FILE_WRITE_DATA(fout, material);

	uint32_t vertexCount = (uint32_t)mesh->mNumFaces * 3;
	FILE_WRITE_DATA(fout, vertexCount);

	uint32_t boneCount = mesh->mNumBones;

	////////////////////////////////////////////////////////////////////////////
	// Gather vertex bones and weights
	std::map<uint32_t, std::vector<float>> vertexBones;
	std::map<uint32_t, std::vector<float>> vertexWeights;

	for (uint32_t i = 0; i < boneCount; ++i)
	{
		aiBone* bone = mesh->mBones[i];
		const char* name = bone->mName.C_Str();
		float boneId = gIndexBoneNameToIndex.at(name);
		for (uint32_t j = 0; j < bone->mNumWeights; ++j)
		{
			auto weight = bone->mWeights[j];
			uint32_t vertexId = (uint32_t)weight.mVertexId;

			auto it = vertexBones.find(vertexId);
			if (it == vertexBones.end())
			{
				std::vector<float> _bones;
				vertexBones.emplace(std::make_pair(vertexId, _bones));

				std::vector<float> _weights;
				vertexWeights.emplace(std::make_pair(vertexId, _weights));
			}

			vertexBones[vertexId].push_back(boneId);
			vertexWeights[vertexId].push_back(weight.mWeight);
		}
	}
	////////////////////////////////////////////////////////////////////////////

	for (unsigned int i = 0; i < faceCount; ++i)
	{
		aiFace& face = mesh->mFaces[i];
		for (unsigned int f = 0; f < face.mNumIndices; ++f)
		{
			uint32_t idx = face.mIndices[f];

			// Vertex
			aiVector3D vertex(mesh->mVertices[idx]);
			//vertex *= matrix;
			FILE_WRITE_VEC3(fout, vertex);

			// Normal
			aiVector3D normal;
			if (mesh->HasNormals())
			{
				normal = aiVector3D(mesh->mNormals[idx]);
				//normal *= matrix;
				FILE_WRITE_VEC3(fout, normal);
			}

			// Texture
			if (mesh->HasTextureCoords(0))
			{
				aiVector3D texture = mesh->mTextureCoords[0][idx];
				texture.y = 1.0f - texture.y;
				FILE_WRITE_VEC2(fout, texture);
			}

			// Color
			aiColor4D& color = (mesh->HasVertexColors(0))
				? mesh->mColors[0][idx]
				: cWhite;
			uint32_t vertexColor = EncodeColor(color);
			FILE_WRITE_DATA(fout, vertexColor);

			if (mesh->HasTangentsAndBitangents())
			{
				// Tangent
				aiVector3D& tangent = mesh->mTangents[idx];
				FILE_WRITE_VEC3(fout, tangent);

				// Bitangent sign
				aiVector3D& bitangent = mesh->mBitangents[idx];
				float sign = GetBitangentSign(normal, tangent, bitangent);
				FILE_WRITE_DATA(fout, sign);
			}

			// Bone indices
			if (vertexBones.find(idx) != vertexBones.end())
			{
				auto _vertexBones = vertexBones.at(idx);
				for (uint32_t j = 0; j < 4; ++j)
				{
					float b = (j < _vertexBones.size()) ? _vertexBones[j] : 0.0f;
					FILE_WRITE_DATA(fout, b);
				}
			}
			else if (forceBonesAndWeights)
			{
				float b = 0.0f;
				for (uint32_t j = 0; j < 4; ++j)
				{
					FILE_WRITE_DATA(fout, b);
				}
			}

			// Vertex weights
			if (vertexWeights.find(idx) != vertexWeights.end())
			{
				auto _vertexWeights = vertexWeights.at(idx);
				for (uint32_t j = 0; j < 4; ++j)
				{
					float w = (j < _vertexWeights.size()) ? _vertexWeights[j] : 0.0f;
					FILE_WRITE_DATA(fout, w);
				}
			}
			else if (forceBonesAndWeights)
			{
				float w = 0.0f;
				for (uint32_t j = 0; j < 4; ++j)
				{
					FILE_WRITE_DATA(fout, w);
				}
			}
		}
	}
}

/**
 * Writes a node into a BBMOD version 1 file.
 *
 * Format:
 *  * Name (null terminated string)
 *  * Mesh count (uint32)
 *  * Meshes follow...
 *  * Number of child nodes (uint32)
 *  * Child nodes follow...
 */
void NodeToBBMOD(
	const aiScene* scene,
	double id,
	aiMatrix4x4& matrix,
	bool forceBonesAndWeights,
	std::ofstream& fout)
{
	aiNode* node = gIndexDoubleToNode.at(id);

	if (!gIndexNodeHasMesh.at(node))
	{
		return;
	}

	uint32_t meshCount = (uint32_t)node->mNumMeshes;
	uint32_t childCount = (uint32_t)node->mNumChildren;

	aiMatrix4x4 matrixBackup(matrix);
	matrix = matrix * node->mTransformation;

	// Write node
	const char* name = node->mName.C_Str();
	fout.write(name, sizeof(char) * (node->mName.length + 1));

	// Write meshes
	FILE_WRITE_DATA(fout, meshCount);

	for (uint32_t i = 0; i < meshCount; ++i)
	{
		size_t idx = GetNodeMesh(id, (size_t)i);
		aiMesh* mesh = scene->mMeshes[idx];
		MeshToBBMOD_1(mesh, matrix, forceBonesAndWeights, fout);
	}

	// Write child nodes
	uint32_t childNumWithMesh = 0;
	for (uint32_t i = 0; i < childCount; ++i)
	{
		double childDouble = GetNodeChild(id, (size_t)i);
		aiNode* child = gIndexDoubleToNode.at(childDouble);
		if (gIndexNodeHasMesh.at(child))
		{
			++childNumWithMesh;
		}
	}

	FILE_WRITE_DATA(fout, childNumWithMesh);

	for (uint32_t i = 0; i < childCount; ++i)
	{
		double child = GetNodeChild(id, (size_t)i);
		NodeToBBMOD(scene, child, matrix, forceBonesAndWeights, fout);
	}

	matrix = matrixBackup;
}

/**
 * Writes a bone into a BBMOD file.
 *
 * Format:
 *  * Name (null terminated string)
 *  * Index (f32)
 *  * Transform matrix (16x f32, row major)
 *  * Offset matrix (16x f32, row major)
 *  * Number of child bones (uint32)
 *  * Child bones follow...
 */
void BoneToBBMOD(double id, aiMatrix4x4& matrix, std::ofstream& fout)
{
	aiNode* node = gIndexDoubleToNode.at(id);
	uint32_t childCount = GetNodeChildCount(id);

	const char* name = node->mName.C_Str();

	bool isBone = gIndexBoneNameToIndex.find(name) != gIndexBoneNameToIndex.end();

	// Bone name
	fout.write(name, sizeof(char) * (node->mName.length + 1));

	// Bone index
	float boneIndex = isBone ? gIndexBoneNameToIndex.at(name) : -1.0f;
	FILE_WRITE_DATA(fout, boneIndex);

	// Node transform matrix
	FILE_WRITE_MATRIX(fout, node->mTransformation);

	// Bone offset matrix
	if (isBone)
	{
		aiBone* bone = gIndexBoneNameToBone.at(name);
		aiMatrix4x4& offsetMatrix = bone->mOffsetMatrix;
		FILE_WRITE_MATRIX(fout, offsetMatrix);
	}
	else
	{
		aiMatrix4x4 offsetMatrix;
		FILE_WRITE_MATRIX(fout, offsetMatrix);
	}

	// Number of child nodes with bones
	//uint32_t childBones = 0;
	//for (uint32_t i = 0; i < childCount; ++i)
	//{
	//	aiNode* child = m_indexDoubleToNode.at(GetNodeChild(id, i));
	//	if (m_indexNodeHasBone.at(child))
	//	{
	//		++childBones;
	//	}
	//}
	//FILE_WRITE_DATA(fout, childBones);
	FILE_WRITE_DATA(fout, childCount);

	// Write child nodes
	for (uint32_t i = 0; i < childCount; ++i)
	{
		aiNode* child = gIndexDoubleToNode.at(GetNodeChild(id, i));
		//if (m_indexNodeHasBone.at(child))
		//{
			BoneToBBMOD(GetNodeChild(id, i), matrix, fout);
		//}
	}
}

/**
 * Writes an animation int o a BBMOD file.
 *
 * Format:
 *  * Name (null terminated string)
 *  * Duration in tics (f64)
 *  * Tics per second (f64)
 *  * Number of affected bones (uint32)
 *  * For each affected bone:
 *     * Bone ID (f32)
 *     * Number of position keys (uint32)
 *     * For each position key:
 *        * Time (double)
 *        * Position (3x f32)
 *     * Number of rotation keys (uint32)
 *     * For each rotation key:
 *        * Time (double)
 *        * Rotation quaternion (4x f32)
 */
void AnimationToBBMOD(aiAnimation* animation, std::ofstream& fout)
{
	// Name
	const char* animationName = animation->mName.C_Str();
	fout.write(animationName, sizeof(char) * (animation->mName.length + 1));

	// Duration in ticks
	FILE_WRITE_DATA(fout, animation->mDuration);

	// Ticks per second
	FILE_WRITE_DATA(fout, animation->mTicksPerSecond);

	// Number of affected bones
	uint32_t affectedBones = 0;

	for (uint32_t j = 0; j < animation->mNumChannels; ++j)
	{
		aiNodeAnim* nodeAnim = animation->mChannels[j];
		const char* nodeAnimName = nodeAnim->mNodeName.C_Str();

		if (gIndexBoneNameToIndex.find(nodeAnimName) != gIndexBoneNameToIndex.end())
		{
			++affectedBones;
		}
	}

	FILE_WRITE_DATA(fout, affectedBones);

	// Write bones
	for (uint32_t j = 0; j < animation->mNumChannels; ++j)
	{
		aiNodeAnim* nodeAnim = animation->mChannels[j];
		const char* nodeAnimName = nodeAnim->mNodeName.C_Str();

		if (gIndexBoneNameToIndex.find(nodeAnimName) != gIndexBoneNameToIndex.end())
		{
			// Bone id
			float boneId = gIndexBoneNameToIndex.at(nodeAnimName);
			FILE_WRITE_DATA(fout, boneId);

			// Position keys
			uint32_t positionKeyCount = nodeAnim->mNumPositionKeys;
			FILE_WRITE_DATA(fout, positionKeyCount);

			for (uint32_t k = 0; k < positionKeyCount; ++k)
			{
				aiVectorKey& key = nodeAnim->mPositionKeys[k];

				// Time
				FILE_WRITE_DATA(fout, key.mTime);

				// Position
				aiVector3D& position = key.mValue;
				FILE_WRITE_VEC3(fout, position);
			}

			// Rotation keys
			uint32_t rotationKeyCount = nodeAnim->mNumRotationKeys;
			FILE_WRITE_DATA(fout, rotationKeyCount);

			for (uint32_t k = 0; k < rotationKeyCount; ++k)
			{
				aiQuatKey& key = nodeAnim->mRotationKeys[k];

				// Time
				FILE_WRITE_DATA(fout, key.mTime);

				// Position
				aiQuaternion& rotation = key.mValue;
				FILE_WRITE_VEC4(fout, rotation);
			}
		}
	}
}

/**
 * Writes the scene into a version 1 BBMOD file.
 *
 * Scene-graph and animations are supported.
 *
 * Format:
 *  * Header
 *  * Global inverse transform matrix (16x f32, row major)
 *  * Root node follows...
 *  * Number of bones (uint32)
 *  * Bones follow...
 *  * Number of animations (uint32)
 *  * Animations follow...
 *  * Number of materials (uint32)
 *  * Material names follow... (null terminated strings)
 */
int SceneToBBMOD_1(const char* fin, std::ofstream& fout)
{
	Assimp::Importer* importer = new Assimp::Importer();

	const aiScene* scene = importer->ReadFile(fin, 0
		| aiProcessPreset_TargetRealtime_Quality
		//| aiProcess_MakeLeftHanded
		//| aiProcess_PreTransformVertices
		| aiProcess_TransformUVCoords
		| aiProcess_OptimizeGraph
		| aiProcess_OptimizeMeshes
	);

	if (!scene)
	{
		delete importer;
		return BBMOD_ERR_LOAD_FAILED;
	}

	if (!BuildIndices(scene, scene->mRootNode))
	{
		delete importer;
		return BBMOD_ERR_CONVERSION_FAILED;
	}

	// Write header
	aiMesh* mesh = scene->mMeshes[0];
	bool hasBones = (gIndexBoneNameToBone.size() > 0);

	WriteHeader_1(mesh->HasNormals(), mesh->HasTextureCoords(0),
		mesh->HasTangentsAndBitangents(), hasBones, fout);

	// Write global inverse transform
	aiMatrix4x4 inverse = scene->mRootNode->mTransformation.Inverse();
	FILE_WRITE_MATRIX(fout, inverse);

	// Write nodes
	aiMatrix4x4 matrix;
	NodeToBBMOD(scene, 0.0f, matrix, hasBones, fout);

	// Write bones
	uint32_t numOfBones = (uint32_t)gNextBoneId;
	FILE_WRITE_DATA(fout, numOfBones);

	if (numOfBones > 0)
	{
		BoneToBBMOD(0.0f, matrix, fout);
	}

	// Write animations
	uint32_t numOfAnimations = scene->mNumAnimations;
	FILE_WRITE_DATA(fout, numOfAnimations);

	for (uint32_t i = 0; i < numOfAnimations; ++i)
	{
		AnimationToBBMOD(scene->mAnimations[i], fout);
	}

	// Write materials
	uint32_t numOfMaterials = scene->mNumMaterials;
	FILE_WRITE_DATA(fout, numOfMaterials);

	if (numOfMaterials > 0)
	{
		std::cout << "Materials:" << std::endl;

		for (uint32_t i = 0; i < numOfMaterials; ++i)
		{
			aiMaterial* material = scene->mMaterials[i];
			std::cout << i << ": " << material->GetName().C_Str() << std::endl;
		}
	}

	delete importer;
	return BBMOD_SUCCESS;
}

int ConvertToBBMOD(const char* fin, const char* fout)
{
	std::ofstream file(fout, std::ios::out | std::ios::binary);

	if (!file.is_open())
	{
		return BBMOD_ERR_SAVE_FAILED;
	}

	int retval = SceneToBBMOD_1(fin, file);

	file.flush();
	file.close();

	if (retval != BBMOD_SUCCESS)
	{
		std::filesystem::remove(fout);
	}

	return retval;
}
