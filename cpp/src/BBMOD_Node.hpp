#pragma once

#include <assimp/matrix4x4.h>
#include <string>
#include <vector>

struct BBMOD_Node
{
	std::string Name;

	aiMatrix4x4 TransformMatrix;

	int Index = 0;

	bool IsBone = false;

	std::vector<size_t> Meshes;

	std::vector<BBMOD_Node*> Children;
};
