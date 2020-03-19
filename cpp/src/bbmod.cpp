#include "bbmod.hpp"
#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <fstream>
#include <iostream>

#define FILE_WRITE_DATA(f, d) \
	(f).write(reinterpret_cast<const char*>(&(d)), sizeof(d))

#define FILE_WRITE_VEC2(f, v) \
	do \
	{ \
		FILE_WRITE_DATA(f, (v).x); \
		FILE_WRITE_DATA(f, (v).y); \
	} \
	while (false)

#define FILE_WRITE_VEC3(f, v) \
	do \
	{ \
		FILE_WRITE_DATA(f, (v).x); \
		FILE_WRITE_DATA(f, (v).y); \
		FILE_WRITE_DATA(f, (v).z); \
	} \
	while (false)

/** Encodes color into a single integer as ARGB. */
uint32_t EncodeColor(const aiColor4D& color)
{
	return (uint32_t)(
		((uint32_t)(color.a * 255.0) << 24) |
		((uint32_t)(color.r * 255.0) << 16) |
		((uint32_t)(color.g * 255.0) << 8) |
		((uint32_t)(color.b * 255.0)));
}

/** Returns bitangent sign. */
float GetBitangentSign(
	const aiVector3D& normal,
	const aiVector3D& tangent,
	const aiVector3D& bitangent)
{
	float cX = normal.y * tangent.z - normal.z * tangent.y;
	float cY = normal.z * tangent.x - normal.x * tangent.z;
	float cZ = normal.x * tangent.y - normal.y * tangent.x;

	float dot = cX * bitangent.x
		+ cY * bitangent.y
		+ cZ * bitangent.z;

	return (dot < 0.0f) ? -1.0f : 1.0f;
}

/** Writes a single mesh into a BBMOD file. */
void MeshToBBMOD(aiMesh* mesh, std::ofstream& fout)
{
	uint32_t faceCount = mesh->mNumFaces;
	aiColor4D cWhite(1.0, 1.0, 1.0, 1.0);

	for (unsigned int i = 0; i < faceCount; ++i)
	{
		aiFace& face = mesh->mFaces[i];
		for (unsigned int f = 0; f < face.mNumIndices; ++f)
		{
			unsigned int idx = face.mIndices[f];

			// Vertex position
			aiVector3D& vertex = mesh->mVertices[idx];
			FILE_WRITE_VEC3(fout, vertex);

			// Normals
			aiVector3D* normal = nullptr;
			if (mesh->HasNormals())
			{
				normal = &(mesh->mNormals[idx]);
				FILE_WRITE_VEC3(fout, *normal);
			}

			// Texture coords
			if (mesh->HasTextureCoords(0))
			{
				aiVector3D& texture = mesh->mTextureCoords[0][idx];
				FILE_WRITE_VEC2(fout, texture);
			}

			// Color
			aiColor4D& color = (mesh->HasVertexColors(0))
				? mesh->mColors[0][idx]
				: cWhite;
			uint32_t vertexColor = EncodeColor(color);
			FILE_WRITE_DATA(fout, vertexColor);


			if (normal && mesh->HasTangentsAndBitangents())
			{
				// Tangent
				aiVector3D& tangent = mesh->mTangents[idx];
				FILE_WRITE_VEC3(fout, tangent);

				// Bitangent sign
				aiVector3D& bitangent = mesh->mBitangents[idx];
				float sign = GetBitangentSign(*normal, tangent, bitangent);
				FILE_WRITE_DATA(fout, sign);
			}
		}
	}
}

/**
 * Writes the scene into a version 0 BBMOD file.
 *
 * In this version, all meshes are pretransformed and merged into one.
 * Animations are not supported.
 */
bool SceneToBBMOD_0(const char* fin, std::ofstream& fout)
{
	Assimp::Importer* importer = new Assimp::Importer();

	const aiScene* scene = importer->ReadFile(fin, 0
		| aiProcessPreset_TargetRealtime_Quality
		| aiProcess_PreTransformVertices
		//| aiProcess_TransformUVCoords
		//| aiProcess_OptimizeGraph
		//| aiProcess_OptimizeMeshes
	);

	if (!scene)
	{
		return false;
	}

	bool first = true;
	uint32_t vertexCount = 0;

	for (size_t i = 0; i < scene->mNumMeshes; ++i)
	{
		vertexCount += scene->mMeshes[i]->mNumFaces * 3;
	}

	for (size_t i = 0; i < scene->mNumMeshes; ++i)
	{
		aiMesh* mesh = scene->mMeshes[i];

		if (first)
		{
			// Write header
			uint8_t version = 0;
			FILE_WRITE_DATA(fout, version);

			bool hasVertices = true;
			FILE_WRITE_DATA(fout, hasVertices);

			bool hasNormals = mesh->HasNormals();
			FILE_WRITE_DATA(fout, hasNormals);

			bool hasTextureCoords = mesh->HasTextureCoords(0);
			FILE_WRITE_DATA(fout, hasTextureCoords);

			bool hasVertexColors = true; //mesh->HasVertexColors(0);
			FILE_WRITE_DATA(fout, hasVertexColors);

			bool hasTangentsAndBitangents = mesh->HasTangentsAndBitangents();
			FILE_WRITE_DATA(fout, hasTangentsAndBitangents);

			FILE_WRITE_DATA(fout, vertexCount);

			first = false;
		}

		MeshToBBMOD(mesh, fout);
	}

	delete importer;

	return true;
}

bool ConvertToBBMOD(const char* fin, const char* fout)
{
	std::ofstream file(fout, std::ios::out | std::ios::binary);

	if (!file.is_open())
	{
		return false;
	}

	bool success = SceneToBBMOD_0(fin, file);

	file.flush();
	file.close();

	return success;
}
