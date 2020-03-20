#pragma once

#include <assimp/scene.h>

/** Converts a model from file fin to BBMOD and saves it to fout. */
bool ConvertToBBMOD(const char* fin, const char* fout);
