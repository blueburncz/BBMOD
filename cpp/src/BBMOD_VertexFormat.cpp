#include "BBMOD_VertexFormat.hpp"
#include "utils.hpp"

bool BBMOD_VertexFormat::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Vertices);
	FILE_WRITE_DATA(file, Normals);
	FILE_WRITE_DATA(file, TextureCoords);
	FILE_WRITE_DATA(file, Colors);
	FILE_WRITE_DATA(file, TangentW);
	FILE_WRITE_DATA(file, Bones);
	FILE_WRITE_DATA(file, Ids);
	return true;
}
