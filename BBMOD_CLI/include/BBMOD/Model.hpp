#pragma once

#include <BBMOD/Config.hpp>
#include <BBMOD/VertexFormat.hpp>
#include <BBMOD/Node.hpp>
#include <BBMOD/Bone.hpp>
#include <BBMOD/Mesh.hpp>

#include <vector>
#include <string>
#include <map>

struct SModel
{
	static SModel* FromAssimp(const struct aiScene* scene, const SConfig& config);

	SBone* FindBoneByName(std::string name) const;

	SBone* FindBoneByIndex(int index) const;

	SNode* FindNodeByName(std::string name, SNode* nodeCurrent) const;

	bool Save(std::string path);

	static SModel* Load(std::string path);

	uint8_t VersionMajor = BBMOD_VERSION_MAJOR;

	uint8_t VersionMinor = BBMOD_VERSION_MINOR;

	// Unused since 3.2 - each mesh has its own vertex format instead!
	SVertexFormat* VertexFormat = nullptr;
	
	std::vector<SMesh*> Meshes;

	uint32_t NodeCount = 0;

	SNode* RootNode = nullptr;

	uint32_t BoneCount = 0;

	std::vector<SBone*> Skeleton;

	std::vector<std::string> MaterialNames;

private:
	bool NodeIsImportant(std::string name) const;

	std::map<std::string, bool> NodeImportanceMap;
};
