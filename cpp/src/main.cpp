#include "bbmod.hpp"
#include "terminal.h"
#include <iostream>
#include <filesystem>
#include <string>

int main(int argc, const char* argv[])
{
	const char* usage = "Usage: BBMOD.exe [-h] input_file [output_file]";

	if (argc < 2)
	{
		PRINT_ERROR("Input file not specified!");
		std::cout << std::endl << usage << std::endl;
		return EXIT_FAILURE;
	}

	const char* fin = argv[1];

	if (strcmp(fin, "-h") == 0)
	{
		std::cout
			<< usage << std::endl
			<< std::endl
			<< "Arguments:" << std::endl
			<< std::endl
			<< "  -h           Shows this help message." << std::endl
			<< "  input_file   Path to the model to convert." << std::endl
			<< "  output_file  Where to save the converted model. If not specified, " << std::endl
			<< "               then the input file path is used. Extensions .bbmod" << std::endl
			<< "               and .bbanim are added automatically." << std::endl
			<< std::endl;
		return EXIT_SUCCESS;
	}

	const char* foutArg = (argc > 2) ? argv[2] : fin;
	std::string foutPath = std::filesystem::path(foutArg).replace_extension(".bbmod").string();
	const char* fout = foutPath.c_str();

	int retval = ConvertToBBMOD(fin, fout);

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
