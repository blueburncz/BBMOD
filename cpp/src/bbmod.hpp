#pragma once

#include <assimp/scene.h>

/** Writes scene into a latest-version BBMOD file. */
bool ConvertToBBMOD(const char* fin, const char* fout);
