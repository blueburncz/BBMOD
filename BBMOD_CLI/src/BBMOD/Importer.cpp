#include <BBMOD/Importer.hpp>
#include <BBMOD/Model.hpp>
#include <BBMOD/Animation.hpp>
#include <terminal.hpp>

#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>

#include <fstream>
#include <iostream>
#include <filesystem>
#include <map>
#include <string>
#include <regex>

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

static std::string GetAnimationFilename(SAnimation* animation, int index, const char* out)
{
	std::string animationName = animation->Name;
	std::regex pattern("\\|?(Armature|mixamo.com)\\|?");
	animationName = std::regex_replace(animationName, pattern, "");

	if (animationName.size() == 0)
	{
		animationName.append("anim");
		animationName.append(std::to_string(index));
	}

	return GetFilename(out, animationName.c_str(), ".bbanim");
}

static void LogNode(std::ofstream& log, SNode* node, size_t indent)
{
	for (size_t i = 0; i < indent * 4; ++i)
	{
		log << " ";
	}
	log << (int)node->Index << ": " << node->Name;
	if (node->IsBone)
	{
		log << " [bone]";
	}
	if (!node->Meshes.empty())
	{
		log << " [" << node->Meshes.size() << " mesh(es)]";
	}
	log << std::endl;
	++indent;
	for (SNode* child : node->Children)
	{
		LogNode(log, child, indent);
	}
}

int ConvertToBBMOD(const char* fin, const char* fout, const SConfig& config)
{
	std::ofstream log(GetFilename(fout, "log", ".txt"), std::ios::out);

	Assimp::Importer* importer = new Assimp::Importer();
	//importer->SetPropertyBool(AI_CONFIG_IMPORT_FBX_PRESERVE_PIVOTS, false);

	int flags = (0
		//aiProcessPreset_TargetRealtime_Quality
		| aiProcess_CalcTangentSpace
		//| aiProcess_GenSmoothNormals
		| aiProcess_JoinIdenticalVertices
		| aiProcess_ImproveCacheLocality
		| aiProcess_LimitBoneWeights
		//| aiProcess_RemoveRedundantMaterials
		| aiProcess_SplitLargeMeshes
		| aiProcess_Triangulate
		| aiProcess_GenUVCoords
		| aiProcess_SortByPType
		| aiProcess_FindDegenerates
		| aiProcess_FindInvalidData
		//
		| aiProcess_TransformUVCoords
		//| aiProcess_OptimizeGraph
		//| aiProcess_OptimizeMeshes
		);

	if (config.GenNormals == BBMOD_NORMALS_FLAT)
	{
		flags |= aiProcess_GenNormals;
	}
	else if (config.GenNormals >= BBMOD_NORMALS_SMOOTH)
	{
		flags |= aiProcess_GenSmoothNormals;
	}

	if (config.OptimizeMaterials)
	{
		flags |= aiProcess_RemoveRedundantMaterials;
	}

	if (config.OptimizeNodes)
	{
		flags |= aiProcess_OptimizeGraph;
	}

	if (config.OptimizeMeshes)
	{
		flags |= aiProcess_OptimizeMeshes;
	}

	if (config.LeftHanded)
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
	SModel* model = SModel::FromAssimp(scene, config);

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

	log << "Vertex format:" << std::endl;
	log << "==============" << std::endl;
	SVertexFormat* vformat = model->VertexFormat;
	if (vformat->Vertices) { log << "Position 3D" << std::endl; }
	if (vformat->Normals) { log << "Normal" << std::endl; }
	if (vformat->TextureCoords) { log << "Texture coords" << std::endl; }
	if (vformat->Colors) { log << "Color" << std::endl; }
	if (vformat->TangentW) { log << "Tangent & bitangent sign" << std::endl; }
	if (vformat->Bones) { log << "Bone indices and weights" << std::endl; }
	if (vformat->Ids) { log << "Ids" << std::endl; }
	log << std::endl;

	log << "Nodes:" << std::endl;
	log << "======" << std::endl;
	LogNode(log, model->RootNode, 0);
	log << std::endl;

	if (model->BoneCount > 64)
	{
		PRINT_WARNING(
			"This model has %d bones, but the default upper limit defined in shader BBMOD_ShDefaultAnimated is 64!"
			" You will need to increase this limit in order to render this model, though be aware that the maximum"
			" number of vertex shader uniforms is determined by the target platform! Setting it higher than 64 can"
			" make your game incompatible with some devices!"
			, model->BoneCount);

		log << "WARNING:" << std::endl
			<< "========" << std::endl
			<< "This model has " << model->BoneCount << " bones, but the default upper limit defined in shader BBMOD_ShDefaultAnimated is 64!" << std::endl
			<< "You will need to increase this limit in order to render this model, though be aware that the maximum" << std::endl
			<< "number of vertex shader uniforms is determined by the target platform! Setting it higher than 64 can" << std::endl
			<< "make your game incompatible with some devices!" << std::endl << std::endl;
	}

	log << "Materials:" << std::endl;
	log << "==========" << std::endl;
	for (size_t i = 0; i < model->MaterialNames.size(); ++i)
	{
		log << i << ": " << model->MaterialNames[i] << std::endl;
	}
	log << std::endl;

	// Write animations
	if (!config.DisableBones)
	{
		uint32_t numOfAnimations = scene->mNumAnimations;

		if (numOfAnimations > 0)
		{
			for (uint32_t i = 0; i < numOfAnimations; ++i)
			{
				SAnimation* animation = SAnimation::FromAssimp(scene->mAnimations[i], model, config);
		
				if (!animation)
				{
					PRINT_ERROR("Failed to convert an animation to BBANIM!");
					return BBMOD_ERR_CONVERSION_FAILED;
				}

				std::string fname = GetAnimationFilename(animation, i, fout);
	
				if (!animation->Save(fname, config))
				{
					PRINT_ERROR("Could not save an animation to \"%s\"!", fname.c_str());
					return BBMOD_ERR_SAVE_FAILED;
				}

				PRINT_SUCCESS("Animation saved to \"%s\"!", fname.c_str());
			}
		}
	}

	log.flush();
	log.close();

	return BBMOD_SUCCESS;
}
