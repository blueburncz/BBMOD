#include "BBMOD_Bone.hpp"
#include "utils.hpp"

bool BBMOD_Bone::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Index);
	FILE_WRITE_MATRIX(file, OffsetMatrix);
	return true;
}
