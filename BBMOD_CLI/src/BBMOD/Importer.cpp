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

static std::string GetFilename(const char* out, const char* name, const char* extension, bool prefix)
{
	std::string fname = prefix ? (std::filesystem::path(out).stem().string() + "_") : "";
	fname.append(name);
	StringReplaceUnsafe(fname);
	return std::filesystem::path(out).parent_path().append(fname.append(extension)).string();
	//return std::filesystem::path(out).replace_filename(fname.c_str()).replace_extension(extension).string();
}

static std::string GetAnimationFilename(SAnimation* animation, int index, const char* out, bool prefix)
{
	std::string animationName = animation->Name;
	std::regex pattern("\\|?(Armature|mixamo.com)\\|?");
	animationName = std::regex_replace(animationName, pattern, "");

	if (animationName.size() == 0)
	{
		animationName.append("anim");
		animationName.append(std::to_string(index));
	}

	return GetFilename(out, animationName.c_str(), ".bbanim", prefix);
}

static void LogNode(std::ofstream& log, SModel* model, SNode* node, uint32_t indent)
{
	for (uint32_t i = 0; i < indent * 4; ++i) { log << " "; }
	log << (int)node->Index << ": " << node->Name;
	if (node->IsBone)
	{
		log << " [bone]";
	}
	if (!node->Meshes.empty())
	{
		log << ":" << std::endl;
		for (uint32_t m = 0; m < node->Meshes.size(); ++m)
		{
			for (uint32_t i = 0; i < (indent + 1) * 4; ++i) { log << " "; }
			log << "* Mesh " << m << " [";
			
			SVertexFormat* vformat = model->Meshes[node->Meshes[m]]->VertexFormat;
			if (vformat->Vertices) { log << "V,"; }
			if (vformat->Normals) { log << "N,"; }
			if (vformat->TextureCoords) { log << "UV,"; }
			if (vformat->TextureCoords2) { log << "UV2,"; }
			if (vformat->Colors) { log << "C,"; }
			if (vformat->TangentW) { log << "T,"; }
			if (vformat->Bones) { log << "B,"; }
			if (vformat->Ids) { log << "I,"; }
			log << "]" << std::endl;
		}
	}
	log << std::endl;
	++indent;
	for (SNode* child : node->Children)
	{
		LogNode(log, model, child, indent);
	}
}

int ConvertToBBMOD(const char* fin, const char* fout, const SConfig& config)
{
	std::filesystem::path pathOut(fout);

	if (std::filesystem::is_directory(pathOut))
	{
		std::filesystem::path pathIn(fin);
		pathOut /= pathIn.filename();
	}

	pathOut = pathOut.replace_extension(".bbmod");
	std::string pathOutStr = pathOut.string();
	fout = pathOutStr.c_str();

	std::ofstream log(GetFilename(fout, "log", ".txt", config.Prefix), std::ios::out);

	Assimp::Importer* importer = new Assimp::Importer();
	//importer->SetPropertyBool(AI_CONFIG_IMPORT_FBX_PRESERVE_PIVOTS, false);

	int flags = (0
		| aiProcess_PopulateArmatureData
		| aiProcess_Triangulate
		| aiProcess_CalcTangentSpace
		| aiProcess_LimitBoneWeights
		| aiProcess_GenUVCoords
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

	if (config.PreTransform)
	{
		flags |= aiProcess_PreTransformVertices;
	}

	if (config.ApplyScale)
	{
		flags |= aiProcess_GlobalScale;
	}

	const aiScene* scene = importer->ReadFile(fin, flags);

	if (!scene)
	{
		delete importer;
		PRINT_ERROR("Failed to load the model!");
		return BBMOD_ERR_LOAD_FAILED;
	}

	if (config.ConvertToZUp)
	{
		aiMatrix4x4 matrixZUp(
			1.0f, 0.0f, 0.0f, 0.0f,
			0.0f, 0.0f, -1.0f, 0.0f,
			0.0f, 1.0f, 0.0f, 0.0f,
			0.0f, 0.0f, 0.0f, 1.0f
		);
		scene->mRootNode->mTransformation *= matrixZUp;
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

	/*log << "Vertex format:" << std::endl;
	log << "==============" << std::endl;
	SVertexFormat* vformat = model->VertexFormat;
	if (vformat->Vertices) { log << "Position 3D" << std::endl; }
	if (vformat->Normals) { log << "Normal" << std::endl; }
	if (vformat->TextureCoords) { log << "Texture coords" << std::endl; }
	if (vformat->Colors) { log << "Color" << std::endl; }
	if (vformat->TangentW) { log << "Tangent & bitangent sign" << std::endl; }
	if (vformat->Bones) { log << "Bone indices and weights" << std::endl; }
	if (vformat->Ids) { log << "Ids" << std::endl; }
	log << std::endl;*/

	log << "Nodes:" << std::endl;
	log << "======" << std::endl;
	LogNode(log, model, model->RootNode, 0);
	log << std::endl;

	if (model->BoneCount > 128)
	{
		PRINT_WARNING(
			"This model has %d bones, but the default upper limit defined in shader BBMOD_ShDefaultAnimated is 128!"
			" You will need to increase this limit in order to render this model, though be aware that the maximum"
			" number of vertex shader uniforms is determined by the target platform! Setting it higher than 128 can"
			" make your game incompatible with some devices!"
			, model->BoneCount);

		log << "WARNING:" << std::endl
			<< "========" << std::endl
			<< "This model has " << model->BoneCount << " bones, but the default upper limit defined in shader BBMOD_ShDefaultAnimated is 128!" << std::endl
			<< "You will need to increase this limit in order to render this model, though be aware that the maximum" << std::endl
			<< "number of vertex shader uniforms is determined by the target platform! Setting it higher than 128 can" << std::endl
			<< "make your game incompatible with some devices!" << std::endl << std::endl;
	}

	log << "Materials:" << std::endl;
	log << "==========" << std::endl;
	for (uint32_t i = 0; i < model->MaterialNames.size(); ++i)
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

				std::string fname = GetAnimationFilename(animation, i, fout, config.Prefix);
	
				if (!animation->Save(fname, config))
				{
					PRINT_ERROR("Could not save an animation to \"%s\"!", fname.c_str());
					return BBMOD_ERR_SAVE_FAILED;
				}

				PRINT_SUCCESS("Animation saved to \"%s\"!", fname.c_str());
			}
		}
	}

	// Write materials
	if (config.ExportMaterials)
	{
		for (int i = 0; i < scene->mNumMaterials; ++i)
		{
			aiMaterial* mat = scene->mMaterials[i];
			const char* matName = mat->GetName().C_Str();
			std::string matFout = GetFilename(fout, matName, ".bbmat", config.Prefix);

			aiColor3D matColor(1.0f, 1.0f, 1.0f);
			mat->Get(AI_MATKEY_COLOR_DIFFUSE, matColor);

			float matOpacity = 1.0f;
			mat->Get(AI_MATKEY_OPACITY, matOpacity);

			std::string matBaseOpacity;
			std::string matNormalRoughness;
			std::string matMetallicAO;
			std::string matSpecularColor;
			std::string matNormalSmoothness;
			std::string matEmissive;
			std::string matSubsurface;
			std::string matLightmap;

			const aiMaterialProperty* prop;

			// Try to get the diffuse texture
			if (aiGetMaterialProperty(mat, AI_MATKEY_TEXTURE_DIFFUSE(0), &prop) == AI_SUCCESS
				&& prop->mType == aiPTI_String)
			{
				aiString s;
				aiGetMaterialString(mat, prop->mKey.data, prop->mSemantic, prop->mIndex, &s);
				std::string str(s.C_Str());
				if (str[0] != '*')
				{
					std::replace(str.begin(), str.end(), '\\', '/');
					matBaseOpacity = str;
				}
			}

			// Try to get other textures from their naming conventions
			for (int j = 0; j < mat->mNumProperties; ++j)
			{
				prop = mat->mProperties[j];

				if (prop->mKey != aiString(_AI_MATKEY_TEXTURE_BASE))
				{
					continue;
				}

				aiString s;
				aiGetMaterialString(mat, prop->mKey.data, prop->mSemantic, prop->mIndex, &s);

				std::string str(s.C_Str());
				std::replace(str.begin(), str.end(), '\\', '/');

				std::string strLower(str);
				std::transform(strLower.begin(), strLower.end(), strLower.begin(),
					[](unsigned char c){ return std::tolower(c); });
				std::string fname = std::filesystem::path(strLower).filename().string();

				if (fname.rfind("normalroughness") != std::string::npos)
				{
					matNormalRoughness = str;
				}
				else if (fname.rfind("metallicao") != std::string::npos)
				{
					matMetallicAO = str;
				}
				else if (fname.rfind("normalsmoothness") != std::string::npos)
				{
					matNormalSmoothness = str;
				}
				else if (fname.rfind("specular") != std::string::npos)
				{
					matSpecularColor = str;
				}
				else if (fname.rfind("emissive") != std::string::npos)
				{
					matEmissive = str;
				}
				else if (fname.rfind("subsurface") != std::string::npos)
				{
					matSubsurface = str;
				}
				else if (fname.rfind("lightmap") != std::string::npos)
				{
					matLightmap = str;
				}
			}

			std::ofstream bbmat(matFout, std::ios::out);

			bbmat << "{\n";
			bbmat << "    \"__MaterialName\": \"BBMOD_MATERIAL_DEFAULT" << (!matLightmap.empty() ? "_LIGHTMAP" : "") << "\",\n";
			bbmat << "    \"RenderQueue\": \"Default\"";

			bbmat << ",\n    \"BaseOpacityMultiplier\": {\n";
			bbmat << "        \"Red\": " << matColor.r * 255.0f << ",\n";
			bbmat << "        \"Green\": " << matColor.g * 255.0f  << ",\n";
			bbmat << "        \"Blue\": " << matColor.b * 255.0f  << ",\n";
			bbmat << "        \"Alpha\": " << matOpacity << "\n";
			bbmat << "    }";

			// bbmat << "    \"BlendMode\": \"bm_normal\",\n";
			// bbmat << "    \"Culling\": \"cull_counterclockwise\",\n";
			// bbmat << "    \"ZWrite\": " << "true" << ",\n";
			// bbmat << "    \"ZTest\": " << "true" << ",\n";
			// bbmat << "    \"ZFunc\": \"cmpfunc_lessequal\",\n";
			// bbmat << "    \"AlphaTest\": " << 1.0f << ",\n";
			// bbmat << "    \"AlphaBlend\": " << "false" << ",\n";
			// bbmat << "    \"Filtering\": " << "true" << ",\n";
			// bbmat << "    \"Mipmapping\": " << "mip_on" << ",\n"; // TODO: __bbmod_mipmapping
			// bbmat << "    \"Repeat\": " << "false" << ",\n";
			// bbmat << "    \"TextureOffset\": {\n";
			// bbmat << "        \"X\": " << 0.0f << ",\n";
			// bbmat << "        \"Y\": " << 0.0f << "\n";
			// bbmat << "    },\n";
			// bbmat << "    \"TextureScale\": {\n";
			// bbmat << "        \"X\": " << 1.0f << ",\n";
			// bbmat << "        \"Y\": " << 1.0f << "\n";
			// bbmat << "    },\n";
			// bbmat << "    \"ShadowmapBias\": " << 0.0f << ",\n";

			bbmat << ",\n    \"Shaders\": {\n";
			bbmat << "        \"Shadows\": \"BBMOD_SHADER_DEFAULT_DEPTH\",\n";
			bbmat << "        \"DepthOnly\": \"BBMOD_SHADER_DEFAULT_DEPTH\",\n";
			bbmat << "        \"Id\": \"BBMOD_SHADER_INSTANCE_ID\"\n";
			bbmat << "    }";

			if (!matBaseOpacity.empty()
				|| !matNormalRoughness.empty()
				|| !matMetallicAO.empty()
				|| !matNormalSmoothness.empty()
				|| !matSpecularColor.empty()
				|| !matEmissive.empty()
				|| !matSubsurface.empty()
				|| !matLightmap.empty())
			{
				bbmat << ",\n    \"__Textures\": {";

				bool hasPrev = false;
				if (!matBaseOpacity.empty())
				{
					bbmat << "\n        \"BaseOpacity\": \"" << matBaseOpacity << "\"";
					hasPrev = true;
				}

				if (!matNormalRoughness.empty())
				{
					if (hasPrev) { bbmat << ","; }
					bbmat << "\n        \"NormalRoughness\": \"" << matNormalRoughness << "\"";
					hasPrev = true;
				}

				if (!matMetallicAO.empty())
				{
					if (hasPrev) { bbmat << ","; }
					bbmat << "\n        \"MetallicAO\": \"" << matMetallicAO << "\"";
					hasPrev = true;
				}
				
				if (!matNormalSmoothness.empty())
				{
					if (hasPrev) { bbmat << ","; }
					bbmat << "\n        \"NormalSmoothness\": \"" << matNormalSmoothness << "\"";
					hasPrev = true;
				}

				if (!matSpecularColor.empty())
				{
					if (hasPrev) { bbmat << ","; }
					bbmat << "\n        \"SpecularColor\": \"" << matSpecularColor << "\"";
					hasPrev = true;
				}

				if (!matEmissive.empty())
				{
					if (hasPrev) { bbmat << ","; }
					bbmat << "\n        \"Emissive\": \"" << matEmissive << "\"";
					hasPrev = true;
				}

				if (!matSubsurface.empty())
				{
					if (hasPrev) { bbmat << ","; }
					bbmat << "\n        \"Subsurface\": \"" << matSubsurface << "\"";
					hasPrev = true;
				}

				if (!matLightmap.empty())
				{
					if (hasPrev) { bbmat << ","; }
					bbmat << "\n        \"Lightmap\": \"" << matLightmap << "\"";
					hasPrev = true;
				}

				bbmat << "\n    }";
			}

			bbmat << "\n}\n";

			PRINT_SUCCESS("Material saved to \"%s\"!", matFout.c_str());

			bbmat.flush();
			bbmat.close();
		}
	}

	log.flush();
	log.close();

	return BBMOD_SUCCESS;
}
