#include "PhysicsShape.hpp"
#include "PhysicsWorld.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

#include <BulletCollision/CollisionShapes/btShapeHull.h>

#include <functional>

GM_EXPORT double BBMOD_PhysicsEngine_CreatePhysicsWorld(char* _buffer)
{
	BBMOD_PhysicsWorldInfo info(_buffer);
	auto world = new BBMOD_PhysicsWorld(&info);
	return Registry::Add(world);
}

GM_EXPORT double BBMOD_PhysicsEngine_DestroyPhysicsWorld(double _worldId)
{
	auto world = Registry::Get<BBMOD_PhysicsWorld>(_worldId);

	for (int i = world->m_dynamicsWorld->getNumCollisionObjects() - 1; i >= 0; --i)
	{
		auto obj = world->m_dynamicsWorld->getCollisionObjectArray()[i];
		auto shape = obj->getCollisionShape();

		if (shape->getShapeType() == COMPOUND_SHAPE_PROXYTYPE)
		{
			auto compound = static_cast<btCompoundShape*>(shape);
			for (int j = compound->getNumChildShapes() - 1; j >= 0; --j)
			{
				auto childShape = compound->getChildShape(j);
				delete childShape;
			}
		}

		if (shape->getShapeType() == TRIANGLE_MESH_SHAPE_PROXYTYPE
			|| shape->getShapeType() == SCALED_TRIANGLE_MESH_SHAPE_PROXYTYPE)
		{
			auto mesh = static_cast<btTriangleMesh*>(shape->getUserPointer());
			delete mesh;
		}

		delete shape;
	}

	Registry::Remove(world);
	delete world;
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsEngine_CreatePhysicsShape(char* _buffer)
{
	auto type = static_cast<BBMOD_EPhysicsShapeType>(BBMOD_PeekBuffer<int8_t>(_buffer));

	BBMOD_PhysicsShapeInfo* info = nullptr;

	btCollisionShape* shape = nullptr;
	switch (type)
	{
		case BBMOD_EPhysicsShapeType::Box:
		{
			info = new BBMOD_BoxPhysicsShapeInfo(_buffer);
			shape = new btBoxShape(static_cast<BBMOD_BoxPhysicsShapeInfo*>(info)->m_size * 0.5);
		}
		break;

		case BBMOD_EPhysicsShapeType::Capsule:
		{
			info = new BBMOD_CapsulePhysicsShapeInfo(_buffer);
			switch (static_cast<BBMOD_CapsulePhysicsShapeInfo*>(info)->m_upAxis)
			{
			case BBMOD_EAxis::X:
				shape = new btCapsuleShapeX(static_cast<BBMOD_CapsulePhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_CapsulePhysicsShapeInfo*>(info)->m_height);
				break;
			case BBMOD_EAxis::Y:
				shape = new btCapsuleShape(static_cast<BBMOD_CapsulePhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_CapsulePhysicsShapeInfo*>(info)->m_height);
				break;
			case BBMOD_EAxis::Z:
				shape = new btCapsuleShapeZ(static_cast<BBMOD_CapsulePhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_CapsulePhysicsShapeInfo*>(info)->m_height);
				break;
			}
		}
		break;

		case BBMOD_EPhysicsShapeType::Compound:
		{
			info = new BBMOD_CompoundPhysicsShapeInfo(_buffer);
			shape = new btCompoundShape();
		}
		break;

		case BBMOD_EPhysicsShapeType::Cone:
		{
			info = new BBMOD_ConePhysicsShapeInfo(_buffer);
			switch (static_cast<BBMOD_ConePhysicsShapeInfo*>(info)->m_upAxis)
			{
			case BBMOD_EAxis::X:
				shape = new btConeShapeX(static_cast<BBMOD_ConePhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_ConePhysicsShapeInfo*>(info)->m_height);
				break;
			case BBMOD_EAxis::Y:
				shape = new btConeShape(static_cast<BBMOD_ConePhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_ConePhysicsShapeInfo*>(info)->m_height);
				break;
			case BBMOD_EAxis::Z:
				shape = new btConeShapeZ(static_cast<BBMOD_ConePhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_ConePhysicsShapeInfo*>(info)->m_height);
				break;
			}
		}
		break;

		case BBMOD_EPhysicsShapeType::ConvexHull:
		{
			info = new BBMOD_ConvexHullPhysicsShapeInfo(_buffer);

			// Build raw hull from vertex data
			auto rawHull = new btConvexHullShape();
			rawHull->setMargin(static_cast<BBMOD_ConvexHullPhysicsShapeInfo*>(info)->m_margin);
			auto data = reinterpret_cast<const uint8_t*>(static_cast<BBMOD_ConvexHullPhysicsShapeInfo*>(info)->m_buffer);
			for (uint32_t i = 0; i < static_cast<BBMOD_ConvexHullPhysicsShapeInfo*>(info)->m_vertexCount; ++i)
			{
				auto v = reinterpret_cast<const btScalar*>(data);
				rawHull->addPoint(btVector3(v[0], v[1], v[2]), false);
				data += static_cast<BBMOD_ConvexHullPhysicsShapeInfo*>(info)->m_vertexStride;
			}
			rawHull->recalcLocalAabb();

			// Optimize hull
			btShapeHull hullHelper(rawHull);
			hullHelper.buildHull(rawHull->getMargin());

			auto optimizedHull = new btConvexHullShape(
				reinterpret_cast<const btScalar*>(hullHelper.getVertexPointer()),
				hullHelper.numVertices(),
				sizeof(btVector3));

			optimizedHull->setMargin(rawHull->getMargin());
			optimizedHull->recalcLocalAabb();

			delete rawHull;
			shape = optimizedHull;
		}
		break;

		case BBMOD_EPhysicsShapeType::Cylinder:
		{
			info = new BBMOD_CylinderPhysicsShapeInfo(_buffer);
			switch (static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_upAxis)
			{
			case BBMOD_EAxis::X:
				shape = new btCylinderShapeX(btVector3(static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_height * 0.5, static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_radius));
				break;
			case BBMOD_EAxis::Y:
				shape = new btCylinderShape(btVector3(static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_height * 0.5, static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_radius));
				break;
			case BBMOD_EAxis::Z:
				shape = new btCylinderShapeZ(btVector3(static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_radius, static_cast<BBMOD_CylinderPhysicsShapeInfo*>(info)->m_height * 0.5));
				break;
			}
			break;
		}
		break;

		case BBMOD_EPhysicsShapeType::Plane:
		{
			info = new BBMOD_PlanePhysicsShapeInfo(_buffer);
			shape = new btStaticPlaneShape(static_cast<BBMOD_PlanePhysicsShapeInfo*>(info)->m_normal, static_cast<BBMOD_PlanePhysicsShapeInfo*>(info)->m_distance);
		}
		break;

		case BBMOD_EPhysicsShapeType::Sphere:
		{
			info = new BBMOD_SpherePhysicsShapeInfo(_buffer);
			shape = new btSphereShape(static_cast<BBMOD_SpherePhysicsShapeInfo*>(info)->m_radius);
		}
		break;

		case BBMOD_EPhysicsShapeType::StaticMesh:
		{
			info = new BBMOD_StaticMeshPhysicsShapeInfo(_buffer);

			btTriangleMesh* mesh = new btTriangleMesh(true, false);
			shape->setUserPointer(mesh); // Store mesh for later deletion

			auto data = reinterpret_cast<const uint8_t*>(static_cast<BBMOD_StaticMeshPhysicsShapeInfo*>(info)->m_buffer);

			for (uint32_t i = 0; i < static_cast<BBMOD_StaticMeshPhysicsShapeInfo*>(info)->m_vertexCount; i += 3)
			{
				auto v0 = reinterpret_cast<const btScalar*>(data + (i + 0) * static_cast<BBMOD_StaticMeshPhysicsShapeInfo*>(info)->m_vertexStride);
				auto v1 = reinterpret_cast<const btScalar*>(data + (i + 1) * static_cast<BBMOD_StaticMeshPhysicsShapeInfo*>(info)->m_vertexStride);
				auto v2 = reinterpret_cast<const btScalar*>(data + (i + 2) * static_cast<BBMOD_StaticMeshPhysicsShapeInfo*>(info)->m_vertexStride);

				mesh->addTriangle(
					btVector3(v0[0], v0[1], v0[2]),
					btVector3(v1[0], v1[1], v1[2]),
					btVector3(v2[0], v2[1], v2[2]),
					true);
			}

			bool useQuantizedAabbCompression = true;

			shape = new btBvhTriangleMeshShape(
				mesh,
				useQuantizedAabbCompression);
		}
		break;

		default:
			delete shape;
			return -1.0;
	}

	shape->setMargin(info->m_margin);

	delete info;

	return Registry::Add(shape);
}

GM_EXPORT double BBMOD_PhysicsEngine_DestroyPhysicsShape(double _shapeId)
{
	auto shape = Registry::Get<btCollisionShape>(_shapeId);

	std::function<void(btCollisionShape*)> deleteShape = [&](btCollisionShape* s)
	{
		switch (s->getShapeType())
		{
			case COMPOUND_SHAPE_PROXYTYPE:
			{
				auto compound = static_cast<btCompoundShape*>(s);
				for (int i = compound->getNumChildShapes() - 1; i >= 0; --i)
				{
					auto child = compound->getChildShape(i);
					deleteShape(child);
				}
			}
			break;

			case TRIANGLE_MESH_SHAPE_PROXYTYPE:
			case SCALED_TRIANGLE_MESH_SHAPE_PROXYTYPE:
			{
				auto meshShape = static_cast<btBvhTriangleMeshShape*>(s);
				auto mesh = static_cast<btTriangleMesh*>(meshShape->getUserPointer());
				delete mesh;
			}
			break;
		}

		Registry::Remove(s);
		delete s;
	};

	deleteShape(shape);

	return 1.0;
}
