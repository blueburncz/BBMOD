#include "DualQuat.hpp"
#include "PhysicsConstraint.hpp"
#include "PhysicsVehicle.hpp"
#include "PhysicsWorld.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

#include <BulletCollision/CollisionShapes/btHeightfieldTerrainShape.h>

#include <cstdint>

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

GM_EXPORT double BBMOD_PhysicsWorld_GetGravity(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	btVector3 gravity = physicsWorld->m_dynamicsWorld->getGravity();
	*reinterpret_cast<btVector3*>(_buffer) = gravity;
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsWorld_SetGravity(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);
	btVector3 gravity = *reinterpret_cast<btVector3*>(_buffer);
	physicsWorld->m_dynamicsWorld->setGravity(gravity);
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

GM_EXPORT double BBMOD_PhysicsWorld_CreateConstraint(double _id, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_id);

	auto type = static_cast<BBMOD_EPhysicsConstraintType>(BBMOD_PeekBuffer<int8_t>(_buffer));

	btTypedConstraint* constraint = nullptr;
	switch (type)
	{
		case BBMOD_EPhysicsConstraintType::ConeTwist:
		{
			BBMOD_ConeTwistPhysicsConstraintInfo info(_buffer);
			if (info.m_rigidBody2)
			{
				constraint = new btConeTwistConstraint(
					*info.m_rigidBody1,
					*info.m_rigidBody2,
					info.m_frame1,
					info.m_frame2
				);
			}
			else
			{
				constraint = new btConeTwistConstraint(
					*info.m_rigidBody1,
					info.m_frame1
				);
			}
		}
		break;

		case BBMOD_EPhysicsConstraintType::Hinge:
		{
			BBMOD_HingePhysicsConstraintInfo info(_buffer);
			if (info.m_rigidBody2)
			{
				constraint = new btHingeConstraint(
					*info.m_rigidBody1,
					*info.m_rigidBody2,
					info.m_pivot1,
					info.m_pivot2,
					info.m_axis1,
					info.m_axis2,
					false
				);
			}
			else
			{
				constraint = new btHingeConstraint(
					*info.m_rigidBody1,
					info.m_pivot1,
					info.m_axis1,
					false
				);
			}
		}
		break;

		case BBMOD_EPhysicsConstraintType::Point:
		{
			BBMOD_PointPhysicsConstraintInfo info(_buffer);
			if (info.m_rigidBody2)
			{
				constraint = new btPoint2PointConstraint(
					*info.m_rigidBody1,
					*info.m_rigidBody2,
					info.m_pivot1,
					info.m_pivot2
				);
			}
			else
			{
				constraint = new btPoint2PointConstraint(
					*info.m_rigidBody1,
					info.m_pivot1
				);
			}
		}
		break;

		case BBMOD_EPhysicsConstraintType::SixDOF:
		{
			BBMOD_SixDOFPhysicsConstraintInfo info(_buffer);

			auto sixDof = new btGeneric6DofSpring2Constraint(
				*info.m_rigidBody1,
				*info.m_rigidBody2,
				info.m_frame1,
				info.m_frame2,
				RO_YXZ // Follow GM's matrix_build
			);

			sixDof->setLinearLowerLimit(info.m_linearLowerLimit);
			sixDof->setLinearUpperLimit(info.m_linearUpperLimit);

			sixDof->setAngularLowerLimit(info.m_angularLowerLimit);
			sixDof->setAngularUpperLimit(info.m_angularUpperLimit);

			sixDof->enableSpring(0, info.m_enableLinearSpring[0]);
			sixDof->enableSpring(1, info.m_enableLinearSpring[1]);
			sixDof->enableSpring(2, info.m_enableLinearSpring[2]);
			sixDof->enableSpring(3, info.m_enableAngularSpring[0]);
			sixDof->enableSpring(4, info.m_enableAngularSpring[1]);
			sixDof->enableSpring(5, info.m_enableAngularSpring[2]);

			sixDof->setStiffness(0, info.m_linearStiffness.getX());
			sixDof->setStiffness(1, info.m_linearStiffness.getY());
			sixDof->setStiffness(2, info.m_linearStiffness.getZ());
			sixDof->setStiffness(3, info.m_angularStiffness.getX());
			sixDof->setStiffness(4, info.m_angularStiffness.getY());
			sixDof->setStiffness(5, info.m_angularStiffness.getZ());

			sixDof->setDamping(0, info.m_linearDamping.getX());
			sixDof->setDamping(1, info.m_linearDamping.getY());
			sixDof->setDamping(2, info.m_linearDamping.getZ());
			sixDof->setDamping(3, info.m_angularDamping.getX());
			sixDof->setDamping(4, info.m_angularDamping.getY());
			sixDof->setDamping(5, info.m_angularDamping.getZ());

			constraint = sixDof;
		}
		break;

		case BBMOD_EPhysicsConstraintType::Slider:
		{
			BBMOD_SliderPhysicsConstraintInfo info(_buffer);
			if (info.m_rigidBody2)
			{
				constraint = new btSliderConstraint(
					*info.m_rigidBody1,
					*info.m_rigidBody2,
					info.m_frame1,
					info.m_frame2,
					false
				);
			}
			else
			{
				constraint = new btSliderConstraint(
					*info.m_rigidBody1,
					info.m_frame1,
					false
				);
			}
		}
		break;

		default:
			// Unsupported constraint type
			return -1.0;
	}

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
