#pragma once

#include <BBMOD/Config.hpp>
#include <BBMOD/VertexFormat.hpp>
#include <BBMOD/Node.hpp>
#include <BBMOD/Bone.hpp>
#include <BBMOD/Mesh.hpp>
#include <BBMOD/Matrix.hpp>

#include <vector>
#include <string>

struct SModel
{
	SModel() : InverseTransformMatrix MATRIX_IDENTITY
	{
	}

	static SModel* FromAssimp(const struct aiScene* scene, const SConfig& config);

	SBone* FindBoneByName(std::string name) const;

	SBone* FindBoneByIndex(int index) const;

	SNode* FindNodeByName(std::string name, SNode* nodeCurrent) const;

	bool Save(std::string path);

	static SModel* Load(std::string path);

	unsigned char Version = BBMOD_VERSION;

	SVertexFormat* VertexFormat = nullptr;
	
	std::vector<SMesh*> Meshes;

	matrix_t InverseTransformMatrix;

	size_t NodeCount = 0;

	SNode* RootNode = nullptr;

	size_t BoneCount = 0;

	std::vector<SBone*> Skeleton;

	std::vector<std::string> MaterialNames;
};
