#pragma once

#define BT_USE_DOUBLE_PRECISION
#include <btBulletDynamicsCommon.h>

struct DualQuat
{
	btQuaternion m_real;
	btQuaternion m_dual;

	// Default constructor - identity transform
	DualQuat()
		: m_real(0, 0, 0, 1)  // No rotation
		, m_dual(0, 0, 0, 0)  // No translation
	{
	}

	void FromTransform(const btTransform& t)
	{
		btQuaternion qr = t.getRotation();
		btVector3 tr = t.getOrigin();
		btQuaternion tq(tr.x(), tr.y(), tr.z(), 0.0);
		m_real = qr;
		m_dual = (tq * qr) * 0.5;
	}
};
