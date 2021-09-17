#include <BBMOD/Model.hpp>

#include <utils.hpp>

#include <assimp/scene.h>

#include <fstream>
#include <iostream>

static inline void AssimpToMatrix(const aiMatrix4x4 from, matrix_t to)
{
	to[0] = from.a1;
	to[1] = from.b1;
	to[2] = from.c1;
	to[3] = from.d1;
	to[4] = from.a2;
	to[5] = from.b2;
	to[6] = from.c2;
	to[7] = from.d2;
	to[8] = from.a3;
	to[9] = from.b3;
	to[10] = from.c3;
	to[11] = from.d3;
	to[12] = from.a4;
	to[13] = from.b4;
	to[14] = from.c4;
	to[15] = from.d4;
}

static SNode* CollectNodes(SModel* model, aiNode* nodeCurrent, const SConfig& config)
{
	SNode* node = new SNode();
	node->Name = nodeCurrent->mName.C_Str();

	if (SBone* bone = model->FindBoneByName(node->Name))
	{
		node->Index = (float)bone->Index;
		node->IsBone = true;
	}
	else
	{
		node->Index = (float)model->NodeCount++;
		node->IsBone = false;
	}

	aiQuaternion aiRot;
	aiVector3D aiPos;
	nodeCurrent->mTransformation.DecomposeNoScaling(aiRot, aiPos);

	quat_t rot = {aiRot.x, aiRot.y, aiRot.z, aiRot.w};
	vec3_t pos = { aiPos.x, aiPos.y, aiPos.z };

	dual_quaternion_from_translation_rotation(node->Transform, pos, rot);

	for (size_t i = 0; i < nodeCurrent->mNumMeshes; ++i)
	{
		node->Meshes.push_back(nodeCurrent->mMeshes[i]);
	}

	for (size_t i = 0; i < nodeCurrent->mNumChildren; ++i)
	{
		node->Children.push_back(CollectNodes(model, nodeCurrent->mChildren[i], config));
	}

	return node;
}

SModel* SModel::FromAssimp(const aiScene* scene, const SConfig& config)
{
	SModel* model = new SModel();

	// Resolve vertex format of the model
	aiMesh* mesh = scene->mMeshes[0];

	SVertexFormat* vertexFormat = new SVertexFormat();
	vertexFormat->Vertices = true;
	vertexFormat->Normals = mesh->HasNormals() && !config.DisableNormals;
	vertexFormat->TextureCoords = mesh->HasTextureCoords(0) && !config.DisableTextureCoords;
	vertexFormat->Colors = mesh->HasVertexColors(0) && !config.DisableVertexColors;
	vertexFormat->TangentW = mesh->HasTangentsAndBitangents() && !(config.DisableNormals || config.DisableTangentW);
	vertexFormat->Bones = false;
	vertexFormat->Ids = false;

	if (!config.DisableBones)
	{
		for (size_t i = 0; i < scene->mNumMeshes; ++i)
		{
			aiMesh* meshCurrent = scene->mMeshes[i];

			if (meshCurrent->HasBones())
			{
				// The model has bones
				vertexFormat->Bones = true;

				// Collect all bones
				for (size_t j = 0; j < meshCurrent->mNumBones; ++j)
				{
					aiBone* boneCurrent = meshCurrent->mBones[j];
					std::string boneName = boneCurrent->mName.C_Str();

					if (model->FindBoneByName(boneName) == nullptr)
					{
						SBone* bone = new SBone();
						bone->Name = boneName;
						bone->Index = (float)model->BoneCount++;

						aiQuaternion aiRot;
						aiVector3D aiPos;
						boneCurrent->mOffsetMatrix.DecomposeNoScaling(aiRot, aiPos);

						quat_t rot = { aiRot.x, aiRot.y, aiRot.z, aiRot.w };
						vec3_t pos = { aiPos.x, aiPos.y, aiPos.z };

						dual_quaternion_from_translation_rotation(bone->Offset, pos, rot);

						model->Skeleton.push_back(bone);
					}
				}
			}
		}
		model->NodeCount = model->BoneCount;
	}

	vertexFormat->Ids = false;

	model->VertexFormat = vertexFormat;
	
	// Meshes
	for (size_t i = 0; i < scene->mNumMeshes; ++i)
	{
		aiMesh* meshCurrent = scene->mMeshes[i];
		model->Meshes.push_back(SMesh::FromAssimp(meshCurrent, model, config));
	}

	// Nodes
	model->RootNode = CollectNodes(model, scene->mRootNode, config);

	// Materials
	for (size_t i = 0; i < scene->mNumMaterials; ++i)
	{
		aiMaterial* materialCurrent = scene->mMaterials[i];
		model->MaterialNames.push_back(materialCurrent->GetName().C_Str());
	}

	return model;
}

SBone* SModel::FindBoneByName(std::string name) const
{
	for (SBone* bone : Skeleton)
	{
		if (bone->Name == name)
		{
			return bone;
		}
	}
	return nullptr;
}

SBone* SModel::FindBoneByIndex(int index) const
{
	for (SBone* bone : Skeleton)
	{
		if (bone->Index == index)
		{
			return bone;
		}
	}
	return nullptr;
}

SNode* SModel::FindNodeByName(std::string name, SNode* nodeCurrent) const
{
	if (nodeCurrent->Name == name)
	{
		return nodeCurrent;
	}
	for (SNode* child : nodeCurrent->Children)
	{
		if (SNode* node = FindNodeByName(name, child))
		{
			return node;
		}
	}
	return nullptr;
}

bool SModel::Save(std::string path)
{
	std::ofstream file(path, std::ios::out | std::ios::binary);

	if (!file.is_open())
	{
		return false;
	}

	file.write("bbmod", sizeof(char) * 6);
	FILE_WRITE_DATA(file, Version);
	
	if (!VertexFormat->Save(file))
	{
		return false;
	}

	size_t meshCount = Meshes.size();
	FILE_WRITE_DATA(file, meshCount);

	for (SMesh* mesh : Meshes)
	{
		if (!mesh->Save(file))
		{
			return false;
		}
	}

	FILE_WRITE_DATA(file, NodeCount);

	if (!RootNode->Save(file))
	{
		return false;
	}

	FILE_WRITE_DATA(file, BoneCount);

	for (SBone* bone : Skeleton)
	{
		if (!bone->Save(file))
		{
			return false;
		}
	}

	size_t materialCount = MaterialNames.size();
	FILE_WRITE_DATA(file, materialCount);

	for (std::string& materialName : MaterialNames)
	{
		const char* str = materialName.c_str();
		file.write(str, strlen(str) + 1);
	}

	file.flush();
	file.close();

	return true;
}

SModel* SModel::Load(std::string path)
{
	std::ifstream file(path, std::ios::in | std::ios::binary);

	if (!file.is_open())
	{
		return nullptr;
	}

	char header[6];
	file.read(header, 6);
	const char* headerExpected = "bbmod";

	if (std::strcmp(header, headerExpected) != 0)
	{
		file.close();
		return nullptr;
	}

	uint8_t version;
	FILE_READ_DATA(file, version);

	if (version != BBMOD_VERSION)
	{
		file.close();
		return nullptr;
	}

	SModel* model = new SModel();

	SVertexFormat* vertexFormat = SVertexFormat::Load(file);
	model->VertexFormat = vertexFormat;

	size_t meshCount;
	FILE_READ_DATA(file, meshCount);

	for (size_t i = 0; i < meshCount; ++i)
	{
		SMesh* mesh = SMesh::Load(file, vertexFormat);
		model->Meshes.push_back(mesh);
	}

	FILE_READ_DATA(file, model->NodeCount);

	model->RootNode = SNode::Load(file);

	FILE_READ_DATA(file, model->BoneCount);

	for (size_t i = 0; i < model->BoneCount; ++i)
	{
		SBone* bone = SBone::Load(file);
		model->Skeleton.push_back(bone);
	}

	size_t materialCount;
	FILE_READ_DATA(file, materialCount);

	for (size_t i = 0; i < materialCount; ++i)
	{
		std::string materialName;
		std::getline(file, materialName, '\0');
		model->MaterialNames.push_back(materialName);
	}

	file.close();
	return model;
}

bool SModel::NodeIsImportant(std::string name) const
{
	return true;
}
