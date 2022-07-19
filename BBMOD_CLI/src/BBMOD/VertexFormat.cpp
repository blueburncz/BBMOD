#include <BBMOD/VertexFormat.hpp>
#include <utils.hpp>

bool SVertexFormat::Save(std::ofstream& file)
{
	FILE_WRITE_DATA(file, Vertices);
	FILE_WRITE_DATA(file, Normals);
	FILE_WRITE_DATA(file, TextureCoords);
	FILE_WRITE_DATA(file, TextureCoords2);
	FILE_WRITE_DATA(file, Colors);
	FILE_WRITE_DATA(file, TangentW);
	FILE_WRITE_DATA(file, Bones);
	FILE_WRITE_DATA(file, Ids);
	return true;
}

SVertexFormat* SVertexFormat::Load(std::ifstream& file, uint8_t versionMinor)
{
	SVertexFormat* vertexFormat = new SVertexFormat();
	FILE_READ_DATA(file, vertexFormat->Vertices);
	FILE_READ_DATA(file, vertexFormat->Normals);
	FILE_READ_DATA(file, vertexFormat->TextureCoords);
	if (versionMinor >= 3)
	{
		FILE_READ_DATA(file, vertexFormat->TextureCoords2);
	}
	FILE_READ_DATA(file, vertexFormat->Colors);
	FILE_READ_DATA(file, vertexFormat->TangentW);
	FILE_READ_DATA(file, vertexFormat->Bones);
	FILE_READ_DATA(file, vertexFormat->Ids);
	return vertexFormat;
}
