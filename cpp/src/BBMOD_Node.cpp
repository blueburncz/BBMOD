#include "BBMOD_Node.hpp"
#include "utils.hpp"

bool BBMOD_Node::Save(std::ofstream& file)
{
	const char* str = Name.c_str();
	file.write(str, strlen(str) + 1);

	FILE_WRITE_DATA(file, Index);
	FILE_WRITE_DATA(file, IsBone);
	FILE_WRITE_MATRIX(file, TransformMatrix);

	size_t meshCount = Meshes.size();
	FILE_WRITE_DATA(file, meshCount);

	for (size_t meshIndex : Meshes)
	{
		FILE_WRITE_DATA(file, meshIndex);
	}

	size_t childCount = Children.size();
	FILE_WRITE_DATA(file, childCount);
	
	for (BBMOD_Node* child : Children)
	{
		if (!child->Save(file))
		{
			return false;
		}
	}

	return true;
}
