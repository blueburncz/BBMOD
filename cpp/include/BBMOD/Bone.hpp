#pragma once

#include <BBMOD/Matrix.hpp>

#include <string>
#include <fstream>

struct SBone
{
	SBone() : OffsetMatrix MATRIX_IDENTITY
	{
	}

	bool Save(std::ofstream& file);

	static SBone* Load(std::ifstream& file);

	std::string Name;

	float Index = 0.0f;

	matrix_t OffsetMatrix;
};
