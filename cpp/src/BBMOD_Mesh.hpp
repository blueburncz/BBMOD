#pragma once

#include <assimp/vector2.h>
#include <assimp/vector3.h>
#include <vector>

struct BBMOD_Vertex
{
	BBMOD_Vertex()
		: Position(aiVector3D())
		, Normal(aiVector3D())
		, Texture(aiVector2D())
		, Tangent(aiVector3D())
	{
	}

	aiVector3D Position;
	aiVector3D Normal;
	aiVector2D Texture;
	uint32_t Color = 0;
	aiVector3D Tangent;
	float BitangentSign = 1.0;
	int Bones[4] = { 0, 0, 0, 0 };
	float Weights[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
};

struct BBMOD_Mesh
{
	static BBMOD_Mesh* FromAssimp(struct aiMesh* mesh, struct BBMOD_Model* model, const struct BBMODConfig& config);

	size_t MaterialIndex = 0;

	std::vector<BBMOD_Vertex*> Data;
};
