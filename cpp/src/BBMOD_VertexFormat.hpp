#pragma once

#include <fstream>

struct BBMOD_VertexFormat
{
	bool Save(std::ofstream& file);

	bool Vertices = true;

	bool Normals = false;

	bool TextureCoords = false;

	bool Colors = false;

	bool TangentW = false;

	bool Bones = false;

	bool Ids = false;
};
