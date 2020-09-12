#include "BBMOD_Model.hpp"
#include "utils.hpp"
#include <fstream>

static BBMOD_Node* CollectNodes(BBMOD_Model* model, aiNode* nodeCurrent)
{
	BBMOD_Node* node = new BBMOD_Node();
	node->Name = nodeCurrent->mName.C_Str();

	if (BBMOD_Bone* bone = model->FindBoneByName(node->Name))
	{
		node->Index = (float)bone->Index;
		node->IsBone = true;
	}
	else
	{
		node->Index = (float)model->NodeCount++;
		node->IsBone = false;
	}

	node->TransformMatrix = nodeCurrent->mTransformation;

	for (size_t i = 0; i < nodeCurrent->mNumMeshes; ++i)
	{
		node->Meshes.push_back(nodeCurrent->mMeshes[i]);
	}

	for (size_t i = 0; i < nodeCurrent->mNumChildren; ++i)
	{
		node->Children.push_back(CollectNodes(model, nodeCurrent->mChildren[i]));
	}

	return node;
}

BBMOD_Model* BBMOD_Model::FromAssimp(const aiScene* scene, const BBMODConfig& config)
{
	BBMOD_Model* model = new BBMOD_Model();
	model->Scene = scene;

	// Resolve vertex format of the model
	aiMesh* mesh = scene->mMeshes[0];

	BBMOD_VertexFormat* vertexFormat = new BBMOD_VertexFormat();
	vertexFormat->Vertices = true;
	vertexFormat->Normals = mesh->HasNormals() && !config.disableNormals;
	vertexFormat->TextureCoords = mesh->HasTextureCoords(0) && !config.disableTextureCoords;
	vertexFormat->Colors = mesh->HasVertexColors(0) && !config.disableVertexColors;
	vertexFormat->TangentW = mesh->HasTangentsAndBitangents() && !(config.disableNormals || config.disableTangentW);

	vertexFormat->Bones = false;

	if (!config.disableBones)
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
						BBMOD_Bone* bone = new BBMOD_Bone();
						bone->Name = boneName;
						bone->Index = (float)model->BoneCount++;
						bone->OffsetMatrix = boneCurrent->mOffsetMatrix;
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
		model->Meshes.push_back(BBMOD_Mesh::FromAssimp(meshCurrent, model, config));
	}

	// Inverse transform matrix
	model->InverseTransformMatrix = scene->mRootNode->mTransformation.Inverse();

	// Nodes
	model->RootNode = CollectNodes(model, scene->mRootNode);
	
	// Materials
	for (size_t i = 0; i < scene->mNumMaterials; ++i)
	{
		aiMaterial* materialCurrent = scene->mMaterials[i];
		model->MaterialNames.push_back(materialCurrent->GetName().C_Str());
	}

	return model;
}

bool BBMOD_Model::Save(std::string path)
{
	std::ofstream file(path, std::ios::out | std::ios::binary);

	if (!file.is_open())
	{
		return false;
	}

	file.write("bbmod", sizeof(char) * 6);
	FILE_WRITE_DATA(file, Version);
	FILE_WRITE_DATA(file, VertexFormat->Vertices);
	FILE_WRITE_DATA(file, VertexFormat->Normals);
	FILE_WRITE_DATA(file, VertexFormat->TextureCoords);
	FILE_WRITE_DATA(file, VertexFormat->Colors);
	FILE_WRITE_DATA(file, VertexFormat->TangentW);
	FILE_WRITE_DATA(file, VertexFormat->Bones);
	FILE_WRITE_DATA(file, VertexFormat->Ids);

	size_t meshCount = Meshes.size();
	FILE_WRITE_DATA(file, meshCount);

	for (BBMOD_Mesh* mesh : Meshes)
	{
		if (!mesh->Save(file))
		{
			return false;
		}
	}

	FILE_WRITE_MATRIX(file, InverseTransformMatrix);

	FILE_WRITE_DATA(file, NodeCount);

	if (!RootNode->Save(file))
	{
		return false;
	}

	FILE_WRITE_DATA(file, BoneCount);

	for (BBMOD_Bone* bone : Skeleton)
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
