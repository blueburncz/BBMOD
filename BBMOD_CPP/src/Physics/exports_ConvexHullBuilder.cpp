#include "PhysicsShape.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

#include <BulletCollision/CollisionShapes/btShapeHull.h>

#include <vector>

// Helper structure to represent a node in the BBMOD hierarchy
struct BBMOD_ModelNode
{
	btTransform transform;
	std::vector<uint32_t> meshIndices;
	std::vector<BBMOD_ModelNode*> children;

	~BBMOD_ModelNode()
	{
		for (auto* child : children)
		{
			delete child;
		}
	}
};

// Reads a dual quaternion from buffer and converts it to a btTransform
static btTransform ReadDualQuaternionAsTransform(char*& buffer)
{
	// Read dual quaternion components
	btScalar realX = BBMOD_ReadBuffer<double>(buffer);
	btScalar realY = BBMOD_ReadBuffer<double>(buffer);
	btScalar realZ = BBMOD_ReadBuffer<double>(buffer);
	btScalar realW = BBMOD_ReadBuffer<double>(buffer);
	btScalar dualX = BBMOD_ReadBuffer<double>(buffer);
	btScalar dualY = BBMOD_ReadBuffer<double>(buffer);
	btScalar dualZ = BBMOD_ReadBuffer<double>(buffer);
	btScalar dualW = BBMOD_ReadBuffer<double>(buffer);

	#ifdef _DEBUG
	printf("[ConvexHull] Read DQ: Real(%.2f,%.2f,%.2f,%.2f) Dual(%.2f,%.2f,%.2f,%.2f)\n",
		realX, realY, realZ, realW, dualX, dualY, dualZ, dualW);
	#endif

	// Extract rotation from real part
	btQuaternion rotation(realX, realY, realZ, realW);
	rotation.normalize();

	// Extract translation from dual part
	// translation = 2 * dual * conjugate(real)
	btQuaternion dual(dualX, dualY, dualZ, dualW);
	btQuaternion realConj(-realX, -realY, -realZ, realW);
	btQuaternion translationQuat = (dual * btScalar(2.0)) * realConj;
	btVector3 translation(translationQuat.x(), translationQuat.y(), translationQuat.z());

	#ifdef _DEBUG
	printf("[ConvexHull] Converted to transform: Translation(%.2f,%.2f,%.2f)\n",
		translation.x(), translation.y(), translation.z());
	#endif

	btTransform transform;
	transform.setRotation(rotation);
	transform.setOrigin(translation);
	return transform;
}

// Recursively reads a node hierarchy from buffer
static BBMOD_ModelNode* ReadNodeHierarchy(char*& buffer)
{
	auto node = new BBMOD_ModelNode();

	// Read dual quaternion transform
	node->transform = ReadDualQuaternionAsTransform(buffer);

	// Read mesh indices
	uint32_t meshIndexCount = BBMOD_ReadBuffer<uint32_t>(buffer);
	node->meshIndices.reserve(meshIndexCount);
	for (uint32_t i = 0; i < meshIndexCount; ++i)
	{
		node->meshIndices.push_back(BBMOD_ReadBuffer<uint32_t>(buffer));
	}

	// Read children
	uint32_t childCount = BBMOD_ReadBuffer<uint32_t>(buffer);
	node->children.reserve(childCount);
	for (uint32_t i = 0; i < childCount; ++i)
	{
		node->children.push_back(ReadNodeHierarchy(buffer));
	}

	return node;
}

// Recursively collects and transforms vertices from the node hierarchy
static void CollectTransformedVertices(
	BBMOD_ModelNode* node,
	const btTransform& parentTransform,
	const std::vector<std::vector<btVector3>>& meshVertices,
	std::vector<btVector3>& outVertices)
{
	// Accumulate transforms: world = parent * local
	btTransform worldTransform = parentTransform * node->transform;

	// Transform vertices of all meshes this node uses
	for (uint32_t meshIndex : node->meshIndices)
	{
		if (meshIndex < meshVertices.size())
		{
			for (const btVector3& vertex : meshVertices[meshIndex])
			{
				outVertices.push_back(worldTransform * vertex);
			}
		}
	}

	// Recurse to children
	for (BBMOD_ModelNode* child : node->children)
	{
		CollectTransformedVertices(child, worldTransform, meshVertices, outVertices);
	}
}

/// @desc Creates a convex hull collision shape from a BBMOD model.
///
/// Buffer format:
/// - uint32_t meshCount
/// - For each mesh:
///   - uint32_t vertexCount
///   - For each vertex:
///     - double x, y, z
/// - Node hierarchy (root):
///   - double realX, realY, realZ, realW (dual quaternion real part)
///   - double dualX, dualY, dualZ, dualW (dual quaternion dual part)
///   - uint32_t meshIndexCount
///   - For each mesh index:
///     - uint32_t meshIndex
///   - uint32_t childCount
///   - For each child:
///     - (recursive node structure)
///
/// @param _buffer Pointer to the buffer containing model data
/// @return Shape ID on success, -1.0 on failure
GM_EXPORT double BBMOD_ConvexHull_CreateFromModel(char* _buffer)
{
	try
	{
		char* buffer = _buffer;

		// Read all mesh vertex data
		uint32_t meshCount = BBMOD_ReadBuffer<uint32_t>(buffer);
		std::vector<std::vector<btVector3>> meshVertices;
		meshVertices.reserve(meshCount);

		// #ifdef _DEBUG
		printf("[ConvexHull] Building from %u meshes\n", meshCount);
		// #endif

		for (uint32_t i = 0; i < meshCount; ++i)
		{
			uint32_t vertexCount = BBMOD_ReadBuffer<uint32_t>(buffer);
			std::vector<btVector3> vertices;
			vertices.reserve(vertexCount);

			// #ifdef _DEBUG
			printf("[ConvexHull] Mesh %u: %u vertices\n", i, vertexCount);
			// #endif

			for (uint32_t j = 0; j < vertexCount; ++j)
			{
				btScalar x = BBMOD_ReadBuffer<double>(buffer);
				btScalar y = BBMOD_ReadBuffer<double>(buffer);
				btScalar z = BBMOD_ReadBuffer<double>(buffer);
				vertices.push_back(btVector3(x, y, z));
			}

			meshVertices.push_back(std::move(vertices));
		}

		// Read node hierarchy
		BBMOD_ModelNode* rootNode = ReadNodeHierarchy(buffer);

		// Collect all transformed vertices
		std::vector<btVector3> allVertices;
		btTransform identityTransform;
		identityTransform.setIdentity();
		CollectTransformedVertices(rootNode, identityTransform, meshVertices, allVertices);

		// Clean up node hierarchy
		delete rootNode;

		// Check if we have any vertices
		if (allVertices.empty())
		{
			return -1.0;
		}

		// Build raw convex hull from all collected vertices
		auto rawHull = new btConvexHullShape();
		for (const btVector3& vertex : allVertices)
		{
			rawHull->addPoint(vertex, false);
		}
		rawHull->recalcLocalAabb();

		// Optimize hull using btShapeHull
		btShapeHull hullHelper(rawHull);
		hullHelper.buildHull(rawHull->getMargin());

		// #ifdef _DEBUG
		printf("[ConvexHull] Raw hull vertices: %zu, Optimized vertices: %d\n",
			allVertices.size(), hullHelper.numVertices());
		// #endif

		// Create optimized convex hull
		auto optimizedHull = new btConvexHullShape(
			reinterpret_cast<const btScalar*>(hullHelper.getVertexPointer()),
			hullHelper.numVertices(),
			sizeof(btVector3));

		optimizedHull->setMargin(rawHull->getMargin());
		optimizedHull->recalcLocalAabb();

		#ifdef _DEBUG
		btVector3 aabbMin, aabbMax;
		optimizedHull->getAabb(btTransform::getIdentity(), aabbMin, aabbMax);
		printf("[ConvexHull] Hull AABB: min(%.2f,%.2f,%.2f) max(%.2f,%.2f,%.2f)\n",
			aabbMin.x(), aabbMin.y(), aabbMin.z(),
			aabbMax.x(), aabbMax.y(), aabbMax.z());
		#endif

		// Clean up raw hull
		delete rawHull;

		// Register and return shape ID
		return Registry::Add(optimizedHull);
	}
	catch (...)
	{
		return -1.0;
	}
}
