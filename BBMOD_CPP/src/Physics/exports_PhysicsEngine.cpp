#include "PhysicsWorld.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

GM_EXPORT double BBMOD_PhysicsEngine_CreatePhysicsWorld(char* _buffer)
{
	auto gravityX = BBMOD_ReadBuffer<double>(_buffer);
	auto gravityY = BBMOD_ReadBuffer<double>(_buffer);
	auto gravityZ = BBMOD_ReadBuffer<double>(_buffer);
	auto debugMode = BBMOD_ReadBuffer<uint64_t>(_buffer);

	auto world = new BBMOD_PhysicsWorld();
	world->m_dynamicsWorld->setGravity(btVector3(gravityX, gravityY, gravityZ));
	world->m_debugDraw->setDebugMode(debugMode);

	world->m_dynamicsWorld->getSolverInfo().m_numIterations = 20;  // or more

	return Registry::Add(world);
}

GM_EXPORT double BBMOD_PhysicsEngine_CreateBoxShape(char* _buffer)
{
	auto margin = BBMOD_ReadBuffer<double>(_buffer);
	btScalar m[16];
	for (int i = 0; i < 16; ++i) { m[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	auto sizeX = BBMOD_ReadBuffer<double>(_buffer);
	auto sizeY = BBMOD_ReadBuffer<double>(_buffer);
	auto sizeZ = BBMOD_ReadBuffer<double>(_buffer);

	auto compoundShape = new btCompoundShape();
	auto boxShape = new btBoxShape(btVector3(sizeX * 0.5, sizeY * 0.5, sizeZ * 0.5));
	boxShape->setMargin(margin);

	btTransform t;
	t.setFromOpenGLMatrix(m);

	compoundShape->addChildShape(t, boxShape);

	return Registry::Add(compoundShape);
}

GM_EXPORT double BBMOD_PhysicsEngine_CreateCapsuleXShape(char* _buffer)
{
	auto margin = BBMOD_ReadBuffer<double>(_buffer);
	btScalar m[16];
	for (int i = 0; i < 16; ++i) { m[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	auto radius = BBMOD_ReadBuffer<double>(_buffer);
	auto height = BBMOD_ReadBuffer<double>(_buffer);

	auto compoundShape = new btCompoundShape();
	auto capsuleXShape = new btCapsuleShapeX(radius, height);
	capsuleXShape->setMargin(margin);

	btTransform t;
	t.setFromOpenGLMatrix(m);

	compoundShape->addChildShape(t, capsuleXShape);

	return Registry::Add(compoundShape);
}

GM_EXPORT double BBMOD_PhysicsEngine_CreateCapsuleYShape(char* _buffer)
{
	auto margin = BBMOD_ReadBuffer<double>(_buffer);
	btScalar m[16];
	for (int i = 0; i < 16; ++i) { m[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	auto radius = BBMOD_ReadBuffer<double>(_buffer);
	auto height = BBMOD_ReadBuffer<double>(_buffer);

	auto compoundShape = new btCompoundShape();
	auto capsuleYShape = new btCapsuleShape(radius, height);
	capsuleYShape->setMargin(margin);

	btTransform t;
	t.setFromOpenGLMatrix(m);

	compoundShape->addChildShape(t, capsuleYShape);

	return Registry::Add(compoundShape);
}

GM_EXPORT double BBMOD_PhysicsEngine_CreateCapsuleZShape(char* _buffer)
{
	auto margin = BBMOD_ReadBuffer<double>(_buffer);
	btScalar m[16];
	for (int i = 0; i < 16; ++i) { m[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	auto radius = BBMOD_ReadBuffer<double>(_buffer);
	auto height = BBMOD_ReadBuffer<double>(_buffer);

	auto compoundShape = new btCompoundShape();
	auto capsuleZShape = new btCapsuleShapeZ(radius, height);
	capsuleZShape->setMargin(margin);

	btTransform t;
	t.setFromOpenGLMatrix(m);

	compoundShape->addChildShape(t, capsuleZShape);

	return Registry::Add(compoundShape);
}

GM_EXPORT double BBMOD_PhysicsEngine_CreateConeXShape(double _radius, double _height)
{
	return Registry::Add(new btConeShapeX(_radius, _height));
}

GM_EXPORT double BBMOD_PhysicsEngine_CreateConeYShape(double _radius, double _height)
{
	return Registry::Add(new btConeShape(_radius, _height));
}

GM_EXPORT double BBMOD_PhysicsEngine_CreateConeZShape(double _radius, double _height)
{
	return Registry::Add(new btConeShapeZ(_radius, _height));
}

GM_EXPORT double BBMOD_PhysicsEngine_CreateSphereShape(char* _buffer)
{
	auto margin = BBMOD_ReadBuffer<double>(_buffer);
	btScalar m[16];
	for (int i = 0; i < 16; ++i) { m[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	auto radius = BBMOD_ReadBuffer<double>(_buffer);

	auto compoundShape = new btCompoundShape();
	auto sphereShape = new btSphereShape(radius);
	sphereShape->setMargin(margin);

	btTransform t;
	t.setFromOpenGLMatrix(m);

	compoundShape->addChildShape(t, sphereShape);

	return Registry::Add(compoundShape);
}

GM_EXPORT double BBMOD_PhysicsEngine_DestroyShape(double _shapeId)
{
	auto shape = Registry::Get<btCollisionShape>(_shapeId);

	// Also delete child shapes, if this is a compound
	if (shape->getShapeType() == COMPOUND_SHAPE_PROXYTYPE)
	{
		auto compound = static_cast<btCompoundShape*>(shape);
		for (int i = compound->getNumChildShapes() - 1; i >= 0; --i)
		{
			auto child = compound->getChildShape(i);
			Registry::Remove(child);
			delete child;
		}
	}

	Registry::Remove(shape);
	delete shape;

	return 1.0;
}
