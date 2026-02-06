#include "DualQuat.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

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
