#pragma once

#include <fstream>

struct SVertexFormat
{
	bool Save(std::ofstream& file);

	static SVertexFormat* Load(std::ifstream& file, uint8_t versionMinor);

	bool Vertices = true;

	bool Normals = false;

	bool TextureCoords = false;

	bool TextureCoords2 = false;

	bool Colors = false;

	bool TangentW = false;

	bool Bones = false;

	bool Ids = false;
};
