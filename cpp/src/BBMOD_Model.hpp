#pragma once

#include <assimp/scene.h>
#include "BBMOD_VertexFormat.hpp"
#include "BBMOD_Node.hpp"
#include "BBMOD_Bone.hpp"
#include "BBMOD_Mesh.hpp"
#include "bbmod.hpp"
#include <vector>
#include <string>

struct BBMOD_Model
{
	static BBMOD_Model* FromAssimp(const aiScene* scene, const BBMODConfig& config);

	BBMOD_Bone* FindBoneByName(std::string name)
	{
		for (BBMOD_Bone* bone : Skeleton)
		{
			if (bone->Name == name)
			{
				return bone;
			}
		}
		return nullptr;
	}

	BBMOD_Bone* FindBoneByIndex(int index)
	{
		for (BBMOD_Bone* bone : Skeleton)
		{
			if (bone->Index == index)
			{
				return bone;
			}
		}
		return nullptr;
	}

	BBMOD_Node* FindNodeByName(std::string name, BBMOD_Node* nodeCurrent)
	{
		if (nodeCurrent->Name == name)
		{
			return nodeCurrent;
		}
		for (BBMOD_Node* child : nodeCurrent->Children)
		{
			if (BBMOD_Node* node = FindNodeByName(name, child))
			{
				return node;
			}
		}
		return nullptr;
	}

	bool Save(std::string path);

	const aiScene* Scene = nullptr;

	size_t Version = BBMOD_VERSION;

	BBMOD_VertexFormat* VertexFormat = nullptr;
	
	std::vector<BBMOD_Mesh*> Meshes;

	aiMatrix4x4 InverseTransformMatrix;

	size_t NodeCount = 0;

	BBMOD_Node* RootNode = nullptr;

	size_t BoneCount = 0;

	std::vector<BBMOD_Bone*> Skeleton;

	std::vector<std::string> MaterialNames;
};
