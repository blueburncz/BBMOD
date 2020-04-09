#include "bbmod.hpp"
#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <fstream>
#include <iostream>
#include <filesystem>
#include <map>
#include <string>

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

typedef float id_t;

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

id_t gNextNodeId = 0;
std::map<id_t, aiNode*> gIndexIdToNode;
std::map<aiNode*, id_t> gIndexNodeToId;

/** Node has a mesh or has a child node with a mesh. */
std::map<aiNode*, bool> gIndexNodeHasMesh;

/** Node is a bone or has a bone child node. */
std::map<aiNode*, bool> gIndexNodeHasBone;

id_t gNextBoneId = 0;
std::map<const char*, id_t, StringCompare> gIndexBoneNameToIndex;
std::map<const char*, aiBone*, StringCompare> gIndexBoneNameToBone;

size_t GetNodeMesh(id_t id, size_t index)
{
	return gIndexIdToNode.at(id)->mMeshes[index];
}

size_t GetNodeChildCount(id_t id)
{
	return gIndexIdToNode.at(id)->mNumChildren;
}

id_t GetNodeChild(id_t id, size_t index)
{
	return gIndexNodeToId.at(gIndexIdToNode.at(id)->mChildren[index]);
}

////////////////////////////////////////////////////////////////////////////////

void StringReplaceUnsafe(std::string& str)
{
	// https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file
	std::transform(str.begin(), str.end(), str.begin(), [](char c) {
		const std::string unsafe = "<>:\"/\\|?*";
		if (unsafe.find(c) != std::string::npos)
		{
			return '_';
		}
		return c;
	});
}

std::string GetFilename(const char* out, const char* name, const char* extension)
{
	std::string fname = std::filesystem::path(out).stem().string() + "_";
	fname.append(name);
	StringReplaceUnsafe(fname);
	return std::filesystem::path(out).replace_filename(fname.c_str()).replace_extension(extension).string();
}

std::string GetAnimationFilename(aiAnimation* animation, int index, const char* out)
{
	std::string animationName = "";

	if (std::strlen(animation->mName.C_Str()) == 0)
	{
		animationName.append("anim");
		animationName.append(std::to_string(index));
	}
	else
	{
		animationName.append(animation->mName.C_Str());
	}

	return GetFilename(out, animationName.c_str(), ".bbanim");
}

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
	id_t id = gNextNodeId++;
	gIndexIdToNode[id] = node;
	gIndexNodeToId[node] = id;
	for (size_t i = 0; i < node->mNumChildren; ++i)
	{
		BuildIndices(scene, node->mChildren[i]);
	}
	return true;
}

/**
 * Writes a BBMOD header into a file.
 *
 * Format:
 *  * String "bbmod" (null terminated)
 *  * Version (uint8)
 *  * HasVertices (bool, always true)
 *  * HasNormals (bool)
 *  * HasTextureCoords (bool)
 *  * HasVertexColors (bool, always true)
 *  * HasTangentW (bool)
 *  * HasBones (bool)
 */
void WriteHeader_BBMOD(
	bool hasNormals,
	bool hasTextureCoords,
	bool hasTangentW,
	bool hasBones,
	std::ofstream& fout)
{
	fout.write("bbmod", sizeof(char) * 6);

	uint8_t version = BBMOD_VERSION;
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
 * Writes a BBANIM header into a file.
 *
 * Format:
 *  * String "bbanim" (null terminated)
 *  * Version (uint8)
 */
void WriteHeader_BBANIM(std::ofstream& fout)
{
	fout.write("bbanim", sizeof(char) * 7);

	uint8_t version = BBMOD_VERSION;
	FILE_WRITE_DATA(fout, version);
}

/**
 * Writes a mesh into a BBMOD file.
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
void MeshToBBMOD(
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
	std::map<uint32_t, std::vector<id_t>> vertexBones;
	std::map<uint32_t, std::vector<float>> vertexWeights;

	for (uint32_t i = 0; i < boneCount; ++i)
	{
		aiBone* bone = mesh->mBones[i];
		const char* name = bone->mName.C_Str();
		id_t boneId = gIndexBoneNameToIndex.at(name);
		for (uint32_t j = 0; j < bone->mNumWeights; ++j)
		{
			auto weight = bone->mWeights[j];
			uint32_t vertexId = (uint32_t)weight.mVertexId;

			auto it = vertexBones.find(vertexId);
			if (it == vertexBones.end())
			{
				std::vector<id_t> _bones;
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
					id_t b = (j < _vertexBones.size()) ? _vertexBones[j] : 0;
					FILE_WRITE_DATA(fout, b);
				}
			}
			else if (forceBonesAndWeights)
			{
				id_t b = 0;
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
 * Writes a node into a BBMOD file.
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
	id_t id,
	aiMatrix4x4& matrix,
	bool forceBonesAndWeights,
	std::ofstream& fout)
{
	aiNode* node = gIndexIdToNode.at(id);

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
		MeshToBBMOD(mesh, matrix, forceBonesAndWeights, fout);
	}

	// Write child nodes
	uint32_t childNumWithMesh = 0;
	for (uint32_t i = 0; i < childCount; ++i)
	{
		id_t childId = GetNodeChild(id, (size_t)i);
		aiNode* child = gIndexIdToNode.at(childId);
		if (gIndexNodeHasMesh.at(child))
		{
			++childNumWithMesh;
		}
	}

	FILE_WRITE_DATA(fout, childNumWithMesh);

	for (uint32_t i = 0; i < childCount; ++i)
	{
		id_t child = GetNodeChild(id, (size_t)i);
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
void BoneToBBMOD(id_t id, aiMatrix4x4& matrix, std::ofstream& fout, std::ofstream& log)
{
	aiNode* node = gIndexIdToNode.at(id);
	uint32_t childCount = GetNodeChildCount(id);
	const char* name = node->mName.C_Str();
	bool isBone = gIndexBoneNameToIndex.find(name) != gIndexBoneNameToIndex.end();

	// Bone name
	fout.write(name, sizeof(char) * (node->mName.length + 1));

	// Bone index
	id_t boneIndex = isBone ? gIndexBoneNameToIndex.at(name) : -1;
	FILE_WRITE_DATA(fout, boneIndex);

	if (isBone)
	{
		log << boneIndex << ": " << name << std::endl;
	}

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

	// Number of child nodes
	FILE_WRITE_DATA(fout, childCount);

	// Write child nodes
	for (uint32_t i = 0; i < childCount; ++i)
	{
		aiNode* child = gIndexIdToNode.at(GetNodeChild(id, i));
		BoneToBBMOD(GetNodeChild(id, i), matrix, fout, log);
	}
}

/**
 * Writes an animation into a BBMOD file.
 *
 * Format:
 *  * Duration in tics (f64)
 *  * Tics per second (f64)
 *  * Number of bones of target mesh (uint32)
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
void AnimationToBBMOD(aiAnimation* animation, uint32_t numOfBones, std::ofstream& fout)
{
	// Duration in ticks
	FILE_WRITE_DATA(fout, animation->mDuration);

	// Ticks per second
	FILE_WRITE_DATA(fout, animation->mTicksPerSecond);

	// Number of bones of target mesh
	FILE_WRITE_DATA(fout, numOfBones);

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
			id_t boneId = gIndexBoneNameToIndex.at(nodeAnimName);
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
 * Writes the scene into a BBMOD file.
 *
 * Scene-graph and animations are supported.
 *
 * Format:
 *  * Header
 *  * Global inverse transform matrix (16x f32, row major)
 *  * Root node follows...
 *  * Number of bones (uint32)
 *  * Bones follow...
 *  * Number of materials (uint32)
 *  * Material names follow... (null terminated strings)
 */
int SceneToBBMOD(const aiScene* scene, std::ofstream& fout, std::ofstream& log)
{
	// Write header
	aiMesh* mesh = scene->mMeshes[0];
	bool hasBones = (gIndexBoneNameToBone.size() > 0);

	WriteHeader_BBMOD(mesh->HasNormals(), mesh->HasTextureCoords(0),
		mesh->HasTangentsAndBitangents(), hasBones, fout);

	// Write global inverse transform
	aiMatrix4x4 inverse = scene->mRootNode->mTransformation.Inverse();
	FILE_WRITE_MATRIX(fout, inverse);

	// Write nodes
	aiMatrix4x4 matrix;
	NodeToBBMOD(scene, 0, matrix, hasBones, fout);

	// Write bones
	uint32_t numOfBones = (uint32_t)gNextBoneId;
	FILE_WRITE_DATA(fout, numOfBones);

	if (numOfBones > 0)
	{
		log << "Bones:" << std::endl;
		BoneToBBMOD(0, matrix, fout, log);
		log << std::endl;
	}

	// Write materials
	uint32_t numOfMaterials = scene->mNumMaterials;
	FILE_WRITE_DATA(fout, numOfMaterials);

	if (numOfMaterials > 0)
	{
		log << "Materials:" << std::endl;
		for (uint32_t i = 0; i < numOfMaterials; ++i)
		{
			aiMaterial* material = scene->mMaterials[i];
			log << i << ": " << material->GetName().C_Str() << std::endl;
		}
		log << std::endl;
	}

	return BBMOD_SUCCESS;
}

int ConvertToBBMOD(const char* fin, const char* fout)
{
	std::ofstream log(GetFilename(fout, "log", ".txt"), std::ios::out);

	Assimp::Importer* importer = new Assimp::Importer();

	const aiScene* scene = importer->ReadFile(fin, 0
		| aiProcessPreset_TargetRealtime_Quality
		//| aiProcess_MakeLeftHanded
		//| aiProcess_PreTransformVertices
		| aiProcess_TransformUVCoords
		| aiProcess_OptimizeGraph
		| aiProcess_OptimizeMeshes);

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

	// Write BBMOD
	std::ofstream file(fout, std::ios::out | std::ios::binary);

	if (!file.is_open())
	{
		return BBMOD_ERR_SAVE_FAILED;
	}

	int retval = SceneToBBMOD(scene, file, log);

	file.flush();
	file.close();

	if (retval != BBMOD_SUCCESS)
	{
		std::filesystem::remove(fout);
		return retval;
	}

	// Write animations
	uint32_t numOfAnimations = scene->mNumAnimations;

	if (numOfAnimations > 0)
	{
		for (uint32_t i = 0; i < numOfAnimations; ++i)
		{
			aiAnimation* animation = scene->mAnimations[i];
			std::string fname = GetAnimationFilename(animation, i, fout);
			std::cout << "Writing animation \"" << fname.c_str() << "\"... ";
			std::ofstream fanim(fname.c_str(), std::ios::out | std::ios::binary);

			WriteHeader_BBANIM(fanim);
			AnimationToBBMOD(animation, (uint32_t)gNextBoneId, fanim);

			file.flush();
			file.close();

			std::cout << "DONE!" << std::endl;
		}
	}

	return BBMOD_SUCCESS;
}
