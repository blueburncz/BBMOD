#include "BBMOD_Model.hpp"

static BBMOD_Node* CollectNodes(BBMOD_Model* model, aiNode* nodeCurrent)
{
	BBMOD_Node* node = new BBMOD_Node();
	node->Name = nodeCurrent->mName.C_Str();

	if (BBMOD_Bone* bone = model->FindBoneByName(node->Name))
	{
		node->Index = bone->Index;
		node->IsBone = true;
	}
	else
	{
		node->Index = model->NodeCount++;
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

BBMOD_Model* BBMOD_Model::FromAssimp(aiScene* scene, const BBMODConfig& config)
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
						bone->Index = model->BoneCount++;
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
	model->MaterialCount = scene->mNumMaterials;

	for (size_t i = 0; i < scene->mNumMaterials; ++i)
	{
		aiMaterial* materialCurrent = scene->mMaterials[i];
		model->MaterialNames.push_back(materialCurrent->GetName().C_Str());
	}

	return model;
}
