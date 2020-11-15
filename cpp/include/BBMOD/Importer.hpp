#pragma once

#include <BBMOD/common.hpp>
#include <BBMOD/Config.hpp>
#include <BBMOD/Model.hpp>
#include <BBMOD/Animation.hpp>

#include <vector>

/** A code returned on fail, when none of BBMOD_ERR_ is applicable. */
#define BBMOD_FAILURE -1

/** A code returned when a model is successfully converted. */
#define BBMOD_SUCCESS 0

/** An error code returned when model loading fails. */
#define BBMOD_ERR_LOAD_FAILED 1

/** An error code returned when model conversion fails. */
#define BBMOD_ERR_CONVERSION_FAILED 2

/** An error code returned when converted model is not saved. */
#define BBMOD_ERR_SAVE_FAILED 3

struct SImportResult
{
	SModel* Model = nullptr;

	std::vector<SAnimation*> Animations;
};

struct SImporter
{
	int Import(const char* file, SImportResult& result);

	SConfig config;
};

int ConvertToBBMOD(const char* fin, const char* fout, const SConfig& config);
