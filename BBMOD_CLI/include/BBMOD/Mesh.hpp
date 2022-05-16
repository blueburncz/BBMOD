#pragma once

#include <BBMOD/Config.hpp>
#include <BBMOD/VertexFormat.hpp>
#include <BBMOD/Vector2.hpp>
#include <BBMOD/Vector3.hpp>
#include <BBMOD/Vector4.hpp>

#include <vector>
#include <fstream>

struct SVertex
{
	SVertex()
		: Position VEC3_ZERO
		, Normal VEC3_ZERO
		, Texture VEC2_ZERO
		, Tangent VEC3_ZERO
		, Bones VEC4_ZERO
		, Weights VEC4_ZERO
	{
	}
	
	bool Save(std::ofstream& file);

	static SVertex* Load(std::ifstream& file, SVertexFormat* vertexFormat);

	SVertexFormat* VertexFormat = nullptr;
	vec3_t Position;
	vec3_t Normal;
	vec2_t Texture;
	uint32_t Color = 0;
	vec3_t Tangent;
	float BitangentSign = 1.0;
	vec4_t Bones;
	vec4_t Weights;
	int Id = 0;
};

struct SMesh
{
	static SMesh* FromAssimp(struct aiMesh* mesh, struct SModel* model, const struct SConfig& config);

	bool Save(std::ofstream& file);

	static SMesh* Load(std::ifstream& file, SVertexFormat* vertexFormat, struct SModel* model);

	struct SModel* Model = nullptr;

	SVertexFormat* VertexFormat = nullptr;

	uint32_t MaterialIndex = 0;

	std::vector<SVertex*> Data;
};
