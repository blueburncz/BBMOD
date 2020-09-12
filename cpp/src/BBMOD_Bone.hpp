#pragma once

#include <assimp/matrix4x4.h>
#include <string>
#include <fstream>

struct BBMOD_Bone
{
	bool Save(std::ofstream& file);

	float Index = 0.0f;

	aiMatrix4x4 OffsetMatrix;
};
