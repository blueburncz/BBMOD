#include "DualQuat.hpp"
#include "PhysicsWorld.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

#include <cstdint>

GM_EXPORT double BBMOD_RigidBody_GetMatrix(double _id, char* _buffer)
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

GM_EXPORT double BBMOD_RigidBody_SetMatrix(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar m[16];
	for (int i = 0; i < 16; ++i)
	{
		m[i] = BBMOD_ReadBuffer<double>(_buffer);
	}

	btTransform transform;
	transform.setFromOpenGLMatrix(m);

	rigidBody->getMotionState()->setWorldTransform(transform);

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetDualQuat(double _id, char* _buffer)
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

GM_EXPORT double BBMOD_RigidBody_SetDualQuat(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	DualQuat dq;
	dq.m_real.setX(BBMOD_ReadBuffer<double>(_buffer));
	dq.m_real.setY(BBMOD_ReadBuffer<double>(_buffer));
	dq.m_real.setZ(BBMOD_ReadBuffer<double>(_buffer));
	dq.m_real.setW(BBMOD_ReadBuffer<double>(_buffer));
	dq.m_dual.setX(BBMOD_ReadBuffer<double>(_buffer));
	dq.m_dual.setY(BBMOD_ReadBuffer<double>(_buffer));
	dq.m_dual.setZ(BBMOD_ReadBuffer<double>(_buffer));
	dq.m_dual.setW(BBMOD_ReadBuffer<double>(_buffer));

	// Convert DualQuat to btTransform
	btQuaternion real = dq.m_real;
	btQuaternion dual = dq.m_dual;

	btQuaternion transQuat = dual * real.inverse() * btScalar(2.0);
	btVector3 translation(transQuat.x(), transQuat.y(), transQuat.z());

	btTransform transform;
	transform.setRotation(real);
	transform.setOrigin(translation);

	rigidBody->getMotionState()->setWorldTransform(transform);

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Forces and Impulses
//

GM_EXPORT double BBMOD_RigidBody_ApplyForce(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar forceX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar forceY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar forceZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 force(forceX, forceY, forceZ);

	btScalar relPosX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar relPosY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar relPosZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 relativePosition(relPosX, relPosY, relPosZ);

	rigidBody->applyForce(force, relativePosition);

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_ApplyCentralForce(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar forceX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar forceY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar forceZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 force(forceX, forceY, forceZ);

	rigidBody->applyCentralForce(force);

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_ApplyTorque(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar torqueX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar torqueY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar torqueZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 torque(torqueX, torqueY, torqueZ);

	rigidBody->applyTorque(torque);

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_ApplyImpulse(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar impulseX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar impulseY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar impulseZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 impulse(impulseX, impulseY, impulseZ);

	btScalar relPosX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar relPosY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar relPosZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 relativePosition(relPosX, relPosY, relPosZ);

	rigidBody->applyImpulse(impulse, relativePosition);

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_ApplyCentralImpulse(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar impulseX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar impulseY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar impulseZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 impulse(impulseX, impulseY, impulseZ);

	rigidBody->applyCentralImpulse(impulse);

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_ApplyTorqueImpulse(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar torqueX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar torqueY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar torqueZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 torque(torqueX, torqueY, torqueZ);

	rigidBody->applyTorqueImpulse(torque);

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_ClearForces(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	rigidBody->clearForces();
	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Velocity Control
//

GM_EXPORT double BBMOD_RigidBody_GetLinearVelocity(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	btVector3 velocity = rigidBody->getLinearVelocity();

	BBMOD_WriteBuffer(_buffer, static_cast<double>(velocity.getX()));
	BBMOD_WriteBuffer(_buffer, static_cast<double>(velocity.getY()));
	BBMOD_WriteBuffer(_buffer, static_cast<double>(velocity.getZ()));

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_SetLinearVelocity(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar velX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar velY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar velZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 velocity(velX, velY, velZ);

	rigidBody->setLinearVelocity(velocity);
	rigidBody->activate();

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetAngularVelocity(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	btVector3 velocity = rigidBody->getAngularVelocity();

	BBMOD_WriteBuffer(_buffer, static_cast<double>(velocity.getX()));
	BBMOD_WriteBuffer(_buffer, static_cast<double>(velocity.getY()));
	BBMOD_WriteBuffer(_buffer, static_cast<double>(velocity.getZ()));

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_SetAngularVelocity(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar velX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar velY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar velZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 velocity(velX, velY, velZ);

	rigidBody->setAngularVelocity(velocity);
	rigidBody->activate();

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Body State Control
//

GM_EXPORT double BBMOD_RigidBody_SetActive(double _id, double _active)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	if (_active > 0.5)
	{
		rigidBody->activate(true);
	}
	else
	{
		rigidBody->setActivationState(WANTS_DEACTIVATION);
	}

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_IsActive(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return rigidBody->isActive() ? 1.0 : 0.0;
}

GM_EXPORT double BBMOD_RigidBody_SetKinematic(double _id, double _kinematic)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	if (_kinematic > 0.5)
	{
		rigidBody->setCollisionFlags(
			rigidBody->getCollisionFlags() | btCollisionObject::CF_KINEMATIC_OBJECT);
		rigidBody->setActivationState(DISABLE_DEACTIVATION);
	}
	else
	{
		rigidBody->setCollisionFlags(
			rigidBody->getCollisionFlags() & ~btCollisionObject::CF_KINEMATIC_OBJECT);
		rigidBody->setActivationState(ACTIVE_TAG);
	}

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_IsKinematic(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return (rigidBody->getCollisionFlags() & btCollisionObject::CF_KINEMATIC_OBJECT) ? 1.0 : 0.0;
}

GM_EXPORT double BBMOD_RigidBody_SetGravity(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar gravX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar gravY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar gravZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 gravity(gravX, gravY, gravZ);

	rigidBody->setGravity(gravity);

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetGravity(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	btVector3 gravity = rigidBody->getGravity();

	BBMOD_WriteBuffer(_buffer, static_cast<double>(gravity.getX()));
	BBMOD_WriteBuffer(_buffer, static_cast<double>(gravity.getY()));
	BBMOD_WriteBuffer(_buffer, static_cast<double>(gravity.getZ()));

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetMass(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	btScalar invMass = rigidBody->getInvMass();

	if (invMass == 0.0)
	{
		return 0.0; // Static body
	}

	return static_cast<double>(1.0 / invMass);
}

GM_EXPORT double BBMOD_RigidBody_SetMassProps(double _id, double _mass, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar inertiaX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar inertiaY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar inertiaZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 inertia(inertiaX, inertiaY, inertiaZ);

	rigidBody->setMassProps(static_cast<btScalar>(_mass), inertia);

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Damping Control
//

GM_EXPORT double BBMOD_RigidBody_SetDamping(double _id, double _linear, double _angular)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	rigidBody->setDamping(static_cast<btScalar>(_linear), static_cast<btScalar>(_angular));
	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetLinearDamping(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return static_cast<double>(rigidBody->getLinearDamping());
}

GM_EXPORT double BBMOD_RigidBody_GetAngularDamping(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return static_cast<double>(rigidBody->getAngularDamping());
}

////////////////////////////////////////////////////////////////////////////////
//
// Axis Locking
//

GM_EXPORT double BBMOD_RigidBody_SetLinearFactor(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar factorX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar factorY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar factorZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 factor(factorX, factorY, factorZ);

	rigidBody->setLinearFactor(factor);

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_SetAngularFactor(double _id, char* _buffer)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	btScalar factorX = BBMOD_ReadBuffer<double>(_buffer);
	btScalar factorY = BBMOD_ReadBuffer<double>(_buffer);
	btScalar factorZ = BBMOD_ReadBuffer<double>(_buffer);
	btVector3 factor(factorX, factorY, factorZ);

	rigidBody->setAngularFactor(factor);

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Collision Filtering
//

GM_EXPORT double BBMOD_RigidBody_SetCollisionFilter(double _worldId, double _bodyId, char* _buffer)
{
	auto physicsWorld = Registry::Get<BBMOD_PhysicsWorld>(_worldId);
	auto rigidBody = Registry::Get<btRigidBody>(_bodyId);

	auto collisionGroup = BBMOD_ReadBuffer<int16_t>(_buffer);
	auto collisionMask = BBMOD_ReadBuffer<int16_t>(_buffer);

	// To change collision filtering, we must remove and re-add the body
	physicsWorld->m_dynamicsWorld->removeRigidBody(rigidBody);
	physicsWorld->m_dynamicsWorld->addRigidBody(rigidBody, collisionGroup, collisionMask);

	return 1.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// Trigger Volumes
//

GM_EXPORT double BBMOD_RigidBody_SetTrigger(double _id, double _isTrigger)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);

	if (_isTrigger > 0.5)
	{
		// Set as trigger - no physical response
		rigidBody->setCollisionFlags(
			rigidBody->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE
		);
	}
	else
	{
		// Remove trigger flag - restore physical response
		rigidBody->setCollisionFlags(
			rigidBody->getCollisionFlags() & ~btCollisionObject::CF_NO_CONTACT_RESPONSE
		);
	}

	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_IsTrigger(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return (rigidBody->getCollisionFlags() & btCollisionObject::CF_NO_CONTACT_RESPONSE) ? 1.0 : 0.0;
}

////////////////////////////////////////////////////////////////////////////////
//
// User Data / Tags
//

GM_EXPORT double BBMOD_RigidBody_SetUserIndex(double _id, double _index)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	rigidBody->setUserIndex(static_cast<int>(_index));
	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetUserIndex(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return static_cast<double>(rigidBody->getUserIndex());
}

////////////////////////////////////////////////////////////////////////////////
//
// Material Properties
//

GM_EXPORT double BBMOD_RigidBody_SetFriction(double _id, double _friction)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	rigidBody->setFriction(static_cast<btScalar>(_friction));
	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetFriction(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return static_cast<double>(rigidBody->getFriction());
}

GM_EXPORT double BBMOD_RigidBody_SetRestitution(double _id, double _restitution)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	rigidBody->setRestitution(static_cast<btScalar>(_restitution));
	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetRestitution(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return static_cast<double>(rigidBody->getRestitution());
}

GM_EXPORT double BBMOD_RigidBody_SetRollingFriction(double _id, double _friction)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	rigidBody->setRollingFriction(static_cast<btScalar>(_friction));
	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetRollingFriction(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return static_cast<double>(rigidBody->getRollingFriction());
}

GM_EXPORT double BBMOD_RigidBody_SetSpinningFriction(double _id, double _friction)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	rigidBody->setSpinningFriction(static_cast<btScalar>(_friction));
	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetSpinningFriction(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return static_cast<double>(rigidBody->getSpinningFriction());
}

////////////////////////////////////////////////////////////////////////////////
//
// Continuous Collision Detection (CCD)
//

GM_EXPORT double BBMOD_RigidBody_SetCcdMotionThreshold(double _id, double _threshold)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	rigidBody->setCcdMotionThreshold(static_cast<btScalar>(_threshold));
	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetCcdMotionThreshold(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return static_cast<double>(rigidBody->getCcdMotionThreshold());
}

GM_EXPORT double BBMOD_RigidBody_SetCcdSweptSphereRadius(double _id, double _radius)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	rigidBody->setCcdSweptSphereRadius(static_cast<btScalar>(_radius));
	return 1.0;
}

GM_EXPORT double BBMOD_RigidBody_GetCcdSweptSphereRadius(double _id)
{
	auto rigidBody = Registry::Get<btRigidBody>(_id);
	return static_cast<double>(rigidBody->getCcdSweptSphereRadius());
}
