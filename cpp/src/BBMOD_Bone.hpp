#pragma once

#include <assimp/matrix4x4.h>
#include <string>

struct BBMOD_Bone
{
	std::string Name;

	int Index = 0;

	aiMatrix4x4 OffsetMatrix;
};
