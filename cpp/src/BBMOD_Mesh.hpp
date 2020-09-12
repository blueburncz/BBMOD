#pragma once

#include "BBMOD_VertexFormat.hpp"
#include <assimp/vector2.h>
#include <assimp/vector3.h>
#include <vector>
#include <fstream>

struct BBMOD_Vertex
{
	BBMOD_Vertex()
		: Position(aiVector3D())
		, Normal(aiVector3D())
		, Texture(aiVector2D())
		, Tangent(aiVector3D())
	{
	}
	
	bool Save(std::ofstream& file);

	BBMOD_VertexFormat* VertexFormat = nullptr;
	aiVector3D Position;
	aiVector3D Normal;
	aiVector2D Texture;
	uint32_t Color = 0;
	aiVector3D Tangent;
	float BitangentSign = 1.0;
	float Bones[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
	float Weights[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
	int Id = 0;
};

struct BBMOD_Mesh
{
	static BBMOD_Mesh* FromAssimp(struct aiMesh* mesh, struct BBMOD_Model* model, const struct BBMODConfig& config);

	bool Save(std::ofstream& file);

	BBMOD_VertexFormat* VertexFormat = nullptr;

	size_t MaterialIndex = 0;

	std::vector<BBMOD_Vertex*> Data;
};
