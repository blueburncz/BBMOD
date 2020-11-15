#include <BBMOD/Node.hpp>
#include <utils.hpp>
#include <iostream>

bool SNode::Save(std::ofstream& file)
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
	
	for (SNode* child : Children)
	{
		if (!child->Save(file))
		{
			return false;
		}
	}

	return true;
}

SNode* SNode::Load(std::ifstream& file)
{
	SNode* node = new SNode();

	std::string name;
	std::getline(file, name, '\0');
	node->Name = name;

	FILE_READ_DATA(file, node->Index);
	FILE_READ_DATA(file, node->IsBone);
	FILE_READ_MATRIX(file, node->TransformMatrix);

	size_t meshCount;
	FILE_READ_DATA(file, meshCount);

	for (size_t i = 0; i < meshCount; ++i)
	{
		size_t meshIndex;
		FILE_READ_DATA(file, meshIndex);
		node->Meshes.push_back(meshIndex);
	}

	size_t childCount;
	FILE_READ_DATA(file, childCount);

	for (size_t i = 0; i < childCount; ++i)
	{
		SNode* child = SNode::Load(file);
		node->Children.push_back(child);
	}

	return node;
}
