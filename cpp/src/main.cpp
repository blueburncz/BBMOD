#include "bbmod.hpp"
#include <iostream>
#include <filesystem>
#include <string>

int main(int argc, const char* argv[])
{
	const char* usage = "Usage: BBMOD.exe [-h] input_file [output_file]";

	if (argc < 2)
	{
		std::cout
			<< "Input file not specified!" << std::endl
			<< std::endl
			<< usage << std::endl;
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
			<< "               then the input file with .bbmod extension is used." << std::endl
			<< std::endl;
		return EXIT_SUCCESS;
	}

	const char* foutArg = (argc > 2) ? argv[2] : fin;
	std::string foutPath = std::filesystem::path(foutArg).replace_extension(".bbmod").string();
	const char* fout = foutPath.c_str();

	if (!ConvertToBBMOD(fin, fout))
	{
		std::cout << "Could not convert model!\n" << std::endl;
		return EXIT_FAILURE;
	}

	std::cout << "Saved to \"" << fout << "\"" << std::endl;

	return EXIT_SUCCESS;
}
