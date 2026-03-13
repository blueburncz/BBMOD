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
	auto collisionGroup = BBMOD_ReadBuffer<int16_t>(_buffer);
	auto collisionMask = BBMOD_ReadBuffer<int16_t>(_buffer);
	auto isTrigger = BBMOD_ReadBuffer<bool>(_buffer);

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

	// Set as trigger (no physical response) if requested
	if (isTrigger)
	{
		body->setCollisionFlags(
			body->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE
		);
	}

	physicsWorld->m_dynamicsWorld->addRigidBody(body, collisionGroup, collisionMask);

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

////////////////////////////////////////////////////////////////////////////////
//
// Constraint Control
//

GM_EXPORT double BBMOD_PhysicsConstraint_SetBreakingThreshold(double _constraintId, double _threshold)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	constraint->setBreakingImpulseThreshold(static_cast<btScalar>(_threshold));
	return 1.0;
}

GM_EXPORT double BBMOD_PhysicsConstraint_GetBreakingThreshold(double _constraintId)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	return static_cast<double>(constraint->getBreakingImpulseThreshold());
}

GM_EXPORT double BBMOD_PhysicsConstraint_IsEnabled(double _constraintId)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	return constraint->isEnabled() ? 1.0 : 0.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Hinge Constraint Motors
//

GM_EXPORT double BBMOD_HingeConstraint_EnableMotor(double _constraintId, double _enable)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto hingeConstraint = dynamic_cast<btHingeConstraint*>(constraint);

	if (hingeConstraint)
	{
		hingeConstraint->enableMotor(_enable > 0.5);
		return 1.0;
	}

	return 0.0; // Not a hinge constraint
}

GM_EXPORT double BBMOD_HingeConstraint_SetMotorTarget(double _constraintId, double _targetAngle, double _dt)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto hingeConstraint = dynamic_cast<btHingeConstraint*>(constraint);

	if (hingeConstraint)
	{
		hingeConstraint->setMotorTarget(static_cast<btScalar>(_targetAngle), static_cast<btScalar>(_dt));
		return 1.0;
	}

	return 0.0;
}

GM_EXPORT double BBMOD_HingeConstraint_SetMaxMotorImpulse(double _constraintId, double _maxImpulse)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto hingeConstraint = dynamic_cast<btHingeConstraint*>(constraint);

	if (hingeConstraint)
	{
		hingeConstraint->setMaxMotorImpulse(static_cast<btScalar>(_maxImpulse));
		return 1.0;
	}

	return 0.0;
}

GM_EXPORT double BBMOD_HingeConstraint_GetHingeAngle(double _constraintId)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto hingeConstraint = dynamic_cast<btHingeConstraint*>(constraint);

	if (hingeConstraint)
	{
		return static_cast<double>(hingeConstraint->getHingeAngle());
	}

	return 0.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Slider Constraint Motors
//

GM_EXPORT double BBMOD_SliderConstraint_SetPoweredLinMotor(double _constraintId, double _enable)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto sliderConstraint = dynamic_cast<btSliderConstraint*>(constraint);

	if (sliderConstraint)
	{
		sliderConstraint->setPoweredLinMotor(_enable > 0.5);
		return 1.0;
	}

	return 0.0;
}

GM_EXPORT double BBMOD_SliderConstraint_SetTargetLinMotorVelocity(double _constraintId, double _velocity)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto sliderConstraint = dynamic_cast<btSliderConstraint*>(constraint);

	if (sliderConstraint)
	{
		sliderConstraint->setTargetLinMotorVelocity(static_cast<btScalar>(_velocity));
		return 1.0;
	}

	return 0.0;
}

GM_EXPORT double BBMOD_SliderConstraint_SetMaxLinMotorForce(double _constraintId, double _force)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto sliderConstraint = dynamic_cast<btSliderConstraint*>(constraint);

	if (sliderConstraint)
	{
		sliderConstraint->setMaxLinMotorForce(static_cast<btScalar>(_force));
		return 1.0;
	}

	return 0.0;
}

GM_EXPORT double BBMOD_SliderConstraint_SetPoweredAngMotor(double _constraintId, double _enable)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto sliderConstraint = dynamic_cast<btSliderConstraint*>(constraint);

	if (sliderConstraint)
	{
		sliderConstraint->setPoweredAngMotor(_enable > 0.5);
		return 1.0;
	}

	return 0.0;
}

GM_EXPORT double BBMOD_SliderConstraint_SetTargetAngMotorVelocity(double _constraintId, double _velocity)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto sliderConstraint = dynamic_cast<btSliderConstraint*>(constraint);

	if (sliderConstraint)
	{
		sliderConstraint->setTargetAngMotorVelocity(static_cast<btScalar>(_velocity));
		return 1.0;
	}

	return 0.0;
}

GM_EXPORT double BBMOD_SliderConstraint_SetMaxAngMotorForce(double _constraintId, double _force)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto sliderConstraint = dynamic_cast<btSliderConstraint*>(constraint);

	if (sliderConstraint)
	{
		sliderConstraint->setMaxAngMotorForce(static_cast<btScalar>(_force));
		return 1.0;
	}

	return 0.0;
}

GM_EXPORT double BBMOD_SliderConstraint_GetLinearPos(double _constraintId)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto sliderConstraint = dynamic_cast<btSliderConstraint*>(constraint);

	if (sliderConstraint)
	{
		return static_cast<double>(sliderConstraint->getLinearPos());
	}

	return 0.0;
}

GM_EXPORT double BBMOD_SliderConstraint_GetAngularPos(double _constraintId)
{
	auto constraint = Registry::Get<btTypedConstraint>(_constraintId);
	auto sliderConstraint = dynamic_cast<btSliderConstraint*>(constraint);

	if (sliderConstraint)
	{
		return static_cast<double>(sliderConstraint->getAngularPos());
	}

	return 0.0;
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
// Raycasting
//

GM_EXPORT double BBMOD_PhysicsWorld_Raycast(double _worldId, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);

	// Read ray start and end positions
	btScalar fromX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar fromY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar fromZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 rayFrom(fromX, fromY, fromZ);

	btScalar toX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar toY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar toZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 rayTo(toX, toY, toZ);

	// Perform raycast
	btCollisionWorld::ClosestRayResultCallback rayCallback(rayFrom, rayTo);
	physicsWorld->m_dynamicsWorld->rayTest(rayFrom, rayTo, rayCallback);

	// Write results back to buffer
	if (rayCallback.hasHit())
	{
		// Hit = true
		BBMOD_WriteBuffer(_buffer, 1.0);

		// Hit position
		BBMOD_WriteBuffer(_buffer, static_cast<double>(rayCallback.m_hitPointWorld.getX()));
		BBMOD_WriteBuffer(_buffer, static_cast<double>(rayCallback.m_hitPointWorld.getY()));
		BBMOD_WriteBuffer(_buffer, static_cast<double>(rayCallback.m_hitPointWorld.getZ()));

		// Hit normal
		BBMOD_WriteBuffer(_buffer, static_cast<double>(rayCallback.m_hitNormalWorld.getX()));
		BBMOD_WriteBuffer(_buffer, static_cast<double>(rayCallback.m_hitNormalWorld.getY()));
		BBMOD_WriteBuffer(_buffer, static_cast<double>(rayCallback.m_hitNormalWorld.getZ()));

		// Hit fraction (0-1 along ray)
		BBMOD_WriteBuffer(_buffer, static_cast<double>(rayCallback.m_closestHitFraction));

		// Hit body ID (find in registry)
		const btCollisionObject* hitObject = rayCallback.m_collisionObject;
		const btRigidBody* hitBody = btRigidBody::upcast(hitObject);
		if (hitBody)
		{
			double bodyId = Registry::GetId(const_cast<btRigidBody*>(hitBody));
			BBMOD_WriteBuffer(_buffer, bodyId);
		}
		else
		{
			BBMOD_WriteBuffer(_buffer, -1.0); // No rigid body
		}
	}
	else
	{
		// Hit = false
		BBMOD_WriteBuffer(_buffer, 0.0);

		// Write dummy data (7 more doubles to keep buffer size consistent)
		for (int i = 0; i < 7; ++i)
		{
			BBMOD_WriteBuffer(_buffer, 0.0);
		}
	}

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Shape Casting (Sweep Tests)
//

GM_EXPORT double BBMOD_PhysicsWorld_ShapeSweep(double _worldId, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);

	// Read shape ID
	auto shapeId = BBMOD_ReadBuffer<double>(_buffer);
	auto colShape = Registry::Get<btCollisionShape>(shapeId);

	// Shape must be convex for sweep tests
	btConvexShape* convexShape = dynamic_cast<btConvexShape*>(colShape);
	if (!convexShape)
	{
		// Not a convex shape - write no hit and return
		BBMOD_WriteBuffer(_buffer, 0.0);
		for (int i = 0; i < 7; ++i)
		{
			BBMOD_WriteBuffer(_buffer, 0.0);
		}
		return 0.0; // Error: shape is not convex
	}

	// Read from transform (16 doubles for 4x4 matrix)
	btScalar fromMatrix[16];
	for (int i = 0; i < 16; ++i)
	{
		fromMatrix[i] = BBMOD_ReadBuffer<double>(_buffer);
	}
	btTransform fromTransform;
	fromTransform.setFromOpenGLMatrix(fromMatrix);

	// Read to transform (16 doubles for 4x4 matrix)
	btScalar toMatrix[16];
	for (int i = 0; i < 16; ++i)
	{
		toMatrix[i] = BBMOD_ReadBuffer<double>(_buffer);
	}
	btTransform toTransform;
	toTransform.setFromOpenGLMatrix(toMatrix);

	// Perform convex sweep test
	btCollisionWorld::ClosestConvexResultCallback sweepCallback(
		fromTransform.getOrigin(),
		toTransform.getOrigin()
	);

	physicsWorld->m_dynamicsWorld->convexSweepTest(
		convexShape,
		fromTransform,
		toTransform,
		sweepCallback
	);

	// Write results back to buffer
	if (sweepCallback.hasHit())
	{
		// Hit = true
		BBMOD_WriteBuffer(_buffer, 1.0);

		// Hit position
		BBMOD_WriteBuffer(_buffer, static_cast<double>(sweepCallback.m_hitPointWorld.getX()));
		BBMOD_WriteBuffer(_buffer, static_cast<double>(sweepCallback.m_hitPointWorld.getY()));
		BBMOD_WriteBuffer(_buffer, static_cast<double>(sweepCallback.m_hitPointWorld.getZ()));

		// Hit normal
		BBMOD_WriteBuffer(_buffer, static_cast<double>(sweepCallback.m_hitNormalWorld.getX()));
		BBMOD_WriteBuffer(_buffer, static_cast<double>(sweepCallback.m_hitNormalWorld.getY()));
		BBMOD_WriteBuffer(_buffer, static_cast<double>(sweepCallback.m_hitNormalWorld.getZ()));

		// Hit fraction (0-1 along sweep)
		BBMOD_WriteBuffer(_buffer, static_cast<double>(sweepCallback.m_closestHitFraction));

		// Hit body ID (find in registry)
		const btCollisionObject* hitObject = sweepCallback.m_hitCollisionObject;
		const btRigidBody* hitBody = btRigidBody::upcast(hitObject);
		if (hitBody)
		{
			double bodyId = Registry::GetId(const_cast<btRigidBody*>(hitBody));
			BBMOD_WriteBuffer(_buffer, bodyId);
		}
		else
		{
			BBMOD_WriteBuffer(_buffer, -1.0); // No rigid body
		}
	}
	else
	{
		// Hit = false
		BBMOD_WriteBuffer(_buffer, 0.0);

		// Write dummy data (7 more doubles to keep buffer size consistent)
		for (int i = 0; i < 7; ++i)
		{
			BBMOD_WriteBuffer(_buffer, 0.0);
		}
	}

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Overlap Tests
//

GM_EXPORT double BBMOD_PhysicsWorld_TestBodyContact(double _worldId, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);

	// Read body IDs
	auto body1Id = BBMOD_ReadBuffer<double>(_buffer);
	auto body2Id = BBMOD_ReadBuffer<double>(_buffer);

	auto body1 = Registry::Get<btRigidBody>(body1Id);
	auto body2 = Registry::Get<btRigidBody>(body2Id);

	// Check if bodies are in contact by examining collision manifolds
	auto dispatcher = physicsWorld->m_dynamicsWorld->getDispatcher();
	int numManifolds = dispatcher->getNumManifolds();

	for (int i = 0; i < numManifolds; i++)
	{
		btPersistentManifold* contactManifold = dispatcher->getManifoldByIndexInternal(i);
		const btCollisionObject* objA = contactManifold->getBody0();
		const btCollisionObject* objB = contactManifold->getBody1();

		// Check if this manifold involves both our bodies
		bool involves1 = (objA == body1 || objB == body1);
		bool involves2 = (objA == body2 || objB == body2);

		if (involves1 && involves2)
		{
			// Check if there are actual contact points
			int numContacts = contactManifold->getNumContacts();
			for (int j = 0; j < numContacts; j++)
			{
				btManifoldPoint& pt = contactManifold->getContactPoint(j);
				if (pt.getDistance() < 0.0)
				{
					// Contact detected (negative distance means penetration)
					return 1.0;
				}
			}
		}
	}

	// No contact found
	return 0.0;
}

// Custom callback for collecting overlapping bodies
struct OverlapResultCallback : public btCollisionWorld::ContactResultCallback
{
	btAlignedObjectArray<const btRigidBody*> m_bodies;
	const btCollisionObject* m_testObject;
	int m_maxResults;

	OverlapResultCallback(const btCollisionObject* testObj, int maxResults)
		: m_testObject(testObj), m_maxResults(maxResults) {}

	virtual btScalar addSingleResult(
		btManifoldPoint& cp,
		const btCollisionObjectWrapper* colObj0Wrap,
		int partId0,
		int index0,
		const btCollisionObjectWrapper* colObj1Wrap,
		int partId1,
		int index1
	)
	{
		if (m_bodies.size() >= m_maxResults)
			return 0.0;

		// Determine which object is the "other" object (not our test object)
		const btCollisionObject* otherObj = nullptr;
		if (colObj0Wrap->getCollisionObject() == m_testObject)
		{
			otherObj = colObj1Wrap->getCollisionObject();
		}
		else
		{
			otherObj = colObj0Wrap->getCollisionObject();
		}

		const btRigidBody* body = btRigidBody::upcast(otherObj);

		if (body && m_bodies.findLinearSearch(body) == m_bodies.size())
		{
			// Not already in list - add it
			m_bodies.push_back(body);
		}

		return 0.0;
	}
};

GM_EXPORT double BBMOD_PhysicsWorld_OverlapShape(double _worldId, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);

	// Read shape ID
	auto shapeId = BBMOD_ReadBuffer<double>(_buffer);
	auto colShape = Registry::Get<btCollisionShape>(shapeId);

	// Read transform (16 doubles for 4x4 matrix)
	btScalar transformMatrix[16];
	for (int i = 0; i < 16; ++i)
	{
		transformMatrix[i] = BBMOD_ReadBuffer<double>(_buffer);
	}
	btTransform transform;
	transform.setFromOpenGLMatrix(transformMatrix);

	// Read max results
	auto maxResults = static_cast<int>(BBMOD_ReadBuffer<double>(_buffer));

	// Create temporary collision object for testing
	btCollisionObject testObject;
	testObject.setCollisionShape(colShape);
	testObject.setWorldTransform(transform);

	// Perform contact test
	OverlapResultCallback callback(&testObject, maxResults);
	physicsWorld->m_dynamicsWorld->contactTest(&testObject, callback);

	// Write results to buffer
	int numBodies = callback.m_bodies.size();
	BBMOD_WriteBuffer(_buffer, static_cast<double>(numBodies));

	for (int i = 0; i < numBodies; ++i)
	{
		double bodyId = Registry::GetId(const_cast<btRigidBody*>(callback.m_bodies[i]));
		BBMOD_WriteBuffer(_buffer, bodyId);
	}

	return static_cast<double>(numBodies);
}

////////////////////////////////////////////////////////////////////////////////
//
// Advanced Queries
//

// Callback for AABB overlap queries
struct AABBQueryCallback : public btBroadphaseAabbCallback
{
	btVector3 m_queryMin;
	btVector3 m_queryMax;
	std::vector<const btRigidBody*> m_bodies;
	int m_maxResults;

	AABBQueryCallback(const btVector3& min, const btVector3& max, int maxResults)
		: m_queryMin(min)
		, m_queryMax(max)
		, m_maxResults(maxResults)
	{
	}

	virtual bool process(const btBroadphaseProxy* proxy)
	{
		// Check if we've reached max results
		if (m_maxResults > 0 && static_cast<int>(m_bodies.size()) >= m_maxResults)
		{
			return false; // Stop searching
		}

		btCollisionObject* colObj = static_cast<btCollisionObject*>(proxy->m_clientObject);
		btRigidBody* rigidBody = btRigidBody::upcast(colObj);

		if (rigidBody)
		{
			// Get object's AABB
			btVector3 aabbMin, aabbMax;
			colObj->getCollisionShape()->getAabb(colObj->getWorldTransform(), aabbMin, aabbMax);

			// Check if AABBs overlap
			if (m_queryMin.x() <= aabbMax.x() && m_queryMax.x() >= aabbMin.x() &&
				m_queryMin.y() <= aabbMax.y() && m_queryMax.y() >= aabbMin.y() &&
				m_queryMin.z() <= aabbMax.z() && m_queryMax.z() >= aabbMin.z())
			{
				m_bodies.push_back(rigidBody);
			}
		}

		return true; // Continue searching
	}
};

GM_EXPORT double BBMOD_PhysicsWorld_QueryRadius(double _worldId, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);

	// Read center position (vec3)
	btVector3 center;
	center.setX(BBMOD_ReadBuffer<double>(_buffer));
	center.setY(BBMOD_ReadBuffer<double>(_buffer));
	center.setZ(BBMOD_ReadBuffer<double>(_buffer));

	// Read radius
	auto radius = static_cast<btScalar>(BBMOD_ReadBuffer<double>(_buffer));

	// Read max results
	auto maxResults = static_cast<int>(BBMOD_ReadBuffer<double>(_buffer));

	// Create AABB around the sphere
	btVector3 radiusVec(radius, radius, radius);
	btVector3 aabbMin = center - radiusVec;
	btVector3 aabbMax = center + radiusVec;

	// Query broadphase
	AABBQueryCallback callback(aabbMin, aabbMax, maxResults);
	physicsWorld->m_dynamicsWorld->getBroadphase()->aabbTest(aabbMin, aabbMax, callback);

	// Filter results by actual sphere distance
	std::vector<const btRigidBody*> sphereResults;
	btScalar radiusSquared = radius * radius;

	for (const auto* body : callback.m_bodies)
	{
		// Get body position
		btVector3 bodyPos = body->getWorldTransform().getOrigin();
		btVector3 diff = bodyPos - center;
		btScalar distSquared = diff.length2();

		if (distSquared <= radiusSquared)
		{
			sphereResults.push_back(body);
			if (maxResults > 0 && static_cast<int>(sphereResults.size()) >= maxResults)
			{
				break;
			}
		}
	}

	// Write results to buffer
	int numBodies = sphereResults.size();
	BBMOD_WriteBuffer(_buffer, static_cast<double>(numBodies));

	for (int i = 0; i < numBodies; ++i)
	{
		double bodyId = Registry::GetId(const_cast<btRigidBody*>(sphereResults[i]));
		BBMOD_WriteBuffer(_buffer, bodyId);
	}

	return static_cast<double>(numBodies);
}

GM_EXPORT double BBMOD_PhysicsWorld_QueryAABB(double _worldId, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);

	// Read min position (vec3)
	btVector3 aabbMin;
	aabbMin.setX(BBMOD_ReadBuffer<double>(_buffer));
	aabbMin.setY(BBMOD_ReadBuffer<double>(_buffer));
	aabbMin.setZ(BBMOD_ReadBuffer<double>(_buffer));

	// Read max position (vec3)
	btVector3 aabbMax;
	aabbMax.setX(BBMOD_ReadBuffer<double>(_buffer));
	aabbMax.setY(BBMOD_ReadBuffer<double>(_buffer));
	aabbMax.setZ(BBMOD_ReadBuffer<double>(_buffer));

	// Read max results
	auto maxResults = static_cast<int>(BBMOD_ReadBuffer<double>(_buffer));

	// Query broadphase
	AABBQueryCallback callback(aabbMin, aabbMax, maxResults);
	physicsWorld->m_dynamicsWorld->getBroadphase()->aabbTest(aabbMin, aabbMax, callback);

	// Write results to buffer
	int numBodies = callback.m_bodies.size();
	BBMOD_WriteBuffer(_buffer, static_cast<double>(numBodies));

	for (int i = 0; i < numBodies; ++i)
	{
		double bodyId = Registry::GetId(const_cast<btRigidBody*>(callback.m_bodies[i]));
		BBMOD_WriteBuffer(_buffer, bodyId);
	}

	return static_cast<double>(numBodies);
}

////////////////////////////////////////////////////////////////////////////////
//
// Collision Callbacks (Polling)
//

GM_EXPORT double BBMOD_PhysicsWorld_GetCollisionCount(double _worldId)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);
	auto dispatcher = physicsWorld->m_dynamicsWorld->getDispatcher();
	return static_cast<double>(dispatcher->getNumManifolds());
}

GM_EXPORT double BBMOD_PhysicsWorld_GetCollisionInfo(double _worldId, double _index, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);
	auto dispatcher = physicsWorld->m_dynamicsWorld->getDispatcher();
	int index = static_cast<int>(_index);

	if (index < 0 || index >= dispatcher->getNumManifolds())
	{
		// Invalid index - write default data
		BBMOD_WriteBuffer(_buffer, -1.0); // body1Id
		BBMOD_WriteBuffer(_buffer, -1.0); // body2Id
		BBMOD_WriteBuffer(_buffer, 0.0);  // contactCount
		BBMOD_WriteBuffer(_buffer, 0.0);  // totalImpulse
		return 0.0;
	}

	btPersistentManifold* manifold = dispatcher->getManifoldByIndexInternal(index);

	// Get the two bodies involved
	const btCollisionObject* objA = manifold->getBody0();
	const btCollisionObject* objB = manifold->getBody1();

	const btRigidBody* bodyA = btRigidBody::upcast(objA);
	const btRigidBody* bodyB = btRigidBody::upcast(objB);

	double body1Id = -1.0;
	double body2Id = -1.0;

	if (bodyA)
	{
		body1Id = Registry::GetId(const_cast<btRigidBody*>(bodyA));
	}

	if (bodyB)
	{
		body2Id = Registry::GetId(const_cast<btRigidBody*>(bodyB));
	}

	// Count contact points and accumulate impulse
	int numContacts = manifold->getNumContacts();
	btScalar totalImpulse = 0.0;

	for (int i = 0; i < numContacts; i++)
	{
		btManifoldPoint& pt = manifold->getContactPoint(i);
		totalImpulse += pt.getAppliedImpulse();
	}

	// Write to buffer
	BBMOD_WriteBuffer(_buffer, body1Id);
	BBMOD_WriteBuffer(_buffer, body2Id);
	BBMOD_WriteBuffer(_buffer, static_cast<double>(numContacts));
	BBMOD_WriteBuffer(_buffer, static_cast<double>(totalImpulse));

	return 1.0;
}
