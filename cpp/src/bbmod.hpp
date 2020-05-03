#pragma once

/** The version of created BBMOD files. */
#define BBMOD_VERSION 1

/** A code returned when a model is successfully converted. */
#define BBMOD_SUCCESS 0

/** An error code returned when model loading fails. */
#define BBMOD_ERR_LOAD_FAILED 1

/** An error code returned when model conversion fails. */
#define BBMOD_ERR_CONVERSION_FAILED 2

/** An error code returned when converted model is not saved. */
#define BBMOD_ERR_SAVE_FAILED 3

/** Configuration structure. */
struct BBMODConfig
{
	/** Convert model's data to left-handed. */
	bool leftHanded = false;

	/** Invert model's vertex winding order. */
	bool invertWinding = false;
};

/** Converts a model from file fin to BBMOD and saves it to fout. */
int ConvertToBBMOD(const char* fin, const char* fout, const BBMODConfig& config);