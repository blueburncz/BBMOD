#ifndef _WINDLL

#include "bbmod.hpp"
#include "terminal.hpp"
#include <iostream>
#include <filesystem>
#include <string>

const char* gUsage = "Usage: BBMOD.exe [-h] input_file [output_file] [args...]";

void PrintHelp()
{
	std::cout
		<< gUsage << std::endl
		<< std::endl
		<< "Arguments:" << std::endl
		<< std::endl
		<< "  -h                     Show this help message and exit." << std::endl
		<< "  input_file             Path to the model to convert." << std::endl
		<< "  output_file            Where to save the converted model. If not specified, " << std::endl
		<< "                         then the input file path is used. Extensions .bbmod" << std::endl
		<< "                         and .bbanim are added automatically." << std::endl
		<< "  -db, --disable-bone    Disable saving bones and animations." << std::endl
		<< "  -dc, --disable-color   Disable saving vertex colors." << std::endl
		<< "  -dn, --disable-normal  Disable saving normal vectors. This also automatically" << std::endl
		<< "                         applies --disable-tangent." << std::endl
		<< "  -dt, --disable-tangent Disable saving tangent vectors and bitangent signs." << std::endl
		<< "  -duv, --disable-uv     Disable saving texture coordinates." << std::endl
		<< "  -iw, --invert-winding  Invert winding order of vertices." << std::endl
		<< "  -lh, --left-handed     Convert to left-handed coordinate system." << std::endl
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
			else if (strcmp(argv[i], "-lh") == 0 || strcmp(argv[i], "--left-handed") == 0)
			{
				config.leftHanded = true;
			}
			else if (strcmp(argv[i], "-iw") == 0 || strcmp(argv[i], "--invert-winding") == 0)
			{
				config.invertWinding = true;
			}
			else if (strcmp(argv[i], "-dn") == 0 || strcmp(argv[i], "--disable-normal") == 0)
			{
				config.disableNormals = true;
				config.disableTangentW = true;
			}
			else if (strcmp(argv[i], "-duv") == 0 || strcmp(argv[i], "--disable-uv") == 0)
			{
				config.disableTextureCoords = true;
			}
			else if (strcmp(argv[i], "-dc") == 0 || strcmp(argv[i], "--disable-color") == 0)
			{
				config.disableVertexColors = true;
			}
			else if (strcmp(argv[i], "-dt") == 0 || strcmp(argv[i], "--disable-tangent") == 0)
			{
				config.disableTangentW = true;
			}
			else if (strcmp(argv[i], "-db") == 0 || strcmp(argv[i], "--disable-bone") == 0)
			{
				config.disableBones = true;
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