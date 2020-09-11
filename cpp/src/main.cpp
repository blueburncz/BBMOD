#ifndef _WINDLL

#include "bbmod.hpp"
#include "terminal.hpp"
#include <iostream>
#include <filesystem>
#include <string>
#include <regex>

const char* gUsage = "Usage: BBMOD.exe [-h] input_file [output_file] [args...]";

#define PRINT_BOOL(b) (b ? "true" : "false")

void PrintHelp()
{
	BBMODConfig config;

	std::cout
		<< gUsage << std::endl
		<< std::endl
		<< "Arguments:" << std::endl
		<< std::endl
		<< "  -h                         Show this help message and exit." << std::endl
		<< "  input_file                 Path to the model to convert." << std::endl
		<< "  output_file                Where to save the converted model. If not specified, " << std::endl
		<< "                             then the input file path is used. Extensions .bbmod" << std::endl
		<< "                             and .bbanim are added automatically." << std::endl
		<< "  -db/--disable-bone=true    Disable saving bones and animations." << std::endl
		<< "                             Default is " << PRINT_BOOL(config.disableBones) << "." << std::endl
		<< "  -dc/--disable-color=true   Disable saving vertex colors." << std::endl
		<< "                             Default is " << PRINT_BOOL(config.disableVertexColors) << "." << std::endl
		<< "  -dn/--disable-normal=true  Disable saving normal vectors. This also automatically" << std::endl
		<< "                             applies --disable-tangent." << std::endl
		<< "                             Default is " << PRINT_BOOL(config.disableNormals) << "." << std::endl
		<< "  -dt/--disable-tangent=true Disable saving tangent vectors and bitangent signs." << std::endl
		<< "                             Default is " << PRINT_BOOL(config.disableTangentW) << "." << std::endl
		<< "  -duv/--disable-uv=true     Disable saving texture coordinates." << std::endl
		<< "                             Default is " << PRINT_BOOL(config.disableTextureCoords) << "." << std::endl
		<< "  -fuvx/--flip-uv-x=true     Flip texture coordinates horizontally." << std::endl
		<< "                             Default is " << PRINT_BOOL(config.flipTextureHorizontally) << "." << std::endl
		<< "  -fuvy/--flip-uv-y=true     Flip texture coordinates vertically." << std::endl
		<< "                             Default is " << PRINT_BOOL(config.flipTextureVertically) << "." << std::endl
		<< "  -iw/--invert-winding=true  Invert winding order of vertices." << std::endl
		<< "                             Default is " << PRINT_BOOL(config.invertWinding) << "." << std::endl
		<< "  -lh/--left-handed=true     Convert to left-handed coordinate system." << std::endl
		<< "                             Default is " << PRINT_BOOL(config.leftHanded) << "." << std::endl
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
	BBMODConfig config;

	std::regex options_regex("(-[a-z]+|--[a-z\-]+)=(true|false)");
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
				bool b = (match[2] == "true");

				if (o == "-lh" || o == "--left-handed")
				{
					config.leftHanded = b;
				}
				else if (o == "-iw" || o == "--invert-winding")
				{
					config.invertWinding = b;
				}
				else if (o == "-dn" || o == "--disable-normal")
				{
					config.disableNormals = b;
					config.disableTangentW = b;
				}
				else if (o == "-duv"|| o == "--disable-uv")
				{
					config.disableTextureCoords = b;
				}
				else if (o == "-fuvx" || o == "--flip-uv-x")
				{
					config.flipTextureHorizontally = b;
				}
				else if (o == "-fuvy" || o == "--flip-uv-y")
				{
					config.flipTextureVertically = b;
				}
				else if (o == "-dc" || o == "--disable-color")
				{
					config.disableVertexColors = b;
				}
				else if (o == "-dt" || o == "--disable-tangent")
				{
					config.disableTangentW = b;
				}
				else if (o == "-db" || o == "--disable-bone")
				{
					config.disableBones = b;
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
		switch (retval)
		{
		case BBMOD_ERR_LOAD_FAILED:
			PRINT_ERROR("Could not load the model!");
			break;

		case BBMOD_ERR_CONVERSION_FAILED:
			PRINT_ERROR("Model conversion failed!");
			break;

		case BBMOD_ERR_SAVE_FAILED:
			PRINT_ERROR("Could not save the model to \"%s\"!", fout);
			break;

		default:
			break;
		}

		return EXIT_FAILURE;
	}

	PRINT_SUCCESS("Model saved to \"%s\"!", fout);

	return EXIT_SUCCESS;
}

#endif // _WINDLL