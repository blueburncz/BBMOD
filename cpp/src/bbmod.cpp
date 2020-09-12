#include "bbmod.hpp"
#include "terminal.hpp"
#include "BBMOD_Model.hpp"
#include "BBMOD_Animation.hpp"
#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <fstream>
#include <iostream>
#include <filesystem>
#include <map>
#include <string>

static void StringReplaceUnsafe(std::string& str)
{
	// https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file
	std::transform(str.begin(), str.end(), str.begin(), [](char c) {
		const std::string unsafe = "<>:\"/\\|?*";
		if (unsafe.find(c) != std::string::npos)
		{
			return '_';
		}
		return c;
	});
}

static std::string GetFilename(const char* out, const char* name, const char* extension)
{
	std::string fname = std::filesystem::path(out).stem().string() + "_";
	fname.append(name);
	StringReplaceUnsafe(fname);
	return std::filesystem::path(out).replace_filename(fname.c_str()).replace_extension(extension).string();
}

static std::string GetAnimationFilename(BBMOD_Animation* animation, int index, const char* out)
{
	std::string animationName = "";

	if (animation->Name.size() == 0)
	{
		animationName.append("anim");
		animationName.append(std::to_string(index));
	}
	else
	{
		animationName.append(animation->Name);
	}

	return GetFilename(out, animationName.c_str(), ".bbanim");
}

int ConvertToBBMOD(const char* fin, const char* fout, const BBMODConfig& config)
{
	std::ofstream log(GetFilename(fout, "log", ".txt"), std::ios::out);

	Assimp::Importer* importer = new Assimp::Importer();
	importer->SetPropertyBool(AI_CONFIG_IMPORT_FBX_PRESERVE_PIVOTS, false);

	int flags = (0
		// aiProcessPreset_TargetRealtime_Quality
		| aiProcess_CalcTangentSpace
		| aiProcess_JoinIdenticalVertices
		| aiProcess_ImproveCacheLocality
		| aiProcess_LimitBoneWeights
		| aiProcess_RemoveRedundantMaterials
		| aiProcess_SplitLargeMeshes
		| aiProcess_Triangulate
		| aiProcess_GenUVCoords
		| aiProcess_SortByPType
		| aiProcess_FindDegenerates
		| aiProcess_FindInvalidData
		//
		| aiProcess_TransformUVCoords
		| aiProcess_OptimizeGraph
		| aiProcess_OptimizeMeshes);

	if (config.genNormals == BBMOD_NORMALS_FLAT)
	{
		flags |= aiProcess_GenNormals;
	}
	else if (config.genNormals >= BBMOD_NORMALS_SMOOTH)
	{
		flags |= aiProcess_GenSmoothNormals;
	}

	if (config.leftHanded)
	{
		flags |= aiProcess_ConvertToLeftHanded;
	}

	const aiScene* scene = importer->ReadFile(fin, flags);

	if (!scene)
	{
		delete importer;
		PRINT_ERROR("Failed to load the model!");
		return BBMOD_ERR_LOAD_FAILED;
	}

	// Write BBMOD
	BBMOD_Model* model = BBMOD_Model::FromAssimp(scene, config);

	if (!model)
	{
		PRINT_ERROR("Failed to convert the model to BBMOD!");
		return BBMOD_ERR_CONVERSION_FAILED;
	}

	if (!model->Save(fout))
	{
		PRINT_ERROR("Could not save the model to \"%s\"!", fout);
		return BBMOD_ERR_SAVE_FAILED;
	}

	PRINT_SUCCESS("Model saved to \"%s\"!", fout);

	// Write animations
	if (!config.disableBones)
	{
		uint32_t numOfAnimations = scene->mNumAnimations;

		if (numOfAnimations > 0)
		{
			for (uint32_t i = 0; i < numOfAnimations; ++i)
			{
				BBMOD_Animation* animation = BBMOD_Animation::FromAssimp(scene->mAnimations[i], model);
		
				if (!animation)
				{
					PRINT_ERROR("Failed to convert an animation to BBANIM!");
					return BBMOD_ERR_CONVERSION_FAILED;
				}

				std::string fname = GetAnimationFilename(animation, i, fout);
	
				if (!animation->Save(fname))
				{
					PRINT_ERROR("Could not save an animation to \"%s\"!", fname.c_str());
					return BBMOD_ERR_SAVE_FAILED;
				}

				PRINT_SUCCESS("Animation saved to \"%s\"!", fname.c_str());
			}
		}
	}

	return BBMOD_SUCCESS;
}
