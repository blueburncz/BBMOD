#include "DualQuat.hpp"
#include "Registry.hpp"

#include <BBMOD/buffer.hpp>
#include <BBMOD/exports.hpp>

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
