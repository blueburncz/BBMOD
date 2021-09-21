#ifndef _WINDLL

#include <BBMOD/Importer.hpp>
#include <terminal.hpp>
#include <iostream>
#include <filesystem>
#include <string>
#include <regex>
#include <cstdlib>

// TODO: Implement class for argument parsing

const char* gUsage = "Usage: BBMOD.exe [-h] input_file [output_file] [args...]";

#define PRINT_BOOL(bValue) (bValue ? "true" : "false")

void PrintHelp()
{
	SConfig config;

	std::cout
		<< gUsage << std::endl
		<< std::endl
		<< "Arguments:" << std::endl
		<< std::endl
		<< "  -h                                   Show this help message and exit." << std::endl
		<< "  input_file                           Path to the model to convert." << std::endl
		<< "  output_file                          Where to save the converted model. If not specified, " << std::endl
		<< "                                       then the input file path is used. Extensions .bbmod" << std::endl
		<< "                                       and .bbanim are added automatically." << std::endl
		<< "  -db|--disable-bone=true|false        Enable/disable saving bones and animations." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.DisableBones) << "." << std::endl
		<< "  -dc|--disable-color=true|false       Enable/disable saving vertex colors." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.DisableVertexColors) << "." << std::endl
		<< "  -dn|--disable-normal=true|false      Enable/disable saving normal vectors. This also automatically" << std::endl
		<< "                                       applies --disable-tangent." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.DisableNormals) << "." << std::endl
		<< "  -dt|--disable-tangent=true|false     Enable/disable saving tangent vectors and bitangent signs." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.DisableTangentW) << "." << std::endl
		<< "  -duv|--disable-uv=true|false         Enable/disable saving texture coordinates." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.DisableTextureCoords) << "." << std::endl
		<< "  -fn|--flip-normal=true|false         Enable/disable flipping normal vectors." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.FlipNormals) << "." << std::endl
		<< "  -fuvx|--flip-uv-x=true|false         Enable/disable flipping texture coordinates horizontally." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.FlipTextureHorizontally) << "." << std::endl
		<< "  -fuvy|--flip-uv-y=true|false         Enable/disable flipping texture coordinates vertically." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.FlipTextureVertically) << "." << std::endl
		<< "  -gn|--gen-normal=0|1|2               Enable/disable generating normal vectors if the model doesn't have any." << std::endl
		<< "                                         * 0 - Do not generate any normal vectors." << std::endl
		<< "                                         * 1 - Generate flat normal vectors." << std::endl
		<< "                                         * 2 - Generate smooth normal vectors." << std::endl
		<< "                                       Default is " << config.GenNormals << "." << std::endl
		<< "  -iw|--invert-winding=true|false      Invert winding order of vertices." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.InvertWinding) << "." << std::endl
		<< "  -lh|--left-handed=true|false         Convert to left-handed coordinate system." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.LeftHanded) << "." << std::endl
		<< "  -oa|--optimize-animations=0|1|2      Optimize animations." << std::endl
		<< "                                         * 0 - No optimizations (node transform in world-space)." << std::endl
		<< "                                         * 1 - Node transform in parent-space." << std::endl
		<< "                                         * 2 - Node transform in bone-space." << std::endl
		<< "                                       Default is " << config.AnimationOptimization << "." << std::endl
		<< "  -on|--optimize-nodes=true|false      Join multiple nodes (without animations, bones, ...) into one." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.OptimizeNodes) << "." << std::endl
		<< "  -ome|--optimize-meshes=true|false    Join multiple meshes with the same material into one." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.OptimizeMeshes) << "." << std::endl
		<< "  -oma|--optimize-materials=true|false Join redundant materials into one and remove unused materials." << std::endl
		<< "                                       Default is " << PRINT_BOOL(config.OptimizeMaterials) << "." << std::endl
		<< "  -sr|--sampling-rate=fps              Configure the sampling rate (frames per second) of animations." << std::endl
		<< "                                       Default is " << config.SamplingRate << "." << std::endl
		<< std::endl;
}

int main(int argc, const char* argv[])
{
	if (!InitTerminal())
	{
		return EXIT_FAILURE;
	}

	const char* fin = NULL;
	const char* fout = NULL;
	bool showHelp = false;
	SConfig config;

	std::regex options_regex("(-[a-z]+|--[a-z\\-]+)=(true|false|[0-9]+)");
	std::cmatch match;

	for (int i = 1; i < argc; ++i)
	{
		if (*argv[i] == '-')
		{
			if (strcmp(argv[i], "-h") == 0)
			{
				PrintHelp();
				return EXIT_SUCCESS;
			}
			else if (std::regex_match(argv[i], match, options_regex))
			{
				auto o = match[1];
				bool bValue = (match[2] == "true");
				size_t iValue = (size_t)strtol(match[2].str().c_str(), (char**)NULL, 10);

				if (o == "-lh" || o == "--left-handed")
				{
					config.LeftHanded = bValue;
				}
				else if (o == "-iw" || o == "--invert-winding")
				{
					config.InvertWinding = bValue;
				}
				else if (o == "-dn" || o == "--disable-normal")
				{
					config.DisableNormals = bValue;
					config.DisableTangentW = bValue;
				}
				else if (o == "-fn" || o == "--flip-normal")
				{
					config.FlipNormals = bValue;
				}
				else if (o == "-gn" || o == "--gen-normal")
				{
					config.GenNormals = iValue;
				}
				else if (o == "-duv"|| o == "--disable-uv")
				{
					config.DisableTextureCoords = bValue;
				}
				else if (o == "-fuvx" || o == "--flip-uv-x")
				{
					config.FlipTextureHorizontally = bValue;
				}
				else if (o == "-fuvy" || o == "--flip-uv-y")
				{
					config.FlipTextureVertically = bValue;
				}
				else if (o == "-dc" || o == "--disable-color")
				{
					config.DisableVertexColors = bValue;
				}
				else if (o == "-dt" || o == "--disable-tangent")
				{
					config.DisableTangentW = bValue;
				}
				else if (o == "-db" || o == "--disable-bone")
				{
					config.DisableBones = bValue;
				}
				else if (o == "-oa" || o == "--optimize-animations")
				{
					config.AnimationOptimization = iValue;
				}
				else if (o == "-on" || o == "--optimize-nodes")
				{
					config.OptimizeNodes = bValue;
				}
				else if (o == "-ome" || o == "--optimize-meshes")
				{
					config.OptimizeMeshes = bValue;
				}
				else if (o == "-oma" || o == "--optimize-materials")
				{
					config.OptimizeMaterials = bValue;
				}
				else if (o == "-sr" || o == "--sampling-rate")
				{
					config.SamplingRate = (double)((iValue < 1) ? 1 : iValue);
				}
				else
				{
					PRINT_ERROR("Unrecognized option %s!", argv[i]);
					return EXIT_FAILURE;
				}
			}
			else
			{
				PRINT_ERROR("Unrecognized option %s!", argv[i]);
				return EXIT_FAILURE;
			}
		}
		else
		{
			if (!fin)
			{
				fin = argv[i];
			}
			else if (!fout)
			{
				fout = argv[i];
			}
			else
			{
				PRINT_ERROR("Too many arguments!");
				std::cout << std::endl << gUsage << std::endl;
				return EXIT_FAILURE;
			}
		}
	}

	if (!fin)
	{
		PRINT_ERROR("Input file not specified!");
		std::cout << std::endl << gUsage << std::endl;
		return EXIT_FAILURE;
	}

	const char* foutArg = (fout) ? fout : fin;
	std::string foutPath = std::filesystem::path(foutArg).replace_extension(".bbmod").string();
	fout = foutPath.c_str();

	int retval = ConvertToBBMOD(fin, fout, config);

	if (retval != BBMOD_SUCCESS)
	{
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}

#endif // _WINDLL
