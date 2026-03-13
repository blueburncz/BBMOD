#include "PhysicsShape.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

#include <BulletCollision/CollisionShapes/btConvexHullShape.h>

#include <fstream>
#include <vector>

// Binary format for convex hull serialization:
// - Magic: "BBCH" (4 bytes)
// - Version: uint32_t (4 bytes)
// - Vertex count: uint32_t (4 bytes)
// - Vertices: array of btVector3 (vertexCount * 3 * 8 bytes for doubles)
// - Margin: double (8 bytes)

static const char MAGIC[4] = {'B', 'B', 'C', 'H'};
static const uint32_t VERSION = 1;

/// @desc Saves a convex hull collision shape to a binary file.
///
/// @param _shapeId The ID of the convex hull shape to save
/// @param _filepath Pointer to null-terminated string containing the file path
/// @return 1.0 on success, -1.0 on failure
GM_EXPORT double BBMOD_ConvexHull_SaveToFile(double _shapeId, char* _filepath)
{
	try
	{
		auto shape = Registry::Get<btCollisionShape>(_shapeId);
		auto convexHull = dynamic_cast<btConvexHullShape*>(shape);

		if (!convexHull)
		{
			#ifdef _DEBUG
			printf("[ConvexHull] ERROR: Shape is not a convex hull\n");
			#endif
			return -1.0;
		}

		// Open file for binary writing
		std::ofstream file(_filepath, std::ios::binary);
		if (!file.is_open())
		{
			#ifdef _DEBUG
			printf("[ConvexHull] ERROR: Failed to open file for writing: %s\n", _filepath);
			#endif
			return -1.0;
		}

		// Write magic number
		file.write(MAGIC, 4);

		// Write version
		file.write(reinterpret_cast<const char*>(&VERSION), sizeof(uint32_t));

		// Get vertices from the convex hull
		int numVertices = convexHull->getNumPoints();
		const btVector3* vertices = convexHull->getUnscaledPoints();

		// Write vertex count
		uint32_t vertexCount = static_cast<uint32_t>(numVertices);
		file.write(reinterpret_cast<const char*>(&vertexCount), sizeof(uint32_t));

		#ifdef _DEBUG
		printf("[ConvexHull] Saving %u vertices to %s\n", vertexCount, _filepath);
		#endif

		// Write all vertices (as doubles for precision)
		for (uint32_t i = 0; i < vertexCount; ++i)
		{
			double x = static_cast<double>(vertices[i].x());
			double y = static_cast<double>(vertices[i].y());
			double z = static_cast<double>(vertices[i].z());

			file.write(reinterpret_cast<const char*>(&x), sizeof(double));
			file.write(reinterpret_cast<const char*>(&y), sizeof(double));
			file.write(reinterpret_cast<const char*>(&z), sizeof(double));
		}

		// Write margin
		double margin = static_cast<double>(convexHull->getMargin());
		file.write(reinterpret_cast<const char*>(&margin), sizeof(double));

		file.close();

		#ifdef _DEBUG
		printf("[ConvexHull] Successfully saved to %s\n", _filepath);
		#endif

		return 1.0;
	}
	catch (...)
	{
		#ifdef _DEBUG
		printf("[ConvexHull] ERROR: Exception during save\n");
		#endif
		return -1.0;
	}
}

/// @desc Loads a convex hull collision shape from a binary file.
///
/// @param _filepath Pointer to null-terminated string containing the file path
/// @return Shape ID on success, -1.0 on failure
GM_EXPORT double BBMOD_ConvexHull_LoadFromFile(char* _filepath)
{
	try
	{
		// Open file for binary reading
		std::ifstream file(_filepath, std::ios::binary);
		if (!file.is_open())
		{
			#ifdef _DEBUG
			printf("[ConvexHull] ERROR: Failed to open file for reading: %s\n", _filepath);
			#endif
			return -1.0;
		}

		// Read and verify magic number
		char magic[4];
		file.read(magic, 4);
		if (magic[0] != MAGIC[0] || magic[1] != MAGIC[1] ||
		    magic[2] != MAGIC[2] || magic[3] != MAGIC[3])
		{
			#ifdef _DEBUG
			printf("[ConvexHull] ERROR: Invalid magic number in file: %s\n", _filepath);
			#endif
			file.close();
			return -1.0;
		}

		// Read and verify version
		uint32_t version;
		file.read(reinterpret_cast<char*>(&version), sizeof(uint32_t));
		if (version != VERSION)
		{
			#ifdef _DEBUG
			printf("[ConvexHull] ERROR: Unsupported version %u (expected %u)\n", version, VERSION);
			#endif
			file.close();
			return -1.0;
		}

		// Read vertex count
		uint32_t vertexCount;
		file.read(reinterpret_cast<char*>(&vertexCount), sizeof(uint32_t));

		#ifdef _DEBUG
		printf("[ConvexHull] Loading %u vertices from %s\n", vertexCount, _filepath);
		#endif

		// Read all vertices
		std::vector<btVector3> vertices;
		vertices.reserve(vertexCount);

		for (uint32_t i = 0; i < vertexCount; ++i)
		{
			double x, y, z;
			file.read(reinterpret_cast<char*>(&x), sizeof(double));
			file.read(reinterpret_cast<char*>(&y), sizeof(double));
			file.read(reinterpret_cast<char*>(&z), sizeof(double));

			vertices.push_back(btVector3(
				static_cast<btScalar>(x),
				static_cast<btScalar>(y),
				static_cast<btScalar>(z)
			));
		}

		// Read margin
		double margin;
		file.read(reinterpret_cast<char*>(&margin), sizeof(double));

		file.close();

		// Create convex hull shape from loaded vertices
		auto hull = new btConvexHullShape(
			reinterpret_cast<const btScalar*>(vertices.data()),
			static_cast<int>(vertexCount),
			sizeof(btVector3)
		);

		hull->setMargin(static_cast<btScalar>(margin));
		hull->recalcLocalAabb();

		#ifdef _DEBUG
		printf("[ConvexHull] Successfully loaded from %s\n", _filepath);
		#endif

		// Register and return shape ID
		return Registry::Add(hull);
	}
	catch (...)
	{
		#ifdef _DEBUG
		printf("[ConvexHull] ERROR: Exception during load\n");
		#endif
		return -1.0;
	}
}
