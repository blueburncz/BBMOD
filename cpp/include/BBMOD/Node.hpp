#pragma once

#include <BBMOD/Matrix.hpp>

#include <string>
#include <vector>
#include <fstream>

struct SNode
{
	SNode() : TransformMatrix MATRIX_IDENTITY
	{
	}

	bool Save(std::ofstream& file);

	static SNode* Load(std::ifstream& file);

	std::string Name;

	float Index = 0.0f;

	bool IsBone = false;

	matrix_t TransformMatrix;

	std::vector<size_t> Meshes;

	std::vector<SNode*> Children;
};
