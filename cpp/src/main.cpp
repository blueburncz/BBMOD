#include "bbmod.hpp"
#include "terminal.hpp"
#include <iostream>
#include <filesystem>
#include <string>

const char* gUsage = "Usage: BBMOD.exe [-h] input_file [output_file] [-lh]";

void PrintHelp()
{
	std::cout
		<< gUsage << std::endl
		<< std::endl
		<< "Arguments:" << std::endl
		<< std::endl
		<< "  -h           Shows this help message." << std::endl
		<< "  input_file   Path to the model to convert." << std::endl
		<< "  output_file  Where to save the converted model. If not specified, " << std::endl
		<< "               then the input file path is used. Extensions .bbmod" << std::endl
		<< "               and .bbanim are added automatically." << std::endl
		<< "  -lh          Convert to left-handed coordinate system." << std::endl
		<< "  -iw          Invert winding order of vertices." << std::endl
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
	bool leftHanded = false;
	bool invertWinding = false;

	for (int i = 1; i < argc; ++i)
	{
		if (*argv[i] == '-')
		{
			if (strcmp(argv[i], "-h") == 0)
			{
				PrintHelp();
				return EXIT_SUCCESS;
			}
			else if (strcmp(argv[i], "-lh") == 0)
			{
				leftHanded = true;
			}
			else if (strcmp(argv[i], "-iw") == 0)
			{
				invertWinding = true;
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

	int retval = ConvertToBBMOD(fin, fout, leftHanded, invertWinding);

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
