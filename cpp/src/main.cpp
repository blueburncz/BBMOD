#ifndef _WINDLL

#include "bbmod.hpp"
#include "terminal.hpp"
#include <iostream>
#include <filesystem>
#include <string>

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

	for (int i = 1; i < argc; ++i)
	{
		if (*argv[i] == '-')
		{
			if (strcmp(argv[i], "-h") == 0)
			{
				PrintHelp();
				return EXIT_SUCCESS;
			}
			else if (strcmp(argv[i], "-lh=true") == 0 || strcmp(argv[i], "--left-handed=true") == 0)
			{
				config.leftHanded = true;
			}
			else if (strcmp(argv[i], "-lh=false") == 0 || strcmp(argv[i], "--left-handed=false") == 0)
			{
				config.leftHanded = false;
			}
			else if (strcmp(argv[i], "-iw=true") == 0 || strcmp(argv[i], "--invert-winding=true") == 0)
			{
				config.invertWinding = true;
			}
			else if (strcmp(argv[i], "-iw=false") == 0 || strcmp(argv[i], "--invert-winding=false") == 0)
			{
				config.invertWinding = false;
			}
			else if (strcmp(argv[i], "-dn=true") == 0 || strcmp(argv[i], "--disable-normal=true") == 0)
			{
				config.disableNormals = true;
				config.disableTangentW = true;
			}
			else if (strcmp(argv[i], "-dn=false") == 0 || strcmp(argv[i], "--disable-normal=false") == 0)
			{
				config.disableNormals = false;
				config.disableTangentW = false;
			}
			else if (strcmp(argv[i], "-duv=true") == 0 || strcmp(argv[i], "--disable-uv=true") == 0)
			{
				config.disableTextureCoords = true;
			}
			else if (strcmp(argv[i], "-duv=false") == 0 || strcmp(argv[i], "--disable-uv=false") == 0)
			{
				config.disableTextureCoords = false;
			}
			else if (strcmp(argv[i], "-dc=true") == 0 || strcmp(argv[i], "--disable-color=true") == 0)
			{
				config.disableVertexColors = true;
			}
			else if (strcmp(argv[i], "-dc=false") == 0 || strcmp(argv[i], "--disable-color=false") == 0)
			{
				config.disableVertexColors = false;
			}
			else if (strcmp(argv[i], "-dt=true") == 0 || strcmp(argv[i], "--disable-tangent=true") == 0)
			{
				config.disableTangentW = true;
			}
			else if (strcmp(argv[i], "-dt=false") == 0 || strcmp(argv[i], "--disable-tangent=false") == 0)
			{
				config.disableTangentW = false;
			}
			else if (strcmp(argv[i], "-db=true") == 0 || strcmp(argv[i], "--disable-bone=true") == 0)
			{
				config.disableBones = true;
			}
			else if (strcmp(argv[i], "-db=false") == 0 || strcmp(argv[i], "--disable-bone=false") == 0)
			{
				config.disableBones = false;
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