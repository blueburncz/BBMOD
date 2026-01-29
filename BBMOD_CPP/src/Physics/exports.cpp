#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

#define BT_USE_DOUBLE_PRECISION
#include <btBulletDynamicsCommon.h>
#include <BulletCollision/CollisionShapes/btHeightfieldTerrainShape.h>
#include <BulletDynamics/Vehicle/btVehicleRaycaster.h>

#include <algorithm>
#include <cassert>
#include <cstdint>
#include <unordered_map>
#include <vector>

using btVehicleTuning = btRaycastVehicle::btVehicleTuning;
using btVehicleRaycasterResult = btVehicleRaycaster::btVehicleRaycasterResult;

////////////////////////////////////////////////////////////////////////////////
//
// Math
//

#define DEG2RAD 0.01745329251
#define RAD2DEG 57.2957795131

static inline float ToRadians(float angle) { return DEG2RAD * angle; }
static inline float ToDegrees(float angle) { return RAD2DEG * angle; }

struct DualQuat
{
	btQuaternion m_real;
	btQuaternion m_dual;

	void FromTransform(const btTransform& t)
	{
		btQuaternion qr = t.getRotation();
		btVector3 tr = t.getOrigin();
		btQuaternion tq(tr.x(), tr.y(), tr.z(), 0.0);
		m_real = qr;
		m_dual = (tq * qr) * 0.5;
	}
};

static btGeneric6DofConstraint* CreateCharacterJoint(
	btRigidBody* parent,
	btRigidBody* child,
	const btVector3& angularLower,
	const btVector3& angularUpper,
	btDiscreteDynamicsWorld* world,
	bool enableSpring = false,
	btScalar stiffness = 5.0f,
	btScalar damping = 0.9f
)
{
	// ------------------------------------------------------------
	// 1. Joint gizmo lives at bone A's origin and basis
	// ------------------------------------------------------------
	btTransform gizmoWorld = child->getWorldTransform();

	// Rotate frame so:
	// Bone Z becomes Bullet X (twist axis)
	btQuaternion fix = btQuaternion(btVector3(0, 0, -1), -SIMD_HALF_PI);

	btTransform basisFix;
	basisFix.setIdentity();
	basisFix.setRotation(fix);

	gizmoWorld = gizmoWorld * basisFix;

	// ------------------------------------------------------------
	// 2. Get rigid body world transforms
	// ------------------------------------------------------------
	btTransform bodyATrans = parent->getWorldTransform();
	btTransform bodyBTrans = child->getWorldTransform();

	// ------------------------------------------------------------
	// 3. Compute local frames
	// frameA = inverse(A) * joint
	// frameB = inverse(B) * joint
	// ------------------------------------------------------------
	btTransform frameA = bodyATrans.inverse() * gizmoWorld;
	btTransform frameB = bodyBTrans.inverse() * gizmoWorld;

	// Create 6DOF spring constraint
	auto joint = new btGeneric6DofConstraint(*parent, *child, frameA, frameB, true);

	// Set linear limits
	joint->setLinearLowerLimit(btVector3(0, 0, 0));
	joint->setLinearUpperLimit(btVector3(0, 0, 0));

	// Set angular limits
	joint->setAngularLowerLimit(angularLower);
	joint->setAngularUpperLimit(angularUpper);

	for(int i=0; i<6; ++i)
	{
		joint->setParam(BT_CONSTRAINT_STOP_ERP, 0.1f, i);
		joint->setParam(BT_CONSTRAINT_STOP_CFM, 0.0f, i);
	}

	world->addConstraint(joint, true);
	return joint;
}

////////////////////////////////////////////////////////////////////////////////
//
// Registry
//

class Registry final
{
public:
	static double Add(void* ptr)
	{
		assert(ptr != nullptr);
		auto it = m_ptrToId.find(ptr);
		if (it != m_ptrToId.end())
		{
			return it->second;
		}
		double id = m_idNext++;
		m_ptrToId[ptr] = id;
		m_idToPtr[id] = ptr;
		return id;
	}

	template<typename T>
	static T* Get(double id)
	{
		auto it = m_idToPtr.find(id);
		if (it != m_idToPtr.end())
		{
			return (T*)(it->second);
		}
		return nullptr;
	}

	static void Remove(double id)
	{
		auto it = m_idToPtr.find(id);
		if (it != m_idToPtr.end())
		{
			m_ptrToId.erase(m_ptrToId.find(it->second));
			m_idToPtr.erase(it);
		}
	}

	static void Remove(void* ptr)
	{
		auto it = m_ptrToId.find(ptr);
		if (it != m_ptrToId.end())
		{
			m_idToPtr.erase(m_idToPtr.find(it->second));
			m_ptrToId.erase(it);
		}
	}

private:
	Registry() {}
	~Registry() {}

	static inline std::unordered_map<void*, double> m_ptrToId{};
	static inline std::unordered_map<double, void*> m_idToPtr{};
	static inline double m_idNext = 0.0;
};

////////////////////////////////////////////////////////////////////////////////
//
// Debug draw
//

static inline uint32_t ColorToUInt32(const btVector3& color)
{
	return (0xff000000U
		| ((uint32_t)(color.z() * 255.0) << 16)
		| ((uint32_t)(color.y() * 255.0) << 8)
		| ((uint32_t)(color.x() * 255.0) << 0));
}

class btDebugDrawInMemory : public btIDebugDraw
{
public:
	virtual void drawLine(
		const btVector3& from, const btVector3& to, const btVector3& color)
	{
		uint32_t colorGM = ColorToUInt32(color);

		m_positions.push_back(from.x());
		m_positions.push_back(from.y());
		m_positions.push_back(from.z());
		m_colors.push_back(colorGM);

		m_positions.push_back(to.x());
		m_positions.push_back(to.y());
		m_positions.push_back(to.z());
		m_colors.push_back(colorGM);
	}

	virtual void drawContactPoint(
		const btVector3& PointOnB,
		const btVector3& normalOnB,
		btScalar distance,
		int lifeTime,
		const btVector3& color)
	{
		drawLine(PointOnB - btVector3(1.0, 0.0, 0.0), PointOnB + btVector3(1.0, 0.0, 0.0), color);
		drawLine(PointOnB - btVector3(0.0, 1.0, 0.0), PointOnB + btVector3(0.0, 1.0, 0.0), color);
		drawLine(PointOnB - btVector3(0.0, 0.0, 1.0), PointOnB + btVector3(0.0, 0.0, 1.0), color);
	}

	virtual void reportErrorWarning(const char* warningString)
	{
	}

	virtual void draw3dText(const btVector3& location, const char* textString)
	{
	}

	virtual void setDebugMode(int debugMode)
	{
		m_debugMode = debugMode;
	}

	virtual int getDebugMode() const
	{
		return m_debugMode;
	}

	virtual void clearLines()
	{
		m_positions.clear();
		m_colors.clear();
	}

	virtual void flushLines()
	{
	}

	size_t getSize() const
	{
		return m_positions.size() * 4
			+ m_colors.size() * 4;
	}

	void toBuffer(uint8_t* buffer) const
	{
		size_t size = m_colors.size();
		uint8_t* current = buffer;

		for (size_t i = 0; i < size; ++i)
		{
			float* currentPos = (float*)current;
			currentPos[0] = m_positions[i * 3 + 0];
			currentPos[1] = m_positions[i * 3 + 1];
			currentPos[2] = m_positions[i * 3 + 2];
			current = (uint8_t*)(currentPos + 3);

			uint32_t* currentCol = (uint32_t*)current;
			currentCol[0] = m_colors[i];
			current = (uint8_t*)(currentCol + 1);
		}
	}

private:
	int m_debugMode = (int)DBG_NoDebug;
	std::vector<float> m_positions;
	std::vector<uint32_t> m_colors;
};

////////////////////////////////////////////////////////////////////////////////

struct BBMOD_PhysicsWorld
{
	BBMOD_PhysicsWorld()
	{
		m_collisionConfiguration = new btDefaultCollisionConfiguration();
		m_dispatcher = new btCollisionDispatcher(m_collisionConfiguration);
		m_overlappingPairCache = new btDbvtBroadphase();
		m_solver = new btSequentialImpulseConstraintSolver();
		m_dynamicsWorld = new btDiscreteDynamicsWorld(m_dispatcher, m_overlappingPairCache, m_solver, m_collisionConfiguration);

		m_dynamicsWorld->getSolverInfo().m_numIterations = 30; // default ~10
		m_dynamicsWorld->getSolverInfo().m_splitImpulse = 1;   // prevents slight sinking

		m_debugDraw = new btDebugDrawInMemory();
		m_dynamicsWorld->setDebugDrawer(m_debugDraw);
	}

	~BBMOD_PhysicsWorld()
	{
		delete m_dynamicsWorld;
		delete m_solver;
		delete m_overlappingPairCache;
		delete m_dispatcher;
		delete m_collisionConfiguration;

		delete m_debugDraw;
	}

	btDefaultCollisionConfiguration* m_collisionConfiguration;
	btCollisionDispatcher* m_dispatcher;
	btBroadphaseInterface* m_overlappingPairCache;
	btSequentialImpulseConstraintSolver* m_solver;
	btDiscreteDynamicsWorld* m_dynamicsWorld;

	btDebugDrawInMemory* m_debugDraw;
};

struct BBMOD_PhysicsVehicle
{
	btDynamicsWorld* m_world;
	btVehicleTuning m_tuning;
	btVehicleRaycaster* m_raycaster;
	btRaycastVehicle* m_vehicle;

	~BBMOD_PhysicsVehicle()
	{
		m_world->removeVehicle(m_vehicle);
		delete m_vehicle;
		delete m_raycaster;
	}
};

////////////////////////////////////////////////////////////////////////////////
//
// BBMOD_PhysicsEngine
//

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

////////////////////////////////////////////////////////////////////////////////
//
// BBMOD_PhysicsWorld
//

GM_EXPORT double BBMOD_PhysicsWorld_SetGravity(double _id, double _x, double _y, double _z)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	physicsWorld->m_dynamicsWorld->setGravity(btVector3(_x, _y, _z));
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsWorld_CreateRigidBody(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	auto shapeId = BBMOD_ReadBuffer<double>(_buffer);
	btScalar m[16];
	for (int i = 0; i < 16; ++i) { m[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	auto mass = BBMOD_ReadBuffer<double>(_buffer);
	auto restitution = BBMOD_ReadBuffer<double>(_buffer);
	auto friction = BBMOD_ReadBuffer<double>(_buffer);

	auto colShape = Registry::Get<btCollisionShape>(shapeId);

	btTransform startTransform;
	startTransform.setFromOpenGLMatrix(m);

	bool isDynamic = (mass != 0.0);

	btVector3 localInertia(0.0, 0.0, 0.0);
	if (isDynamic)
	{
		colShape->calculateLocalInertia(mass, localInertia);
	}

	auto motionState = new btDefaultMotionState(startTransform);
	btRigidBody::btRigidBodyConstructionInfo rbInfo(mass, motionState, colShape, localInertia);
	rbInfo.m_restitution = restitution;
	rbInfo.m_friction = friction;
	auto body = new btRigidBody(rbInfo);

	body->setDamping(0.05f, 0.85f);
	body->setSleepingThresholds(0.1f, 0.1f);
	body->setDeactivationTime(1.0f);

	physicsWorld->m_dynamicsWorld->addRigidBody(body);

	return Registry::Add(body);
}

GM_EXPORT double BBMOD_PhysicsWorld_DestroyRigidBody(double _worldId, double _bodyId)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);
	auto rigidBody = Registry::Get<btRigidBody>(_bodyId);

	physicsWorld->m_dynamicsWorld->removeRigidBody(rigidBody);

	rigidBody->setCollisionShape(nullptr);

	delete rigidBody->getMotionState();

	Registry::Remove(rigidBody);
	delete rigidBody;

	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsWorld_CreatePointConstraint(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	auto bodyId1 = BBMOD_ReadBuffer<double>(_buffer);
	auto bodyId2 = BBMOD_ReadBuffer<double>(_buffer);
	auto x1 = BBMOD_ReadBuffer<double>(_buffer);
	auto y1 = BBMOD_ReadBuffer<double>(_buffer);
	auto z1 = BBMOD_ReadBuffer<double>(_buffer);
	auto x2 = BBMOD_ReadBuffer<double>(_buffer);
	auto y2 = BBMOD_ReadBuffer<double>(_buffer);
	auto z2 = BBMOD_ReadBuffer<double>(_buffer);

	auto body1 = Registry::Get<btRigidBody>(bodyId1);
	auto body2 = Registry::Get<btRigidBody>(bodyId2);

	btPoint2PointConstraint* constraint = nullptr;
	if (body2)
	{
		constraint = new btPoint2PointConstraint(
			*body1,
			*body2,
			btVector3(x1, y1, z1),
			btVector3(x2, y2, z2)
		);
	}
	else
	{
		constraint = new btPoint2PointConstraint(
			*body1,
			btVector3(x1, y1, z1)
		);
	}

	physicsWorld->m_dynamicsWorld->addConstraint(constraint);
	return Registry::Add(constraint);
}

GM_EXPORT double BBMOD_PhysicsWorld_CreateHingeConstraint(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	auto bodyId1 = BBMOD_ReadBuffer<double>(_buffer);
	auto bodyId2 = BBMOD_ReadBuffer<double>(_buffer);
	auto pivotX1 = BBMOD_ReadBuffer<double>(_buffer);
	auto pivotY1 = BBMOD_ReadBuffer<double>(_buffer);
	auto pivotZ1 = BBMOD_ReadBuffer<double>(_buffer);
	auto pivotX2 = BBMOD_ReadBuffer<double>(_buffer);
	auto pivotY2 = BBMOD_ReadBuffer<double>(_buffer);
	auto pivotZ2 = BBMOD_ReadBuffer<double>(_buffer);
	auto axisX1 = BBMOD_ReadBuffer<double>(_buffer);
	auto axisY1 = BBMOD_ReadBuffer<double>(_buffer);
	auto axisZ1 = BBMOD_ReadBuffer<double>(_buffer);
	auto axisX2 = BBMOD_ReadBuffer<double>(_buffer);
	auto axisY2 = BBMOD_ReadBuffer<double>(_buffer);
	auto axisZ2 = BBMOD_ReadBuffer<double>(_buffer);

	auto body1 = Registry::Get<btRigidBody>(bodyId1);
	auto body2 = Registry::Get<btRigidBody>(bodyId2);

	btHingeConstraint* constraint = nullptr;
	if (body2)
	{
		constraint = new btHingeConstraint(
			*body1,
			*body2,
			btVector3(pivotX1, pivotY1, pivotZ1),
			btVector3(pivotX2, pivotY2, pivotZ2),
			btVector3(axisX1, axisY1, axisZ1),
			btVector3(axisX2, axisY2, axisZ2)
		);
	}
	else
	{
		constraint = new btHingeConstraint(
			*body1,
			btVector3(pivotX1, pivotY1, pivotZ1),
			btVector3(axisX1, axisY1, axisZ1)
		);
	}


	physicsWorld->m_dynamicsWorld->addConstraint(constraint);
	return Registry::Add(constraint);
}

GM_EXPORT double BBMOD_PhysicsWorld_CreateSliderConstraint(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	auto bodyId1 = BBMOD_ReadBuffer<double>(_buffer);
	auto bodyId2 = BBMOD_ReadBuffer<double>(_buffer);
	btScalar m1[16];
	btScalar m2[16];
	for (int i = 0; i < 16; ++i) { m1[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	for (int i = 0; i < 16; ++i) { m2[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }

	btTransform t1;
	btTransform t2;
	t1.setFromOpenGLMatrix(m1);
	t2.setFromOpenGLMatrix(m2);

	auto body1 = Registry::Get<btRigidBody>(bodyId1);
	auto body2 = Registry::Get<btRigidBody>(bodyId2);

	btSliderConstraint* constraint = nullptr;
	if (body2)
	{
		constraint = new btSliderConstraint(
			*body1,
			*body2,
			t1,
			t2,
			false
		);

	}
	else
	{
		constraint = new btSliderConstraint(
			*body1,
			t1,
			false
		);
	}

	physicsWorld->m_dynamicsWorld->addConstraint(constraint);
	return Registry::Add(constraint);
}

GM_EXPORT double BBMOD_PhysicsWorld_CreateConeTwistConstraint(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	auto bodyId1 = BBMOD_ReadBuffer<double>(_buffer);
	auto bodyId2 = BBMOD_ReadBuffer<double>(_buffer);
	btScalar m1[16];
	btScalar m2[16];
	for (int i = 0; i < 16; ++i) { m1[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	for (int i = 0; i < 16; ++i) { m2[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }

	btTransform t1;
	btTransform t2;
	t1.setFromOpenGLMatrix(m1);
	t2.setFromOpenGLMatrix(m2);

	auto body1 = Registry::Get<btRigidBody>(bodyId1);
	auto body2 = Registry::Get<btRigidBody>(bodyId2);

	btConeTwistConstraint* constraint = nullptr;
	if (body2)
	{
		constraint = new btConeTwistConstraint(
			*body1,
			*body2,
			t1,
			t2
		);
	}
	else
	{
		constraint = new btConeTwistConstraint(
			*body1,
			t1
		);
	}

	constraint->setLimit(btRadians(1), btRadians(1), 0);

	physicsWorld->m_dynamicsWorld->addConstraint(constraint);
	return Registry::Add(constraint);
}

GM_EXPORT double BBMOD_PhysicsWorld_CreateSixDOFConstraint(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	auto bodyId1 = BBMOD_ReadBuffer<double>(_buffer);
	auto bodyId2 = BBMOD_ReadBuffer<double>(_buffer);
	btScalar m1[16];
	btScalar m2[16];
	for (int i = 0; i < 16; ++i) { m1[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	for (int i = 0; i < 16; ++i) { m2[i] = (btScalar)BBMOD_ReadBuffer<double>(_buffer); }
	auto linearLowerLimitX = BBMOD_ReadBuffer<double>(_buffer);
	auto linearLowerLimitY = BBMOD_ReadBuffer<double>(_buffer);
	auto linearLowerLimitZ = BBMOD_ReadBuffer<double>(_buffer);
	auto linearUpperLimitX = BBMOD_ReadBuffer<double>(_buffer);
	auto linearUpperLimitY = BBMOD_ReadBuffer<double>(_buffer);
	auto linearUpperLimitZ = BBMOD_ReadBuffer<double>(_buffer);
	auto angularLowerLimitX = BBMOD_ReadBuffer<double>(_buffer);
	auto angularLowerLimitY = BBMOD_ReadBuffer<double>(_buffer);
	auto angularLowerLimitZ = BBMOD_ReadBuffer<double>(_buffer);
	auto angularUpperLimitX = BBMOD_ReadBuffer<double>(_buffer);
	auto angularUpperLimitY = BBMOD_ReadBuffer<double>(_buffer);
	auto angularUpperLimitZ = BBMOD_ReadBuffer<double>(_buffer);
	auto enableLinearSpringX = BBMOD_ReadBuffer<bool>(_buffer);
	auto enableLinearSpringY = BBMOD_ReadBuffer<bool>(_buffer);
	auto enableLinearSpringZ = BBMOD_ReadBuffer<bool>(_buffer);
	auto enableAngularSpringX = BBMOD_ReadBuffer<bool>(_buffer);
	auto enableAngularSpringY = BBMOD_ReadBuffer<bool>(_buffer);
	auto enableAngularSpringZ = BBMOD_ReadBuffer<bool>(_buffer);
	auto linearStiffnessX = BBMOD_ReadBuffer<double>(_buffer);
	auto linearStiffnessY = BBMOD_ReadBuffer<double>(_buffer);
	auto linearStiffnessZ = BBMOD_ReadBuffer<double>(_buffer);
	auto angularStiffnessX = BBMOD_ReadBuffer<double>(_buffer);
	auto angularStiffnessY = BBMOD_ReadBuffer<double>(_buffer);
	auto angularStiffnessZ = BBMOD_ReadBuffer<double>(_buffer);
	auto linearDampingX = BBMOD_ReadBuffer<double>(_buffer);
	auto linearDampingY = BBMOD_ReadBuffer<double>(_buffer);
	auto linearDampingZ = BBMOD_ReadBuffer<double>(_buffer);
	auto angularDampingX = BBMOD_ReadBuffer<double>(_buffer);
	auto angularDampingY = BBMOD_ReadBuffer<double>(_buffer);
	auto angularDampingZ = BBMOD_ReadBuffer<double>(_buffer);

	btTransform t1;
	btTransform t2;
	t1.setFromOpenGLMatrix(m1);
	t2.setFromOpenGLMatrix(m2);

	auto body1 = Registry::Get<btRigidBody>(bodyId1);
	auto body2 = Registry::Get<btRigidBody>(bodyId2);

	btGeneric6DofSpring2Constraint* constraint = new btGeneric6DofSpring2Constraint(
		*body1,
		*body2,
		t1,
		t2,
		RO_YXZ // Follow GM's matrix_build
	);

	constraint->setLinearLowerLimit(btVector3(linearLowerLimitX, linearLowerLimitY, linearLowerLimitZ));
	constraint->setLinearUpperLimit(btVector3(linearUpperLimitX, linearUpperLimitY, linearUpperLimitZ));

	constraint->setAngularLowerLimit(btVector3(angularLowerLimitX, angularLowerLimitY, angularLowerLimitZ));
	constraint->setAngularUpperLimit(btVector3(angularUpperLimitX, angularUpperLimitY, angularUpperLimitZ));

	constraint->enableSpring(0, enableLinearSpringX);
	constraint->enableSpring(1, enableLinearSpringY);
	constraint->enableSpring(2, enableLinearSpringZ);
	constraint->enableSpring(3, enableAngularSpringX);
	constraint->enableSpring(4, enableAngularSpringY);
	constraint->enableSpring(5, enableAngularSpringZ);

	constraint->setStiffness(0, linearStiffnessX);
	constraint->setStiffness(1, linearStiffnessY);
	constraint->setStiffness(2, linearStiffnessZ);
	constraint->setStiffness(3, angularStiffnessX);
	constraint->setStiffness(4, angularStiffnessY);
	constraint->setStiffness(5, angularStiffnessZ);

	constraint->setDamping(0, linearDampingX);
	constraint->setDamping(1, linearDampingY);
	constraint->setDamping(2, linearDampingZ);
	constraint->setDamping(3, angularDampingX);
	constraint->setDamping(4, angularDampingY);
	constraint->setDamping(5, angularDampingZ);

	physicsWorld->m_dynamicsWorld->addConstraint(constraint);
	return Registry::Add(constraint);
}

GM_EXPORT double BBMOD_PhysicsWorld_CreateCharacterJoint(double _worldId, char* _buffer)
{
	auto A = Registry::Get<btRigidBody>(BBMOD_ReadBuffer<double>(_buffer));
	auto B = Registry::Get<btRigidBody>(BBMOD_ReadBuffer<double>(_buffer));
	float lowerX = BBMOD_ReadBuffer<float>(_buffer);
	float lowerY = BBMOD_ReadBuffer<float>(_buffer);
	float lowerZ = BBMOD_ReadBuffer<float>(_buffer);
	float upperX = BBMOD_ReadBuffer<float>(_buffer);
	float upperY = BBMOD_ReadBuffer<float>(_buffer);
	float upperZ = BBMOD_ReadBuffer<float>(_buffer);

	auto dynamicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId)->m_dynamicsWorld;

	auto DegToRad = [](float d) { return d * SIMD_PI / 180.0f; };

	btVector3 lower(
		DegToRad(std::min(lowerX, upperX)),
		DegToRad(std::min(lowerY, upperY)),
		DegToRad(std::min(lowerZ, upperZ))
	);

	btVector3 upper(
		DegToRad(std::max(lowerX, upperX)),
		DegToRad(std::max(lowerY, upperY)),
		DegToRad(std::max(lowerZ, upperZ))
	);

	auto joint = CreateCharacterJoint(
		B,
		A,
		lower,
		upper,
		dynamicsWorld
	);

	return Registry::Add(joint);
}

GM_EXPORT double BBMOD_PhysicsWorld_DestroyConstraint(double _worldId, double _constraintId)
{
	auto world = Registry::Get<BBMOD_PhysicsWorld>(_worldId)->m_dynamicsWorld;
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);

	world->removeConstraint(constraint);

	Registry::Remove(constraint);
	delete constraint;

	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsWorld_CreateTerrain(double _id, char* _buffer)
{
	auto width = BBMOD_ReadBuffer<uint32_t>(_buffer);
	auto height = BBMOD_ReadBuffer<uint32_t>(_buffer);
	auto positionX = BBMOD_ReadBuffer<double>(_buffer);
	auto positionY = BBMOD_ReadBuffer<double>(_buffer);
	auto positionZ = BBMOD_ReadBuffer<double>(_buffer);
	auto scaleX = BBMOD_ReadBuffer<double>(_buffer);
	auto scaleY = BBMOD_ReadBuffer<double>(_buffer);
	auto scaleZ = BBMOD_ReadBuffer<double>(_buffer);
	auto heightmap = reinterpret_cast<uint8_t*>(_buffer);

	// Create collision shape
	const double heightmapScale = 1.0;
	const double heightmapMin = 0.0;
	const double heightmapMax = 255.0;
	const int upAxis = 2; // Z
	const bool flipQuadEdges = true;

	auto shape = new btHeightfieldTerrainShape(height, width,
		heightmap, heightmapScale, heightmapMin, heightmapMax, upAxis, flipQuadEdges);

	shape->setFlipTriangleWinding(true);
	shape->setLocalScaling(btVector3(scaleX, scaleY, scaleZ));
	shape->buildAccelerator();

	// Create rigid body
	btTransform transform;
	transform.setIdentity();
	transform.setOrigin(btVector3(
		positionX + ((width - 1) * scaleX * 0.5),
		positionY + ((height - 1) * scaleY * 0.5),
		positionZ + (255.0 * scaleZ * 0.5)
	));

	btVector3 localInertia(0.0, 0.0, 0.0);
	auto motionState = new btDefaultMotionState(transform);
	btRigidBody::btRigidBodyConstructionInfo rbInfo(0.0, motionState, shape, localInertia);
	auto body = new btRigidBody(rbInfo);

	// Add to physics world
	Registry::Get<BBMOD_PhysicsWorld>(_id)->m_dynamicsWorld->addRigidBody(body);

	return Registry::Add(body);
}

GM_EXPORT double BBMOD_PhysicsWorld_DestroyTerrain(double _worldId, double _terrainId)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId)->m_dynamicsWorld;
	auto body = Registry::Get<btRigidBody>(_terrainId);
	auto shape = body->getCollisionShape();

	physicsWorld->removeRigidBody(body);

	body->setCollisionShape(nullptr);
	delete shape;

	delete body->getMotionState();

	Registry::Remove(body);
	delete body;

	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsWorld_CreateVehicle(double _id, char* _buffer)
{
	auto world = Registry::Get<BBMOD_PhysicsWorld>(_id)->m_dynamicsWorld;

	auto res = new BBMOD_PhysicsVehicle();

	res->m_tuning.m_suspensionStiffness = BBMOD_ReadBuffer<double>(_buffer);
	res->m_tuning.m_suspensionCompression = BBMOD_ReadBuffer<double>(_buffer);
	res->m_tuning.m_suspensionDamping = BBMOD_ReadBuffer<double>(_buffer);
	res->m_tuning.m_maxSuspensionTravelCm = BBMOD_ReadBuffer<double>(_buffer);
	res->m_tuning.m_frictionSlip = BBMOD_ReadBuffer<double>(_buffer);
	res->m_tuning.m_maxSuspensionForce = BBMOD_ReadBuffer<double>(_buffer);

	auto chassis = Registry::Get<btRigidBody>(BBMOD_ReadBuffer<double>(_buffer));
	auto raycaster = new btDefaultVehicleRaycaster(world);
	auto vehicle = new btRaycastVehicle(res->m_tuning, chassis, raycaster);
	vehicle->setCoordinateSystem(1, 2, 0);

	world->addVehicle(vehicle);

	res->m_world = world;
	res->m_raycaster = raycaster;
	res->m_vehicle = vehicle;

	return Registry::Add(res);
}

GM_EXPORT double BBMOD_PhysicsWorld_DestroyVehicle(double _worldId, double _vehicleId)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_vehicleId);
	Registry::Remove(vehicle);
	delete vehicle; // Note: Removes itself from world
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsWorld_Simulate(double _id, double _timeStep, double _maxSubSteps)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	physicsWorld->m_dynamicsWorld->stepSimulation(_timeStep, _maxSubSteps);
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsWorld_DrawDebug(double _id)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	physicsWorld->m_dynamicsWorld->debugDrawWorld();
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsWorld_GetDebugDrawSize(double _id)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	return physicsWorld->m_debugDraw->getSize();
}

GM_EXPORT double BBMOD_PhysicsWorld_GetDebugDrawToBuffer(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	physicsWorld->m_debugDraw->toBuffer((uint8_t*)_buffer);
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsWorld_Destroy(double _id)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	auto dynamicsWorld = physicsWorld->m_dynamicsWorld;

	for (int i = dynamicsWorld->getNumCollisionObjects() - 1; i >= 0; --i)
	{
		btCollisionObject* obj = dynamicsWorld->getCollisionObjectArray()[i];
		btRigidBody* body = btRigidBody::upcast(obj);
		if (body)
		{
			if (body->getMotionState())
			{
				delete body->getMotionState();
			}
			Registry::Remove(body);
		}
		dynamicsWorld->removeCollisionObject(obj);
		delete obj;
	}

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// BBMOD_RigidBody
//

GM_EXPORT double BBMOD_RigidBody_GetMatrixToBuffer(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btTransform transform;
	rigidBody->getMotionState()->getWorldTransform(transform);

	btScalar m[16];
	transform.getOpenGLMatrix(m);

	for (int i = 0; i < 16; ++i)
	{
		BBMOD_WriteBuffer(_buffer, (double)m[i]);
	}

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetDualQuatToBuffer(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btTransform transform;
	rigidBody->getMotionState()->getWorldTransform(transform);

	DualQuat dq;
	dq.FromTransform(transform);

	BBMOD_WriteBuffer(_buffer, dq.m_real.getX());
	BBMOD_WriteBuffer(_buffer, dq.m_real.getY());
	BBMOD_WriteBuffer(_buffer, dq.m_real.getZ());
	BBMOD_WriteBuffer(_buffer, dq.m_real.getW());
	BBMOD_WriteBuffer(_buffer, dq.m_dual.getX());
	BBMOD_WriteBuffer(_buffer, dq.m_dual.getY());
	BBMOD_WriteBuffer(_buffer, dq.m_dual.getZ());
	BBMOD_WriteBuffer(_buffer, dq.m_dual.getW());

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// BBMOD_PhysicsVehicle
//

GM_EXPORT double BBMOD_PhysicsVehicle_AddWheel(double _id, char* _buffer)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id);

	btVector3 connectionPoint;
	connectionPoint.setX(BBMOD_ReadBuffer<double>(_buffer));
	connectionPoint.setY(BBMOD_ReadBuffer<double>(_buffer));
	connectionPoint.setZ(BBMOD_ReadBuffer<double>(_buffer));

	btVector3 direction;
	direction.setX(BBMOD_ReadBuffer<double>(_buffer));
	direction.setY(BBMOD_ReadBuffer<double>(_buffer));
	direction.setZ(BBMOD_ReadBuffer<double>(_buffer));

	btVector3 axle;
	axle.setX(BBMOD_ReadBuffer<double>(_buffer));
	axle.setY(BBMOD_ReadBuffer<double>(_buffer));
	axle.setZ(BBMOD_ReadBuffer<double>(_buffer));

	double suspensionRestLength = BBMOD_ReadBuffer<double>(_buffer);
	double radius = BBMOD_ReadBuffer<double>(_buffer);
	auto isFrontWheel = BBMOD_ReadBuffer<bool>(_buffer);

	auto& wheelInfo = vehicle->m_vehicle->addWheel(
		connectionPoint,
		direction,
		axle,
		suspensionRestLength,
		radius,
		vehicle->m_tuning,
		isFrontWheel);

	// wheelInfo.m_wheelsDampingCompression = 4.0f;
	// wheelInfo.m_wheelsDampingRelaxation = 6.0f;
	wheelInfo.m_frictionSlip = 5.0f;
	wheelInfo.m_maxSuspensionTravelCm = 10.0f;

	return static_cast<double>(vehicle->m_vehicle->getNumWheels() - 1);
}

GM_EXPORT double BBMOD_PhysicsVehicle_SetBrake(double _id, double _wheelIndex, double _brake)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	vehicle->setBrake(_brake, static_cast<int>(_wheelIndex));
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_SetSteering(double _id, double _wheelIndex, double _steering)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	vehicle->setSteeringValue(_steering, static_cast<int>(_wheelIndex));
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_ApplyEngineForce(double _id, double _wheelIndex, double _force)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	vehicle->applyEngineForce(_force, static_cast<int>(_wheelIndex));
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_UpdateWheelTransform(double _id, double _wheelIndex)
{
	Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle->updateWheelTransform(static_cast<int>(_wheelIndex), true);
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_GetWheelTransform(double _id, double _wheelIndex, char* _outBuffer)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	auto transform = vehicle->getWheelTransformWS(static_cast<int>(_wheelIndex));
	btScalar m[16];
	transform.getOpenGLMatrix(m);
	for (int i = 0; i < 16; ++i)
	{
		BBMOD_WriteBuffer(_outBuffer, (double)m[i]);
	}
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsVehicle_GetDeltaRotation(double _id, double _wheelIndex)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	return ToDegrees(vehicle->getWheelInfo(static_cast<int>(_wheelIndex)).m_deltaRotation);
}

GM_EXPORT double BBMOD_PhysicsVehicle_IsWheelInContact(double _id, double _wheelIndex)
{
	auto vehicle = Registry::Get<BBMOD_PhysicsVehicle>(_id)->m_vehicle;
	return vehicle->getWheelInfo(static_cast<int>(_wheelIndex)).m_raycastInfo.m_isInContact ? 1.0 : 0.0;
}
