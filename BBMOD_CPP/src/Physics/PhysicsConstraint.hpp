#pragma once

#include "Registry.hpp"

#include <BBMOD/buffer.hpp>

#define BT_USE_DOUBLE_PRECISION
#include <btBulletDynamicsCommon.h>

#include <cassert>

enum class BBMOD_EPhysicsConstraintType : int8_t
{
	Invalid = -1,
	ConeTwist,
	Hinge,
	Point,
	SixDOF,
	Slider,
};

enum class BBMOD_EAxis : uint8_t
{
	X,
	Y,
	Z,
};

struct BBMOD_PhysicsConstraintInfo
{
	BBMOD_PhysicsConstraintInfo() = default;

	BBMOD_PhysicsConstraintInfo(char*& buffer)
	{
		FromBuffer(buffer);
	}

	virtual BBMOD_EPhysicsConstraintType GetType() const
	{
		return BBMOD_EPhysicsConstraintType::Invalid;
	}

	virtual void FromBuffer(char*& buffer)
	{
		auto type = static_cast<BBMOD_EPhysicsConstraintType>(BBMOD_ReadBuffer<int8_t>(buffer));
		assert(type == GetType());
		m_rigidBody1 = Registry::Get<btRigidBody>(BBMOD_ReadBuffer<double>(buffer));
		m_rigidBody2 = Registry::Get<btRigidBody>(BBMOD_ReadBuffer<double>(buffer));
	}

	btRigidBody* m_rigidBody1 = nullptr;
	btRigidBody* m_rigidBody2 = nullptr;
};

struct BBMOD_ConeTwistPhysicsConstraintInfo : public BBMOD_PhysicsConstraintInfo
{
	BBMOD_ConeTwistPhysicsConstraintInfo() = default;

	BBMOD_ConeTwistPhysicsConstraintInfo(char*& buffer) : BBMOD_PhysicsConstraintInfo(buffer)
	{
	}

	BBMOD_EPhysicsConstraintType GetType() const override
	{
		return BBMOD_EPhysicsConstraintType::ConeTwist;
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsConstraintInfo::FromBuffer(buffer);

		btScalar m[16];
		for (int i = 0; i < 16; ++i) { m[i] = BBMOD_ReadBuffer<btScalar>(buffer); }
		m_frame1.setFromOpenGLMatrix(m);

		for (int i = 0; i < 16; ++i) { m[i] = BBMOD_ReadBuffer<btScalar>(buffer); }
		m_frame2.setFromOpenGLMatrix(m);
	}

	btTransform m_frame1 {};
	btTransform m_frame2 {};
};

struct BBMOD_HingePhysicsConstraintInfo : public BBMOD_PhysicsConstraintInfo
{
	BBMOD_HingePhysicsConstraintInfo() = default;

	BBMOD_HingePhysicsConstraintInfo(char*& buffer) : BBMOD_PhysicsConstraintInfo(buffer)
	{
	}

	BBMOD_EPhysicsConstraintType GetType() const override
	{
		return BBMOD_EPhysicsConstraintType::Hinge;
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsConstraintInfo::FromBuffer(buffer);

		btScalar tempX, tempY, tempZ;
		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_pivot1 = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_pivot2 = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_axis1 = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_axis2 = btVector3(tempX, tempY, tempZ);
	}

	btVector3 m_pivot1 {};
	btVector3 m_pivot2 {};
	btVector3 m_axis1 { 1.0, 0.0, 0.0 };
	btVector3 m_axis2 { 1.0, 0.0, 0.0 };
};

struct BBMOD_PointPhysicsConstraintInfo : public BBMOD_PhysicsConstraintInfo
{
	BBMOD_PointPhysicsConstraintInfo() = default;

	BBMOD_PointPhysicsConstraintInfo(char*& buffer) : BBMOD_PhysicsConstraintInfo(buffer)
	{
	}

	BBMOD_EPhysicsConstraintType GetType() const override
	{
		return BBMOD_EPhysicsConstraintType::Point;
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsConstraintInfo::FromBuffer(buffer);

		btScalar tempX, tempY, tempZ;
		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_pivot1 = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_pivot2 = btVector3(tempX, tempY, tempZ);
	}

	btVector3 m_pivot1 {};
	btVector3 m_pivot2 {};
};

struct BBMOD_SixDOFPhysicsConstraintInfo : public BBMOD_PhysicsConstraintInfo
{
	BBMOD_SixDOFPhysicsConstraintInfo() = default;

	BBMOD_SixDOFPhysicsConstraintInfo(char*& buffer) : BBMOD_PhysicsConstraintInfo(buffer)
	{
	}

	BBMOD_EPhysicsConstraintType GetType() const override
	{
		return BBMOD_EPhysicsConstraintType::SixDOF;
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsConstraintInfo::FromBuffer(buffer);

		btScalar m[16];
		for (int i = 0; i < 16; ++i) { m[i] = BBMOD_ReadBuffer<btScalar>(buffer); }
		m_frame1.setFromOpenGLMatrix(m);

		for (int i = 0; i < 16; ++i) { m[i] = BBMOD_ReadBuffer<btScalar>(buffer); }
		m_frame2.setFromOpenGLMatrix(m);

		btScalar tempX, tempY, tempZ;
		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_linearLowerLimit = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_linearUpperLimit = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_angularLowerLimit = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_angularUpperLimit = btVector3(tempX, tempY, tempZ);

		bool tempBool;
		tempBool = BBMOD_ReadBuffer<bool>(buffer);
		m_enableLinearSpring[0] = tempBool;

		tempBool = BBMOD_ReadBuffer<bool>(buffer);
		m_enableLinearSpring[1] = tempBool;

		tempBool = BBMOD_ReadBuffer<bool>(buffer);
		m_enableLinearSpring[2] = tempBool;

		tempBool = BBMOD_ReadBuffer<bool>(buffer);
		m_enableAngularSpring[0] = tempBool;

		tempBool = BBMOD_ReadBuffer<bool>(buffer);
		m_enableAngularSpring[1] = tempBool;

		tempBool = BBMOD_ReadBuffer<bool>(buffer);
		m_enableAngularSpring[2] = tempBool;

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_linearStiffness = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_angularStiffness = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_linearDamping = btVector3(tempX, tempY, tempZ);

		tempX = BBMOD_ReadBuffer<btScalar>(buffer);
		tempY = BBMOD_ReadBuffer<btScalar>(buffer);
		tempZ = BBMOD_ReadBuffer<btScalar>(buffer);
		m_angularDamping = btVector3(tempX, tempY, tempZ);
	}

	btTransform m_frame1 {};
	btTransform m_frame2 {};
	btVector3 m_linearLowerLimit {};
	btVector3 m_linearUpperLimit {};
	btVector3 m_angularLowerLimit {};
	btVector3 m_angularUpperLimit {};
	bool m_enableLinearSpring[3] { false, false, false };
	bool m_enableAngularSpring[3] { false, false, false };
	btVector3 m_linearStiffness {};
	btVector3 m_angularStiffness {};
	btVector3 m_linearDamping {};
	btVector3 m_angularDamping {};
};

struct BBMOD_SliderPhysicsConstraintInfo : public BBMOD_PhysicsConstraintInfo
{
	BBMOD_SliderPhysicsConstraintInfo() = default;

	BBMOD_SliderPhysicsConstraintInfo(char*& buffer) : BBMOD_PhysicsConstraintInfo(buffer)
	{
	}

	BBMOD_EPhysicsConstraintType GetType() const override
	{
		return BBMOD_EPhysicsConstraintType::Slider;
	}

	void FromBuffer(char*& buffer) override
	{
		BBMOD_PhysicsConstraintInfo::FromBuffer(buffer);

		btScalar m[16];
		for (int i = 0; i < 16; ++i) { m[i] = BBMOD_ReadBuffer<btScalar>(buffer); }
		m_frame1.setFromOpenGLMatrix(m);

		for (int i = 0; i < 16; ++i) { m[i] = BBMOD_ReadBuffer<btScalar>(buffer); }
		m_frame2.setFromOpenGLMatrix(m);
	}

	btTransform m_frame1 {};
	btTransform m_frame2 {};
};
