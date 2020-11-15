#include <BBMOD/Bone.hpp>
#include <utils.hpp>

bool SBone::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Index);
	FILE_WRITE_MATRIX(file, OffsetMatrix);
	return true;
}

SBone* SBone::Load(std::ifstream& file)
{
	SBone* bone = new SBone();
	FILE_READ_DATA(file, bone->Index);
	FILE_READ_MATRIX(file, bone->OffsetMatrix);
	return bone;
}
