#pragma once

#include <BBMOD/DualQuaternion.hpp>

#include <string>
#include <vector>
#include <fstream>

struct SNode
{
	SNode() : Transform DUAL_QUATERNION_IDENTITY
	{
	}

	bool Save(std::ofstream& file);

	static SNode* Load(std::ifstream& file);

	std::string Name;

	float Index = 0.0f;

	bool IsBone = false;

	bool Visible = true;

	dual_quat_t Transform;

	std::vector<size_t> Meshes;

	std::vector<SNode*> Children;
};
