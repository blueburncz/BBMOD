#include "PhysicsShape.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

GM_EXPORT double BBMOD_PhysicsShape_GetShapeType(double _id)
{
	auto shape = Registry::Get<btCollisionShape>(_id);

	switch (shape->getShapeType())
	{
	case BOX_SHAPE_PROXYTYPE:
		return static_cast<double>(BBMOD_EPhysicsShapeType::Box);

	case CAPSULE_SHAPE_PROXYTYPE:
		return static_cast<double>(BBMOD_EPhysicsShapeType::Capsule);

	case COMPOUND_SHAPE_PROXYTYPE:
		return static_cast<double>(BBMOD_EPhysicsShapeType::Compound);

	case CONE_SHAPE_PROXYTYPE:
		return static_cast<double>(BBMOD_EPhysicsShapeType::Cone);

	case CONVEX_HULL_SHAPE_PROXYTYPE:
		return static_cast<double>(BBMOD_EPhysicsShapeType::ConvexHull);

	case CYLINDER_SHAPE_PROXYTYPE:
		return static_cast<double>(BBMOD_EPhysicsShapeType::Cylinder);

	case SPHERE_SHAPE_PROXYTYPE:
		return static_cast<double>(BBMOD_EPhysicsShapeType::Sphere);

	case TRIANGLE_MESH_SHAPE_PROXYTYPE:
	case SCALED_TRIANGLE_MESH_SHAPE_PROXYTYPE:
		return static_cast<double>(BBMOD_EPhysicsShapeType::StaticMesh);

	default:
		return -1.0;
	}
}

GM_EXPORT double BBMOD_PhysicsShape_GetUpAxis(double _id)
{
	auto shape = Registry::Get<btCollisionShape>(_id);
	switch (shape->getShapeType())
	{
		case CAPSULE_SHAPE_PROXYTYPE:
		{
			auto capsule = static_cast<btCapsuleShape*>(shape);
			return static_cast<double>(capsule->getUpAxis());
		}

		case CONE_SHAPE_PROXYTYPE:
		{
			auto cone = static_cast<btConeShape*>(shape);
			return static_cast<double>(cone->getConeUpIndex());
		}

		case CYLINDER_SHAPE_PROXYTYPE:
		{
			auto cylinder = static_cast<btCylinderShape*>(shape);
			return static_cast<double>(cylinder->getUpAxis());
		}

		default:
			break;
	}
	return 0.0;
}

GM_EXPORT double BBMOD_PhysicsShape_GetMargin(double _id)
{
	auto shape = Registry::Get<btCollisionShape>(_id);
	return static_cast<double>(shape->getMargin());
}

GM_EXPORT double BBMOD_PhysicsShape_SetMargin(double _id, double _margin)
{
	auto shape = Registry::Get<btCollisionShape>(_id);
	shape->setMargin(static_cast<btScalar>(_margin));
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsShape_GetLocalScaling(double _id, char* _buffer)
{
	auto shape = Registry::Get<btCollisionShape>(_id);
	btVector3 scaling = shape->getLocalScaling();
	*reinterpret_cast<btVector3*>(_buffer) = scaling;
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsShape_SetLocalScaling(double _id, char* _buffer)
{
	auto shape = Registry::Get<btCollisionShape>(_id);
	btVector3 scaling = *reinterpret_cast<btVector3*>(_buffer);
	shape->setLocalScaling(scaling);
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsShape_AddChildShape(double _compoundId, double _childShapeId, char* _buffer)
{
	auto collisionShape = Registry::Get<btCollisionShape>(_compoundId);
	if (collisionShape->getShapeType() != COMPOUND_SHAPE_PROXYTYPE)
	{
		return -1.0;
	}

	auto childShape = Registry::Get<btCollisionShape>(_childShapeId);

	btTransform localTransform;
	localTransform.setFromOpenGLMatrix(reinterpret_cast<const btScalar*>(_buffer));

	auto compound = static_cast<btCompoundShape*>(collisionShape);
	compound->addChildShape(localTransform, childShape);

	return 1.0;
}
