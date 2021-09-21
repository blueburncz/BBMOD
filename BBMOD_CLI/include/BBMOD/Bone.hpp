#pragma once

#include <BBMOD/DualQuaternion.hpp>

#include <string>
#include <fstream>

struct SBone
{
	SBone() : Offset DUAL_QUATERNION_IDENTITY
	{
	}

	bool Save(std::ofstream& file);

	static SBone* Load(std::ifstream& file);

	std::string Name;

	float Index = 0.0f;

	dual_quat_t Offset;
};
