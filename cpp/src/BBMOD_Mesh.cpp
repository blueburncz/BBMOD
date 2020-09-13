#include "BBMOD_Mesh.hpp"
#include "BBMOD_Model.hpp"
#include "bbmod.hpp"
#include "terminal.hpp"
#include <map>
#include <vector>
#include <string>
#include "utils.hpp"
#include <iostream>

/** Encodes color into a single integer as ARGB. */
static inline uint32_t EncodeColor(const aiColor4D& color)
{
	return (uint32_t)(
		((uint32_t)(color.a * 255.0f) << 24) |
		((uint32_t)(color.b * 255.0f) << 16) |
		((uint32_t)(color.g * 255.0f) << 8) |
		((uint32_t)(color.r * 255.0f)));
}

/** Returns cross product of vectors v1 and v2. */
static inline aiVector3D Vec3Cross(const aiVector3D& v1, const aiVector3D& v2)
{
	aiVector3D res;
	res.x = v1.y * v2.z - v1.z * v2.y;
	res.y = v1.z * v2.x - v1.x * v2.z;
	res.z = v1.x * v2.y - v1.y * v2.x;
	return res;
}

/** Returns dot product of vectors v1 and v2. */
static inline float Vec3Dot(const aiVector3D& v1, const aiVector3D& v2)
{
	return (v1.x * v2.x
		+ v1.y * v2.y
		+ v1.z * v2.z);
}

/** Returns bitangent sign. */
static inline float GetBitangentSign(
	const aiVector3D& normal,
	const aiVector3D& tangent,
	const aiVector3D& bitangent)
{
	aiVector3D cross = Vec3Cross(normal, tangent);
	float dot = Vec3Dot(cross, bitangent);
	return (dot < 0.0f) ? -1.0f : 1.0f;
}

BBMOD_Mesh* BBMOD_Mesh::FromAssimp(aiMesh* aiMesh, BBMOD_Model* model, const BBMODConfig& config)
{
	BBMOD_Mesh* mesh = new BBMOD_Mesh();

	mesh->VertexFormat = model->VertexFormat;
	mesh->MaterialIndex = aiMesh->mMaterialIndex;

	uint32_t faceCount = aiMesh->mNumFaces;
	aiColor4D cWhite(1.0f, 1.0f, 1.0f, 1.0f);
	uint32_t vertexCount = faceCount * 3;

	////////////////////////////////////////////////////////////////////////////
	// Gather vertex bones and weights
	std::map<uint32_t, std::vector<float>> vertexBones;
	std::map<uint32_t, std::vector<float>> vertexWeights;

	if (model->VertexFormat->Bones)
	{
		uint32_t boneCount = aiMesh->mNumBones;

		for (uint32_t i = 0; i < boneCount; ++i)
		{
			aiBone* bone = aiMesh->mBones[i];
			std::string name = bone->mName.C_Str();

			float boneId = model->FindBoneByName(name)->Index;

			for (uint32_t j = 0; j < bone->mNumWeights; ++j)
			{
				auto weight = bone->mWeights[j];
				uint32_t vertexId = (uint32_t)weight.mVertexId;

				auto it = vertexBones.find(vertexId);
				if (it == vertexBones.end())
				{
					std::vector<float> _bones;
					vertexBones.emplace(std::make_pair(vertexId, _bones));

					std::vector<float> _weights;
					vertexWeights.emplace(std::make_pair(vertexId, _weights));
				}

				vertexBones[vertexId].push_back(boneId);
				vertexWeights[vertexId].push_back(weight.mWeight);
			}
		}
	}
	////////////////////////////////////////////////////////////////////////////

	for (unsigned int i = 0; i < faceCount; ++i)
	{
		aiFace& face = aiMesh->mFaces[i];

		if (face.mNumIndices != 3)
		{
			PRINT_ERROR("Mesh \"%s\" has a polygon with %d vertices, but only triangles are supported!", aiMesh->mName.C_Str(), face.mNumIndices);
			exit(EXIT_FAILURE);
		}

		for (unsigned int f = config.invertWinding ? face.mNumIndices - 1 : 0; f >= 0 && f < face.mNumIndices; f += config.invertWinding ? -1 : +1)
		{
			uint32_t idx = face.mIndices[f];

			BBMOD_Vertex* vertex = new BBMOD_Vertex();
			vertex->VertexFormat = mesh->VertexFormat;

			// Vertex
			vertex->Position = aiVector3D(aiMesh->mVertices[idx]);

			// Normal
			aiVector3D normal;
			if (model->VertexFormat->Normals)
			{
				normal = aiMesh->HasNormals()
					? aiVector3D(aiMesh->mNormals[idx])
					: aiVector3D();
				if (config.flipNormals)
				{
					normal *= -1.0f;
				}
				vertex->Normal = normal;
			}

			// Texture
			if (model->VertexFormat->TextureCoords)
			{
				aiVector3D texture = aiMesh->HasTextureCoords(0)
					? aiMesh->mTextureCoords[0][idx]
					: aiVector3D();
				if (config.flipTextureHorizontally)
				{
					texture.x = 1.0f - texture.x;
				}
				if (config.flipTextureVertically)
				{
					texture.y = 1.0f - texture.y;
				}
				vertex->Texture = aiVector2D(texture.x, texture.y);
			}

			// Color
			if (model->VertexFormat->Colors)
			{
				aiColor4D& color = (aiMesh->HasVertexColors(0))
					? aiMesh->mColors[0][idx]
					: cWhite;
				vertex->Color = EncodeColor(color);
			}

			if (model->VertexFormat->TangentW)
			{
				if (aiMesh->HasTangentsAndBitangents())
				{
					// Tangent
					vertex->Tangent = aiVector3D(aiMesh->mTangents[idx]);

					// Bitangent sign
					aiVector3D& bitangent = aiMesh->mBitangents[idx];
					vertex->BitangentSign = GetBitangentSign(normal, vertex->Tangent, bitangent);
				}
				else
				{
					vertex->Tangent = aiVector3D(0.0f, 0.0f, 0.0f);
					vertex->BitangentSign = 1.0f;
				}
			}

			if (model->VertexFormat->Bones)
			{
				// Bone indices
				if (vertexBones.find(idx) != vertexBones.end())
				{
					auto _vertexBones = vertexBones.at(idx);
					for (uint32_t j = 0; j < 4; ++j)
					{
						vertex->Bones[j] = (j < _vertexBones.size()) ? _vertexBones[j] : 0.0f;
					}
				}

				// Vertex weights
				if (vertexWeights.find(idx) != vertexWeights.end())
				{
					auto _vertexWeights = vertexWeights.at(idx);
					for (uint32_t j = 0; j < 4; ++j)
					{
						vertex->Weights[j] = (j < _vertexWeights.size()) ? _vertexWeights[j] : 0.0f;
					}
				}
			}

			mesh->Data.push_back(vertex);
		}
	}

	return mesh;
}

bool BBMOD_Vertex::Save(std::ofstream& file)
{
	BBMOD_VertexFormat* vertexFormat = VertexFormat;

	if (vertexFormat->Vertices)
	{
		FILE_WRITE_VEC3(file, Position);
	}

	if (vertexFormat->Normals)
	{
		FILE_WRITE_VEC3(file, Normal);
	}

	if (vertexFormat->TextureCoords)
	{
		FILE_WRITE_VEC2(file, Texture);
	}

	if (vertexFormat->Colors)
	{
		FILE_WRITE_DATA(file, Color);
	}

	if (vertexFormat->TangentW)
	{
		FILE_WRITE_VEC3(file, Tangent);
		FILE_WRITE_DATA(file, BitangentSign);
	}

	if (vertexFormat->Bones)
	{
		for (size_t i = 0; i < 4; ++i)
		{
			FILE_WRITE_DATA(file, Bones[i]);
		}

		for (size_t i = 0; i < 4; ++i)
		{
			FILE_WRITE_DATA(file, Weights[i]);
		}
	}

	if (vertexFormat->Ids)
	{
		FILE_WRITE_DATA(file, Id);
	}


	return true;
}


bool BBMOD_Mesh::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, MaterialIndex);

	size_t vertexCount = Data.size();
	FILE_WRITE_DATA(file, vertexCount);

	for (BBMOD_Vertex* vertex : Data)
	{
		if (!vertex->Save(file))
		{
			return false;
		}
	}

	return true;
}
